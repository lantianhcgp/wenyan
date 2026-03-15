import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class LessonPage extends StatefulWidget {
  const LessonPage({super.key});

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final raw = await rootBundle.loadString('assets/texts/sample.json');
    setState(() => _data = json.decode(raw) as Map<String, dynamic>);
  }

  @override
  Widget build(BuildContext context) {
    if (_data == null) return const Center(child: CircularProgressIndicator());
    return Padding(
      padding: const EdgeInsets.all(12),
      child: ListView(
        children: [
          Text(_data!['title'] ?? '', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(_data!['author'] ?? '', style: Theme.of(context).textTheme.labelMedium),
          const Divider(height: 24),
          ...((_data!['paragraphs'] as List).map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(p as String, style: const TextStyle(fontSize: 18, height: 1.6)),
              ))),
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
