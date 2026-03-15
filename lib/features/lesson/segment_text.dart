import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'models.dart';
import 'word_popup.dart';

class SegmentedText extends StatelessWidget {
  final String text;
  final Map<String, Gloss> lexicon; // 词典（简易本地）
  const SegmentedText({super.key, required this.text, required this.lexicon});

  List<InlineSpan> _buildSpans(BuildContext context) {
    final spans = <InlineSpan>[];
    // 简化：按每个汉字或标点遍历，若能在词典中找到以该字开头的最长词，则高亮那段
    int i = 0;
    while (i < text.length) {
      // 跳过空白
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
      if (lexicon.containsKey(best)) {
        final g = lexicon[best]!;
        spans.add(TextSpan(
          text: best,
          style: const TextStyle(color: Colors.teal, decoration: TextDecoration.underline),
          recognizer: TapGestureRecognizer()..onTap = () => showWordPopup(context, g),
        ));
        i += best.length;
      } else {
        spans.add(TextSpan(text: text[i]));
        i++;
      }
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return RichText(text: TextSpan(style: const TextStyle(color: Colors.black, fontSize: 18, height: 1.6), children: _buildSpans(context)));
  }
}
