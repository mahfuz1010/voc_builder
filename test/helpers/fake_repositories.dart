import 'dart:async';

import 'package:vocbuilder/core/enums/review_rating.dart';
import 'package:vocbuilder/domain/entities/deck.dart';
import 'package:vocbuilder/domain/entities/flashcard.dart';
import 'package:vocbuilder/domain/repositories/card_repository.dart';
import 'package:vocbuilder/domain/repositories/deck_repository.dart';

class FakeCardRepository implements CardRepository {
  final Map<String, Flashcard> _cardsById = {};
  String? lastSubmitReviewCardId;
  ReviewRating? lastSubmitReviewRating;

  void seed(List<Flashcard> cards) {
    for (final card in cards) {
      _cardsById[card.id] = card;
    }
  }

  @override
  Future<void> add(Flashcard card) async {
    _cardsById[card.id] = card;
  }

  @override
  Future<void> addAll(List<Flashcard> cards) async {
    for (final card in cards) {
      _cardsById[card.id] = card;
    }
  }

  @override
  Future<void> delete(String id) async {
    _cardsById.remove(id);
  }

  @override
  Future<Flashcard?> getById(String id) async => _cardsById[id];

  @override
  Future<List<Flashcard>> getByDeck(String deckId) async {
    return _cardsById.values.where((c) => c.deckId == deckId).toList();
  }

  @override
  Future<Map<String, int>> getDashboardStats() async => {
        'due': 0,
        'new': 0,
        'shortTerm': 0,
        'longTerm': 0,
      };

  @override
  Future<Map<String, int>> getDashboardStatsByLanguage(String languageCode) async => {
        'due': 0,
        'new': 0,
        'shortTerm': 0,
        'longTerm': 0,
      };

  @override
  Future<List<Flashcard>> getDueCards({String? deckId}) async {
    final cards = _cardsById.values.where((c) => c.isDue);
    if (deckId == null) return cards.toList();
    return cards.where((c) => c.deckId == deckId).toList();
  }

  @override
  Future<List<Flashcard>> getDueCardsByLanguage(String languageCode) async {
    return getDueCards();
  }

  @override
  Future<Map<String, int>> getStatsByDeck(String deckId) async {
    final cards = await getByDeck(deckId);
    return {
      'total': cards.length,
      'due': cards.where((c) => c.isDue).length,
    };
  }

  @override
  Future<int> getTotalDue() async => (await getDueCards()).length;

  @override
  Future<void> moveToDeck(String cardId, String deckId) async {
    final card = _cardsById[cardId];
    if (card == null) return;
    _cardsById[cardId] = card.copyWith(deckId: deckId);
  }

  @override
  Future<int> resetShortTermCards() async => 0;

  @override
  Future<void> submitReview(String cardId, ReviewRating rating) async {
    lastSubmitReviewCardId = cardId;
    lastSubmitReviewRating = rating;
  }

  @override
  Future<void> update(Flashcard card) async {
    _cardsById[card.id] = card;
  }

  @override
  Stream<List<Flashcard>> watchByDeck(String deckId) async* {
    yield await getByDeck(deckId);
  }

  @override
  Stream<List<Flashcard>> watchDue({String? deckId}) async* {
    yield await getDueCards(deckId: deckId);
  }

  @override
  Stream<List<Flashcard>> watchDueByLanguage(String languageCode) async* {
    yield await getDueCards();
  }
}

class FakeDeckRepository implements DeckRepository {
  final Map<String, Deck> _decksById = {};

  void seed(List<Deck> decks) {
    for (final deck in decks) {
      _decksById[deck.id] = deck;
    }
  }

  @override
  Future<String> create(String name, {String languageCode = 'de'}) async {
    final id = 'deck-${_decksById.length + 1}';
    _decksById[id] = Deck(
      id: id,
      name: name,
      languageCode: languageCode,
      createdAt: DateTime.now(),
    );
    return id;
  }

  @override
  Future<void> delete(String id) async {
    _decksById.remove(id);
  }

  @override
  Future<List<Deck>> getAll() async => _decksById.values.toList();

  @override
  Future<List<Deck>> getByLanguage(String languageCode) async {
    return _decksById.values.where((d) => d.languageCode == languageCode).toList();
  }

  @override
  Future<Deck> getById(String id) async {
    final deck = _decksById[id];
    if (deck == null) throw Exception('Deck not found: $id');
    return deck;
  }

  @override
  Future<void> rename(String id, String newName) async {
    final deck = _decksById[id];
    if (deck == null) return;
    _decksById[id] = deck.copyWith(name: newName);
  }

  @override
  Stream<List<Deck>> watchAll() async* {
    yield _decksById.values.toList();
  }

  @override
  Stream<List<Deck>> watchByLanguage(String languageCode) async* {
    yield await getByLanguage(languageCode);
  }
}
