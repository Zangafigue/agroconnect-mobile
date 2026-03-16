import 'dart:async';

class MockAuthRepository {
  // Simple in-memory storage for mock users
  static final List<Map<String, dynamic>> _mockUsers = [
    {
      'id': '1',
      'email': 'agri@agroconnect.bf',
      'password': 'Password123!',
      'name': 'Moussa Traoré',
      'role': 'FARMER',
      'isVerified': true,
    },
    {
      'id': '2',
      'email': 'acheteur@agroconnect.bf',
      'password': 'Password123!',
      'name': 'Fatima Sawadogo',
      'role': 'BUYER',
      'isVerified': true,
    },
    {
      'id': '3',
      'email': 'trans@agroconnect.bf',
      'password': 'Password123!',
      'name': 'Oumar Koné',
      'role': 'TRANSPORTER',
      'isVerified': true,
    }
  ];

  static Future<Map<String, dynamic>> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network latency

    final user = _mockUsers.firstWhere(
      (u) => u['email'] == email,
      orElse: () => throw Exception('Utilisateur non trouvé'),
    );

    if (user['password'] != password) {
      throw Exception('Mot de passe incorrect');
    }

    return {
      'access_token': 'mock_jwt_token_${user['id']}',
      'user': user,
    };
  }

  static Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(seconds: 1));

    // Backend-style validation
    final password = data['password'] as String;
    if (password.length < 8) {
      throw Exception('Le mot de passe doit contenir au moins 8 caractères');
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      throw Exception('Le mot de passe doit contenir au moins une majuscule');
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      throw Exception('Le mot de passe doit contenir au moins un chiffre');
    }
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>+-]'))) {
      throw Exception('Le mot de passe doit contenir au moins un caractère spécial');
    }

    if (data['password'] != data['confirmPassword']) {
      throw Exception('Les mots de passe ne correspondent pas');
    }

    if (_mockUsers.any((u) => u['email'] == data['email'])) {
      throw Exception('Cet email est déjà utilisé');
    }

    final newUser = {
      'id': (_mockUsers.length + 1).toString(),
      'email': data['email'],
      'password': data['password'],
      'name': '${data['firstName']} ${data['lastName']}',
      'role': data['role'],
      'isVerified': false,
    };

    _mockUsers.add(newUser);

    return {
      'access_token': 'mock_jwt_token_${newUser['id']}',
      'user': newUser,
    };
  }

  static Future<Map<String, dynamic>> verifyOtp(String otp) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (otp == '123456') {
      return {
        'token': 'mock_verified_token',
        'user': {
          ..._mockUsers.last,
          'isVerified': true,
        }
      };
    } else {
      throw Exception('Code de vérification invalide');
    }
  }
}
