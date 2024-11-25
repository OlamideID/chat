import 'package:chat/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Textfield2 extends ConsumerWidget {
  const Textfield2(
      {super.key,
      required this.hintText,
      required this.obscure,
      this.focusNode,
      required this.controller,
      required this.onTap,
      this.onChanged,
      this.keyboardtype,
      });
  final String hintText;
  final bool obscure;
  final FocusNode? focusNode;
  final TextEditingController controller;
  final Function() onTap;
  final Function(String)? onChanged;
  final TextInputType? keyboardtype;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        focusNode: focusNode,
        onChanged: onChanged,
        onTap: onTap,
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardtype,
        cursorColor: isDarkMode ? Colors.white : Colors.black,
        decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.tertiary),
                borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.primary),
              borderRadius: BorderRadius.circular(10),
            ),
            fillColor: Theme.of(context).colorScheme.secondary,
            filled: true,
            hintText: hintText,
            hintStyle:
                TextStyle(color: isDarkMode ? Colors.grey : Colors.black)),
      ),
    );
  }
}
