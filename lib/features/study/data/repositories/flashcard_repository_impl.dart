import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/flashcard.dart';
import '../../domain/repositories/flashcard_repository.dart';

class FlashcardRepositoryImpl implements FlashcardRepository {
  final SupabaseClient _supabaseClient;

  FlashcardRepositoryImpl(this._supabaseClient);

  @override
  Future<List<Flashcard>> getFlashcardsByDeck(String deckId) async {
    final response = await _supabaseClient
        .from('flashcards')
        .select()
        .eq('deck_id', deckId)
        .eq('is_deleted', false);
    return (response as List).map((json) => Flashcard.fromJson(json)).toList();
  }

  @override
  Future<Flashcard?> getFlashcardById(String id) async {
    final response = await _supabaseClient
        .from('flashcards')
        .select()
        .eq('id', id)
        .maybeSingle();
    if (response == null) return null;
    return Flashcard.fromJson(response);
  }

  @override
  Future<void> saveFlashcard(Flashcard flashcard) async {
    flashcard.updatedAt = DateTime.now();
    await _supabaseClient.from('flashcards').upsert(flashcard.toJson());
  }

  @override
  Future<void> deleteFlashcard(String id) async {
    await _supabaseClient
        .from('flashcards')
        .update({
          'is_deleted': true,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id);
  }

  @override
  Future<List<Flashcard>> getStudySession(
    String deckId, {
    int limit = 20,
  }) async {
    final now = DateTime.now().toIso8601String();
    final response = await _supabaseClient
        .from('flashcards')
        .select()
        .eq('deck_id', deckId)
        .eq('is_deleted', false)
        .lte('due_date', now)
        .order('due_date', ascending: true)
        .limit(limit);
    return (response as List).map((json) => Flashcard.fromJson(json)).toList();
  }
}
