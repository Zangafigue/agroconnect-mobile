class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final String role;
  final bool isVerified;
  final bool canSell;
  final bool canBuy;
  final double walletBalance;
  final double walletPending;
  final double totalEarned;
  final String? profilePicture;
  final String? city;
  final String? address;
  final String? vehicleType;
  final String? specialty;
  final double averageRating;
  final int totalRatings;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    required this.role,
    this.isVerified = false,
    this.canSell = false,
    this.canBuy = true,
    this.walletBalance = 0,
    this.walletPending = 0,
    this.totalEarned = 0,
    this.profilePicture,
    this.city,
    this.address,
    this.vehicleType,
    this.specialty,
    this.averageRating = 0,
    this.totalRatings = 0,
  });

  String get fullName => '$lastName $firstName';
  String get name => fullName;

  String get roleLabel {
    switch (role) {
      case 'FARMER':      return 'Agriculteur';
      case 'BUYER':       return 'Acheteur';
      case 'TRANSPORTER': return 'Transporteur';
      case 'ADMIN':       return 'Administrateur';
      default:            return role;
    }
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      phone: json['phone'],
      role: json['role'] ?? 'BUYER',
      isVerified: json['isVerified'] ?? false,
      canSell: json['canSell'] ?? false,
      canBuy: json['canBuy'] ?? true,
      walletBalance: (json['walletBalance'] ?? 0).toDouble(),
      walletPending: (json['walletPending'] ?? 0).toDouble(),
      totalEarned: (json['totalEarned'] ?? 0).toDouble(),
      profilePicture: json['profilePicture'],
      city: json['city'],
      address: json['address'],
      vehicleType: json['vehicleType'],
      specialty: json['specialty'],
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      totalRatings: json['totalRatings'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'role': role,
      'isVerified': isVerified,
      'canSell': canSell,
      'canBuy': canBuy,
      'walletBalance': walletBalance,
      'walletPending': walletPending,
      'totalEarned': totalEarned,
      'profilePicture': profilePicture,
      'city': city,
      'address': address,
      'vehicleType': vehicleType,
      'specialty': specialty,
      'averageRating': averageRating,
      'totalRatings': totalRatings,
    };
  }
}
