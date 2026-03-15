import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'models.dart';
import 'segment_text.dart';

class LessonPage extends StatefulWidget {
  const LessonPage({super.key});

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  Map<String, dynamic>? _data;
  Map<String, Gloss> _lexicon = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final raw = await rootBundle.loadString('assets/texts/sample.json');
    final idxRaw = await rootBundle.loadString('assets/texts/index.json');
    // 简易内置词典（后续接入权威词典API）
    _lexicon = {
      '陋室': Gloss('陋室', '简陋的屋子。'),
      '惟': Gloss('惟', '只、唯。'),
      '德馨': Gloss('德馨', '美德芳香，比喻品德高尚。'),
      '仙': Gloss('仙', '指仙人，这里泛指高人。'),
      '灵': Gloss('灵', '灵验、神奇。'),
    };
    setState(() => _data = json.decode(raw) as Map<String, dynamic>);
  }

  @override
  Widget build(BuildContext context) {
    if (_data == null) return const Center(child: CircularProgressIndicator());
    final paragraphs = (_data!['paragraphs'] as List).cast<String>();
    return Padding(
      padding: const EdgeInsets.all(12),
      child: ListView(
        children: [
          Text(_data!['title'] ?? '', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(_data!['author'] ?? '', style: Theme.of(context).textTheme.labelMedium),
          const Divider(height: 24),
          ...paragraphs.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SegmentedText(text: p, lexicon: _lexicon),
              )),
          const Divider(height: 24),
          Text('注释', style: Theme.of(context).textTheme.titleMedium),
          ...((_data!['notes'] as List).map((n) => ListTile(leading: const Text('·'), title: Text(n as String)))),
          const Divider(height: 24),
          Text('译文', style: Theme.of(context).textTheme.titleMedium),
          Text(_data!['translation'] ?? ''),
        ],
      ),
    );
  }
}
