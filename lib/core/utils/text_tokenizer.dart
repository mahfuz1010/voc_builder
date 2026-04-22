/// Splits a block of text into individual word tokens,
/// stripping punctuation but preserving original casing for display.
class TextTokenizer {
  static List<String> tokenize(String text) {
    if (text.trim().isEmpty) return [];

    // Split on whitespace and common punctuation boundaries
    final rawTokens = text.split(RegExp(r'[\s\n\r]+'));
    final result = <String>[];

    for (final token in rawTokens) {
      final cleaned = token.replaceAll(RegExp(r'^[^\wäöüÄÖÜß]+|[^\wäöüÄÖÜß]+$'), '').trim();
      if (cleaned.isNotEmpty && cleaned.length > 1) {
        result.add(cleaned);
      }
    }

    // Remove duplicates while preserving order
    final seen = <String>{};
    return result.where((t) => seen.add(t.toLowerCase())).toList();
  }

  /// Parse a vocabulary list line: supports formats like
  /// "German;English", "German | English", "German - English"
  static Map<String, String>? parseVocabLine(String line) {
    final separators = [';', '|', ' - '];
    for (final sep in separators) {
      if (line.contains(sep)) {
        final parts = line.split(sep);
        if (parts.length >= 2) {
          return {
            'german': parts[0].trim(),
            'english': parts.sublist(1).join(sep).trim(),
          };
        }
      }
    }
    return null;
  }
}
