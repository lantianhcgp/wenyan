class Token {
  final String text;
  final int start;
  final int end;
  Token(this.text, this.start, this.end);
}

class Gloss {
  final String word;
  final String explain;
  Gloss(this.word, this.explain);
}
