import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/auth_state.dart';
import '../models/user.dart';
import '../repository/auth_repository.dart';

part 'auth_provider.g.dart';

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() {
    _checkAuthStatus();
    return const AuthState.initial();
  }

  Future<void> _checkAuthStatus() async {
    final repository = ref.read(authRepositoryProvider);
    try {
      final user = await repository.getCurrentUser();
      if (user != null) {
        state = AuthState.authenticated(user: user);
      } else {
        state = const AuthState.unauthenticated();
      }
    } catch (e) {
      state = const AuthState.unauthenticated();
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = const AuthState.loading();

    final repository = ref.read(authRepositoryProvider);
    try {
      final user = await repository.login(email: email, password: password);
      state = AuthState.authenticated(user: user);
    } catch (e) {
      state = AuthState.error(message: e.toString());
    }
  }

  Future<void> register({
    required String email,
    required String password,
    String? name,
  }) async {
    state = const AuthState.loading();

    final repository = ref.read(authRepositoryProvider);
    try {
      final user = await repository.register(
        email: email,
        password: password,
        name: name,
      );
      state = AuthState.authenticated(user: user);
    } catch (e) {
      state = AuthState.error(message: e.toString());
    }
  }

  Future<void> logout() async {
    state = const AuthState.loading();

    final repository = ref.read(authRepositoryProvider);
    try {
      await repository.logout();
      state = const AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.error(message: e.toString());
    }
  }

  Future<void> resetPassword({required String email}) async {
    final repository = ref.read(authRepositoryProvider);
    await repository.resetPassword(email: email);
  }
}

@riverpod
User? currentUser(Ref ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.maybeWhen(authenticated: (user) => user, orElse: () => null);
}

@riverpod
bool isAuthenticated(Ref ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.maybeWhen(authenticated: (_) => true, orElse: () => false);
}
