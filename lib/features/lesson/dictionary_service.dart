import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class DictionaryService {
  static const _kBaseKey = 'dic_base';
  static const _kApiKey = 'dic_key';

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
        // 期望格式：{ word: '惟', explain: '只、唯。' } 或 { entries: [{ head, gloss }] }
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
