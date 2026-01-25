import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../models/user.dart';
import 'auth_repository.dart';

/// Supabase implementation of [AuthRepository].
class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._auth);

  final supabase.GoTrueClient _auth;

  @override
  Future<User> login({required String email, required String password}) async {
    try {
      final response = await _auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Login failed: No user returned');
      }

      return _mapSupabaseUser(response.user!);
    } on supabase.AuthException catch (e) {
      throw Exception('Login failed: ${e.message}');
    }
  }

  @override
  Future<User> register({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final response = await _auth.signUp(
        email: email,
        password: password,
        data: name != null ? {'name': name} : null,
      );

      if (response.user == null) {
        throw Exception('Registration failed: No user returned');
      }

      return _mapSupabaseUser(response.user!);
    } on supabase.AuthException catch (e) {
      throw Exception('Registration failed: ${e.message}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } on supabase.AuthException catch (e) {
      throw Exception('Logout failed: ${e.message}');
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    final supabaseUser = _auth.currentUser;
    if (supabaseUser == null) {
      return null;
    }
    return _mapSupabaseUser(supabaseUser);
  }

  @override
  Future<void> resetPassword({required String email}) async {
    try {
      await _auth.resetPasswordForEmail(email);
    } on supabase.AuthException catch (e) {
      throw Exception('Password reset failed: ${e.message}');
    }
  }

  /// Maps a Supabase user to our domain User model.
  User _mapSupabaseUser(supabase.User supabaseUser) {
    final metadata = supabaseUser.userMetadata ?? {};

    return User(
      id: supabaseUser.id,
      email: supabaseUser.email ?? '',
      name: metadata['name'] as String?,
      avatarUrl: metadata['avatar_url'] as String?,
      emailVerified: supabaseUser.emailConfirmedAt != null,
      createdAt: DateTime.tryParse(supabaseUser.createdAt),
    );
  }
}
