import '../entities/flashcard.dart';
import '../../core/enums/review_rating.dart';

abstract class CardRepository {
  Future<List<Flashcard>> getByDeck(String deckId);
  Future<List<Flashcard>> getDueCards({String? deckId});
  Future<Flashcard?> getById(String id);
  Future<void> add(Flashcard card);
  Future<void> update(Flashcard card);
  Future<void> delete(String id);
  Future<void> moveToDeck(String cardId, String deckId);
  Future<void> submitReview(String cardId, ReviewRating rating);
  Future<Map<String, int>> getStatsByDeck(String deckId);
  Stream<List<Flashcard>> watchByDeck(String deckId);
  Stream<List<Flashcard>> watchDue({String? deckId});
  Future<int> getTotalDue();
  Future<Map<String, int>> getDashboardStats();
  Future<void> addAll(List<Flashcard> cards);
  Future<int> resetShortTermCards();
}
