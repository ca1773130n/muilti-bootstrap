import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import 'package:auth/auth.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<User?> getCurrentUser() async => null;

  @override
  Future<User> login({required String email, required String password}) {
    throw UnimplementedError();
  }

  @override
  Future<void> logout() async {}

  @override
  Future<User> register({
    required String email,
    required String password,
    String? name,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> resetPassword({required String email}) async {}
}

void main() {
  test('authNotifier starts in initial state', () {
    Env.initialize(
      flavorValue: 'dev',
      apiBaseUrlValue: 'https://example.com',
      appNameValue: 'TestApp',
      enableLoggingValue: 'false',
    );

    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
      ],
    );
    addTearDown(container.dispose);

    final state = container.read(authNotifierProvider);
    expect(state, isA<AuthInitial>());
  });
}
