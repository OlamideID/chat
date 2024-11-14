import 'package:chat/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Button extends ConsumerWidget {
  const Button({super.key, required this.text, required this.onTap});
  final String text;
  final Function()? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(10)),
        child: Center(
          child: Text(
            text,
            style:
                TextStyle(color: isDarkMode ? Colors.white : Colors.grey[900]),
          ),
        ),
      ),
    );
  }
}
