class Product {
  final String id;
  final String seller;
  final String name;
  final String description;
  final double price;
  final String unit;
  final int quantity;
  final String category;
  final List<String> images;
  final String city;
  final String? address;
  final double? lat;
  final double? lng;
  final bool available;

  Product({
    required this.id,
    required this.seller,
    required this.name,
    required this.description,
    required this.price,
    required this.unit,
    required this.quantity,
    required this.category,
    required this.images,
    required this.city,
    this.address,
    this.lat,
    this.lng,
    this.available = true,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? json['id'] ?? '',
      seller: json['seller'] is Map ? json['seller']['_id'] : (json['seller'] ?? ''),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      unit: json['unit'] ?? 'kg',
      quantity: (json['quantity'] ?? 0).toInt(),
      category: json['category'] ?? 'Autres',
      images: List<String>.from(json['images'] ?? []),
      city: json['city'] ?? '',
      address: json['address'],
      lat: (json['lat'] != null && json['lat'] != 0) ? json['lat'].toDouble() : null,
      lng: (json['lng'] != null && json['lng'] != 0) ? json['lng'].toDouble() : null,
      available: json['available'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'unit': unit,
      'quantity': quantity,
      'category': category,
      'images': images,
      'city': city,
      'address': address,
      'lat': lat,
      'lng': lng,
      'available': available,
    };
  }

  String get imageUrl => images.isNotEmpty ? images.first : 'https://placehold.co/400/png?text=AgroConnect';
}
