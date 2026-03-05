import '../models/flashcard.dart';

abstract class FlashcardRepository {
  Future<List<Flashcard>> getFlashcardsByDeck(String deckId);
  Future<Flashcard?> getFlashcardById(String id);
  Future<void> saveFlashcard(Flashcard flashcard);
  Future<void> deleteFlashcard(String id);
  Future<List<Flashcard>> getStudySession(String deckId, {int limit = 20});
}
