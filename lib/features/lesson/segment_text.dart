import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'models.dart';
import 'word_popup.dart';
import 'dictionary_service.dart';

class SegmentedText extends StatelessWidget {
  final String text;
  final Map<String, Gloss> lexicon; // 词典（简易本地）
  const SegmentedText({super.key, required this.text, required this.lexicon});

  List<InlineSpan> _buildSpans(BuildContext context) {
    final spans = <InlineSpan>[];
    final dic = DictionaryService();
    int i = 0;
    while (i < text.length) {
      if (text[i].trim().isEmpty) {
        spans.add(TextSpan(text: text[i]));
        i++; continue;
      }
      String best = text[i];
      for (int j = i + 1; j <= text.length; j++) {
        final cand = text.substring(i, j);
        if (lexicon.containsKey(cand)) {
          best = cand;
        }
      }
      Future<void> onTapWord(String w) async {
        // 先内置，再权威库/远程
        final g = lexicon[w] ?? await dic.lookup(w) ?? Gloss(w, '未找到词条');
        // ignore: use_build_context_synchronously
        await showWordPopup(context, g);
      }
      if (lexicon.containsKey(best)) {
        spans.add(TextSpan(
          text: best,
          style: const TextStyle(color: Colors.teal, decoration: TextDecoration.underline),
          recognizer: TapGestureRecognizer()..onTap = () => onTapWord(best),
        ));
        i += best.length;
      } else {
        spans.add(TextSpan(
          text: text[i],
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          recognizer: TapGestureRecognizer()..onTap = () => onTapWord(text[i]),
        ));
        i++;
      }
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return RichText(text: TextSpan(style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18, height: 1.6), children: _buildSpans(context)));
  }
}
