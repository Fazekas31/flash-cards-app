import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/deck.dart';
import '../../domain/repositories/deck_repository.dart';

class DeckRepositoryImpl implements DeckRepository {
  final SupabaseClient _supabaseClient;

  DeckRepositoryImpl(this._supabaseClient);

  @override
  Future<List<Deck>> getDecks() async {
    final response = await _supabaseClient
        .from('decks')
        .select()
        .eq('is_deleted', false);
    return (response as List).map((json) => Deck.fromJson(json)).toList();
  }

  @override
  Future<Deck?> getDeckById(String id) async {
    final response = await _supabaseClient
        .from('decks')
        .select()
        .eq('id', id)
        .maybeSingle();
    if (response == null) return null;
    return Deck.fromJson(response);
  }

  @override
  Future<void> saveDeck(Deck deck) async {
    deck.updatedAt = DateTime.now();
    await _supabaseClient.from('decks').upsert(deck.toJson());
  }

  @override
  Future<void> deleteDeck(String id) async {
    await _supabaseClient
        .from('decks')
        .update({
          'is_deleted': true,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id);
  }

  @override
  Stream<List<Deck>> watchDecks() {
    return _supabaseClient
        .from('decks')
        .stream(primaryKey: ['id'])
        .eq('is_deleted', false)
        .map((data) => data.map((json) => Deck.fromJson(json)).toList());
  }
}
