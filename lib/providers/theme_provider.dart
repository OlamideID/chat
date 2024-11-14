import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light) {
    _loadTheme();
  }

  // Method to toggle between light and dark mode
  void toggleTheme() {
    state = (state == ThemeMode.light) ? ThemeMode.dark : ThemeMode.light;
    _saveTheme(state);
  }

  // Load the theme mode from shared preferences
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? false;
    state = isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  // Save the theme mode to shared preferences
  Future<void> _saveTheme(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', themeMode == ThemeMode.dark);
  }
}
