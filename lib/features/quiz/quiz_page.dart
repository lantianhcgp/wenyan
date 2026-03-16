import 'package:flutter/material.dart';
import '../../data/dictionary_db.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final _qCount = 10;
  int _index = 0;
  late Future<List<_Q>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<_Q>> _load() async {
    final samples = await DictionaryDb.sampleEntries(_qCount);
    final list = <_Q>[];
    for (final g in samples) {
      // 简易四选一：正确释义 + 随机干扰
      final distractors = (await DictionaryDb.sampleEntries(3))
          .map((e) => e.explain)
          .where((t) => t != g.explain)
          .toList();
      final options = [...distractors, g.explain]..shuffle();
      list.add(_Q(word: g.word, answer: g.explain, options: options));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<_Q>>(
      future: _future,
      builder: (context, snap) {
        final qs = snap.data;
        if (qs == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (qs.isEmpty) {
          return const Center(child: Text('请先在设置页导入词典，或打包内置 dictionary.db'));
        }
        final q = qs[_index.clamp(0, qs.length - 1)];
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('选择正确释义', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Text(q.word, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              ...q.options.map((opt) => ListTile(
                    title: Text(opt),
                    leading: const Icon(Icons.circle_outlined),
                    onTap: () {
                      final correct = opt == q.answer;
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text(correct ? '正确' : '再想想'),
                          content: Text('释义：${q.answer}'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                setState(() {
                                  _index = (_index + 1) % qs.length;
                                });
                              },
                              child: const Text('下一题'),
                            )
                          ],
                        ),
                      );
                    },
                  )),
            ],
          ),
        );
      },
    );
  }
}

class _Q {
  final String word;
  final String answer;
  final List<String> options;
  _Q({required this.word, required this.answer, required this.options});
}
