import '../models/deck.dart';

abstract class DeckRepository {
  Future<List<Deck>> getDecks();
  Future<Deck?> getDeckById(int id);
  Future<int> saveDeck(Deck deck);
  Future<void> deleteDeck(int id);
  Future<List<Deck>> getUnsyncedDecks();
  Stream<List<Deck>> watchDecks();
}
