import 'package:dio/dio.dart';
import '../../../core/models/auth_models.dart';
import '../../../core/models/user_model.dart';

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur de connexion');
    }
  }

  Future<AuthResponse> register(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/auth/register', data: data);
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur lors de l\'inscription');
    }
  }

  Future<AuthResponse> verifyOtp(String otp) async {
    try {
      final response = await _dio.post('/auth/verify-otp', data: {'otp': otp});
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Code de vérification invalide');
    }
  }

  Future<AuthResponse> changeEmail(String newEmail) async {
    try {
      final response = await _dio.post('/auth/change-email', data: {'newEmail': newEmail});
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur lors de la modification de l\'email');
    }
  }

  Future<void> resendOtp() async {
    try {
      await _dio.post('/auth/resend-otp');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur lors de l\'envoi du code');
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _dio.post('/auth/forgot-password', data: {'email': email});
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur lors de la demande');
    }
  }

  Future<void> resetPassword(String email, String otp, String newPassword) async {
    try {
      await _dio.post('/auth/reset-password', data: {
        'email': email,
        'otp': otp,
        'newPassword': newPassword,
      });
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur lors de la réinitialisation');
    }
  }

  Future<void> updateCapabilities(bool canSell, bool canBuy) async {
    try {
      await _dio.patch('/auth/capabilities', data: {
        'canSell': canSell,
        'canBuy': canBuy,
      });
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur lors de la mise à jour');
    }
  }

  Future<AuthResponse> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _dio.patch('/auth/profile', data: data);
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur lors de la mise à jour du profil');
    }
  }

  Future<AuthResponse> getMe() async {
    try {
      final response = await _dio.get('/auth/me');
      return AuthResponse(
        accessToken: '', 
        user: User.fromJson(response.data),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur de récupération du profil');
    }
  }
}
