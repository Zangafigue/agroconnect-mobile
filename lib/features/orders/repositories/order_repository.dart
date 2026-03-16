import 'package:dio/dio.dart';
import '../../../core/models/order_model.dart';

class OrderRepository {
  final Dio _dio;

  OrderRepository(this._dio);

  Future<List<OrderModel>> getOrders({String? role}) async {
    try {
      final response = await _dio.get('/orders', queryParameters: {
        if (role != null) 'role': role,
      });
      final List data = response.data;
      return data.map((json) => OrderModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur lors du chargement des commandes');
    }
  }

  Future<OrderModel> getOrderById(String id) async {
    try {
      final response = await _dio.get('/orders/$id');
      return OrderModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur lors du chargement de la commande');
    }
  }

  Future<OrderModel> createOrder(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/orders', data: data);
      return OrderModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur lors de la création de la commande');
    }
  }

  Future<OrderModel> updateOrderStatus(String id, String status) async {
    try {
      final response = await _dio.patch('/orders/$id/status', data: {'status': status});
      return OrderModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur lors de la mise à jour du statut');
    }
  }
}
