import 'package:drift/drift.dart';

import '../../core/enums/article.dart';
import '../../core/enums/memory_stage.dart';
import '../../core/enums/review_rating.dart';
import '../../core/enums/word_type.dart';
import '../../domain/entities/flashcard.dart';
import '../../domain/repositories/card_repository.dart';
import '../../domain/usecases/review/srs_algorithm.dart';
import '../database/app_database.dart';

class CardRepositoryImpl implements CardRepository {
  final AppDatabase _db;
  const CardRepositoryImpl(this._db);

  // ── Mapping ──────────────────────────────────────────────────────────────────

  static Flashcard _fromRow(dynamic row) {
    return Flashcard(
      id: row.id as String,
      deckId: row.deckId as String,
      german: row.german as String,
      english: row.english as String,
      article: Article.values[(row.article as int).clamp(0, 3)],
      plural: row.plural as String? ?? '',
      wordType: WordType.values[(row.wordType as int).clamp(0, WordType.values.length - 1)],
      exampleDe: row.exampleDe as String? ?? '',
      exampleEn: row.exampleEn as String? ?? '',
      verbIchForm: row.verbIchForm as String? ?? '',
      partizipII: row.partizipII as String? ?? '',
      comparative: row.comparative as String? ?? '',
      superlative: row.superlative as String? ?? '',
      notes: row.notes as String? ?? '',
      tags: (row.tags as String? ?? '').isEmpty
          ? []
          : (row.tags as String).split(',').map((t) => t.trim()).toList(),
      memoryStage: MemoryStage.fromDbValue(row.memoryStage as int),
      intervalDays: row.intervalDays as int? ?? 0,
      easeFactor: (row.easeFactor as num?)?.toDouble() ?? 2.5,
      nextReview: DateTime.fromMillisecondsSinceEpoch(row.nextReview as int),
      repetitions: row.repetitions as int? ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt as int),
    );
  }

  static CardsCompanion _toCompanion(Flashcard card) {
    return CardsCompanion(
      id: Value(card.id),
      deckId: Value(card.deckId),
      german: Value(card.german),
      english: Value(card.english),
      article: Value(card.article.index),
      plural: Value(card.plural),
      wordType: Value(card.wordType.index),
      exampleDe: Value(card.exampleDe),
      exampleEn: Value(card.exampleEn),
      verbIchForm: Value(card.verbIchForm),
      partizipII: Value(card.partizipII),
      comparative: Value(card.comparative),
      superlative: Value(card.superlative),
      notes: Value(card.notes),
      tags: Value(card.tags.join(',')),
      memoryStage: Value(card.memoryStage.dbValue),
      intervalDays: Value(card.intervalDays),
      easeFactor: Value(card.easeFactor),
      nextReview: Value(card.nextReview.millisecondsSinceEpoch),
      repetitions: Value(card.repetitions),
      createdAt: Value(card.createdAt.millisecondsSinceEpoch),
    );
  }

  // ── Repository ───────────────────────────────────────────────────────────────

  @override
  Future<List<Flashcard>> getByDeck(String deckId) async {
    final rows = await _db.cardDao.getCardsByDeck(deckId);
    return rows.map(_fromRow).toList();
  }

  @override
  Stream<List<Flashcard>> watchByDeck(String deckId) {
    return _db.cardDao.watchCardsByDeck(deckId).map((rows) => rows.map(_fromRow).toList());
  }

  @override
  Future<List<Flashcard>> getDueCards({String? deckId}) async {
    final rows = await _db.cardDao.getDueCards(deckId: deckId);
    return rows.map(_fromRow).toList();
  }

  @override
  Stream<List<Flashcard>> watchDue({String? deckId}) {
    return _db.cardDao.watchDueCards(deckId: deckId).map((rows) => rows.map(_fromRow).toList());
  }

  @override
  Future<Flashcard?> getById(String id) async {
    final row = await _db.cardDao.getCardById(id);
    return row == null ? null : _fromRow(row);
  }

  @override
  Future<void> add(Flashcard card) async {
    await _db.cardDao.insertCard(_toCompanion(card));
  }

  @override
  Future<void> addAll(List<Flashcard> cards) async {
    await _db.cardDao.insertAll(cards.map(_toCompanion).toList());
  }

  @override
  Future<void> update(Flashcard card) async {
    await _db.cardDao.updateCard(_toCompanion(card));
  }

  @override
  Future<void> delete(String id) async {
    await _db.cardDao.deleteCard(id);
  }

  @override
  Future<void> moveToDeck(String cardId, String deckId) async {
    final card = await getById(cardId);
    if (card == null) return;
    await update(card.copyWith(deckId: deckId));
  }

  @override
  Future<void> submitReview(String cardId, ReviewRating rating) async {
    final card = await getById(cardId);
    if (card == null) return;
    final updated = SrsAlgorithm.applyReview(card, rating);
    await update(updated);
  }

  @override
  Future<Map<String, int>> getStatsByDeck(String deckId) async {
    return {
      'total': await _db.cardDao.countByDeck(deckId),
      'due': await _db.cardDao.countDueByDeck(deckId),
    };
  }

  @override
  Future<int> getTotalDue() => _db.cardDao.countTotalDue();

  @override
  Future<Map<String, int>> getDashboardStats() async {
    return {
      'due': await _db.cardDao.countTotalDue(),
      'new': await _db.cardDao.countByStage(0),
      'shortTerm': await _db.cardDao.countByStage(1),
      'longTerm': await _db.cardDao.countByStage(2),
    };
  }

  @override
  Future<int> resetShortTermCards() {
    return _db.cardDao.resetShortTermCards();
  }
}
