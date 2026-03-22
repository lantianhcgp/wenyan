import 'package:flutter/material.dart';
import 'models.dart';
import 'segment_text.dart';
import 'dictionary_service.dart';
import '../quiz/quiz_page.dart';
import 'library_service.dart';

class LessonPage extends StatefulWidget {
  final Map<String, dynamic> data;
  const LessonPage({super.key, required this.data});

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  late Map<String, dynamic> _data;
  Map<String, Gloss> _lexicon = {};
  final _dic = DictionaryService();

  @override
  void initState() {
    super.initState();
    _data = widget.data;
    _initLexicon();
  }

  void _initLexicon() {
    _lexicon = {
      '陋室': Gloss('陋室', '简陋的屋子。'),
      '惟': Gloss('惟', '只、唯。'),
      '德馨': Gloss('德馨', '美德芳香，比喻品德高尚。'),
      '仙': Gloss('仙', '指仙人，这里泛指高人。'),
      '灵': Gloss('灵', '灵验、神奇。'),
      '谪守': Gloss('谪守', '因罪贬谪流放，出任外官。'),
      '百废具兴': Gloss('百废具兴', '各种荒废的事业都兴办起来。具，同“俱”。'),
      '先帝': Gloss('先帝', '指蜀汉先主刘备。'),
      '崩殂': Gloss('崩殂', '古代称帝王去世。'),
      '劝学': Gloss('劝学', '勉励学习、强调后天积累的重要。'),
    };

    final notes = ((_data['notes'] as List?) ?? const []).map((e) => e.toString());
    for (final note in notes) {
      final normalized = note.replaceAll('：', ':');
      final idx = normalized.indexOf(':');
      if (idx > 0 && idx < normalized.length - 1) {
        final head = normalized.substring(0, idx).trim();
        final gloss = normalized.substring(idx + 1).trim();
        if (head.isNotEmpty && gloss.isNotEmpty) {
          _lexicon[head] = Gloss(head, gloss);
        }
      }
    }
  }

  Future<Gloss?> _lookup(String word) async {
    if (_lexicon.containsKey(word)) return _lexicon[word];
    final g = await _dic.lookup(word);
    return g ?? Gloss(word, '未找到权威词条（可在设置中配置词典 API 或导入本地词典）');
  }

  @override
  Widget build(BuildContext context) {
    final paragraphs = ((_data['paragraphs'] as List?) ?? const []).cast<String>();
    final notes = ((_data['notes'] as List?) ?? const []).cast<String>();
    final translation = (_data['translation'] ?? '').toString();
    final questions = LibraryService.buildQuestions(_data);

    final scheme = Theme.of(context).colorScheme;
    return ListView(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_data['title'] ?? '', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: scheme.onPrimaryContainer)),
              const SizedBox(height: 8),
              Text(_data['author'] ?? '', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onPrimaryContainer.withOpacity(0.9))),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    icon: const Icon(Icons.quiz_outlined),
                    label: Text('本篇测验（${questions.length}题）'),
                    onPressed: questions.isEmpty
                        ? null
                        : () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => QuizPage(lessonData: _data),
                            ));
                          },
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.menu_book),
                    label: const Text('点击正文可查词'),
                    onPressed: null,
                  ),
                ],
              ),
            ],
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('正文', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                ...paragraphs.map((p) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SegmentedText(text: p, lexicon: _lexicon),
                    )),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('注释', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                if (notes.isEmpty)
                  const Text('当前篇目暂无结构化注释，仍可点击正文逐词查询。')
                else
                  ...notes.map((n) => ListTile(contentPadding: EdgeInsets.zero, leading: const Text('·'), title: Text(n))),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('译文', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                Text(translation.isEmpty ? '当前篇目暂未内置完整译文。' : translation),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
