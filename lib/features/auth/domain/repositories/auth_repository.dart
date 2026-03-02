import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

abstract class AuthRepository {
  Stream<supabase.AuthState> get authStateChanges;
  supabase.User? get currentUser;
  Future<void> signInWithEmail(String email, String password);
  Future<void> signUpWithEmail(String email, String password);
  Future<void> signOut();
}
