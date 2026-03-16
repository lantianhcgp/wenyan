import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';
import '../../data/dictionary_db.dart';

class DictionaryService {
  static const _kBaseKey = 'dic_base';
  static const _kApiKey = 'dic_key';

  Future<Gloss?> lookup(String word) async {
    // 1) 本地 SQLite 权威词典（若已导入）
    final dbExact = await DictionaryDb.lookupExact(word);
    if (dbExact != null) return dbExact;
    // 2) DB 模糊匹配
    final fuzzy = await DictionaryDb.lookupFuzzy(word);
    if (fuzzy != null) return fuzzy;
    // 3) 远程 API（可选）
    final remote = await lookupRemote(word);
    return remote;
  }

  Future<Gloss?> lookupRemote(String word) async {
    final sp = await SharedPreferences.getInstance();
    final base = sp.getString(_kBaseKey) ?? '';
    final key = sp.getString(_kApiKey) ?? '';
    if (base.isEmpty) return null;
    try {
      final uri = Uri.parse(base).replace(queryParameters: {
        'q': word,
        if (key.isNotEmpty) 'key': key,
      });
      final res = await http.get(uri, headers: {
        'Accept': 'application/json',
      }).timeout(const Duration(seconds: 6));
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = json.decode(utf8.decode(res.bodyBytes));
        if (data is Map<String, dynamic>) {
          if (data['explain'] is String && data['word'] is String) {
            return Gloss(data['word'] as String, data['explain'] as String);
          }
          if (data['entries'] is List && (data['entries'] as List).isNotEmpty) {
            final e = (data['entries'] as List).first as Map<String, dynamic>;
            final head = (e['head'] ?? word).toString();
            final gloss = (e['gloss'] ?? e['explain'] ?? '').toString();
            if (gloss.isNotEmpty) return Gloss(head, gloss);
          }
        }
      }
    } catch (_) {}
    return null;
  }
}
