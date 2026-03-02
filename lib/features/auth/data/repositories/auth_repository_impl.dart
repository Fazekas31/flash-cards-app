import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final supabase.SupabaseClient _supabaseClient;

  AuthRepositoryImpl(this._supabaseClient);

  @override
  Stream<supabase.AuthState> get authStateChanges =>
      _supabaseClient.auth.onAuthStateChange;

  @override
  supabase.User? get currentUser => _supabaseClient.auth.currentUser;

  @override
  Future<void> signInWithEmail(String email, String password) async {
    await _supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> signUpWithEmail(String email, String password) async {
    await _supabaseClient.auth.signUp(email: email, password: password);
  }

  @override
  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }
}
