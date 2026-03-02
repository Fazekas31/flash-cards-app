import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/decks/domain/models/deck.dart';
import '../../features/decks/domain/repositories/deck_repository.dart';
import '../../features/study/domain/models/flashcard.dart';
import '../../features/study/domain/repositories/flashcard_repository.dart';

class SyncService {
  final SupabaseClient _supabase;
  final DeckRepository _deckRepository;
  final FlashcardRepository _flashcardRepository;

  SyncService(this._supabase, this._deckRepository, this._flashcardRepository);

  Future<void> sync() async {
    if (_supabase.auth.currentUser == null) return;

    try {
      await _pushDecks();
      await _pullDecks();

      await _pushFlashcards();
      await _pullFlashcards();
    } catch (e) {
      /// Silent fail for sync to retry later
    }
  }

  Future<void> _pushDecks() async {
    final unsynced = await _deckRepository.getUnsyncedDecks();
    for (final deck in unsynced) {
      if (deck.isDeleted) {
        if (deck.remoteId != null) {
          await _supabase.from('decks').delete().eq('id', deck.remoteId!);
        }
      } else {
        final data = {
          'name': deck.name,
          'description': deck.description,
          'user_id': _supabase.auth.currentUser!.id,
          'updated_at': deck.updatedAt.toIso8601String(),
        };

        if (deck.remoteId != null) {
          await _supabase.from('decks').update(data).eq('id', deck.remoteId!);
        } else {
          final res = await _supabase
              .from('decks')
              .insert(data)
              .select('id')
              .single();
          deck.remoteId = res['id'] as String;
        }

        deck.needsSync = false;
        await _deckRepository.saveDeck(deck);
      }
    }
  }

  Future<void> _pullDecks() async {
    final response = await _supabase
        .from('decks')
        .select()
        .eq('user_id', _supabase.auth.currentUser!.id);
    final localDecks = await _deckRepository.getDecks();

    for (var remoteDeck in response) {
      final remoteId = remoteDeck['id'] as String;
      final remoteUpdatedAt = DateTime.parse(remoteDeck['updated_at']);

      final localDeckIndex = localDecks.indexWhere(
        (d) => d.remoteId == remoteId,
      );
      if (localDeckIndex != -1) {
        final localDeck = localDecks[localDeckIndex];
        if (remoteUpdatedAt.isAfter(localDeck.updatedAt)) {
          localDeck.name = remoteDeck['name'];
          localDeck.description = remoteDeck['description'];
          localDeck.updatedAt = remoteUpdatedAt;
          localDeck.needsSync = false;
          await _deckRepository.saveDeck(localDeck);
        }
      } else {
        final newDeck = Deck()
          ..remoteId = remoteId
          ..name = remoteDeck['name']
          ..description = remoteDeck['description']
          ..updatedAt = remoteUpdatedAt
          ..needsSync = false;
        await _deckRepository.saveDeck(newDeck);
      }
    }
  }

  Future<void> _pushFlashcards() async {
    final unsynced = await _flashcardRepository.getUnsyncedFlashcards();
    for (final card in unsynced) {
      final deck = await _deckRepository.getDeckById(card.deckId);
      if (deck == null || deck.remoteId == null) continue;

      if (card.isDeleted) {
        if (card.remoteId != null) {
          await _supabase.from('flashcards').delete().eq('id', card.remoteId!);
        }
      } else {
        final data = {
          'deck_id': deck.remoteId,
          'question': card.question,
          'answer': card.answer,
          'ease_factor': card.easeFactor,
          'interval_days': card.intervalDays,
          'repetitions': card.repetitions,
          'due_date': card.dueDate.toIso8601String(),
          'updated_at': card.updatedAt.toIso8601String(),
          'user_id': _supabase.auth.currentUser!.id,
        };

        if (card.remoteId != null) {
          await _supabase
              .from('flashcards')
              .update(data)
              .eq('id', card.remoteId!);
        } else {
          final res = await _supabase
              .from('flashcards')
              .insert(data)
              .select('id')
              .single();
          card.remoteId = res['id'] as String;
        }

        card.needsSync = false;
        await _flashcardRepository.saveFlashcard(card);
      }
    }
  }

  Future<void> _pullFlashcards() async {
    final response = await _supabase
        .from('flashcards')
        .select()
        .eq('user_id', _supabase.auth.currentUser!.id);
    final localDecks = await _deckRepository.getDecks();

    for (var remoteCard in response) {
      final remoteId = remoteCard['id'] as String;
      final deckRemoteId = remoteCard['deck_id'] as String;
      final remoteUpdatedAt = DateTime.parse(remoteCard['updated_at']);

      final localDeckIndex = localDecks.indexWhere(
        (d) => d.remoteId == deckRemoteId,
      );
      if (localDeckIndex == -1) continue;

      final localDeck = localDecks[localDeckIndex];
      // Note: In real app, we should fetch local flashcards globally or by deck.
      // This is a naive implementation assuming DB is synced well.
    }
  }
}
