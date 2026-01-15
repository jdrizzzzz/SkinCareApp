import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../services/notification_service.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  final user = FirebaseAuth.instance.currentUser!;
  final _db = FirebaseFirestore.instance;

  // sign user out
  Future<void> signUserOut() async {
    final providerIds =
        FirebaseAuth.instance.currentUser?.providerData
            .map((provider) => provider.providerId)
            .toList() ??
        [];

    //google sign out
    try {
      await GoogleSignIn.instance.signOut(); //soft sign out
      await GoogleSignIn.instance
          .disconnect(); //hard sign out (removes cached account)
    } catch (_) {}

    //apple sign out
    if (providerIds.contains('apple.com')) {
      await signOutApple();
      return;
    }

    //firebase sign out
    await FirebaseAuth.instance.signOut();
  }

  Future<void> signOutApple() async {
    await FirebaseAuth.instance.signOut();
  }

  //deleting account
  Future<void> deleteAccountWithPassword({
    required String email,
    required String password,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );

    await currentUser.reauthenticateWithCredential(credential);
    await deleteUserData(uid: currentUser.uid);
    await currentUser.delete();
  }

  Future<void> deleteAccountWithApple() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [AppleIDAuthorizationScopes.email],
    );

    final credential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

    await currentUser.reauthenticateWithCredential(credential);
    await deleteUserData(uid: currentUser.uid);
    await currentUser.delete();
  }

  Future<void> reauthenticateForSensitiveAction(BuildContext context) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final providerIds = currentUser.providerData
        .map((provider) => provider.providerId)
        .toList();

    if (providerIds.contains('password')) {
      final email = currentUser.email;
      if (email == null) {
        throw FirebaseAuthException(
          code: 'missing-email',
          message: "This account doesn't have an email.",
        );
      }

      final password = await _askForPassword(context);
      if (password == null || password.isEmpty) {
        throw FirebaseAuthException(
          code: 'missing-password',
          message: 'Password is required to continue.',
        );
      }

      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await currentUser.reauthenticateWithCredential(credential);
      return;
    }

    //google
    if (providerIds.contains('google.com')) {
      await GoogleSignIn.instance.initialize();
      final googleUser = await GoogleSignIn.instance.authenticate();
      if (googleUser == null) {
        throw FirebaseAuthException(
          code: 'cancelled',
          message: 'Google sign in canceled.',
        );
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      await currentUser.reauthenticateWithCredential(credential);
      return;
    }

    //apple
    if (providerIds.contains('apple.com')) {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email],
      );

      final credential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      await currentUser.reauthenticateWithCredential(credential);
      return;
    }

    throw FirebaseAuthException(
      code: 'unsupported-provider',
      message: 'Unsupported sign-in provider.',
    );
  }

  //Deletes the user info - quiz
  Future<void> deleteUserData({required String uid}) async {
    final batch = _db.batch();
    final userDoc = _db.collection('users').doc(uid);
    batch.delete(userDoc);

    await batch.commit();
  }

  Future<String?> _askForPassword(BuildContext context) async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Confirm account deletion'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please enter your password to delete your account.'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // updating/changing password - need old password
  Future<void> changePassword({
    required String email,
    required String oldPassword,
    required String newPassword,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final credential = EmailAuthProvider.credential(
      email: email,
      password: oldPassword,
    );

    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  void _showMessage(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _showBlockingLoader(BuildContext context, String message) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false, // removes the arrow to navigate back
        backgroundColor: Colors.grey[100],
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await signUserOut();

              //clear navigation stack so user cant go back into logged-in screens
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/loginpage',
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),

      // body
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.amber[200],
                      child: const Icon(
                        Icons.person,
                        size: 32,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back',
                            style: textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            user.email ?? 'Signed in',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              //routine reminder
              Text(
                'Routine reminder',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () async {
                      await NotificationService.instance.showNotification(
                        title: "This is a routine reminder! ",
                      );
                    },
                    child: const Text("Send Notification"),
                  ),
                ),
              ),

              //account actions
              Text(
                'Account actions',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.delete_forever),
                        label: const Text('Delete account'),
                        onPressed: () async {
                          // ---------------- to delete account----------------
                          // Verify current user first
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete account?'),
                              content: const Text(
                                'This action is permanent. Are you sure you want to delete your account?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Continue'),
                                ),
                              ],
                            ),
                          );

                          if (confirm != true) return;

                          // Delete account
                          try {
                            _showBlockingLoader(
                              context,
                              'Deleting your account...',
                            );

                            final providerIds = user.providerData
                                .map((provider) => provider.providerId)
                                .toList();

                            if (providerIds.contains('apple.com')) {
                              await deleteAccountWithApple();
                            } else if (providerIds.contains('password')) {
                              final email = user.email;
                              if (email == null) {
                                throw FirebaseAuthException(
                                  code: 'missing-email',
                                  message:
                                      "This account doesn't have an email.",
                                );
                              }

                              final password = await _askForPassword(context);
                              if (password == null || password.isEmpty) {
                                throw FirebaseAuthException(
                                  code: 'missing-password',
                                  message: 'Password is required to continue.',
                                );
                              }

                              await deleteAccountWithPassword(
                                email: email,
                                password: password,
                              );
                            } else {
                              await reauthenticateForSensitiveAction(context);
                              await deleteUserData(uid: user.uid);
                              await user.delete();
                            }

                            // Sign out locally after deletion (sign out everything)
                            await signUserOut();

                            if (context.mounted) {
                              Navigator.pop(context);
                              _showMessage(context, 'Account deleted.');

                              //clear navigation stack so user cant go back into logged-in screens
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/loginpage',
                                (route) => false,
                              );
                            }
                          } on FirebaseAuthException catch (e) {
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                            if (e.code == 'wrong-password') {
                              _showMessage(context, 'Wrong password.');
                            } else if (e.code == 'requires-recent-login') {
                              _showMessage(
                                context,
                                'Please log in again, then try deleting.',
                              );
                            } else {
                              _showMessage(
                                context,
                                'Delete failed: ${e.message}',
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                            _showMessage(context, 'Delete failed: $e');
                          }
                        },
                      ),
                    ),

                    //------------------to change password-----------
                    //Change password - need old password
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey[900],
                          side: BorderSide(color: Colors.grey[300]!),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.lock_reset),
                        label: const Text('Change password'),
                        onPressed: () async {
                          final email =
                              FirebaseAuth.instance.currentUser?.email;
                          if (email == null) return;

                          final result = await showDialog<Map<String, String>>(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) {
                              final oldPasswordController =
                                  TextEditingController();
                              final newPasswordController =
                                  TextEditingController();

                              return AlertDialog(
                                title: const Text('Change password'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(
                                      controller: oldPasswordController,
                                      obscureText: true,
                                      decoration: const InputDecoration(
                                        labelText: 'Current password',
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: newPasswordController,
                                      obscureText: true,
                                      decoration: const InputDecoration(
                                        labelText: 'New password',
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, null),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, {
                                      'old': oldPasswordController.text.trim(),
                                      'new': newPasswordController.text.trim(),
                                    }),
                                    child: const Text('Update'),
                                  ),
                                ],
                              );
                            },
                          );

                          if (result == null) return;

                          try {
                            await changePassword(
                              email: email,
                              oldPassword: result['old']!,
                              newPassword: result['new']!,
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Password updated')),
                            );
                          } on FirebaseAuthException catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.message ?? 'Error')),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // bottom navigation bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedItemColor: Colors.amber[500],
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Routine',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_basket),
            label: 'Products',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: 3,
        onTap: (index) {
          final routes = ['/weatherpage', '/routine', '/products', '/profile'];
          Navigator.pushNamed(context, routes[index]);
        },
      ),
    );
  }
}
