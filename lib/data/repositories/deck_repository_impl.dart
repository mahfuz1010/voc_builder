import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/deck.dart' as entity;
import '../../domain/repositories/deck_repository.dart';
import '../database/app_database.dart';

class DeckRepositoryImpl implements DeckRepository {
  final AppDatabase _db;
  const DeckRepositoryImpl(this._db);

  static entity.Deck _mapRow(Deck row) => entity.Deck(
        id: row.id,
        name: row.name,
        createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt),
      );

  @override
  Future<List<entity.Deck>> getAll() async {
    final rows = await _db.deckDao.getAllDecks();
    return rows.map(_mapRow).toList();
  }

  @override
  Stream<List<entity.Deck>> watchAll() {
    return _db.deckDao.watchAllDecks().map((rows) => rows.map(_mapRow).toList());
  }

  @override
  Future<entity.Deck> getById(String id) async {
    final row = await _db.deckDao.getDeckById(id);
    if (row == null) throw Exception('Deck not found: $id');
    return _mapRow(row);
  }

  @override
  Future<String> create(String name) async {
    final id = const Uuid().v4();
    await _db.deckDao.insertDeck(DecksCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));
    return id;
  }

  @override
  Future<void> rename(String id, String newName) async {
    final existing = await _db.deckDao.getDeckById(id);
    if (existing == null) return;
    await _db.deckDao.updateDeck(DecksCompanion(
      id: Value(id),
      name: Value(newName),
      createdAt: Value(existing.createdAt),
    ));
  }

  @override
  Future<void> delete(String id) async {
    await _db.cardDao.deleteCardsByDeck(id);
    await _db.deckDao.deleteDeck(id);
  }
}
