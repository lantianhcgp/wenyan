import 'package:flutter/material.dart';
import '../../data/review_db.dart';
import 'models.dart';

Future<void> showWordPopup(BuildContext context, Gloss gloss) async {
  await showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(gloss.word),
      content: Text(gloss.explain),
      actions: [
        TextButton(
          onPressed: () async {
            await ReviewDb.upsert(gloss.word, gloss.explain);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已加入生词本')));
            }
          },
          child: const Text('加入生词本'),
        ),
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('关闭')),
      ],
    ),
  );
}
