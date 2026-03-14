import 'dart:async';

import 'package:tripsync/features/auth/domain/app_user.dart';

class AuthRepository {
  const AuthRepository();

  static const _accounts = <String, Map<String, String>>{
    'demo@tripsync.app': {
      'password': '123456',
      'name': 'Demo Traveler',
      'avatar': '🧳',
    },
    'jyoti@tripsync.app': {
      'password': 'tripsync',
      'name': 'Gleb Garbuz',
      'avatar': '✈️',
    },
  };

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));

    final normalizedEmail = email.trim().toLowerCase();
    final account = _accounts[normalizedEmail];

    if (account == null) {
      throw Exception('Пользователь с таким email не найден');
    }

    if (account['password'] != password.trim()) {
      throw Exception('Неверный пароль');
    }

    return AppUser(
      id: normalizedEmail,
      name: account['name']!,
      email: normalizedEmail,
      avatar: account['avatar']!,
    );
  }

  Future<void> logout() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }
}
