import '../models/flashcard.dart';

abstract class FlashcardRepository {
  Future<List<Flashcard>> getFlashcardsByDeck(int deckId);
  Future<Flashcard?> getFlashcardById(int id);
  Future<int> saveFlashcard(Flashcard flashcard);
  Future<void> deleteFlashcard(int id);
  Future<List<Flashcard>> getStudySession(int deckId, {int limit = 20});
  Future<List<Flashcard>> getUnsyncedFlashcards();
}
