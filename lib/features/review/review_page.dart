import 'package:flutter/material.dart';
import '../../data/review_db.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  late Future<List<ReviewItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = ReviewDb.dueItems();
  }

  Future<void> _reload() async {
    setState(() => _future = ReviewDb.dueItems());
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FutureBuilder<List<ReviewItem>>(
      future: _future,
      builder: (context, snap) {
        final items = snap.data;
        if (items == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (items.isEmpty) {
          return Center(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.done_all_rounded, size: 40, color: scheme.primary),
                    const SizedBox(height: 12),
                    Text('当前没有待复习词条', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text('在学习页点词后加入生词本，这里会自动出现复习卡片。', style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          );
        }
        final item = items.first;
        return ListView(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: scheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(32),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('今日复习', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: scheme.onTertiaryContainer)),
                  const SizedBox(height: 8),
                  Text('剩余 ${items.length} 个词条，按感觉选择“认识 / 模糊 / 不认识”。', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onTertiaryContainer.withOpacity(0.9))),
                ],
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.word, style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 12),
                    Text(item.gloss, style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        FilledButton.tonal(
                          onPressed: () async {
                            await ReviewDb.grade(item.word, button: 'unknown');
                            await _reload();
                          },
                          child: const Text('不认识'),
                        ),
                        OutlinedButton(
                          onPressed: () async {
                            await ReviewDb.grade(item.word, button: 'fuzzy');
                            await _reload();
                          },
                          child: const Text('模糊'),
                        ),
                        FilledButton(
                          onPressed: () async {
                            await ReviewDb.grade(item.word, button: 'known');
                            await _reload();
                          },
                          child: const Text('认识'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
