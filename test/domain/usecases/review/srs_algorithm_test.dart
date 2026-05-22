import 'package:flutter_test/flutter_test.dart';
import 'package:vocbuilder/core/enums/memory_stage.dart';
import 'package:vocbuilder/core/enums/review_rating.dart';
import 'package:vocbuilder/domain/entities/flashcard.dart';
import 'package:vocbuilder/domain/usecases/review/srs_algorithm.dart';

Flashcard _baseCard({
  MemoryStage stage = MemoryStage.newCard,
  int reps = 0,
  double ease = 2.5,
}) {
  return Flashcard(
    id: 'c1',
    deckId: 'd1',
    german: 'Haus',
    english: 'house',
    memoryStage: stage,
    repetitions: reps,
    easeFactor: ease,
    nextReview: DateTime.now(),
    createdAt: DateTime.now(),
  );
}

void main() {
  group('SrsAlgorithm.applyReview', () {
    test('again resets repetitions and keeps ease clamped', () {
      final card = _baseCard(stage: MemoryStage.longTerm, reps: 7, ease: 1.35);
      final before = DateTime.now();
      final updated = SrsAlgorithm.applyReview(card, ReviewRating.again);

      expect(updated.repetitions, 0);
      expect(updated.easeFactor, closeTo(1.3, 0.0001));
      expect(updated.memoryStage, MemoryStage.shortTerm);
      final diff = updated.nextReview.difference(before);
      expect(diff.inMinutes, inInclusiveRange(9, 11));
      expect(updated.intervalDays, 0);
    });

    test('hard on new card moves to short-term with first short step', () {
      final card = _baseCard(stage: MemoryStage.newCard, reps: 0, ease: 2.5);
      final before = DateTime.now();
      final updated = SrsAlgorithm.applyReview(card, ReviewRating.hard);

      expect(updated.memoryStage, MemoryStage.shortTerm);
      expect(updated.repetitions, 1);
      expect(updated.easeFactor, closeTo(2.35, 0.0001));
      final diff = updated.nextReview.difference(before);
      expect(diff.inMinutes, inInclusiveRange(9, 11));
    });

    test('good after final short-term step graduates to long-term', () {
      final card = _baseCard(stage: MemoryStage.shortTerm, reps: 2);
      final before = DateTime.now();
      final updated = SrsAlgorithm.applyReview(card, ReviewRating.good);

      expect(updated.repetitions, 3);
      expect(updated.memoryStage, MemoryStage.longTerm);
      expect(updated.intervalDays, 3);
      final diff = updated.nextReview.difference(before);
      expect(diff.inDays, inInclusiveRange(2, 3));
    });

    test('easy boosts ease and uses long short-term interval for early reps', () {
      final card = _baseCard(stage: MemoryStage.newCard, reps: 0, ease: 2.5);
      final before = DateTime.now();
      final updated = SrsAlgorithm.applyReview(card, ReviewRating.easy);

      expect(updated.repetitions, 2);
      expect(updated.easeFactor, closeTo(2.65, 0.0001));
      expect(updated.memoryStage, MemoryStage.shortTerm);
      final diff = updated.nextReview.difference(before);
      expect(diff.inHours, inInclusiveRange(23, 25));
    });

    test('hard in long-term stays long-term and assigns day interval', () {
      final card = _baseCard(stage: MemoryStage.longTerm, reps: 6, ease: 2.4);
      final updated = SrsAlgorithm.applyReview(card, ReviewRating.hard);

      expect(updated.memoryStage, MemoryStage.longTerm);
      expect(updated.intervalDays, greaterThanOrEqualTo(1));
      expect(updated.intervalDays, lessThan(365));
    });
  });
}
