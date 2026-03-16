import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class ReviewItem {
  final String word;
  final String gloss;
  final double ease; // 学习难度系数，默认 2.5
  final int interval; // 间隔天数
  final int due; // 到期时间戳（ms）
  ReviewItem(this.word, this.gloss, this.ease, this.interval, this.due);
}

class ReviewDb {
  static Database? _db;

  static Future<Database> _open() async {
    if (_db != null) return _db!;
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, 'review.db');
    _db = await openDatabase(dbPath, version: 1, onCreate: (db, v) async {
      await db.execute('''
        CREATE TABLE review (
          word TEXT PRIMARY KEY,
          gloss TEXT,
          ease REAL,
          interval INTEGER,
          due INTEGER
        );
      ''');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_due ON review(due)');
    });
    return _db!;
  }

  static Future<void> upsert(String word, String gloss) async {
    final db = await _open();
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.insert(
      'review',
      {
        'word': word,
        'gloss': gloss,
        'ease': 2.5,
        'interval': 0,
        'due': now,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  static Future<List<ReviewItem>> dueItems({int limit = 50}) async {
    final db = await _open();
    final now = DateTime.now().millisecondsSinceEpoch;
    final rows = await db.query('review', where: 'due <= ?', whereArgs: [now], orderBy: 'due ASC', limit: limit);
    return rows
        .map((r) => ReviewItem(
              (r['word'] ?? '').toString(),
              (r['gloss'] ?? '').toString(),
              (r['ease'] as num?)?.toDouble() ?? 2.5,
              (r['interval'] as num?)?.toInt() ?? 0,
              (r['due'] as num?)?.toInt() ?? now,
            ))
        .toList();
  }

  static Future<void> grade(String word, {required String button}) async {
    // 简化版 SM-2：
    // 认识: interval = max(1, interval*ease)；ease += 0.15；due=now+interval天
    // 模糊: interval = max(1, interval)；ease += 0；due=now+interval天
    // 不认识: interval = 0；ease = max(1.3, ease-0.2)；due=now+10分钟
    final db = await _open();
    final rows = await db.query('review', where: 'word = ?', whereArgs: [word], limit: 1);
    if (rows.isEmpty) return;
    final r = rows.first;
    var ease = (r['ease'] as num?)?.toDouble() ?? 2.5;
    var interval = (r['interval'] as num?)?.toInt() ?? 0;
    final now = DateTime.now();
    DateTime nextDue;
    switch (button) {
      case 'known':
        interval = (interval == 0 ? 1 : (interval * ease).round());
        ease += 0.15;
        nextDue = now.add(Duration(days: interval));
        break;
      case 'fuzzy':
        interval = (interval == 0 ? 1 : interval);
        nextDue = now.add(Duration(days: interval));
        break;
      default:
        interval = 0;
        ease = ease - 0.2;
        if (ease < 1.3) ease = 1.3;
        nextDue = now.add(const Duration(minutes: 10));
    }
    await db.update('review', {
      'ease': ease,
      'interval': interval,
      'due': nextDue.millisecondsSinceEpoch,
    }, where: 'word = ?', whereArgs: [word]);
  }

  static Future<int> count() async {
    final db = await _open();
    final rows = await db.rawQuery('SELECT COUNT(*) AS c FROM review');
    return (rows.first['c'] as int?) ?? 0;
  }
}