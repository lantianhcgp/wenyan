import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'models.dart';

class LibraryEntry {
  final String title;
  final String author;
  final String source;
  LibraryEntry({required this.title, required this.author, required this.source});
}

class LibraryService {
  static Future<List<LibraryEntry>> listAll() async {
    final list = <LibraryEntry>[];
    try {
      final raw = await rootBundle.loadString('assets/texts/index.json');
      final arr = json.decode(raw) as List;
      for (final e in arr) {
        final m = e as Map<String, dynamic>;
        final file = m['file'] as String? ?? '';
        final title = m['title'] as String? ?? file;
        final author = m['author'] as String? ?? '';
        if (file.isNotEmpty) {
          list.add(LibraryEntry(title: title, author: author, source: 'asset:assets/texts/$file'));
        }
      }
    } catch (_) {}

    try {
      final dir = await getApplicationDocumentsDirectory();
      final tdir = Directory(p.join(dir.path, 'texts'));
      if (await tdir.exists()) {
        final files = await tdir.list().toList();
        for (final f in files) {
          if (f is File && f.path.toLowerCase().endsWith('.json')) {
            try {
              final raw = await f.readAsString();
              final m = json.decode(raw) as Map<String, dynamic>;
              final title = (m['title'] ?? p.basenameWithoutExtension(f.path)).toString();
              final author = (m['author'] ?? '').toString();
              list.add(LibraryEntry(title: title, author: author, source: 'file:${f.path}'));
            } catch (_) {}
          }
        }
      }
    } catch (_) {}
    return list;
  }

  static Future<Map<String, dynamic>> loadBySource(String source) async {
    if (source.startsWith('asset:')) {
      final path = source.substring('asset:'.length);
      final raw = await rootBundle.loadString(path);
      return json.decode(raw) as Map<String, dynamic>;
    }
    if (source.startsWith('file:')) {
      final path = source.substring('file:'.length);
      final raw = await File(path).readAsString();
      return json.decode(raw) as Map<String, dynamic>;
    }
    final raw = await rootBundle.loadString('assets/texts/sample.json');
    return json.decode(raw) as Map<String, dynamic>;
  }

  static Future<void> importJson(String jsonText, {String? filename}) async {
    final dir = await getApplicationDocumentsDirectory();
    final tdir = Directory(p.join(dir.path, 'texts'));
    await tdir.create(recursive: true);
    final name = filename ?? 'import_${DateTime.now().millisecondsSinceEpoch}.json';
    final f = File(p.join(tdir.path, name));
    await f.writeAsString(jsonText);
  }

  static List<LessonQuestion> buildQuestions(Map<String, dynamic> data) {
    final paragraphs = ((data['paragraphs'] as List?) ?? const []).map((e) => e.toString()).toList();
    final notes = ((data['notes'] as List?) ?? const []).map((e) => e.toString()).toList();
    final translation = (data['translation'] ?? '').toString();
    final title = (data['title'] ?? '').toString();
    final author = (data['author'] ?? '').toString();

    final qa = <MapEntry<String, String>>[];

    for (final note in notes) {
      final normalized = note.replaceAll('：', ':');
      final idx = normalized.indexOf(':');
      if (idx > 0 && idx < normalized.length - 1) {
        final head = normalized.substring(0, idx).trim();
        final gloss = normalized.substring(idx + 1).trim();
        if (head.isNotEmpty && gloss.isNotEmpty) qa.add(MapEntry('“$head”的意思是？', gloss));
      }
    }

    if (title.isNotEmpty) {
      qa.add(MapEntry('本文标题是？', title));
    }
    if (author.isNotEmpty) {
      qa.add(MapEntry('本文作者是？', author));
    }
    if (translation.isNotEmpty) {
      qa.add(MapEntry('下列哪项最符合本文主旨概括？', _summarizeTranslation(translation)));
    }

    final candidateSentences = paragraphs.where((p) => p.trim().length >= 8).take(6).toList();
    for (final p in candidateSentences) {
      qa.add(MapEntry('下列哪一句出自《$title》？', p));
    }

    final unique = <String, String>{};
    for (final e in qa) {
      unique[e.key] = e.value;
    }

    final entries = unique.entries.toList();
    final answerPool = entries.map((e) => e.value).where((e) => e.trim().isNotEmpty).toSet().toList();
    final result = <LessonQuestion>[];
    for (final e in entries) {
      final distractors = answerPool.where((v) => v != e.value).take(3).toList();
      if (distractors.length < 3) continue;
      final options = [...distractors, e.value]..shuffle();
      result.add(LessonQuestion(
        prompt: e.key,
        answer: e.value,
        options: options,
        sourceText: e.value.length > 40 ? e.value.substring(0, 40) : e.value,
      ));
    }
    result.shuffle();
    return result.take(10).toList();
  }

  static String _summarizeTranslation(String translation) {
    final text = translation.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (text.length <= 36) return text;
    return '${text.substring(0, 36)}…';
  }
}
