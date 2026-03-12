import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

class AuthState {
  final String? token;
  final Map<String, dynamic>? user;
  final bool isLoading;
  final String? error;

  const AuthState({ this.token, this.user, this.isLoading = false, this.error });

  bool get isLoggedIn => token != null;
  String? get role => user?['role'];
  bool get isVerified => user?['isVerified'] == true;
  bool get canSell => user?['canSell'] == true;
}

class AuthNotifier extends StateNotifier<AuthState> {
  final _storage = const FlutterSecureStorage();

  AuthNotifier() : super(const AuthState()) {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final token = await _storage.read(key: 'jwt_token');
    final userStr = await _storage.read(key: 'user_data');
    if (token != null && userStr != null) {
      state = AuthState(token: token, user: json.decode(userStr));
    }
  }

  Future<void> register(Map<String, dynamic> data) async {
    state = const AuthState(isLoading: true);
    try {
      final res = await DioClient.dio.post('/auth/register', data: data);
      await _saveAuth(res.data['access_token'], res.data['user']);
      state = AuthState(token: res.data['access_token'], user: res.data['user']);
    } on DioException catch (e) {
      state = AuthState(error: e.response?.data['message'] ?? 'Erreur d\'inscription');
    }
  }

  Future<void> login(String email, String password) async {
    state = const AuthState(isLoading: true);
    try {
      final res = await DioClient.dio.post('/auth/login', data: { 'email': email, 'password': password });
      await _saveAuth(res.data['access_token'], res.data['user']);
      state = AuthState(token: res.data['access_token'], user: res.data['user']);
    } on DioException catch (e) {
      state = AuthState(error: e.response?.data['message'] ?? 'Email ou mot de passe incorrect');
    }
  }

  Future<void> verifyOtp(String otp) async {
    try {
      final res = await DioClient.dio.post('/auth/verify-otp', data: { 'otp': otp });
      await _saveAuth(res.data['token'], res.data['user']);
      state = AuthState(token: res.data['token'], user: res.data['user']);
    } on DioException catch (e) {
      state = state.copyWith(error: e.response?.data['message']);
    }
  }

  Future<void> logout() async {
    await DioClient.clearToken();
    await _storage.delete(key: 'user_data');
    state = const AuthState();
  }

  Future<void> _saveAuth(String token, Map<String, dynamic> user) async {
    await DioClient.saveToken(token);
    await _storage.write(key: 'user_data', value: json.encode(user));
  }
}

extension on AuthState {
  AuthState copyWith({ String? error }) => AuthState(
    token: token, user: user, isLoading: false, error: error ?? this.error
  );
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier());
