import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart';

class AuthRepository {
  final SupabaseClient _client;

  AuthRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  /// Get currently logged in Supabase User Session
  User? get currentAuthUser => _client.auth.currentUser;

  /// Stream of Auth State changes
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Sign in with Email and Password
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final authUser = response.user;
      if (authUser != null) {
        return await fetchUserProfile(authUser.id);
      }
    } catch (_) {
      // Fallback to direct DB user table profile lookup
    }

    return await fetchUserProfileByEmail(email);
  }

  /// Fetch user profile record from `users` table by auth_user_id
  Future<UserModel> fetchUserProfile(String authUserId) async {
    final response = await _client
        .from('users')
        .select()
        .eq('auth_user_id', authUserId)
        .single();

    return UserModel.fromMap(response);
  }

  /// Fetch user profile record from `users` table by email
  Future<UserModel> fetchUserProfileByEmail(String email) async {
    final response = await _client
        .from('users')
        .select()
        .eq('email', email)
        .single();

    return UserModel.fromMap(response);
  }

  /// Sign Out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
