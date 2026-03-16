import 'package:dio/dio.dart';

class MessagingRepository {
  final Dio _dio;

  MessagingRepository(this._dio);

  Future<List<Map<String, dynamic>>> getConversations() async {
    try {
      final response = await _dio.get('/conversations/mine');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur lors du chargement des conversations');
    }
  }

  Future<List<Map<String, dynamic>>> getMessages(String conversationId) async {
    try {
      final response = await _dio.get('/conversations/$conversationId/messages');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur lors du chargement des messages');
    }
  }

  Future<void> sendMessage(String conversationId, String text) async {
    try {
      await _dio.post('/conversations/$conversationId/messages', data: {'content': text});
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur lors de l\'envoi du message');
    }
  }

  Future<void> sendPriceOffer(String conversationId, double amount) async {
    try {
      await _dio.post('/conversations/$conversationId/price-offer', data: {'amount': amount});
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur lors de l\'envoi de l\'offre');
    }
  }

  Future<void> respondToOffer(String msgId, String action) async {
    try {
      await _dio.patch('/conversations/messages/$msgId/respond', data: {'action': action});
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur lors de la réponse à l\'offre');
    }
  }

  Future<Map<String, dynamic>> startConversation(String recipientId, {String? productId, String? orderId}) async {
    try {
      final response = await _dio.post('/conversations', data: {
        'recipientId': recipientId,
        if (productId != null) 'productId': productId,
        if (orderId != null) 'orderId': orderId,
      });
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur lors de l\'initialisation de la conversation');
    }
  }
}
