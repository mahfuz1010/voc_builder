/// Splits a block of text into individual word tokens,
/// stripping punctuation but preserving original casing for display.
class TextTokenizer {
  static final RegExp _emailRegex = RegExp(
    r'^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$',
    caseSensitive: false,
  );
  static final RegExp _urlRegex = RegExp(
    r'^(https?:\/\/|www\.)',
    caseSensitive: false,
  );
  static final RegExp _domainLikeRegex = RegExp(
    r'^[A-Z0-9.-]+\.[A-Z]{2,}$',
    caseSensitive: false,
  );
  static final RegExp _hasDigitRegex = RegExp(r'\d');

  static const Set<String> _noiseWords = {
    'http',
    'https',
    'www',
    'com',
    'net',
    'org',
    'mail',
    'email',
  };

  static const Set<String> _commonGermanAdjectives = {
    'gut',
    'schlecht',
    'gro',
    'klein',
    'neu',
    'alt',
    'jung',
    'lang',
    'kurz',
    'schnell',
    'langsam',
    'leicht',
    'schwer',
    'wichtig',
    'einfach',
    'schon',
    'teuer',
    'billig',
    'stark',
    'schwach',
  };

  static const List<String> _germanAdjectiveSuffixes = [
    'ig',
    'lich',
    'isch',
    'bar',
    'sam',
    'haft',
    'los',
    'voll',
    'arm',
    'end',
  ];

  /// Cleans common OCR artifacts before tokenization.
  static String normalizeOcrText(String text) {
    if (text.trim().isEmpty) return '';

    return text
        // Join words split by line-break hyphenation: "Wor-\nter" -> "Worter"
        .replaceAll(RegExp(r'-\s*\n\s*'), '')
        // Normalize newlines/tabs to spaces.
        .replaceAll(RegExp(r'[\n\r\t]+'), ' ')
        // Normalize smart quotes and long dashes.
        .replaceAll('“', '"')
        .replaceAll('”', '"')
        .replaceAll('„', '"')
        .replaceAll('’', "'")
        .replaceAll('–', '-')
        .replaceAll('—', '-')
        // Remove odd OCR separators that create noisy tokens.
        .replaceAll(RegExp(r'[|¦•·]'), ' ')
        // Collapse repeated spaces.
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

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

  /// OCR-focused tokenization with stronger filtering for non-vocabulary noise.
  ///
  /// Intended for photo-to-text flows where OCR often extracts emails,
  /// numbers, links, and adjective fragments that are usually not desired as
  /// standalone flashcards.
  static List<String> tokenizeForOcrVocabulary(String text) {
    final tokens = tokenize(text);
    return tokens.where(_isLikelyVocabularyWord).toList();
  }

  static bool _isLikelyVocabularyWord(String token) {
    final t = token.trim();
    if (t.isEmpty) return false;

    final lower = t.toLowerCase();
    if (_noiseWords.contains(lower)) return false;
    if (t.length < 2 || t.length > 30) return false;
    if (_hasDigitRegex.hasMatch(t)) return false;
    if (t.contains('@') || _emailRegex.hasMatch(t)) return false;
    if (lower.contains('://') || _urlRegex.hasMatch(lower)) return false;
    if (_domainLikeRegex.hasMatch(t)) return false;

    // Strip known umlaut variants to catch words like "groß" in list checks.
    final loweredAscii = lower
        .replaceAll('ß', 'ss')
        .replaceAll('ä', 'a')
        .replaceAll('ö', 'o')
        .replaceAll('ü', 'u');

    if (_commonGermanAdjectives.contains(loweredAscii)) return false;

    // Heuristic: lowercase words with typical adjective suffixes are likely
    // descriptors (e.g., "wichtig", "freundlich") and can be skipped.
    final startsUppercase = t[0] != t[0].toLowerCase();
    if (!startsUppercase && loweredAscii.length >= 5) {
      for (final suffix in _germanAdjectiveSuffixes) {
        if (loweredAscii.endsWith(suffix)) return false;
      }
    }

    return true;
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
