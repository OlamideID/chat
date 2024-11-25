import 'package:chat/pages/home.dart';
import 'package:chat/pages/settings.dart';
import 'package:chat/providers/theme_provider.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class MyWidget extends ConsumerStatefulWidget {
  const MyWidget({super.key});

  @override
  ConsumerState<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends ConsumerState<MyWidget> {
  int _selectedIndex = 0;

  // List of pages to display for each tab
  List<Widget> pages = [
    const HomePage(),
    const SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark;

    return Scaffold(
      // Conditional rendering for mobile and web
      bottomNavigationBar: kIsWeb
          ? Container(
              height: 70,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.black : Colors.grey[500],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GNav(
                haptic: true,
                gap: 8,
                activeColor: isDarkMode ? Colors.grey : Colors.white,
                iconSize: 24,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                color: Colors.black,
                tabs: [
                  GButton(
                    textStyle: TextStyle(
                        color: isDarkMode ? Colors.grey : Colors.white),
                    iconColor: isDarkMode ? Colors.grey : Colors.grey[200],
                    iconActiveColor: isDarkMode ? Colors.grey : Colors.white,
                    icon: Icons.home,
                    text: 'Home',
                  ),
                  GButton(
                    iconActiveColor: isDarkMode ? Colors.grey : Colors.white,
                    textStyle: TextStyle(
                        color: isDarkMode ? Colors.grey : Colors.white),
                    iconColor: isDarkMode ? Colors.grey : Colors.white,
                    icon: Icons.settings,
                    text: 'Settings',
                  ),
                ],
                selectedIndex: _selectedIndex,
                onTabChange: _onItemTapped,
              ),
            )
          : CurvedNavigationBar(
              backgroundColor: isDarkMode ? Colors.black : Colors.white,
              color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade800,
              height: 60,
              items: [
                CurvedNavigationBarItem(
                  labelStyle: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.white),
                  label: 'Home',
                  child: Icon(
                    Icons.home,
                    color: isDarkMode ? Colors.black : Colors.grey[300],
                  ),
                ),
                CurvedNavigationBarItem(
                  labelStyle: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.white),
                  child: Icon(
                    Icons.settings,
                    color: isDarkMode ? Colors.black : Colors.grey[300],
                  ),
                  label: 'Settings',
                ),
              ],
              onTap: _onItemTapped,
            ),
      // Display the current page based on selected index
      body: pages[_selectedIndex],
    );
  }
}
