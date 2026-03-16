import 'package:dio/dio.dart';
import '../../../core/models/product_model.dart';

class ProductRepository {
  final Dio _dio;

  ProductRepository(this._dio);

  Future<List<Product>> getProducts({String? category, String? query}) async {
    try {
      final response = await _dio.get('/products', queryParameters: {
        if (category != null && category != 'Tous') 'category': category,
        if (query != null && query.isNotEmpty) 'search': query,
      });
      
      final List data = response.data['products'] ?? [];
      return data.map((json) => Product.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur lors du chargement des produits');
    }
  }

  /// Returns only the authenticated farmer's own products.
  Future<List<Product>> getMyProducts() async {
    try {
      final response = await _dio.get('/products/mine');
      // Backend returns a raw array, not a wrapped { products: [] }
      final dynamic raw = response.data;
      final List data = raw is List ? raw : (raw['products'] ?? []);
      return data.map((json) => Product.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur lors du chargement de vos produits');
    }
  }

  Future<Product> getProductById(String id) async {
    try {
      final response = await _dio.get('/products/$id');
      return Product.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur lors du chargement du produit');
    }
  }

  Future<Product> createProduct(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/products', data: data);
      return Product.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur lors de la création du produit');
    }
  }

  Future<Product> updateProduct(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.patch('/products/$id', data: data);
      return Product.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur lors de la mise à jour du produit');
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _dio.delete('/products/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur lors de la suppression du produit');
    }
  }
}
