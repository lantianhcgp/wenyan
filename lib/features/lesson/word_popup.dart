import 'package:flutter/material.dart';
import 'models.dart';

Future<void> showWordPopup(BuildContext context, Gloss gloss) async {
  await showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(gloss.word),
      content: Text(gloss.explain),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('关闭')),
      ],
    ),
  );
}
