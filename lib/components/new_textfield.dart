import 'package:flutter/material.dart';

class NewPass extends StatefulWidget {
  const NewPass(
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
  State<NewPass> createState() => _NewPass();
}

class _NewPass extends State<NewPass> {
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
                       hintText: widget.thing,
            hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary)),
      ),
    );
  }
}
