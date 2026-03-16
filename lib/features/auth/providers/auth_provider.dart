import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../repositories/auth_repository.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/models/user_model.dart';

class AuthState {
  final String? token;
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({ this.token, this.user, this.isLoading = false, this.error });

  bool get isLoggedIn => token != null;
  String? get role => user?.role;
  bool get isVerified => user?.isVerified == true;
  bool get canSell => user?.isVerified == true; // Adjust logic if needed

  AuthState copyWith({
    String? token,
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      token: token ?? this.token,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final _storage = const FlutterSecureStorage();
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState()) {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      final userStr = await _storage.read(key: 'user_data');
      if (token != null && userStr != null) {
        final userData = json.decode(userStr);
        state = AuthState(
          token: token, 
          user: User.fromJson(userData)
        );
        // Important: Set the token in DioClient interceptor via the static method if needed, 
        // but DioClient usually reads it itself or we set it here.
        await DioClient.saveToken(token);
      }
    } catch (e) {
      debugPrint('Error loading from storage: $e');
    }
  }

  Future<void> register(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _repository.register(data);
      await _saveAuth(response.accessToken, response.user);
      state = AuthState(token: response.accessToken, user: response.user);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _repository.login(email, password);
      await _saveAuth(response.accessToken, response.user);
      state = AuthState(token: response.accessToken, user: response.user);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> verifyOtp(String otp) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _repository.verifyOtp(otp);
      await _saveAuth(response.accessToken, response.user);
      state = AuthState(token: response.accessToken, user: response.user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> resendOtp() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.resendOtp();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> changeEmail(String newEmail) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _repository.changeEmail(newEmail);
      await _saveAuth(response.accessToken, response.user);
      state = AuthState(token: response.accessToken, user: response.user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    await DioClient.clearToken();
    await _storage.delete(key: 'jwt_token');
    await _storage.delete(key: 'user_data');
    state = const AuthState();
  }

  Future<void> updateUser(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _repository.updateProfile(data);
      await _storage.write(key: 'user_data', value: json.encode(response.user.toJson()));
      state = state.copyWith(user: response.user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.forgotPassword(email);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> resetPassword(String email, String otp, String newPassword) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.resetPassword(email, otp, newPassword);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refreshProfile() async {
    try {
      final response = await _repository.getMe();
      await _storage.write(key: 'user_data', value: json.encode(response.user.toJson()));
      state = state.copyWith(user: response.user);
    } catch (e) {
      debugPrint('Failed to refresh profile: $e');
    }
  }

  Future<void> _saveAuth(String token, User? user) async {
    await DioClient.saveToken(token);
    await _storage.write(key: 'jwt_token', value: token);
    if (user != null) {
      await _storage.write(key: 'user_data', value: json.encode(user.toJson()));
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(DioClient.dio);
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});
