import 'dart:io';

import 'package:chat/pages/change_pass.dart';
import 'package:chat/providers/theme_provider.dart';
import 'package:chat/services/auth/authservice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final Authservice _authService = Authservice();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _aboutController =
      TextEditingController(); // New about controller
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
        _aboutController.text =
            data['about'] ?? ''; // Load about data if available
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
          const SnackBar(
            content: Text('Username is already taken'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      await FirebaseFirestore.instance.collection('Users').doc(userId).update({
        'username': _usernameController.text,
        'about': _aboutController.text, // Save about data
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showDeleteAccountDialog() {
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
              'Are you sure you want to delete your account? This action cannot be undone.'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context), // Close dialog
              child: const Text('No'),
            ),
            CupertinoDialogAction(
              onPressed: () async {
                try {
                  User? user = _authService.currentUser();
                  if (user != null) {
                    // Delete associated chat rooms and user data, then delete account
                    await _deleteUserAccount(user.uid);

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
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('An unexpected error occurred.')),
                  );
                }
              },
              child: const Text('Yes'),
            ),
          ],
        ),
      );
    } else {
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
                      // Delete associated chat rooms and user data, then delete account
                      await _deleteUserAccount(user.uid);

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
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('An unexpected error occurred.')),
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
  }

  Future<void> _deleteUserAccount(String userId) async {
    // Delete all associated chat rooms
    QuerySnapshot chatRooms = await FirebaseFirestore.instance
        .collection('ChatRooms')
        .where('participants', arrayContains: userId)
        .get();

    for (var doc in chatRooms.docs) {
      await doc.reference.delete();
    }

    // Delete user data
    await FirebaseFirestore.instance.collection('Users').doc(userId).delete();

    // Delete the user's account
    User? user = _authService.currentUser();
    await user?.delete();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: isLoading
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 100,
                  child: Center(
                    child: Lottie.asset(
                      'assets/Animation - 1730069741511.json',
                      animate: true,
                      frameRate: const FrameRate(60),
                    ),
                  ),
                ),
              ],
            )
          : Padding(
              padding: const EdgeInsets.all(25.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                    TextField(
                      controller: _aboutController,
                      decoration: InputDecoration(
                        fillColor: Theme.of(context).colorScheme.secondary,
                        filled: true,
                        labelText: 'About',
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
                    Column(
                      children: [
                        const Divider(),
                        ListTile(
                          title: const Text('Change Password'),
                          leading: const Icon(Icons.lock),
                          onTap: () {
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
                          onTap: _showDeleteAccountDialog,
                        ),
                        const Divider()
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _updateProfile,
                      child: Text(
                        'Save Changes',
                        style: TextStyle(
                            color:
                                isDarkMode ? Colors.white : Colors.grey[900]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
