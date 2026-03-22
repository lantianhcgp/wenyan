import 'package:flutter/material.dart';
import '../../data/dictionary_db.dart';
import '../lesson/library_service.dart';
import '../lesson/models.dart';

class QuizPage extends StatefulWidget {
  final Map<String, dynamic>? lessonData;
  const QuizPage({super.key, this.lessonData});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final _qCount = 10;
  int _index = 0;
  int _score = 0;
  bool _finished = false;
  late Future<List<LessonQuestion>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<LessonQuestion>> _load() async {
    if (widget.lessonData != null) {
      final lessonQs = LibraryService.buildQuestions(widget.lessonData!);
      if (lessonQs.isNotEmpty) return lessonQs;
    }

    final samples = await DictionaryDb.sampleEntries(_qCount);
    final list = <LessonQuestion>[];
    for (final g in samples) {
      final distractors = (await DictionaryDb.sampleEntries(6))
          .map((e) => e.explain)
          .where((t) => t != g.explain)
          .toSet()
          .take(3)
          .toList();
      if (distractors.length < 3) continue;
      final options = [...distractors, g.explain]..shuffle();
      list.add(LessonQuestion(prompt: g.word, answer: g.explain, options: options));
    }
    return list;
  }

  void _pick(List<LessonQuestion> qs, LessonQuestion q, String opt) {
    if (_finished) return;
    final correct = opt == q.answer;
    if (correct) _score++;
    final isLast = _index >= qs.length - 1;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(correct ? '答对了' : '答错了'),
        content: Text('正确答案：${q.answer}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                if (isLast) {
                  _finished = true;
                } else {
                  _index += 1;
                }
              });
            },
            child: Text(isLast ? '查看成绩' : '下一题'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<LessonQuestion>>(
      future: _future,
      builder: (context, snap) {
        final qs = snap.data;
        if (qs == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (qs.isEmpty) {
          return const Center(child: Text('请先在设置页导入词典，或进入具体篇目使用本篇测验。'));
        }
        final scheme = Theme.of(context).colorScheme;
        if (_finished) {
          return Center(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.emoji_events_rounded, size: 40, color: scheme.primary),
                    const SizedBox(height: 12),
                    Text('测验完成', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 12),
                    Text('得分：$_score / ${qs.length}', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        setState(() {
                          _index = 0;
                          _score = 0;
                          _finished = false;
                          _future = _load();
                        });
                      },
                      child: const Text('再来一轮'),
                    )
                  ],
                ),
              ),
            ),
          );
        }
        final q = qs[_index.clamp(0, qs.length - 1)];
        return ListView(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: scheme.secondaryContainer,
                borderRadius: BorderRadius.circular(32),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('第 ${_index + 1} / ${qs.length} 题', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: scheme.onSecondaryContainer)),
                      Text('得分：$_score', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: scheme.onSecondaryContainer)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(widget.lessonData != null ? '本篇测验' : '词典测验', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: scheme.onSecondaryContainer)),
                  const SizedBox(height: 8),
                  Text('从题目与干扰项中快速建立语感。', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSecondaryContainer.withOpacity(0.9))),
                ],
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(q.prompt, style: Theme.of(context).textTheme.headlineSmall),
                    if ((q.sourceText ?? '').isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(q.sourceText!, style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ],
                ),
              ),
            ),
            ...q.options.map((opt) => Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    title: Text(opt),
                    leading: Icon(Icons.radio_button_unchecked_rounded, color: scheme.primary),
                    trailing: Icon(Icons.arrow_outward_rounded, color: scheme.primary),
                    onTap: () => _pick(qs, q, opt),
                  ),
                )),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}
