import 'package:chat/components/new_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isNewPasswordVisible = false; // For new password visibility
  bool _isCurrentPasswordVisible = false; // For current password visibility

  void _toggleNewPasswordVisibility() {
    setState(() {
      _isNewPasswordVisible = !_isNewPasswordVisible;
    });
  }

  void _toggleCurrentPasswordVisibility() {
    setState(() {
      _isCurrentPasswordVisible = !_isCurrentPasswordVisible;
    });
  }

  Future<void> _changePassword() async {
    User? user = _auth.currentUser;

    if (user != null) {
      // Show dialog to get the current password for reauthentication
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Reauthenticate'),
            content: Column(
              mainAxisSize: MainAxisSize.min, // Adjust size to fit content
              children: [
                NewPass(
                    controller: _currentPasswordController,
                    thing: 'Current Password',
                    ontap: _toggleCurrentPasswordVisibility),
                const SizedBox(height: 20),
                NewPass(
                    controller: _newPasswordController,
                    thing: 'New Password',
                    ontap: _toggleNewPasswordVisibility)
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _currentPasswordController.clear();
                  _newPasswordController.clear();

                  Navigator.pop(context);
                }, // Close dialog
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    // Reauthenticate the user
                    AuthCredential credential = EmailAuthProvider.credential(
                      email: user.email!,
                      password: _currentPasswordController.text,
                    );
                    await user.reauthenticateWithCredential(credential);

                    // Update the password
                    await user.updatePassword(_newPasswordController.text);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Password updated successfully')),
                    );
                    _currentPasswordController.clear();
                    _newPasswordController.clear();

                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Go back to the previous page
                  } on FirebaseAuthException catch (e) {
                    if (e.code == 'wrong-password') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Wrong password provided')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${e.message}')),
                      );
                    }
                  }
                },
                child: const Text('Confirm'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _currentPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ElevatedButton(
          onPressed: _changePassword,
          child: const Text('Change Password'),
        ),
      ),
    );
  }
}
