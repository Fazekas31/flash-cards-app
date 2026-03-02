import '../../domain/models/deck.dart';

abstract class DeckState {}

class DeckInitial extends DeckState {}

class DeckLoading extends DeckState {}

class DeckLoaded extends DeckState {
  final List<Deck> decks;
  DeckLoaded(this.decks);
}

class DeckError extends DeckState {
  final String message;
  DeckError(this.message);
}
