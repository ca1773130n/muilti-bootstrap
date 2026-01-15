import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:core/core.dart';

import '../models/user.dart';

part 'auth_repository.g.dart';

abstract class AuthRepository {
  Future<User> login({required String email, required String password});
  Future<User> register({
    required String email,
    required String password,
    String? name,
  });
  Future<void> logout();
  Future<User?> getCurrentUser();
  Future<void> resetPassword({required String email});
}

@riverpod
AuthRepository authRepository(Ref ref) {
  if (Env.isDev) {
    return MockAuthRepository();
  }
  return ApiAuthRepository(ref);
}

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._ref);

  final Ref _ref;

  @override
  Future<User> login({required String email, required String password}) async {
    final dio = _ref.read(dioProvider);
    final response = await dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return User.fromJson(response.data['user']);
  }

  @override
  Future<User> register({
    required String email,
    required String password,
    String? name,
  }) async {
    final dio = _ref.read(dioProvider);
    final response = await dio.post('/auth/register', data: {
      'email': email,
      'password': password,
      if (name != null) 'name': name,
    });
    return User.fromJson(response.data['user']);
  }

  @override
  Future<void> logout() async {
    final dio = _ref.read(dioProvider);
    await dio.post('/auth/logout');
  }

  @override
  Future<User?> getCurrentUser() async {
    final dio = _ref.read(dioProvider);
    try {
      final response = await dio.get('/auth/me');
      return User.fromJson(response.data['user']);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> resetPassword({required String email}) async {
    final dio = _ref.read(dioProvider);
    await dio.post('/auth/reset-password', data: {'email': email});
  }
}

class MockAuthRepository implements AuthRepository {
  User? _currentUser;

  @override
  Future<User> login({required String email, required String password}) async {
    await Future.delayed(const Duration(seconds: 1));
    
    if (password.length < 6) {
      throw Exception('Invalid credentials');
    }

    _currentUser = User(
      id: 'mock-user-id',
      email: email,
      name: 'Mock User',
      emailVerified: true,
      createdAt: DateTime.now(),
    );
    return _currentUser!;
  }

  @override
  Future<User> register({
    required String email,
    required String password,
    String? name,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    _currentUser = User(
      id: 'mock-user-id',
      email: email,
      name: name ?? 'New User',
      emailVerified: false,
      createdAt: DateTime.now(),
    );
    return _currentUser!;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
  }

  @override
  Future<User?> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _currentUser;
  }

  @override
  Future<void> resetPassword({required String email}) async {
    await Future.delayed(const Duration(seconds: 1));
  }
}
