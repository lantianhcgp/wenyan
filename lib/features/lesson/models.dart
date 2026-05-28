class Gloss {
  final String word;
  final String explain;
  Gloss(this.word, this.explain);
}

class LessonQuestion {
  final String prompt;
  final String answer;
  final List<String> options;
  final String? sourceText;

  const LessonQuestion({
    required this.prompt,
    required this.answer,
    required this.options,
    this.sourceText,
  });
}
