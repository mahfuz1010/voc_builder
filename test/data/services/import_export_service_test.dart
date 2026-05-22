import 'package:flutter_test/flutter_test.dart';
import 'package:vocbuilder/core/enums/article.dart';
import 'package:vocbuilder/core/enums/word_type.dart';
import 'package:vocbuilder/data/services/import_export_service.dart';
import 'package:vocbuilder/domain/entities/flashcard.dart';

Flashcard _card({
  required String id,
  required String german,
  required String english,
  Article article = Article.none,
  WordType type = WordType.other,
  String notes = '',
}) {
  return Flashcard(
    id: id,
    deckId: 'deck-1',
    german: german,
    english: english,
    article: article,
    wordType: type,
    notes: notes,
    nextReview: DateTime.now(),
    createdAt: DateTime.now(),
  );
}

void main() {
  group('ImportService.parseContent', () {
    test('parses CSV with header aliases and hint/date columns', () {
      const csv = 'front\tback\thint\tpublishedAt\nHaus\thouse\tbuilding\t2024-01-02T00:00:00Z';
      final cards = ImportService.parseContent(csv, 'csv', 'deck-1');

      expect(cards, hasLength(1));
      expect(cards.first.german, 'Haus');
      expect(cards.first.english, 'house');
      expect(cards.first.notes, 'building');
      expect(cards.first.createdAt.toUtc(), DateTime.parse('2024-01-02T00:00:00Z'));
    });

    test('parses plain CSV rows with article and plural', () {
      const csv = 'Hund;dog;der;Hunde';
      final cards = ImportService.parseContent(csv, 'csv', 'deck-2');

      expect(cards, hasLength(1));
      expect(cards.first.german, 'Hund');
      expect(cards.first.article, Article.der);
      expect(cards.first.plural, 'Hunde');
    });

    test('parses TXT line pairs with separators', () {
      const txt = 'Baum | tree\nKatze - cat\n';
      final cards = ImportService.parseContent(txt, 'txt', 'deck-1');

      expect(cards, hasLength(2));
      expect(cards.map((c) => c.german), ['Baum', 'Katze']);
    });

    test('parses JSON cards payload', () {
      const json = '{"cards":[{"german":"Hund","english":"dog","article":"der","type":"noun"}]}';
      final cards = ImportService.parseContent(json, 'json', 'deck-3');

      expect(cards, hasLength(1));
      expect(cards.first.article, Article.der);
      expect(cards.first.wordType, WordType.noun);
    });

    test('returns empty for invalid JSON', () {
      final cards = ImportService.parseContent('{oops', 'json', 'deck-3');
      expect(cards, isEmpty);
    });
  });

  group('ExportService', () {
    test('exports cards to JSON with cards wrapper', () {
      final payload = ExportService.toJson([
        _card(id: '1', german: 'Haus', english: 'house', article: Article.das),
      ]);

      expect(payload, contains('"cards"'));
      expect(payload, contains('"german": "Haus"'));
      expect(payload, contains('"article": "das"'));
    });

    test('exports cards to CSV and escapes semicolons', () {
      final csv = ExportService.toCsv([
        _card(
          id: '2',
          german: 'rot;blau',
          english: 'red;blue',
          notes: 'a;b',
        ),
      ]);

      expect(csv, startsWith('german;english;article;plural;type;example_de;example_en;notes'));
      expect(csv, contains('rot,blau;red,blue;none;;other'));
      expect(csv, contains('a,b'));
    });
  });
}
