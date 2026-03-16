import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/order_repository.dart';
import '../../../core/models/order_model.dart';
import '../../../core/network/dio_client.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(DioClient.dio);
});

final ordersProvider = FutureProvider.family<List<OrderModel>, String?>((ref, role) async {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.getOrders(role: role);
});

final orderDetailProvider = FutureProvider.family<OrderModel, String>((ref, id) async {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.getOrderById(id);
});
