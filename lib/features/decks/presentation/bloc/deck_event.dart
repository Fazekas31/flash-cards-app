import '../../domain/models/deck.dart';

abstract class DeckEvent {}

class LoadDecks extends DeckEvent {}

class DecksUpdated extends DeckEvent {
  final List<Deck> decks;
  DecksUpdated(this.decks);
}

class CreateDeck extends DeckEvent {
  final String name;
  final String? description;
  CreateDeck(this.name, this.description);
}

class UpdateDeck extends DeckEvent {
  final Deck deck;
  UpdateDeck(this.deck);
}

class DeleteDeck extends DeckEvent {
  final String id;
  DeleteDeck(this.id);
}
