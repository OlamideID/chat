import 'dart:io';

import 'package:chat/pages/change_pass.dart';
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
  final TextEditingController _aboutController = TextEditingController();
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
        _aboutController.text = data['about'] ?? '';
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
                await _deleteAccount();
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
                  await _deleteAccount();
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
        .collection('chat_rooms')
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

  Future<void> _deleteAccount() async {
    try {
      User? user = _authService.currentUser();
      if (user != null) {
        // Delete associated chat rooms and user data, then delete account
        await _deleteUserAccount(user.uid);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account deleted successfully.')),
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
        const SnackBar(content: Text('An unexpected error occurred.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Profile'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: isLoading
          ? Center(
              child: Lottie.asset(
                'assets/Animation - 1730069741511.json',
                height: 150,
                frameRate: const FrameRate(60),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Hero Header
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor:
                              Theme.of(context).colorScheme.tertiary,
                          child: const Icon(Icons.person, size: 60),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _usernameController.text,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // User Information Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Account Information",
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          controller: _usernameController,
                          labelText: "Username",
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          controller: _emailController,
                          labelText: "Email",
                          readOnly: true,
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          controller: _aboutController,
                          labelText: "About",
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Action Buttons Section
                  Container(
                    color: Theme.of(context).colorScheme.surface,
                    child: Column(
                      children: [
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 2, horizontal: 10),
                          child: ListTile(
                            leading: Icon(Icons.lock,
                                color: Theme.of(context).colorScheme.primary),
                            title: const Text("Change Password"),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ChangePasswordPage()),
                              );
                            },
                          ),
                        ),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: ListTile(
                            leading: Icon(Icons.delete_forever,
                                color: Theme.of(context).colorScheme.error),
                            title: const Text("Delete Account"),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: _showDeleteAccountDialog,
                          ),
                        ),
                        const Divider(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Save Changes Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _updateProfile,
                      child: Text(
                        "Save Changes",
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        filled: true,
        fillColor: Theme.of(context).colorScheme.secondaryContainer,
        labelText: labelText,
        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.primary,
        ),
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
    );
  }
}
