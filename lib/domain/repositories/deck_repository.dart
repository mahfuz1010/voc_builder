import '../entities/deck.dart';

abstract class DeckRepository {
  Future<List<Deck>> getAll();
  Future<Deck> getById(String id);
  Future<String> create(String name);
  Future<void> rename(String id, String newName);
  Future<void> delete(String id);
  Stream<List<Deck>> watchAll();
}
