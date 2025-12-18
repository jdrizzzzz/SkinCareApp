import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  final user = FirebaseAuth.instance.currentUser!;

  // sign user out
  Future<void> signUserOut() async {
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
    await currentUser.delete();
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
            const Text(
              'Please enter your password to delete your account.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await signUserOut();
              Navigator.pushReplacementNamed(context, '/loginpage');
            },
          ),
        ],
      ),

      // body
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Logged in as ${user.email}',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete account'),
              onPressed: () async {
                final email = user.email;
                if (email == null) {
                  _showMessage(context, "This account doesn't have an email.");
                  return;
                }

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
                        onPressed: () => Navigator.pop(context, false),
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

                // Ask for password
                final password = await _askForPassword(context);
                if (password == null || password.isEmpty) return;

                // Delete account
                try {
                  await deleteAccountWithPassword(email: email, password: password);

                  // Sign out locally after deletion
                  await FirebaseAuth.instance.signOut();

                  Navigator.pushReplacementNamed(context, '/loginpage');
                } on FirebaseAuthException catch (e) {
                  if (e.code == 'wrong-password') {
                    _showMessage(context, 'Wrong password.');
                  } else if (e.code == 'requires-recent-login') {
                    _showMessage(context, 'Please log in again, then try deleting.');
                  } else {
                    _showMessage(context, 'Delete failed: ${e.message}');
                  }
                } catch (e) {
                  _showMessage(context, 'Delete failed: $e');
                }
              },
            ),

            //------------------to change password-----------
            //Change password - need old password
            ElevatedButton(
              child: const Text('Change password'),
              onPressed: () async {
                final email = FirebaseAuth.instance.currentUser?.email;
                if (email == null) return;

                final result = await showDialog<Map<String, String>>(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    final oldPasswordController = TextEditingController();
                    final newPasswordController = TextEditingController();

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
                          onPressed: () => Navigator.pop(context, null),
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

          ],
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
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month), label: 'Routine'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_basket), label: 'Products'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'Profile'),
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
