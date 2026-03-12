import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://agroconnect-backend.up.railway.app/api', // URL prod par défaut
    connectTimeout: const Duration(seconds: 10),
  ));
  
  final _storage = const FlutterSecureStorage();

  ApiService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'jwt');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (err, handler) {
        if (err.response?.statusCode == 401) {
          // Gérer la déconnexion forcée si besoin
        }
        return handler.next(err);
      },
    ));
  }

  Dio get client => _dio;
}
