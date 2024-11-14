import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  const UserTile({
    super.key,
    required this.text,
    this.onTap,
    this.delete, this.block,
  });
  final String text;
  final Function()? onTap;
  final Function()? delete;
    final Function()? block;


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: InkWell(
          onLongPress: delete,
          enableFeedback: true,
          splashColor: Theme.of(context).colorScheme.primary,
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                const SizedBox(
                  width: 20,
                ),
                Text(text)
              ],
            ),
          )),
    );
  }
}
