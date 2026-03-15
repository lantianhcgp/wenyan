import 'dart:io';
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
    _db = await openDatabase(dbPath);
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
}
