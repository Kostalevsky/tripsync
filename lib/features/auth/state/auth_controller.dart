import 'package:flutter_riverpod/flutter_riverpod.dart';

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(),
);

class AuthState {
  const AuthState({this.user, this.isLoading = false, this.errorMessage});

  final AuthUser? user;
  final bool isLoading;
  final String? errorMessage;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    AuthUser? user,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.avatar,
  });

  final String id;
  final String name;
  final String email;
  final String avatar;
}

class AuthController extends StateNotifier<AuthState> {
  AuthController() : super(const AuthState());

  static const _demoEmail = 'demo@tripsync.app';
  static const _demoPassword = '123456';

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    await Future.delayed(const Duration(milliseconds: 500));

    if (email.trim().toLowerCase() == _demoEmail && password == _demoPassword) {
      state = AuthState(
        user: const AuthUser(
          id: '1',
          name: 'Demo User',
          email: _demoEmail,
          avatar: '🧑🏽‍💻',
        ),
        isLoading: false,
      );
      return true;
    }

    state = state.copyWith(
      isLoading: false,
      errorMessage: 'Неверный email или пароль',
    );
    return false;
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    await Future.delayed(const Duration(milliseconds: 600));

    state = AuthState(
      user: AuthUser(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name.trim(),
        email: email.trim(),
        avatar: '🧑‍💻',
      ),
      isLoading: false,
    );

    return true;
  }

  Future<void> logout() async {
    state = const AuthState();
  }
}
