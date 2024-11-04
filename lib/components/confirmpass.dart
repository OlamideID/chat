import 'package:chat/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConfirmPass extends ConsumerStatefulWidget {
  const ConfirmPass({
    super.key,
    required this.controller,
    required this.thing,
    required this.ontap,
    required this.onPressed,
    required this.icon,
    required this.obscured,
    this.onChanged,
    this.focusNode,
  });

  final TextEditingController controller;
  final String thing;
  final Function() ontap;
  final Function() onPressed;
  final Widget icon;
  final bool obscured;
  final FocusNode? focusNode;
  final Function(String)? onChanged;

  @override
  _ConfirmPassState createState() => _ConfirmPassState();
}

class _ConfirmPassState extends ConsumerState<ConfirmPass> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: TextField(
        focusNode: widget.focusNode,
        onChanged: widget.onChanged,
        onTap: widget.ontap,
        controller: widget.controller,
        obscureText: widget.obscured,
        decoration: InputDecoration(
          suffixIcon: IconButton(
            onPressed: widget.onPressed,
            icon: widget.icon,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.tertiary),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
            borderRadius: BorderRadius.circular(10),
          ),
          fillColor: Theme.of(context).colorScheme.secondary,
          filled: true,
          hintText: widget.thing,
          hintStyle: TextStyle(
            color: isDarkMode ? Colors.grey : Colors.grey[900],
          ),
        ),
      ),
    );
  }
}
