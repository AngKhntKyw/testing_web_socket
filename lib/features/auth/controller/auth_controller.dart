import 'dart:async';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_socket/features/auth/repository/auth_repository.dart';

// The AuthController using AsyncNotifier
class AuthController extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    // This is called when the provider is first initialized.
    // We check if the user is already authenticated.
    return ref.read(authRepositoryProvider).isAuthenticated();
  }

  // Login method
  Future<void> login(String email, String password) async {
    log("Login called in auth controller");
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).login(email, password);
      return true; // Return true on successful login
    });
  }

  // Signup method
  Future<void> signup({
    required String username,
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(authRepositoryProvider)
          .signup(username: username, email: email, password: password);
      return true;
    });
  }

  // Logout method
  Future<void> logout() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).logout();
      return false; // Return false on successful logout
    });
  }
}

// The provider for our AuthController
final authControllerProvider = AsyncNotifierProvider<AuthController, bool>(() {
  return AuthController();
});
