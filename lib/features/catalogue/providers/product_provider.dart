import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/product_repository.dart';
import '../../../core/models/product_model.dart';
import '../../../core/network/dio_client.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(DioClient.dio);
});

final productsProvider = FutureProvider.family<List<Product>, String?>((ref, category) async {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getProducts(category: category);
});

/// Provider for the currently logged-in farmer's own products (calls /products/mine)
final myProductsProvider = FutureProvider<List<Product>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getMyProducts();
});

final productDetailProvider = FutureProvider.family<Product, String>((ref, id) async {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getProductById(id);
});
