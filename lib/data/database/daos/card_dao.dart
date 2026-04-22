import 'package:drift/drift.dart';
import '../app_database.dart';

part 'card_dao.g.dart';

@DriftAccessor(tables: [Cards])
class CardDao extends DatabaseAccessor<AppDatabase> with _$CardDaoMixin {
  CardDao(super.db);

  Future<List<Card>> getCardsByDeck(String deckId) =>
      (select(cards)..where((c) => c.deckId.equals(deckId))).get();

  Stream<List<Card>> watchCardsByDeck(String deckId) =>
      (select(cards)..where((c) => c.deckId.equals(deckId))).watch();

  Future<List<Card>> getDueCards({String? deckId}) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final query = select(cards)
      ..where((c) => c.nextReview.isSmallerOrEqualValue(now));
    if (deckId != null) {
      query.where((c) => c.deckId.equals(deckId));
    }
    return query.get();
  }

  Stream<List<Card>> watchDueCards({String? deckId}) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final query = select(cards)
      ..where((c) => c.nextReview.isSmallerOrEqualValue(now));
    if (deckId != null) {
      query.where((c) => c.deckId.equals(deckId));
    }
    return query.watch();
  }

  Future<Card?> getCardById(String id) =>
      (select(cards)..where((c) => c.id.equals(id))).getSingleOrNull();

  Future<int> insertCard(CardsCompanion card) => into(cards).insert(card);

  Future<bool> updateCard(CardsCompanion card) => update(cards).replace(card);

  Future<int> deleteCard(String id) =>
      (delete(cards)..where((c) => c.id.equals(id))).go();

  Future<int> deleteCardsByDeck(String deckId) =>
      (delete(cards)..where((c) => c.deckId.equals(deckId))).go();

  Future<int> countByDeck(String deckId) async {
    final count = countAll();
    final query = selectOnly(cards)
      ..addColumns([count])
      ..where(cards.deckId.equals(deckId));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  Future<int> countDueByDeck(String deckId) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final count = countAll();
    final query = selectOnly(cards)
      ..addColumns([count])
      ..where(cards.deckId.equals(deckId) &
          cards.nextReview.isSmallerOrEqualValue(now));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  Future<int> countByStage(int stage) async {
    final count = countAll();
    final query = selectOnly(cards)
      ..addColumns([count])
      ..where(cards.memoryStage.equals(stage));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  Future<int> countTotalDue() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final count = countAll();
    final query = selectOnly(cards)
      ..addColumns([count])
      ..where(cards.nextReview.isSmallerOrEqualValue(now));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  Future<int> resetShortTermCards() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return (update(cards)..where((c) => c.memoryStage.equals(1))).write(
      CardsCompanion(
        memoryStage: const Value(0),
        repetitions: const Value(0),
        intervalDays: const Value(0),
        nextReview: Value(now),
      ),
    );
  }

  Future<void> insertAll(List<CardsCompanion> rows) =>
      batch((b) => b.insertAll(cards, rows));
}
