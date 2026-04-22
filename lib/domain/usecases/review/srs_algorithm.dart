import '../../../core/enums/memory_stage.dart';
import '../../../core/enums/review_rating.dart';
import '../../entities/flashcard.dart';

/// SM-2 inspired spaced repetition algorithm with short-term/long-term stages.
class SrsAlgorithm {
  SrsAlgorithm._();

  // Short-term intervals in minutes
  static const _shortTermMinutes = [10, 60, 1440]; // 10m, 1h, 1d

  // Long-term intervals in days
  static const _longTermDays = [3, 7, 14, 30, 90];

  static Flashcard applyReview(Flashcard card, ReviewRating rating) {
    final now = DateTime.now();
    double ease = card.easeFactor;
    int reps = card.repetitions;
    MemoryStage stage = card.memoryStage;
    DateTime nextReview;
    int interval = card.intervalDays;

    switch (rating) {
      case ReviewRating.again:
        // Reset to beginning of current stage
        reps = 0;
        ease = (ease - 0.2).clamp(1.3, 3.0);
        if (stage == MemoryStage.longTerm) {
          stage = MemoryStage.shortTerm;
        }
        nextReview = now.add(const Duration(minutes: 10));
        interval = 0;
        break;

      case ReviewRating.hard:
        ease = (ease - 0.15).clamp(1.3, 3.0);
        reps++;
        final result = _calcNext(stage, reps, ease, now, isHard: true);
        nextReview = result.$1;
        interval = result.$2;
        stage = result.$3;
        break;

      case ReviewRating.good:
        reps++;
        final result = _calcNext(stage, reps, ease, now);
        nextReview = result.$1;
        interval = result.$2;
        stage = result.$3;
        break;

      case ReviewRating.easy:
        ease = (ease + 0.15).clamp(1.3, 3.0);
        reps += 2;
        final result = _calcNext(stage, reps, ease, now, isEasy: true);
        nextReview = result.$1;
        interval = result.$2;
        stage = result.$3;
        break;
    }

    return card.copyWith(
      memoryStage: stage,
      easeFactor: ease,
      repetitions: reps,
      intervalDays: interval,
      nextReview: nextReview,
    );
  }

  static (DateTime, int, MemoryStage) _calcNext(
    MemoryStage stage,
    int reps,
    double ease,
    DateTime now, {
    bool isHard = false,
    bool isEasy = false,
  }) {
    if (stage == MemoryStage.newCard || stage == MemoryStage.shortTerm) {
      // Short-term: minute-based intervals
      final index = (reps - 1).clamp(0, _shortTermMinutes.length - 1);
      final minutes = isHard
          ? _shortTermMinutes[0]
          : isEasy
              ? _shortTermMinutes[(_shortTermMinutes.length - 1)]
              : _shortTermMinutes[index];

      final next = now.add(Duration(minutes: minutes));

      // Graduate to long-term after completing all short-term steps
      if (reps >= _shortTermMinutes.length && !isHard) {
        return (now.add(const Duration(days: 3)), 3, MemoryStage.longTerm);
      }

      final nextStage =
          stage == MemoryStage.newCard && reps > 0 ? MemoryStage.shortTerm : stage;
      return (next, 0, nextStage);
    } else {
      // Long-term: day-based intervals using SM-2
      final longTermIndex = (reps - _shortTermMinutes.length - 1)
          .clamp(0, _longTermDays.length - 1);

      int days;
      if (reps <= _shortTermMinutes.length) {
        days = _longTermDays[0];
      } else {
        final baseIdx = longTermIndex.clamp(0, _longTermDays.length - 1);
        days = isEasy
            ? (_longTermDays[baseIdx] * 1.5).round()
            : isHard
                ? (_longTermDays[baseIdx] * 0.8).clamp(1, 9999).round()
                : (longTermIndex < _longTermDays.length
                    ? _longTermDays[longTermIndex]
                    : (_longTermDays.last * ease).round());
      }

      return (
        now.add(Duration(days: days)),
        days,
        MemoryStage.longTerm,
      );
    }
  }
}
