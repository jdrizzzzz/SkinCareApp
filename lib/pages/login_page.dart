import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:skincare_project/utils/validation.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscurePassword = true;

  //Must initialize async + listen to auth events
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  //used to let "signInWithGoogle()" wait until the auth stream fires
  Completer<void>? _googleAuthCompleter;
  Object? _googleAuthLastError;

  //form key - used to run built in validators
  final _formKey = GlobalKey<FormState>();

  //text controllers - storing what the user types
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    unawaited(
      _googleSignIn.initialize().then((_) {
        //listen to sign in/sign out events (stream-based approach)
        _googleSignIn.authenticationEvents
            .listen(_handleGoogleAuthenticationEvent)
            .onError(_handleGoogleAuthenticationError);

      }),
    );
  }

  @override
  void dispose() {
    //clean up controllers when leaving this page
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  //sign in with firebase
  Future<void> signIn() async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
  }

  //google sign in
  Future<void> signInWithGoogle() async {
    //safety: android/ios should support authenticate(), but keep the official check
    if (!_googleSignIn.supportsAuthenticate()) {
      throw StateError(
        'This platform does not support GoogleSignIn.authenticate().',
      );
    }

    //if there’s already an in-flight sign in, don’t start another one
    if (_googleAuthCompleter != null && !_googleAuthCompleter!.isCompleted) {
      await _googleAuthCompleter!.future;
      return;
    }

    _googleAuthLastError = null;
    _googleAuthCompleter = Completer<void>();

    try {
      await _googleSignIn.authenticate();

      //wait until _handleGoogleAuthenticationEvent completes firebase sign-in
      await _googleAuthCompleter!.future;
    } catch (e) {
      _googleAuthCompleter?.completeError(e);
      rethrow;
    } finally {
      _googleAuthCompleter = null;
    }
  }

  //called automatically when google_sign_in emits sign in/sign out
  Future<void> _handleGoogleAuthenticationEvent(
      GoogleSignInAuthenticationEvent event,
      ) async {
    final GoogleSignInAccount? user = switch (event) {
      GoogleSignInAuthenticationEventSignIn() => event.user,
      GoogleSignInAuthenticationEventSignOut() => null,
    };

    if (user == null) {
      await FirebaseAuth.instance.signOut();
      _googleAuthCompleter?.complete();
      return;
    }

    try {
      //convert google user -> firebase credential (then sign in)
      await _signInGoogleUserToFirebase(user);

      //tell signInWithGoogle() we're done
      _googleAuthCompleter?.complete();
    } catch (e) {
      _googleAuthLastError = e;
      _googleAuthCompleter?.completeError(e);
    }
  }

  Future<void> _handleGoogleAuthenticationError(Object e) async {
    _googleAuthLastError = e;
    if (_googleAuthCompleter != null && !_googleAuthCompleter!.isCompleted) {
      _googleAuthCompleter!.completeError(e);
    }
  }

  //google -> firebase auth bridge
  Future<void> _signInGoogleUserToFirebase(GoogleSignInAccount user) async {
    //get the authentication tokens from the signed-in account
    final GoogleSignInAuthentication googleAuth = await user.authentication;

    //build a firebase credential
    final OAuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);
  }


  Future<void> signInWithApple() async {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

    await FirebaseAuth.instance.signInWithCredential(oauthCredential);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
            child: Form(

              //wrap inputs in a form so validators work
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 20.0,
                        backgroundColor: Colors.transparent,
                        child: ClipOval(
                          child: Image.asset(
                            'images/SERUM_icon.png',
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "SERUM",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Center(
                    child: Text(
                      "Welcome Back",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Center(
                    child: Text(
                      "Sign in to your account to continue",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Email text and textbox
                  const Text(
                    "Email",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white),
                    validator: Validator.validateEmail, //built in email validation
                    decoration: InputDecoration(
                      hintText: "Enter your email",
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: const Color(0xFF1A1A1A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password text and textbox
                  const Text(
                    "Password",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(color: Colors.white),
                    validator:
                    Validator.validatePassword, //built in password validation
                    decoration: InputDecoration(
                      hintText: "Enter your password",
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: const Color(0xFF1A1A1A),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.white54,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Forgot password text/button
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        "Forgot password?",
                        style: TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Sign in button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        //run validators first (shows messages under fields)
                        final isValid =
                            _formKey.currentState?.validate() ?? false;
                        if (!isValid) return;
                        try {
                          await signIn(); //firebase sign in
                          Navigator.pushReplacementNamed(
                            context,
                            '/weatherpage',
                          ); //replace login page (user cant go back)
                        } on FirebaseAuthException catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.message ?? "Sign in failed"),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC933),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        "Sign in",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),

                  // The --or-- row
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.grey[600],
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(
                          "or",
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.grey[600],
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),

                  // Google and Apple icons row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          try {
                            await signInWithGoogle(); //google
                            if (context.mounted) {
                              Navigator.pushReplacementNamed(
                                context,
                                '/weatherpage',
                              );
                            }
                          } on FirebaseAuthException catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                Text(e.message ?? "Google sign in failed"),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  _googleAuthLastError?.toString() ??
                                      e.toString(),
                                ),
                              ),
                            );
                          }
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF1A1A1A),
                            border: Border.all(
                              color: Colors.white24,
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Image.asset(
                              'images/google_icon.png',
                              width: 26,
                              height: 26,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 30),
                      GestureDetector(
                        onTap: () async {
                          try {
                            await signInWithApple();
                            if (context.mounted) {
                              Navigator.pushReplacementNamed(
                                context,
                                '/weatherpage',
                              );
                            }
                          } on FirebaseAuthException catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                Text(e.message ?? "Apple sign in failed"),
                              ),
                            );
                          }
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF1A1A1A),
                            border: Border.all(
                              color: Colors.white24,
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Image.asset(
                              'images/apple_icon.png',
                              width: 26,
                              height: 26,
                              fit: BoxFit.contain,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          color: Colors.grey[400],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/createaccountpage',
                          ); //go to create account page
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          "Create one",
                          style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
