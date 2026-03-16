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

  Future<void> _refresh() async {
    setState(() => _future = ReviewDb.dueItems());
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<List<ReviewItem>>(
        future: _future,
        builder: (context, snap) {
          final items = snap.data ?? [];
          if (items.isEmpty) return const Center(child: Text('暂无待复习词条'));
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final it = items[i];
              return ListTile(
                title: Text(it.word),
                subtitle: Text(it.gloss),
                trailing: Wrap(spacing: 8, children: [
                  OutlinedButton(onPressed: () async { await ReviewDb.grade(it.word, button: 'again'); _refresh(); }, child: const Text('不认识')),
                  OutlinedButton(onPressed: () async { await ReviewDb.grade(it.word, button: 'fuzzy'); _refresh(); }, child: const Text('模糊')),
                  FilledButton(onPressed: () async { await ReviewDb.grade(it.word, button: 'known'); _refresh(); }, child: const Text('认识')),
                ]),
              );
            },
          );
        },
      ),
    );
  }
}
