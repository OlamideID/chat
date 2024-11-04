import 'package:chat/pages/blocked.dart';
import 'package:chat/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark;

    final themeMode = ref.watch(themeProvider); // Watch the theme mode

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: themeMode == ThemeMode.dark,
              onChanged: (bool value) {
                ref.read(themeProvider.notifier).toggleTheme(); // Toggle theme
              },
            ),
            SizedBox(
              height: 15,
            ),
            ListTile(
              trailing: Icon(Icons.arrow_forward),
              title: const Text('Blocked Users'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlockedPage(TextStyle(
                        color: isDarkMode ? Colors.white : Colors.grey[700])),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
