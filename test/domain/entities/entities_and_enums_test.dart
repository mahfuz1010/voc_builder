import 'package:flutter_test/flutter_test.dart';
import 'package:vocbuilder/core/constants/supported_languages.dart';
import 'package:vocbuilder/core/enums/article.dart';
import 'package:vocbuilder/core/enums/memory_stage.dart';
import 'package:vocbuilder/core/enums/review_rating.dart';
import 'package:vocbuilder/core/enums/word_type.dart';
import 'package:vocbuilder/domain/entities/flashcard.dart';
import 'package:vocbuilder/domain/entities/word_info.dart';

void main() {
  group('Enums', () {
    test('MemoryStage db mapping round-trips', () {
      for (final stage in MemoryStage.values) {
        expect(MemoryStage.fromDbValue(stage.dbValue), stage);
      }
      expect(MemoryStage.fromDbValue(999), MemoryStage.newCard);
    });

    test('enum labels are user-friendly', () {
      expect(ReviewRating.easy.label, 'Easy');
      expect(WordType.adjective.label, 'Adjective');
      expect(Article.none.displayLabel, '—');
      expect(Article.der.label, 'der');
    });
  });

  group('SupportedLanguage', () {
    test('resolves known codes and defaults unknown to first language', () {
      expect(SupportedLanguage.fromCode('de').name, 'German');
      expect(SupportedLanguage.fromCode('unknown').code, SupportedLanguage.all.first.code);
    });

    test('uses locale overrides for zh and pt', () {
      expect(SupportedLanguage.fromCode('zh').ttsLocale, 'zh-CN');
      expect(SupportedLanguage.fromCode('pt').ttsLocale, 'pt-BR');
    });
  });

  group('WordInfo', () {
    test('hasData reflects whether synonyms, antonyms, or definition exist', () {
      expect(const WordInfo().hasData, isFalse);
      expect(const WordInfo(synonyms: ['x']).hasData, isTrue);
      expect(const WordInfo(antonyms: ['x']).hasData, isTrue);
      expect(const WordInfo(definition: 'desc').hasData, isTrue);
    });

    test('copyWith updates selected fields', () {
      const info = WordInfo(definition: 'old');
      final updated = info.copyWith(definition: 'new', isFetched: true);

      expect(updated.definition, 'new');
      expect(updated.isFetched, isTrue);
    });
  });

  group('Flashcard', () {
    test('displayGerman prepends article when present', () {
      final card = Flashcard(
        id: '1',
        deckId: 'd1',
        german: 'Hund',
        english: 'dog',
        article: Article.der,
        nextReview: DateTime.now(),
        createdAt: DateTime.now(),
      );
      expect(card.displayGerman, 'der Hund');
    });

    test('isDue returns true for past review times', () {
      final dueCard = Flashcard(
        id: '2',
        deckId: 'd1',
        german: 'Katze',
        english: 'cat',
        nextReview: DateTime.now().subtract(const Duration(minutes: 1)),
        createdAt: DateTime.now(),
      );

      expect(dueCard.isDue, isTrue);
    });

    test('copyWith keeps unspecified values and applies changed ones', () {
      final card = Flashcard(
        id: '3',
        deckId: 'd1',
        german: 'Baum',
        english: 'tree',
        notes: 'old',
        nextReview: DateTime.now(),
        createdAt: DateTime.now(),
      );

      final updated = card.copyWith(notes: 'new', deckId: 'd2');
      expect(updated.notes, 'new');
      expect(updated.deckId, 'd2');
      expect(updated.german, 'Baum');
    });
  });
}
