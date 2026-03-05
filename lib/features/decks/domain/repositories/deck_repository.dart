import '../models/deck.dart';

abstract class DeckRepository {
  Future<List<Deck>> getDecks();
  Future<Deck?> getDeckById(String id);
  Future<void> saveDeck(Deck deck);
  Future<void> deleteDeck(String id);
  Stream<List<Deck>> watchDecks();
}
