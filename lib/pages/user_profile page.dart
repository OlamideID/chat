// ignore_for_file: file_names

import 'package:flutter/material.dart';

class UserProfilePage extends StatelessWidget {
  final String username;
  final String about;

  const UserProfilePage(
      {super.key, required this.username, required this.about});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
          // mainAxisAlignment: MainAxisAlignment.m,
          children: [
            Text(
              'Username: $username',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                  // backgroundBlendMode: BlendMode.color,
                  // color: const Color.fromARGB(255, 213, 211, 211),
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text('About: '),
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      about,
                      style: const TextStyle(
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ),
            )
            // You can add more profile details here if needed
          ],
        ),
      ),
    );
  }
}
