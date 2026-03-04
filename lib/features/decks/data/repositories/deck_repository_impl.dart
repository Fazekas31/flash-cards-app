import 'package:isar/isar.dart';
import '../../../../core/services/local_db_service.dart';
import '../../domain/models/deck.dart';
import '../../domain/repositories/deck_repository.dart';

class DeckRepositoryImpl implements DeckRepository {
  final LocalDbService _dbService;

  DeckRepositoryImpl(this._dbService);

  Isar get _isar => _dbService.isar;

  @override
  Future<List<Deck>> getDecks() async {
    return _isar.decks.filter().isDeletedEqualTo(false).findAll();
  }

  @override
  Future<Deck?> getDeckById(int id) async {
    return _isar.decks.get(id);
  }

  @override
  Future<int> saveDeck(Deck deck) async {
    deck.updatedAt = DateTime.now();
    deck.needsSync = true;
    return _isar.writeTxn(() async {
      return _isar.decks.put(deck);
    });
  }

  @override
  Future<void> deleteDeck(int id) async {
    final deck = await getDeckById(id);
    if (deck != null) {
      deck.isDeleted = true;
      deck.needsSync = true;
      deck.updatedAt = DateTime.now();
      await _isar.writeTxn(() async {
        await _isar.decks.put(deck);
      });
    }
  }

  @override
  Future<List<Deck>> getUnsyncedDecks() async {
    return _isar.decks.filter().needsSyncEqualTo(true).findAll();
  }

  @override
  Stream<List<Deck>> watchDecks() {
    return _isar.decks
        .filter()
        .isDeletedEqualTo(false)
        .watch(fireImmediately: true);
  }
}
