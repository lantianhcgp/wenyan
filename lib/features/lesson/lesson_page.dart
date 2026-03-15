import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'models.dart';
import 'segment_text.dart';
import 'dictionary_service.dart';

class LessonPage extends StatefulWidget {
  const LessonPage({super.key});

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  Map<String, dynamic>? _data;
  Map<String, Gloss> _lexicon = {};
  final _dic = DictionaryService();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final raw = await rootBundle.loadString('assets/texts/sample.json');
    _lexicon = {
      '陋室': Gloss('陋室', '简陋的屋子。'),
      '惟': Gloss('惟', '只、唯。'),
      '德馨': Gloss('德馨', '美德芳香，比喻品德高尚。'),
      '仙': Gloss('仙', '指仙人，这里泛指高人。'),
      '灵': Gloss('灵', '灵验、神奇。'),
    };
    setState(() => _data = json.decode(raw) as Map<String, dynamic>);
  }

  Future<Gloss?> _lookup(String word) async {
    // 本地优先，其次远程词典
    if (_lexicon.containsKey(word)) return _lexicon[word];
    final g = await _dic.lookupRemote(word);
    return g ?? Gloss(word, '未找到权威词条（可在设置中配置词典 API）');
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
                child: Builder(
                  builder: (context) => FutureBuilder<Map<String, Gloss>>(
                    future: Future.value(_lexicon),
                    builder: (context, snapshot) {
                      final map = snapshot.data ?? _lexicon;
                      return SegmentedText(
                        text: p,
                        lexicon: map,
                      );
                    },
                  ),
                ),
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
