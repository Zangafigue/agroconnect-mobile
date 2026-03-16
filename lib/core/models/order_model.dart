import 'user_model.dart';
import 'product_model.dart';

class OrderModel {
  final String id;
  final String buyerId;
  final User? buyer;
  final String sellerId;
  final User? seller;
  final String productId;
  final Product? product;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String status;
  final String? pickupAddress;
  final String? pickupCity;
  final double? pickupLat;
  final double? pickupLng;
  final String deliveryAddress;
  final String deliveryCity;
  final double? deliveryLat;
  final double? deliveryLng;
  final double? deliveryBudget;
  final String? transporterId;
  final User? transporter;
  final bool transporterAssigned;
  final double? deliveryFee;
  final double? transporterLat;
  final double? transporterLng;
  final DateTime? transporterPositionUpdatedAt;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.buyerId,
    this.buyer,
    required this.sellerId,
    this.seller,
    required this.productId,
    this.product,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.status,
    this.pickupAddress,
    this.pickupCity,
    this.pickupLat,
    this.pickupLng,
    required this.deliveryAddress,
    required this.deliveryCity,
    this.deliveryLat,
    this.deliveryLng,
    this.deliveryBudget,
    this.transporterId,
    this.transporter,
    this.transporterAssigned = false,
    this.deliveryFee,
    this.transporterLat,
    this.transporterLng,
    this.transporterPositionUpdatedAt,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['_id'] ?? json['id'] ?? '',
      buyerId: json['buyer'] is Map ? json['buyer']['_id'] : (json['buyer'] ?? ''),
      buyer: json['buyer'] is Map ? User.fromJson(json['buyer']) : null,
      sellerId: json['seller'] is Map ? json['seller']['_id'] : (json['seller'] ?? ''),
      seller: json['seller'] is Map ? User.fromJson(json['seller']) : null,
      productId: json['product'] is Map ? json['product']['_id'] : (json['product'] ?? ''),
      product: json['product'] is Map ? Product.fromJson(json['product']) : null,
      quantity: (json['quantity'] ?? 0).toInt(),
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      status: json['status'] ?? 'PENDING',
      pickupAddress: json['pickupAddress'],
      pickupCity: json['pickupCity'],
      pickupLat: (json['pickupLat'] ?? 0).toDouble() != 0 ? (json['pickupLat'] ?? 0).toDouble() : null,
      pickupLng: (json['pickupLng'] ?? 0).toDouble() != 0 ? (json['pickupLng'] ?? 0).toDouble() : null,
      deliveryAddress: json['deliveryAddress'] ?? '',
      deliveryCity: json['deliveryCity'] ?? '',
      deliveryLat: (json['deliveryLat'] ?? 0).toDouble() != 0 ? (json['deliveryLat'] ?? 0).toDouble() : null,
      deliveryLng: (json['deliveryLng'] ?? 0).toDouble() != 0 ? (json['deliveryLng'] ?? 0).toDouble() : null,
      deliveryBudget: (json['deliveryBudget'] ?? 0).toDouble(),
      transporterId: json['transporter'] is Map ? json['transporter']['_id'] : (json['transporter'] ?? ''),
      transporter: json['transporter'] is Map ? User.fromJson(json['transporter']) : null,
      transporterAssigned: json['transporterAssigned'] ?? false,
      deliveryFee: (json['deliveryFee'] ?? 0).toDouble(),
      transporterLat: (json['transporterLat'] ?? 0).toDouble() != 0 ? (json['transporterLat'] ?? 0).toDouble() : null,
      transporterLng: (json['transporterLng'] ?? 0).toDouble() != 0 ? (json['transporterLng'] ?? 0).toDouble() : null,
      transporterPositionUpdatedAt: json['transporterPositionUpdatedAt'] != null 
          ? DateTime.parse(json['transporterPositionUpdatedAt']) 
          : null,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }

  // Helper for status French labels
  String get statusLabel {
    switch (status) {
      case 'PENDING': return 'En attente';
      case 'CONFIRMED': return 'Confirmée';
      case 'IN_TRANSIT': return 'En transit';
      case 'DELIVERED': return 'Livrée';
      case 'CANCELLED': return 'Annulée';
      case 'DISPUTED': return 'Litige';
      default: return status;
    }
  }
}
