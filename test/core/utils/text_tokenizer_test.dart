import 'package:flutter_test/flutter_test.dart';
import 'package:vocbuilder/core/utils/text_tokenizer.dart';

void main() {
  group('TextTokenizer.normalizeOcrText', () {
    test('normalizes OCR artifacts and whitespace', () {
      const input = 'Wor-\n ter  “Hallo”  — test | item';
      final result = TextTokenizer.normalizeOcrText(input);

      expect(result, 'Worter "Hallo" - test item');
    });
  });

  group('TextTokenizer.tokenize', () {
    test('splits words, strips punctuation, deduplicates case-insensitively', () {
      const input = 'Haus, haus! Katze. Hund?';
      final tokens = TextTokenizer.tokenize(input);

      expect(tokens, ['Haus', 'Katze', 'Hund']);
    });

    test('returns empty for blank text', () {
      expect(TextTokenizer.tokenize('   \n\t  '), isEmpty);
    });
  });

  group('TextTokenizer.tokenizeForOcrVocabulary', () {
    test('filters urls, emails, numbers, and noise words', () {
      const input = 'kontakt@example.com www.site.com 2024 wichtig Baum';
      final tokens = TextTokenizer.tokenizeForOcrVocabulary(input);

      expect(tokens, ['Baum']);
    });
  });

  group('TextTokenizer.parseVocabLine', () {
    test('parses semicolon format', () {
      final result = TextTokenizer.parseVocabLine('Hund;dog');
      expect(result, {'german': 'Hund', 'english': 'dog'});
    });

    test('parses pipe format', () {
      final result = TextTokenizer.parseVocabLine('Katze | cat');
      expect(result, {'german': 'Katze', 'english': 'cat'});
    });

    test('returns null for unsupported format', () {
      expect(TextTokenizer.parseVocabLine('No separator here'), isNull);
    });
  });
}
