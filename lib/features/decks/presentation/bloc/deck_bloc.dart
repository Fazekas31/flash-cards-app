import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/deck_repository.dart';
import '../../domain/models/deck.dart';
import 'deck_event.dart';
import 'deck_state.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeckBloc extends Bloc<DeckEvent, DeckState> {
  final DeckRepository _repository;
  StreamSubscription? _decksSubscription;

  DeckBloc(this._repository) : super(DeckInitial()) {
    on<LoadDecks>(_onLoadDecks);
    on<DecksUpdated>(_onDecksUpdated);
    on<CreateDeck>(_onCreateDeck);
    on<UpdateDeck>(_onUpdateDeck);
    on<DeleteDeck>(_onDeleteDeck);
  }

  void _onLoadDecks(LoadDecks event, Emitter<DeckState> emit) {
    emit(DeckLoading());
    _decksSubscription?.cancel();
    _decksSubscription = _repository.watchDecks().listen(
      (decks) {
        add(DecksUpdated(decks));
      },
      onError: (error) {
        emit(DeckError(error.toString()));
      },
    );
  }

  void _onDecksUpdated(DecksUpdated event, Emitter<DeckState> emit) {
    emit(DeckLoaded(event.decks));
  }

  Future<void> _onCreateDeck(CreateDeck event, Emitter<DeckState> emit) async {
    final deck = Deck(
      id: const Uuid().v4(),
      name: event.name,
      description: event.description,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      userId: Supabase.instance.client.auth.currentUser?.id,
    );
    await _repository.saveDeck(deck);
  }

  Future<void> _onUpdateDeck(UpdateDeck event, Emitter<DeckState> emit) async {
    await _repository.saveDeck(event.deck);
  }

  Future<void> _onDeleteDeck(DeleteDeck event, Emitter<DeckState> emit) async {
    await _repository.deleteDeck(event.id);
  }

  @override
  Future<void> close() {
    _decksSubscription?.cancel();
    return super.close();
  }
}
