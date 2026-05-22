import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocbuilder/core/enums/article.dart';
import 'package:vocbuilder/core/enums/review_rating.dart';
import 'package:vocbuilder/core/enums/word_type.dart';
import 'package:vocbuilder/domain/entities/flashcard.dart';
import 'package:vocbuilder/presentation/providers/card_provider.dart';
import 'package:vocbuilder/presentation/providers/repository_providers.dart';

import '../../helpers/fake_repositories.dart';

void main() {
  group('buildNewCard', () {
    test('creates a card with expected defaults', () {
      final card = buildNewCard(
        deckId: 'deck-1',
        german: 'Haus',
        english: 'house',
      );

      expect(card.deckId, 'deck-1');
      expect(card.german, 'Haus');
      expect(card.english, 'house');
      expect(card.article, Article.none);
      expect(card.wordType, WordType.other);
      expect(card.repetitions, 0);
      expect(card.intervalDays, 0);
    });

    test('applies optional grammar fields', () {
      final card = buildNewCard(
        deckId: 'deck-1',
        german: 'sehen',
        english: 'see',
        verbIchForm: 'ich sehe',
        partizipII: 'gesehen',
      );

      expect(card.verbIchForm, 'ich sehe');
      expect(card.partizipII, 'gesehen');
    });
  });

  group('ReviewNotifier', () {
    test('delegates submitReview to repository', () async {
      final fakeRepo = FakeCardRepository();
      final card = Flashcard(
        id: 'c-1',
        deckId: 'd-1',
        german: 'Hund',
        english: 'dog',
        nextReview: DateTime.now(),
        createdAt: DateTime.now(),
      );
      fakeRepo.seed([card]);

      final container = ProviderContainer(
        overrides: [
          cardRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(reviewNotifierProvider.notifier)
          .submitReview('c-1', ReviewRating.good);

      expect(fakeRepo.lastSubmitReviewCardId, 'c-1');
      expect(fakeRepo.lastSubmitReviewRating, ReviewRating.good);
    });
  });
}
