import 'package:drift/drift.dart';
import '../app_database.dart';

part 'deck_dao.g.dart';

@DriftAccessor(tables: [Decks])
class DeckDao extends DatabaseAccessor<AppDatabase> with _$DeckDaoMixin {
  DeckDao(super.db);

  Future<List<Deck>> getAllDecks() => select(decks).get();

  Stream<List<Deck>> watchAllDecks() => select(decks).watch();

  Future<List<Deck>> getDecksByLanguage(String langCode) =>
      (select(decks)..where((d) => d.languageCode.equals(langCode))).get();

  Stream<List<Deck>> watchDecksByLanguage(String langCode) =>
      (select(decks)..where((d) => d.languageCode.equals(langCode))).watch();

  Future<Deck?> getDeckById(String id) =>
      (select(decks)..where((d) => d.id.equals(id))).getSingleOrNull();

  Future<int> insertDeck(DecksCompanion deck) => into(decks).insert(deck);

  Future<bool> updateDeck(DecksCompanion deck) => update(decks).replace(deck);

  Future<int> deleteDeck(String id) =>
      (delete(decks)..where((d) => d.id.equals(id))).go();
}
