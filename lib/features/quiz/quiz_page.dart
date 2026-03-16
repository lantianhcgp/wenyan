import 'dart:math';
import 'package:flutter/material.dart';

class QuizPage extends StatefulWidget {
  final Map<String, dynamic> lessonData;
  const QuizPage({super.key, required this.lessonData});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late List<_Question> _questions;
  int _index = 0;
  int _correct = 0;

  @override
  void initState() {
    super.initState();
    _questions = _buildQuestions(widget.lessonData);
  }

  List<_Question> _buildQuestions(Map<String, dynamic> data) {
    final List<String> paras = (data['paragraphs'] as List).cast<String>();
    final Map<String, String> notes = {};
    for (final n in (data['notes'] as List).cast<String>()) {
      final parts = n.split('：');
      if (parts.length >= 2) {
        notes[parts[0].trim()] = parts.sublist(1).join('：').trim();
      }
    }

    final rnd = Random();
    final words = notes.keys.toList();
    final qs = <_Question>[];

    // 1) 词义选择：给词，选释义
    for (final w in words) {
      final correct = notes[w]!;
      final distractors = words.where((x) => x != w).toList()..shuffle(rnd);
      final options = <String>{correct};
      for (final d in distractors.take(3)) {
        options.add(notes[d]!);
      }
      final opts = options.toList()..shuffle(rnd);
      qs.add(_Question(
        type: 'meaning',
        stem: '“$w”最合适的释义是？',
        options: opts,
        answer: correct,
      ));
    }

    // 2) 句意判断：从原文挑句子，问其大意
    for (final p in paras.take(3)) {
      final others = paras.where((x) => x != p).toList();
      final correct = '大意：$p';
      final distract = others.isNotEmpty ? '大意：${others[rnd.nextInt(others.length)]}' : '大意：——';
      final opts = [correct, distract, '与文意无关', '无法判断']..shuffle(rnd);
      qs.add(_Question(
        type: 'gist',
        stem: '这句的恰当大意是？\n$p',
        options: opts,
        answer: correct,
      ));
    }

    qs.shuffle(rnd);
    return qs.take(10).toList();
  }

  void _choose(String opt) {
    final q = _questions[_index];
    final ok = opt == q.answer;
    if (ok) _correct++;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(ok ? '正确' : '不对'),
        content: Text('答案：${q.answer}'),
        actions: [TextButton(onPressed: () { Navigator.of(context).pop(); _next(); }, child: const Text('继续'))],
      ),
    );
  }

  void _next() {
    if (_index + 1 >= _questions.length) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('测验结束'),
          content: Text('得分：$_correct / ${_questions.length}'),
          actions: [TextButton(onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst), child: const Text('返回'))],
        ),
      );
    } else {
      setState(() => _index++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_index];
    return Scaffold(
      appBar: AppBar(title: const Text('本篇测验')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('第 ${_index + 1} 题 / ${_questions.length}'),
            const SizedBox(height: 8),
            Text(q.stem, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            ...q.options.map((o) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: FilledButton(
                    onPressed: () => _choose(o),
                    child: Align(alignment: Alignment.centerLeft, child: Text(o)),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _Question {
  final String type;
  final String stem;
  final List<String> options;
  final String answer;
  _Question({required this.type, required this.stem, required this.options, required this.answer});
}
