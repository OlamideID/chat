import 'package:flutter/material.dart';

class ConfirmPass extends StatefulWidget {
  const ConfirmPass(
      {super.key,
      required this.controller,
      required this.thing,
      required this.ontap,
      this.onChanged});
  final TextEditingController controller;
  final String thing;
  final Function() ontap;
  final Function(String)? onChanged;

  @override
  State<ConfirmPass> createState() => _ConfirmPassState();
}

class _ConfirmPassState extends State<ConfirmPass> {
  togglePass() {
    setState(() {
      obscured = !obscured;
    });
  }

  bool obscured = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: TextField(
        onChanged: widget.onChanged,
        onTap: widget.ontap,
        controller: widget.controller,
        obscureText: obscured,
        decoration: InputDecoration(
            suffix: IconButton(
                onPressed: togglePass,
                icon: obscured
                    ? const Icon(Icons.visibility_off)
                    : const Icon(Icons.visibility)),
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
            hintText: widget.thing,
            hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary)),
      ),
    );
  }
}
