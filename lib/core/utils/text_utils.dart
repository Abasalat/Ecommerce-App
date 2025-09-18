class TextUtils {
  /// Returns the first [maxWords] words of [text].
  /// Adds [ellipsis] at the end when the title had more words.
  static String truncateWords(
    String text, {
    int maxWords = 2,
    String ellipsis = ' ..',
    bool alwaysEllipsis = false, // set true if you ALWAYS want the suffix
  }) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return '';

    final words = trimmed.split(RegExp(r'\s+')); // split on any whitespace
    if (words.length <= maxWords) {
      return alwaysEllipsis ? (words.join(' ') + ellipsis) : words.join(' ');
    }
    return words.take(maxWords).join(' ') + ellipsis;
  }
}
