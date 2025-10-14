import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_socket/core/services/api_service.dart';
import 'package:test_socket/core/services/token_service.dart';

class AuthRepository {
  final ApiService apiService;
  final TokenService tokenService;

  AuthRepository(this.apiService, this.tokenService);

  // Login Logic
  Future<void> login(String email, String password) async {
    log("Login called in auth repository");
    final response = await apiService.post('/auth/login', {
      'email': email,
      'password': password,
    });
    // Assuming the token is in response['token']
    final token = response['token'];
    if (token != null) {
      await tokenService.saveToken(token);
    } else {
      throw Exception('Token not found in response');
    }
  }

  // Signup Logic
  Future<void> signup({
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await apiService.post('/auth/signup', {
      'username': username,
      'email': email,
      'password': password,
    });
    final token = response['token'];
    if (token != null) {
      await tokenService.saveToken(token);
    } else {
      throw Exception('Token not found in response');
    }
  }

  // Logout
  Future<void> logout() async {
    await tokenService.deleteToken();
  }

  // Check Authentication Status
  Future<bool> isAuthenticated() async {
    final token = await tokenService.getToken();
    // In a real app, you might also want to verify the token with the backend here
    return token != null;
  }
}

// Provider for the AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ApiService(), TokenService());
});
