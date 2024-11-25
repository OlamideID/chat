import 'package:chat/components/new_textfield.dart';
import 'package:chat/providers/theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isNewPasswordVisible = false;
  bool _isCurrentPasswordVisible = false;
  String? _errorMessage; // To display error messages

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
            title: const Text(
              'Reauthenticate',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  NewPass(
                    controller: _currentPasswordController,
                    thing: 'Current Password',
                    ontap: _toggleCurrentPasswordVisibility,
                  ),
                  const SizedBox(height: 20),
                  NewPass(
                    controller: _newPasswordController,
                    thing: 'New Password',
                    ontap: _toggleNewPasswordVisibility,
                  ),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red[600]),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _clearControllers();
                  Navigator.pop(context);
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  await _confirmPasswordChange(context, user);
                },
                child: const Text('Confirm'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _confirmPasswordChange(BuildContext context, User user) async {
    try {
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPasswordController.text,
      );

      await user.reauthenticateWithCredential(credential);

      await user.updatePassword(_newPasswordController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Password updated successfully',
            style: TextStyle(color: Colors.green[700]),
          ),
          backgroundColor: Colors.green[100],
        ),
      );

      _clearControllers();
      Navigator.pop(context); // Close dialog
      Navigator.pop(context); // Go back to the previous page
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'wrong-password') {
          _errorMessage = 'Wrong password provided. Try again.';
        } else {
          _errorMessage = 'Error: ${e.message}';
        }
      });
    }
  }

  void _clearControllers() {
    _currentPasswordController.clear();
    _newPasswordController.clear();
    setState(() {
      _errorMessage = null;
    });
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _currentPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0.5,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Update Your Password',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Secure your account by updating your password. Enter your current password and new password.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _changePassword,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Change Password',
                  style: TextStyle(
                      fontSize: 18,
                      color: isDarkMode ? Colors.white : Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
