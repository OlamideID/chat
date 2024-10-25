import 'package:flutter/material.dart';

class PassText extends StatefulWidget {
  const PassText({
    super.key,
    required this.controller,
    required this.thing,
    required this.ontap,
    this.onPressed,
    required this.icon, required this.obscured, this.onChanged, this.focusNode,
  });
  final TextEditingController controller;
  final String thing;
  final Function() ontap;
  final Function()? onPressed;
  final Widget icon;
  final bool obscured;
  final FocusNode? focusNode;
  final Function(String)? onChanged;

  @override
  State<PassText> createState() => _PassTextState();
}

class _PassTextState extends State<PassText> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        focusNode: widget.focusNode,
        onChanged: widget.onChanged,
        onTap: widget.ontap,
        controller: widget.controller,
        obscureText: widget.obscured,
        decoration: InputDecoration(
            suffix: IconButton(onPressed: widget.onPressed, icon: widget.icon),
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
            hintText: 'Password',
            hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary)),
      ),
    );
  }
}
