import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/enums/article.dart';
import '../../core/enums/memory_stage.dart';
import '../../core/enums/review_rating.dart';
import '../../core/enums/word_type.dart';
import '../../domain/entities/flashcard.dart';
import 'repository_providers.dart';

// ── Cards for a specific deck ─────────────────────────────────────────────────

final cardsForDeckProvider = StreamProvider.family<List<Flashcard>, String>(
  (ref, deckId) => ref.watch(cardRepositoryProvider).watchByDeck(deckId),
);

// ── Due cards ─────────────────────────────────────────────────────────────────

final dueCardsProvider = StreamProvider<List<Flashcard>>((ref) {
  return ref.watch(cardRepositoryProvider).watchDue();
});

final dueCardsByDeckProvider =
    StreamProvider.family<List<Flashcard>, String>((ref, deckId) {
  return ref.watch(cardRepositoryProvider).watchDue(deckId: deckId);
});

final cardsByStageProvider =
    FutureProvider.family<List<Flashcard>, MemoryStage>((ref, stage) async {
  final deckRepo = ref.read(deckRepositoryProvider);
  final cardRepo = ref.read(cardRepositoryProvider);
  final decks = await deckRepo.getAll();
  final grouped = await Future.wait(decks.map((d) => cardRepo.getByDeck(d.id)));
  final allCards = grouped.expand((cards) => cards);
  return allCards.where((c) => c.memoryStage == stage).toList();
});

// ── Dashboard stats ───────────────────────────────────────────────────────────

final dashboardStatsProvider = FutureProvider<Map<String, int>>((ref) {
  return ref.watch(cardRepositoryProvider).getDashboardStats();
});

// ── Card notifier ─────────────────────────────────────────────────────────────

class CardNotifier extends Notifier<void> {
  @override
  void build() {}

  void _invalidateStats() {
    ref.invalidate(dashboardStatsProvider);
    ref.invalidate(dueCardsProvider);
    ref.invalidate(cardsForDeckProvider);
    ref.invalidate(dueCardsByDeckProvider);
    ref.invalidate(cardsByStageProvider);
  }

  Future<void> addCard(Flashcard card) async {
    await ref.read(cardRepositoryProvider).add(card);
    _invalidateStats();
    ref.invalidate(cardsForDeckProvider(card.deckId));
    ref.invalidate(dueCardsByDeckProvider(card.deckId));
  }

  Future<void> updateCard(Flashcard card) async {
    await ref.read(cardRepositoryProvider).update(card);
    _invalidateStats();
    ref.invalidate(cardsForDeckProvider(card.deckId));
    ref.invalidate(dueCardsByDeckProvider(card.deckId));
  }

  Future<void> deleteCard(String id) async {
    final existing = await ref.read(cardRepositoryProvider).getById(id);
    await ref.read(cardRepositoryProvider).delete(id);
    _invalidateStats();
    if (existing != null) {
      ref.invalidate(cardsForDeckProvider(existing.deckId));
      ref.invalidate(dueCardsByDeckProvider(existing.deckId));
    }
  }

  Future<void> moveCard(String cardId, String deckId) async {
    final existing = await ref.read(cardRepositoryProvider).getById(cardId);
    await ref.read(cardRepositoryProvider).moveToDeck(cardId, deckId);
    _invalidateStats();
    ref.invalidate(cardsForDeckProvider(deckId));
    ref.invalidate(dueCardsByDeckProvider(deckId));
    if (existing != null) {
      ref.invalidate(cardsForDeckProvider(existing.deckId));
      ref.invalidate(dueCardsByDeckProvider(existing.deckId));
    }
  }

  Future<void> addAll(List<Flashcard> cards) async {
    await ref.read(cardRepositoryProvider).addAll(cards);
    _invalidateStats();
    final deckIds = cards.map((c) => c.deckId).toSet();
    for (final deckId in deckIds) {
      ref.invalidate(cardsForDeckProvider(deckId));
      ref.invalidate(dueCardsByDeckProvider(deckId));
    }
  }

  Future<int> resetShortTermCards() async {
    final updated = await ref.read(cardRepositoryProvider).resetShortTermCards();
    _invalidateStats();
    return updated;
  }
}

final cardNotifierProvider = NotifierProvider<CardNotifier, void>(CardNotifier.new);

// ── Review notifier ───────────────────────────────────────────────────────────

class ReviewNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> submitReview(String cardId, ReviewRating rating) async {
    final existing = await ref.read(cardRepositoryProvider).getById(cardId);
    await ref.read(cardRepositoryProvider).submitReview(cardId, rating);
    ref.invalidate(dashboardStatsProvider);
    ref.invalidate(dueCardsProvider);
    if (existing != null) {
      ref.invalidate(cardsForDeckProvider(existing.deckId));
      ref.invalidate(dueCardsByDeckProvider(existing.deckId));
    }
  }
}

final reviewNotifierProvider =
    NotifierProvider<ReviewNotifier, void>(ReviewNotifier.new);

// ── Helper: build a new Flashcard with defaults ───────────────────────────────

Flashcard buildNewCard({
  required String deckId,
  required String german,
  required String english,
  Article article = Article.none,
  String plural = '',
  WordType wordType = WordType.other,
  String exampleDe = '',
  String exampleEn = '',
  String verbIchForm = '',
  String partizipII = '',
  String comparative = '',
  String superlative = '',
  String notes = '',
  List<String> tags = const [],
}) {
  return Flashcard(
    id: const Uuid().v4(),
    deckId: deckId,
    german: german,
    english: english,
    article: article,
    plural: plural,
    wordType: wordType,
    exampleDe: exampleDe,
    exampleEn: exampleEn,
    verbIchForm: verbIchForm,
    partizipII: partizipII,
    comparative: comparative,
    superlative: superlative,
    notes: notes,
    tags: tags,
    memoryStage: MemoryStage.newCard,
    intervalDays: 0,
    easeFactor: 2.5,
    nextReview: DateTime.now(),
    repetitions: 0,
    createdAt: DateTime.now(),
  );
}
