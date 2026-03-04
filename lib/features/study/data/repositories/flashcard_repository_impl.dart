import 'package:isar/isar.dart';
import '../../../../core/services/local_db_service.dart';
import '../../domain/models/flashcard.dart';
import '../../domain/repositories/flashcard_repository.dart';

class FlashcardRepositoryImpl implements FlashcardRepository {
  final LocalDbService _dbService;

  FlashcardRepositoryImpl(this._dbService);

  Isar get _isar => _dbService.isar;

  @override
  Future<List<Flashcard>> getFlashcardsByDeck(int deckId) async {
    return _isar.flashcards
        .filter()
        .deckIdEqualTo(deckId)
        .and()
        .isDeletedEqualTo(false)
        .findAll();
  }

  @override
  Future<Flashcard?> getFlashcardById(int id) async {
    return _isar.flashcards.get(id);
  }

  @override
  Future<int> saveFlashcard(Flashcard flashcard) async {
    flashcard.updatedAt = DateTime.now();
    flashcard.needsSync = true;
    return _isar.writeTxn(() async {
      return _isar.flashcards.put(flashcard);
    });
  }

  @override
  Future<void> deleteFlashcard(int id) async {
    final flashcard = await getFlashcardById(id);
    if (flashcard != null) {
      flashcard.isDeleted = true;
      flashcard.needsSync = true;
      flashcard.updatedAt = DateTime.now();
      await _isar.writeTxn(() async {
        await _isar.flashcards.put(flashcard);
      });
    }
  }

  @override
  Future<List<Flashcard>> getStudySession(int deckId, {int limit = 20}) async {
    final now = DateTime.now();
    return _isar.flashcards
        .filter()
        .deckIdEqualTo(deckId)
        .and()
        .isDeletedEqualTo(false)
        .and()
        .dueDateLessThan(now)
        .sortByDueDate()
        .limit(limit)
        .findAll();
  }

  @override
  Future<List<Flashcard>> getUnsyncedFlashcards() async {
    return _isar.flashcards.filter().needsSyncEqualTo(true).findAll();
  }
}
