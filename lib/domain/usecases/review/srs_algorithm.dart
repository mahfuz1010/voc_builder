import '../../../core/enums/memory_stage.dart';
import '../../../core/enums/review_rating.dart';
import '../../entities/flashcard.dart';

/// SM-2 inspired spaced repetition algorithm with short-term/long-term stages.
class SrsAlgorithm {
  SrsAlgorithm._();

  static Flashcard applyReview(
    Flashcard card,
    ReviewRating rating, {
    List<int> shortTermMinutes = const [10, 60, 1440],
    List<int> longTermDays = const [3, 7, 14, 30, 90],
  }) {
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
        nextReview = now.add(Duration(minutes: shortTermMinutes.isNotEmpty ? shortTermMinutes[0] : 10));
        interval = 0;
        break;

      case ReviewRating.hard:
        ease = (ease - 0.15).clamp(1.3, 3.0);
        reps++;
        final result = _calcNext(stage, reps, ease, now, shortTermMinutes, longTermDays, isHard: true);
        nextReview = result.$1;
        interval = result.$2;
        stage = result.$3;
        break;

      case ReviewRating.good:
        reps++;
        final result = _calcNext(stage, reps, ease, now, shortTermMinutes, longTermDays);
        nextReview = result.$1;
        interval = result.$2;
        stage = result.$3;
        break;

      case ReviewRating.easy:
        ease = (ease + 0.15).clamp(1.3, 3.0);
        reps += 2;
        final result = _calcNext(stage, reps, ease, now, shortTermMinutes, longTermDays, isEasy: true);
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
    DateTime now,
    List<int> shortTermMinutes,
    List<int> longTermDays, {
    bool isHard = false,
    bool isEasy = false,
  }) {
    if (stage == MemoryStage.newCard || stage == MemoryStage.shortTerm) {
      // Short-term: minute-based intervals
      final index = (reps - 1).clamp(0, shortTermMinutes.length - 1);
      final minutes = isHard
          ? shortTermMinutes[0]
          : isEasy
              ? shortTermMinutes[(shortTermMinutes.length - 1)]
              : shortTermMinutes[index];

      final next = now.add(Duration(minutes: minutes));

      // Graduate to long-term after completing all short-term steps
      if (reps >= shortTermMinutes.length && !isHard) {
        return (now.add(const Duration(days: 3)), 3, MemoryStage.longTerm);
      }

      final nextStage =
          stage == MemoryStage.newCard && reps > 0 ? MemoryStage.shortTerm : stage;
      return (next, 0, nextStage);
    } else {
      // Long-term: day-based intervals using SM-2
      final longTermIndex = (reps - shortTermMinutes.length - 1)
          .clamp(0, longTermDays.length - 1);

      int days;
      if (reps <= shortTermMinutes.length) {
        days = longTermDays[0];
      } else {
        final baseIdx = longTermIndex.clamp(0, longTermDays.length - 1);
        days = isEasy
            ? (longTermDays[baseIdx] * 1.5).round()
            : isHard
                ? (longTermDays[baseIdx] * 0.8).clamp(1, 9999).round()
                : (longTermIndex < longTermDays.length
                    ? longTermDays[longTermIndex]
                    : (longTermDays.last * ease).round());
      }

      return (
        now.add(Duration(days: days)),
        days,
        MemoryStage.longTerm,
      );
    }
  }
}
