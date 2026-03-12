import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  final _api     = ApiService();
  
  bool _isLoading = true;
  bool _isAuthenticated = false;
  String? _token;
  String? _userRole;
  Map<String, dynamic>? _user;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get userRole => _userRole;
  Map<String, dynamic>? get user => _user;

  AuthProvider() {
    _loadState();
  }

  Future<void> _loadState() async {
    _token = await _storage.read(key: 'jwt');
    if (_token != null) {
      try {
        final res = await _api.client.get('/auth/me');
        _user = res.data;
        _userRole = _user?['role'];
        _isAuthenticated = true;
      } catch (e) {
        await logout();
      }
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    try {
      final res = await _api.client.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      
      _token = res.data['access_token'];
      _user  = res.data['user'];
      _userRole = _user?['role'];
      
      await _storage.write(key: 'jwt', value: _token);
      _isAuthenticated = true;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt');
    _token = null;
    _user = null;
    _userRole = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}
