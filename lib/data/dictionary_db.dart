import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../features/lesson/models.dart';

class DictionaryDb {
  static Database? _db;

  /// 初始化：优先使用应用数据目录下的 dictionary.db；
  /// 若不存在且 assets/db/dictionary.db 存在，则复制过去。
  static Future<void> init() async {
    if (_db != null) return;
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, 'dictionary.db');
    final f = File(dbPath);
    if (!await f.exists()) {
      // 尝试从 assets 拷贝预置库（可选）
      try {
        final bytes = await rootBundle.load('assets/db/dictionary.db');
        await f.create(recursive: true);
        await f.writeAsBytes(bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
      } catch (_) {
        // 资产里没有预置库，跳过
      }
    }
    _db = await openDatabase(dbPath, version: 1, onCreate: (db, v) async {
      await db.execute(
        'CREATE TABLE IF NOT EXISTS entries (head TEXT PRIMARY KEY, gloss TEXT)'
      );
      await db.execute('CREATE INDEX IF NOT EXISTS idx_head ON entries(head)');
    });
  }

  static Future<Gloss?> lookupExact(String head) async {
    await init();
    if (_db == null) return null;
    final rows = await _db!.query('entries', where: 'head = ?', whereArgs: [head], limit: 1);
    if (rows.isEmpty) return null;
    final r = rows.first;
    return Gloss((r['head'] ?? head).toString(), (r['gloss'] ?? '').toString());
  }

  static Future<Gloss?> lookupFuzzy(String head) async {
    await init();
    if (_db == null) return null;
    final rows = await _db!.query('entries', where: 'head LIKE ?', whereArgs: ['%$head%'], limit: 1);
    if (rows.isEmpty) return null;
    final r = rows.first;
    return Gloss((r['head'] ?? head).toString(), (r['gloss'] ?? '').toString());
  }

  /// 随机抽取若干词条（用于测验）
  static Future<List<Gloss>> sampleEntries(int n) async {
    await init();
    if (_db == null) return [];
    final rows = await _db!.rawQuery('SELECT head, gloss FROM entries ORDER BY RANDOM() LIMIT ?', [n]);
    return rows
        .map((r) => Gloss((r['head'] ?? '').toString(), (r['gloss'] ?? '').toString()))
        .where((g) => g.word.isNotEmpty && g.explain.isNotEmpty)
        .toList();
  }

  /// 导入词典 JSON 到本地数据库。
  /// 支持格式：
  /// - 数组：[{"word":"陋室","explain":"简陋的屋子"}, ...] 或 [{"head":"...","gloss":"..."}]
  /// - 对象：{"陋室":"简陋的屋子", "惟":"只、唯"}
  static Future<int> importJson(String jsonText) async {
    await init();
    if (_db == null) return 0;
    final db = _db!;
    int count = 0;
    try {
      final data = json.decode(jsonText);
      await db.transaction((txn) async {
        Batch batch = txn.batch();
        void put(String head, String gloss) {
          if (head.trim().isEmpty || gloss.trim().isEmpty) return;
          batch.insert('entries', {'head': head.trim(), 'gloss': gloss.trim()}, conflictAlgorithm: ConflictAlgorithm.replace);
          count++;
        }
        if (data is List) {
          for (final e in data) {
            if (e is Map<String, dynamic>) {
              final head = (e['head'] ?? e['word'] ?? '').toString();
              final gloss = (e['gloss'] ?? e['explain'] ?? '').toString();
              if (head.isNotEmpty && gloss.isNotEmpty) put(head, gloss);
            }
          }
        } else if (data is Map<String, dynamic>) {
          data.forEach((k, v) => put(k.toString(), v.toString()));
        }
        await batch.commit(noResult: true);
      });
    } catch (_) {}
    return count;
  }
}
