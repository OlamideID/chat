import 'package:chat/pages/change_pass.dart';
import 'package:chat/services/auth/authservice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final Authservice _authService = Authservice();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String? userId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    userId = _authService.currentUser()?.uid;
    if (userId != null) {
      var userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        var data = userDoc.data()!;
        _usernameController.text = data['username'];
        _emailController.text = data['email'];
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _updateProfile() async {
    if (userId != null) {
      var existingUserDoc = await FirebaseFirestore.instance
          .collection('Users')
          .where('username', isEqualTo: _usernameController.text)
          .get();

      if (existingUserDoc.docs.isNotEmpty &&
          existingUserDoc.docs.first.id != userId) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username is already taken')),
        );
        return;
      }

      await FirebaseFirestore.instance.collection('Users').doc(userId).update({
        'username': _usernameController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    }
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
              'Are you sure you want to delete your account? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Close dialog
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  User? user = _authService.currentUser();
                  if (user != null) {
                    await FirebaseFirestore.instance
                        .collection('Users')
                        .doc(userId)
                        .delete(); // Delete user data
                    await user.delete(); // Delete the user's account
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Account deleted successfully.')),
                    );
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Go back to the previous page
                  }
                } on FirebaseAuthException catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.message}')),
                  );
                }
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        fillColor: Theme.of(context).colorScheme.secondary,
                        filled: true,
                        labelText: 'Username',
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        filled: true,
                        labelText: 'Email',
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 20),
                    Column(
                      children: [
                        const Divider(),
                        ListTile(
                          title: const Text('Change Password'),
                          leading: const Icon(Icons.lock),
                          onTap: () {
                            // Navigate to the change password page
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ChangePasswordPage()),
                            );
                          },
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Divider(),
                        ListTile(
                          title: const Text('Delete Account'),
                          leading: const Icon(Icons.delete_forever),
                          onTap: _showDeleteAccountDialog, // Show delete dialog
                        ),
                        const Divider()
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _updateProfile,
                      child: const Text('Save Changes'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
