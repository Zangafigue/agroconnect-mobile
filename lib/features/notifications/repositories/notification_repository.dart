import 'package:dio/dio.dart';

class NotificationRepository {
  final Dio _dio;

  NotificationRepository(this._dio);

  Future<List<Map<String, dynamic>>> getMyNotifications() async {
    try {
      final response = await _dio.get('/notifications/mine');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur lors du chargement des notifications');
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _dio.patch('/notifications/$id/read');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur lors du marquage comme lu');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _dio.patch('/notifications/read-all');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur lors du marquage de toutes comme lues');
    }
  }
}
