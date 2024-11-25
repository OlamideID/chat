import 'package:chat/pages/blocked.dart';
import 'package:chat/pages/profile_page.dart';
import 'package:chat/pages/reviews.dart';
import 'package:chat/providers/theme_provider.dart';
import 'package:chat/services/auth/authservice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark;
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Dark Mode Toggle with Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile(
                contentPadding: const EdgeInsets.all(16.0),
                title: const Text('Dark Mode'),
                value: themeMode == ThemeMode.dark,
                onChanged: (bool value) {
                  ref
                      .read(themeProvider.notifier)
                      .toggleTheme(); // Toggle theme
                },
                activeColor: Theme.of(context).colorScheme.secondary,
                inactiveThumbColor: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 20),

            // Blocked Users with Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.block, color: Colors.red),
                title: const Text('Blocked Users'),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlockedPage(TextStyle(
                        color: isDarkMode ? Colors.white : Colors.grey[700],
                      )),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 15),

            // Profile with Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.account_circle, color: Colors.blue),
                title: const Text('Profile'),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfilePage(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 15),

            // Reviews with Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.rate_review, color: Colors.green),
                title: const Text('Reviews'),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReviewPage(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 15),

            // Logout Button
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                tileColor: Colors.red.shade100,
                leading: const Icon(Icons.logout_sharp, color: Colors.red),
                title: const Text(
                  'LOGOUT',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Authservice().signOut();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
