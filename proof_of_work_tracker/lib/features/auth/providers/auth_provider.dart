import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/user.dart';
import '../../../services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider =
    StateNotifierProvider<AuthStateNotifier, AsyncValue<UserModel?>>((ref) {
      return AuthStateNotifier(ref.read(authServiceProvider));
    });

class AuthStateNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthService _authService;

  AuthStateNotifier(this._authService) : super(const AsyncData(null));

  Future<void> login(String username, String password) async {
    state = const AsyncLoading();
    try {
      await _authService.login(username, password);
      final user = await _authService.getMe();
      state = AsyncData(user);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> register(String username, String email, String password) async {
    state = const AsyncLoading();
    try {
      await _authService.register(username, email, password);
      final user = await _authService.getMe();
      state = AsyncData(user);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> checkAuth() async {
    final loggedIn = await _authService.isLoggedIn();
    if (loggedIn) {
      try {
        final user = await _authService.getMe();
        state = AsyncData(user);
      } catch (_) {
        state = const AsyncData(null);
      }
    } else {
      state = const AsyncData(null);
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = const AsyncData(null);
  }
}
