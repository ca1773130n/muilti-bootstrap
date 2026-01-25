import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:core/core.dart';

import '../models/auth_state.dart';
import '../models/user.dart';

part 'auth_state_stream.g.dart';

/// Provides a stream of auth state changes from Supabase.
/// This enables real-time auth state synchronization.
@riverpod
Stream<AuthState> authStateStream(Ref ref) {
  if (!Env.hasSupabaseConfig) {
    // Return a stream that just yields unauthenticated for mock mode
    return Stream.value(const AuthState.unauthenticated());
  }

  final auth = ref.watch(supabaseAuthProvider);

  return auth.onAuthStateChange.map((event) {
    final session = event.session;
    final user = session?.user;

    if (user != null) {
      return AuthState.authenticated(
        user: User(
          id: user.id,
          email: user.email ?? '',
          name: user.userMetadata?['name'] as String?,
          avatarUrl: user.userMetadata?['avatar_url'] as String?,
          emailVerified: user.emailConfirmedAt != null,
          createdAt: DateTime.tryParse(user.createdAt),
        ),
      );
    }

    return const AuthState.unauthenticated();
  });
}
