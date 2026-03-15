import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class LibraryEntry {
  final String title;
  final String author;
  final String source; // asset:assets/texts/xxx.json or file:/.../texts/xxx.json
  LibraryEntry({required this.title, required this.author, required this.source});
}

class LibraryService {
  static Future<List<LibraryEntry>> listAll() async {
    final list = <LibraryEntry>[];
    // assets index
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
    // local files (app documents)/texts/*.json
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

  static Future<void> importJson(String jsonText, {String? filename}) async {
    final dir = await getApplicationDocumentsDirectory();
    final tdir = Directory(p.join(dir.path, 'texts'));
    await tdir.create(recursive: true);
    final name = filename ?? 'import_${DateTime.now().millisecondsSinceEpoch}.json';
    final f = File(p.join(tdir.path, name));
    await f.writeAsString(jsonText);
  }
}
