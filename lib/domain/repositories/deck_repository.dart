import '../entities/deck.dart';

abstract class DeckRepository {
  Future<List<Deck>> getAll();
  Future<List<Deck>> getByLanguage(String languageCode);
  Future<Deck> getById(String id);
  Future<String> create(String name, {String languageCode = 'de'});
  Future<void> rename(String id, String newName);
  Future<void> delete(String id);
  Stream<List<Deck>> watchAll();
  Stream<List<Deck>> watchByLanguage(String languageCode);
}
