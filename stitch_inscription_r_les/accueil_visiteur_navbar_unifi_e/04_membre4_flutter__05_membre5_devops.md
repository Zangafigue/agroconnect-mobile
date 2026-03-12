# 📱 Membre 4 — Mobile Flutter
**AgroConnect BF — CS27 Groupe 14**

> **Ton rôle :** Tu développes l'application mobile Flutter. Mêmes flux que le web, adaptés à l'expérience mobile. Tu utilises les mêmes API backend que Membre 3.

---

## Tes Responsabilités

| Tâche | Priorité | Jour |
|---|---|---|
| Setup Flutter + pubspec + structure | 🔴 Critique | Jour 1 |
| DioClient + interceptor JWT | 🔴 Critique | Jour 1 |
| AuthProvider Riverpod + GoRouter | 🔴 Critique | Jour 1 |
| Vues Auth (Register, OTP, Login) | 🔴 Critique | Jour 2 |
| Vues Farmer (Dashboard, Produits, Commandes) | 🟠 Haute | Jour 3 |
| Vues Buyer (Catalogue, Commandes, Paiement) | 🟠 Haute | Jour 3-4 |
| Vues Transporter (Missions, Carte, Wallet) | 🟠 Haute | Jour 4 |
| Composant carte flutter_map (gratuit) | 🟡 Normale | Jour 3-4 |
| Build APK release | 🟡 Normale | Jour 6 |

---

## Jour 1 — Setup Flutter

### 1.1 `pubspec.yaml`
```yaml
name: agroconnect_bf
description: Plateforme agricole du Burkina Faso
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # State management
  flutter_riverpod: ^2.5.1

  # Navigation
  go_router: ^14.0.0

  # HTTP
  dio: ^5.4.3

  # Stockage local
  shared_preferences: ^2.2.3
  flutter_secure_storage: ^9.0.0

  # Cartographie GRATUITE (OpenStreetMap — aucune clé API)
  flutter_map: ^6.1.0
  latlong2: ^0.9.0
  http: ^1.2.1

  # UI
  cached_network_image: ^3.3.1
  image_picker: ^1.0.7
  intl: ^0.19.0
  shimmer: ^3.0.0
  pin_code_fields: ^8.0.1   # OTP input avec cases séparées

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/images/
```

### 1.2 Structure des dossiers
```
lib/
├── core/
│   ├── config.dart               # URL API
│   ├── network/
│   │   └── dio_client.dart       # Dio + interceptor JWT
│   └── router/
│       └── app_router.dart       # GoRouter + guards
├── features/
│   ├── auth/
│   │   ├── models/user.model.dart
│   │   ├── providers/auth_provider.dart
│   │   ├── repositories/auth_repository.dart
│   │   └── screens/
│   │       ├── login_screen.dart
│   │       ├── register_screen.dart
│   │       ├── verify_otp_screen.dart
│   │       └── forgot_password_screen.dart
│   ├── products/
│   ├── orders/
│   ├── deliveries/
│   ├── payments/
│   ├── messaging/
│   └── shared/
│       ├── widgets/
│       │   ├── delivery_map_widget.dart
│       │   ├── location_picker_widget.dart
│       │   ├── status_badge.dart
│       │   └── bottom_nav.dart
│       └── layouts/
│           ├── farmer_layout.dart
│           ├── buyer_layout.dart
│           └── transporter_layout.dart
└── main.dart
```

### 1.3 `lib/core/config.dart`
```dart
class AppConfig {
  static const String apiBaseUrl = 'https://agroconnect-backend.up.railway.app/api';
  // Développement local :
  // static const String apiBaseUrl = 'http://10.0.2.2:3000/api';

  // Cartographie — aucune clé requise (OpenStreetMap + OSRM gratuits)
  static const String osrmUrl = 'https://router.project-osrm.org';
  static const String nominatimUrl = 'https://nominatim.openstreetmap.org';

  static const String appName = 'AgroConnect BF';
  static const Color primaryColor = Color(0xFF16a34a);
}
```

### 1.4 `lib/core/network/dio_client.dart`
```dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DioClient {
  static final _storage = FlutterSecureStorage();
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static void init() {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'jwt_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await _storage.delete(key: 'jwt_token');
          // Rediriger vers login via GoRouter
        }
        handler.next(error);
      },
    ));
  }

  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: 'jwt_token');
  }
}
```

### 1.5 `lib/features/auth/providers/auth_provider.dart`
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';

class AuthState {
  final String? token;
  final Map<String, dynamic>? user;
  final bool isLoading;
  final String? error;

  const AuthState({ this.token, this.user, this.isLoading = false, this.error });

  bool get isLoggedIn => token != null;
  String? get role => user?['role'];
  bool get isVerified => user?['isVerified'] == true;
  bool get canSell => user?['canSell'] == true;
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final token = await DioClient._storage.read(key: 'jwt_token');
    final userStr = await DioClient._storage.read(key: 'user_data');
    if (token != null && userStr != null) {
      state = AuthState(token: token, user: json.decode(userStr));
    }
  }

  Future<void> register(Map<String, dynamic> data) async {
    state = AuthState(isLoading: true);
    try {
      final res = await DioClient.dio.post('/auth/register', data: data);
      await _saveAuth(res.data['access_token'], res.data['user']);
      state = AuthState(token: res.data['access_token'], user: res.data['user']);
    } on DioException catch (e) {
      state = AuthState(error: e.response?.data['message'] ?? 'Erreur d\'inscription');
    }
  }

  Future<void> login(String email, String password) async {
    state = AuthState(isLoading: true);
    try {
      final res = await DioClient.dio.post('/auth/login', data: { 'email': email, 'password': password });
      await _saveAuth(res.data['access_token'], res.data['user']);
      state = AuthState(token: res.data['access_token'], user: res.data['user']);
    } on DioException catch (e) {
      state = AuthState(error: e.response?.data['message'] ?? 'Email ou mot de passe incorrect');
    }
  }

  Future<void> verifyOtp(String otp) async {
    try {
      final res = await DioClient.dio.post('/auth/verify-otp', data: { 'otp': otp });
      await _saveAuth(res.data['token'], res.data['user']);
      state = AuthState(token: res.data['token'], user: res.data['user']);
    } on DioException catch (e) {
      state = state.copyWith(error: e.response?.data['message']);
    }
  }

  Future<void> logout() async {
    await DioClient.clearToken();
    await DioClient._storage.delete(key: 'user_data');
    state = const AuthState();
  }

  Future<void> _saveAuth(String token, Map<String, dynamic> user) async {
    await DioClient.saveToken(token);
    await DioClient._storage.write(key: 'user_data', value: json.encode(user));
  }
}

extension on AuthState {
  AuthState copyWith({ String? error }) => AuthState(
    token: token, user: user, isLoading: false, error: error ?? this.error
  );
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier());
```

### 1.6 `lib/core/router/app_router.dart`
```dart
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authState.isLoggedIn;
      final isAuthRoute = ['/login', '/register', '/verify-otp', '/forgot-password', '/reset-password']
          .contains(state.matchedLocation);

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && state.matchedLocation == '/') {
        return switch (authState.role) {
          'FARMER'      => '/farmer',
          'BUYER'       => '/buyer',
          'TRANSPORTER' => '/transporter',
          'ADMIN'       => '/admin',
          _ => '/login',
        };
      }
      return null;
    },
    routes: [
      // Auth
      GoRoute(path: '/login',            builder: (_, __) => LoginScreen()),
      GoRoute(path: '/register',         builder: (_, __) => RegisterScreen()),
      GoRoute(path: '/verify-otp',       builder: (_, __) => VerifyOtpScreen()),
      GoRoute(path: '/forgot-password',  builder: (_, __) => ForgotPasswordScreen()),
      GoRoute(path: '/reset-password',   builder: (_, __) => ResetPasswordScreen()),

      // Farmer
      ShellRoute(
        builder: (_, __, child) => FarmerLayout(child: child),
        routes: [
          GoRoute(path: '/farmer',               builder: (_, __) => FarmerDashboardScreen()),
          GoRoute(path: '/farmer/products',      builder: (_, __) => FarmerProductsScreen()),
          GoRoute(path: '/farmer/products/new',  builder: (_, __) => ProductFormScreen()),
          GoRoute(path: '/farmer/orders',        builder: (_, __) => FarmerOrdersScreen()),
          GoRoute(path: '/farmer/orders/:id',    builder: (_, s) => OrderDetailScreen(orderId: s.pathParameters['id']!)),
          GoRoute(path: '/farmer/messages',      builder: (_, __) => MessagingScreen()),
          GoRoute(path: '/farmer/wallet',        builder: (_, __) => WalletScreen()),
          GoRoute(path: '/farmer/profile',       builder: (_, __) => ProfileScreen()),
        ],
      ),

      // Buyer
      ShellRoute(
        builder: (_, __, child) => BuyerLayout(child: child),
        routes: [
          GoRoute(path: '/buyer',                      builder: (_, __) => BuyerDashboardScreen()),
          GoRoute(path: '/buyer/orders',               builder: (_, __) => BuyerOrdersScreen()),
          GoRoute(path: '/buyer/orders/:id',           builder: (_, s) => OrderDetailScreen(orderId: s.pathParameters['id']!)),
          GoRoute(path: '/buyer/orders/:id/transport', builder: (_, s) => TransportOffersScreen(orderId: s.pathParameters['id']!)),
          GoRoute(path: '/buyer/orders/:id/payment',   builder: (_, s) => PaymentScreen(orderId: s.pathParameters['id']!)),
          GoRoute(path: '/buyer/messages',             builder: (_, __) => MessagingScreen()),
          GoRoute(path: '/buyer/profile',              builder: (_, __) => ProfileScreen()),
        ],
      ),

      // Transporter
      ShellRoute(
        builder: (_, __, child) => TransporterLayout(child: child),
        routes: [
          GoRoute(path: '/transporter',            builder: (_, __) => TransporterDashboardScreen()),
          GoRoute(path: '/transporter/missions',   builder: (_, __) => MissionsScreen()),
          GoRoute(path: '/transporter/offers',     builder: (_, __) => MyOffersScreen()),
          GoRoute(path: '/transporter/deliveries', builder: (_, __) => MyDeliveriesScreen()),
          GoRoute(path: '/transporter/messages',   builder: (_, __) => MessagingScreen()),
          GoRoute(path: '/transporter/wallet',     builder: (_, __) => WalletScreen()),
          GoRoute(path: '/transporter/profile',    builder: (_, __) => ProfileScreen()),
        ],
      ),
    ],
  );
});
```

---

## Jour 3-4 — Composant Carte Flutter (Gratuit)

### `lib/features/shared/widgets/delivery_map_widget.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DeliveryMapWidget extends StatefulWidget {
  final LatLng pickup;
  final LatLng delivery;
  final LatLng? transporter;
  final double height;

  const DeliveryMapWidget({
    super.key,
    required this.pickup,
    required this.delivery,
    this.transporter,
    this.height = 220,
  });

  @override State<DeliveryMapWidget> createState() => _DeliveryMapWidgetState();
}

class _DeliveryMapWidgetState extends State<DeliveryMapWidget> {
  List<LatLng> _route = [];
  String _distance = '';
  String _duration = '';

  @override void initState() { super.initState(); _fetchRoute(); }

  Future<void> _fetchRoute() async {
    try {
      final url = '${AppConfig.osrmUrl}/route/v1/driving/'
          '${widget.pickup.longitude},${widget.pickup.latitude};'
          '${widget.delivery.longitude},${widget.delivery.latitude}'
          '?overview=full&geometries=geojson';

      final response = await http.get(Uri.parse(url));
      final data = jsonDecode(response.body);
      final route = data['routes'][0];

      final coords = (route['geometry']['coordinates'] as List)
          .map((c) => LatLng(c[1].toDouble(), c[0].toDouble()))
          .toList();

      final distKm = (route['legs'][0]['distance'] / 1000).toStringAsFixed(0);
      final durMin = (route['legs'][0]['duration'] / 60).toInt();
      final durStr = durMin > 60 ? '${durMin ~/ 60}h${durMin % 60}min' : '${durMin}min';

      setState(() { _route = coords; _distance = '$distKm km'; _duration = durStr; });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final center = LatLng(
      (widget.pickup.latitude  + widget.delivery.latitude)  / 2,
      (widget.pickup.longitude + widget.delivery.longitude) / 2,
    );

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: widget.height,
            child: FlutterMap(
              options: MapOptions(initialCenter: center, initialZoom: 7),
              children: [
                // Tuiles OpenStreetMap — 100% gratuites
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.agroconnect.bf',
                ),
                // Itinéraire tracé en vert
                if (_route.isNotEmpty) PolylineLayer(polylines: [
                  Polyline(points: _route, color: Color(0xFF16a34a), strokeWidth: 4),
                ]),
                // Markers
                MarkerLayer(markers: [
                  Marker(
                    point: widget.pickup, width: 36, height: 36,
                    child: Icon(Icons.location_on, color: Colors.green[700], size: 36),
                  ),
                  Marker(
                    point: widget.delivery, width: 36, height: 36,
                    child: Icon(Icons.location_on, color: Colors.red, size: 36),
                  ),
                  if (widget.transporter != null) Marker(
                    point: widget.transporter!, width: 36, height: 36,
                    child: Icon(Icons.local_shipping, color: Colors.blue, size: 30),
                  ),
                ]),
              ],
            ),
          ),
        ),
        // Bande info
        if (_distance.isNotEmpty)
          Container(
            color: Color(0xFFf0fdf4),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Chip('📏 $_distance'),
                SizedBox(width: 8),
                _Chip('⏱ $_duration'),
              ],
            ),
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  const _Chip(this.text);
  @override Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Color(0xFFbbf7d0)),
    ),
    child: Text(text, style: TextStyle(fontSize: 12)),
  );
}
```

### Permissions `android/app/src/main/AndroidManifest.xml`
```xml
<!-- Ajouter avant <application> -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

<!-- Aucune clé Google Maps requise — on utilise OpenStreetMap -->
```

---

## Navbar Bottom commune

```dart
// lib/features/shared/layouts/farmer_layout.dart
class FarmerLayout extends ConsumerWidget {
  final Widget child;
  const FarmerLayout({super.key, required this.child});

  @override Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;

    final tabs = [
      (path: '/farmer',          icon: Icons.home_rounded,    label: 'Accueil'),
      (path: '/farmer/products', icon: Icons.inventory_2,     label: 'Produits'),
      (path: '/farmer/orders',   icon: Icons.shopping_cart,   label: 'Commandes'),
      (path: '/farmer/messages', icon: Icons.chat_bubble,     label: 'Messages'),
      (path: '/farmer/profile',  icon: Icons.person,          label: 'Profil'),
    ];

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: tabs.indexWhere((t) => location.startsWith(t.path)).clamp(0, 4),
        selectedItemColor: Color(0xFF16a34a),
        unselectedItemColor: Color(0xFF9ca3af),
        type: BottomNavigationBarType.fixed,
        onTap: (i) => context.go(tabs[i].path),
        items: tabs.map((t) => BottomNavigationBarItem(
          icon: Icon(t.icon), label: t.label,
        )).toList(),
      ),
    );
  }
}
```

---

## Jour 6 — Build APK Release

```bash
# 1. Configurer la signature (optionnel pour démo)
flutter build apk --release

# Le fichier APK :
# build/app/outputs/flutter-apk/app-release.apk

# 2. Partage direct via cable USB ou Firebase App Distribution (gratuit)
# ou simplement envoyer le .apk par email/WhatsApp pour la démo

# 3. Vérifier la taille
ls -lh build/app/outputs/flutter-apk/app-release.apk
```

---

## Checklist Membre 4

- [ ] `pubspec.yaml` : `pin_code_fields` pour les cases OTP
- [ ] `DioClient` utilise `flutter_secure_storage` (plus sécurisé que SharedPreferences)
- [ ] `lib/core/config.dart` : URL locale en dev (`10.0.2.2:3000`), URL Railway en prod
- [ ] GoRouter redirige selon `role` après login
- [ ] Permissions INTERNET dans AndroidManifest.xml
- [ ] `userAgentPackageName` renseigné dans TileLayer (requis par OpenStreetMap)
- [ ] Tester la carte sur un émulateur Android (internet requis)
- [ ] APK release construit et testé avant la démo

---

---

# 🧪 Membre 5 — DevOps / Docs / Tests
**AgroConnect BF — CS27 Groupe 14**

> **Ton rôle :** Qualité, documentation, déploiement. Tu t'assures que tout le monde peut bosser efficacement et que le projet est livré proprement.

---

## Tes Responsabilités

| Tâche | Priorité | Jour |
|---|---|---|
| Setup MongoDB Atlas | 🔴 Critique | Jour 1 matin |
| Créer toutes les Issues GitHub | 🔴 Critique | Jour 1 |
| Configuration Swagger (Membre 1 fournit la base) | 🟠 Haute | Jour 2 |
| Workspace Postman + tests | 🟠 Haute | Jour 2-3 |
| Déploiement Railway | 🟡 Normale | Jour 6 |
| Déploiement Vercel | 🟡 Normale | Jour 6 |
| README complet | 🟡 Normale | Jour 6 |
| Slides démo (6 slides) | 🟡 Normale | Jour 6 |

---

## Jour 1 — MongoDB Atlas

```
1. atlas.mongodb.com → Create Free Account
2. New Project : "agroconnect-bf"
3. Build a Database → M0 FREE (512 MB, gratuit)
4. Provider : AWS, Region : Paris (eu-west-3) ou le plus proche
5. Cluster Name : agroconnect-cluster

6. Database Access → Add New User :
   Username : agroconnect
   Password : [générer un mot de passe fort]
   Role : Atlas Admin

7. Network Access → Add IP Address → 0.0.0.0/0
   (Railway a des IPs dynamiques, cette règle est obligatoire)

8. Connect → Drivers → Node.js → Copier l'URI :
   mongodb+srv://agroconnect:<password>@agroconnect-cluster.xxxxx.mongodb.net/agroconnect?retryWrites=true&w=majority

9. Donner cette URI à Membre 1 pour le .env
```

---

## Jour 1 — GitHub Issues (28 issues)

Créer ces issues et les assigner dans GitHub :

### Backend (Membre 1 & 2)
| # | Titre | Assigné |
|---|---|---|
| 1 | Setup Node.js + Express + structure + middlewares RBAC | Membre 1 |
| 2 | `User.model.js` + canSell/canBuy + toJSON | Membre 2 |
| 3 | `AuthModule` — register + OTP email + login + JWT | Membre 2 |
| 4 | `AuthModule` — forgot-password + reset + capabilities | Membre 2 |
| 5 | Seeder Admin | Membre 2 |
| 6 | `Product.model.js` + CRUD complet + filtres catalogue | Membre 2 |
| 7 | `Order.model.js` + createOrder + confirmOrder + règles métier | Membre 2 |
| 8 | `DeliveriesModule` — appel d'offres complet | Membre 1 |
| 9 | `PaymentsModule` — escrow + split + releaseFunds | Membre 1 |
| 10 | `MessagingModule` — conversations + offres de prix | Membre 2 |
| 11 | `DisputesModule` — ouverture + gel des fonds | Membre 2 |
| 12 | `AdminModule` — stats + users + litiges + paiements | Membre 1 |
| 13 | Configuration Swagger/OpenAPI | Membre 5 |
| 14 | Déploiement Railway + variables d'env | Membre 1 |

### Frontend Web (Membre 3)
| # | Titre | Assigné |
|---|---|---|
| 15 | Setup Vite + Tailwind + Zustand + Router + Axios | Membre 3 |
| 16 | Pages Auth — Register + OTP + Login + Reset | Membre 3 |
| 17 | Composant DeliveryMap + LocationPicker | Membre 3 |
| 18 | Catalogue public + Détail Produit | Membre 3 |
| 19 | Dashboard Farmer + Mes Produits + Formulaire | Membre 3 |
| 20 | Commandes Farmer + Confirmation + Carte | Membre 3 |
| 21 | Dashboard Buyer + Commandes + Offres transport + Paiement | Membre 3 |
| 22 | Dashboard Transporter + Missions + Carte + Wallet | Membre 3 |
| 23 | Console Admin — Dashboard + Utilisateurs + Litiges | Membre 3 |
| 24 | Déploiement Vercel | Membre 3 |

### Mobile (Membre 4)
| # | Titre | Assigné |
|---|---|---|
| 25 | Setup Flutter + DioClient + GoRouter + Auth | Membre 4 |
| 26 | Vues Auth Flutter | Membre 4 |
| 27 | Vues Farmer + Buyer + Transporter Flutter | Membre 4 |
| 28 | Composant carte flutter_map + APK release | Membre 4 |

---

## Jour 2-3 — Postman — 31 Cas de Tests

### Collection Structure
```
AgroConnect BF API
├── 🔐 Auth
│   ├── Register — Farmer
│   ├── Register — email dupliqué (doit retourner 409)
│   ├── Verify OTP — code correct
│   ├── Verify OTP — code incorrect (doit retourner 400)
│   ├── Verify OTP — code expiré (doit retourner 400)
│   ├── Login — succès
│   ├── Login — mauvais mot de passe (doit retourner 401)
│   └── Forgot Password
├── 📦 Products
│   ├── GET Catalogue public (sans token)
│   ├── POST Créer produit — Farmer vérifié ✅
│   ├── POST Créer produit — Buyer (doit retourner 403)
│   ├── POST Créer produit — Farmer non vérifié (doit retourner 403)
│   ├── PUT Modifier produit — owner
│   └── DELETE Supprimer produit
├── 🛒 Orders
│   ├── POST Passer commande — Buyer
│   ├── POST Passer commande — son propre produit (doit retourner 400)
│   ├── POST Passer commande — stock insuffisant (doit retourner 400)
│   ├── PATCH Confirmer commande — Farmer
│   ├── PATCH Confirmer commande — Buyer (doit retourner 403)
│   └── PATCH Annuler commande
├── 🚛 Deliveries
│   ├── GET Missions disponibles — Transporter
│   ├── POST Soumettre offre
│   ├── POST Accepter offre — Buyer
│   │   → Vérifier : autres offres REJECTED automatiquement
│   ├── PATCH Status → IN_TRANSIT
│   ├── PATCH Status → DELIVERED
│   │   → Vérifier : wallets crédités automatiquement
│   └── PATCH Status — Transporter non assigné (doit retourner 403)
├── 💰 Payments
│   ├── POST Initier paiement
│   ├── GET Mon portefeuille
│   └── POST Demander retrait
├── 💬 Messaging
│   ├── POST Créer conversation
│   ├── POST Envoyer message
│   └── POST Envoyer offre de prix
└── 👑 Admin
    ├── GET Stats globales
    ├── GET Stats — Farmer (doit retourner 403)
    ├── PATCH Suspendre utilisateur
    ├── POST Résoudre litige
    └── GET Tous les paiements
```

### Script auto-save token (onglet Tests de chaque login)
```javascript
// À coller dans l'onglet "Tests" de POST /auth/login
const res = pm.response.json();
if (res.access_token) {
  pm.environment.set('jwt_token', res.access_token);
  pm.environment.set('user_id', res.user._id || res.user.id);
  pm.environment.set('user_role', res.user.role);
  console.log('✅ Token sauvegardé pour rôle :', res.user.role);
}
// Pour le register :
if (res.token) {
  pm.environment.set('jwt_token', res.token);
}
```

### Variables d'environnement Postman
```
base_url    = http://localhost:3000
jwt_token   = (auto-renseigné par le script)
user_id     = (auto-renseigné)
product_id  = (copier après création)
order_id    = (copier après création)
offer_id    = (copier après soumission)
```

---

## Jour 2 — Swagger

```javascript
// src/config/swagger.js
const swaggerJsdoc = require('swagger-jsdoc');

const options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: '🌾 AgroConnect BF API',
      version: '1.0.0',
      description: 'API de la plateforme agricole du Burkina Faso — CS27 Groupe 14',
    },
    servers: [
      { url: 'http://localhost:3000', description: 'Développement local' },
      { url: 'https://agroconnect-backend.up.railway.app', description: 'Production Railway' },
    ],
    components: {
      securitySchemes: {
        bearerAuth: { type: 'http', scheme: 'bearer', bearerFormat: 'JWT' }
      }
    },
    security: [{ bearerAuth: [] }],
  },
  apis: ['./src/routes/*.js'],
};

module.exports = swaggerJsdoc(options);
```

### Exemple annotation Swagger dans une route
```javascript
// Dans auth.routes.js — ajouter ces commentaires avant chaque route

/**
 * @swagger
 * /auth/register:
 *   post:
 *     summary: Inscription d'un nouvel utilisateur
 *     tags: [Auth]
 *     security: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [email, password, firstName, lastName, role]
 *             properties:
 *               email:     { type: string, example: amadou@email.com }
 *               password:  { type: string, example: MonMotDePasse@1 }
 *               firstName: { type: string, example: Amadou }
 *               lastName:  { type: string, example: Kaboré }
 *               role:      { type: string, enum: [FARMER, BUYER, TRANSPORTER] }
 *     responses:
 *       201:
 *         description: Compte créé, OTP envoyé par email
 *       409:
 *         description: Email déjà utilisé
 */
router.post('/register', ctrl.register);
```

---

## Jour 6 — Déploiement

### Railway (Backend)
```
1. railway.app → New Project → Deploy from GitHub Repo
2. Sélectionner agroconnect-backend (branche main)
3. Variables d'environnement → ajouter toutes les variables du .env
4. Domain → Generate Domain → copier l'URL
5. Exécuter le seeder : Railway > Service > Terminal → npm run seed
6. Vérifier : https://votre-url.railway.app/api/health
7. Vérifier Swagger : https://votre-url.railway.app/api/docs
```

### Vercel (Frontend)
```
1. vercel.com → New Project → Import from GitHub
2. Sélectionner agroconnect-frontend
3. Framework Preset : Vite
4. Environment Variables → VITE_API_URL = https://votre-url.railway.app
5. Deploy → copier l'URL de production
6. Donner l'URL Vercel à Membre 1 → mettre à jour le CORS dans app.js
```

---

## Jour 6 — README.md

```markdown
# 🌾 AgroConnect BF

Plateforme digitale connectant agriculteurs, acheteurs et transporteurs au Burkina Faso.

## 🚀 Liens

- **API** : https://agroconnect-backend.up.railway.app
- **Swagger** : https://agroconnect-backend.up.railway.app/api/docs
- **Frontend** : https://agroconnect-bf.vercel.app

## 🛠 Stack

| Composant | Technologie |
|---|---|
| Backend | Node.js + Express + Mongoose |
| Frontend | ReactJS + Vite + Tailwind CSS |
| Mobile | Flutter |
| Base de données | MongoDB Atlas |
| Cartographie | OpenStreetMap + OSRM (gratuit) |

## ⚡ Installation locale

git clone https://github.com/votre-repo/agroconnect-backend
cd agroconnect-backend
npm install
cp .env.example .env   # remplir les variables
npm run seed           # créer le compte admin
npm run dev            # lancer sur http://localhost:3000

## 🧪 Comptes de test

| Rôle | Email | Mot de passe |
|---|---|---|
| Admin | admin@agroconnect.bf | Admin@AgroConnect2026! |
| Farmer | farmer@test.com | Test@1234! |
| Buyer | buyer@test.com | Test@1234! |
| Transporter | transporter@test.com | Test@1234! |

## 👥 Équipe — CS27 Groupe 14

| Membre | Rôle |
|---|---|
| Membre 1 | Lead Dev / Architecte |
| Membre 2 | Backend Dev |
| Membre 3 | Frontend Web |
| Membre 4 | Mobile Dev |
| Membre 5 | DevOps / Docs |
```

---

## Jour 6 — Slides Démo (6 slides)

| Slide | Contenu | Durée |
|---|---|---|
| **1 — Problème** | Contexte agricole BF, 3 problèmes, solution AgroConnect | 1 min |
| **2 — Architecture** | Schéma stack, 4 rôles, flux principal en 9 étapes | 1 min |
| **3 — Démo Auth** | Register → OTP email en live → Login → JWT | 2 min |
| **4 — Démo Flux Principal** | Farmer publie → Buyer commande → Farmer confirme + carte → Transporter offre → Buyer choisit | 3 min |
| **5 — Démo Paiement + Livraison** | Payer → Escrow → IN_TRANSIT → DELIVERED → Wallets crédités | 2 min |
| **6 — Tech + Qualité** | Swagger, console admin, stats, OpenStreetMap gratuit, 31 tests | 1 min |

### Scénario démo complet (répéter avant la présentation)
```
Préparer 4 onglets navigateur :
  Tab 1 : Frontend Farmer connecté
  Tab 2 : Frontend Buyer connecté
  Tab 3 : Frontend Transporter connecté
  Tab 4 : Console Admin

Étapes :
  1. [Farmer] Publier produit : Maïs sec 500 kg, 5 000 FCFA/sac, Bobo-Dioulasso
  2. [Buyer]  Catalogue → Trouver le produit → Commander 10 sacs
  3. [Farmer] Commandes en attente → Confirmer → Placer le pin sur la carte
  4. [Transporter] Missions disponibles → Voir la commande + carte → Soumettre offre 12 500 FCFA
  5. [Buyer] Offres reçues → 3 offres → Choisir Koné Dramane → Payer 62 500 FCFA
  6. [Transporter] Livraisons → Confirmer départ → Statut IN_TRANSIT
  7. [Transporter] Arrivé → Confirmer livraison → Statut DELIVERED
  8. [Farmer] Wallet : 48 500 FCFA crédités automatiquement ✅
  9. [Transporter] Wallet : 12 500 FCFA crédités automatiquement ✅
 10. [Admin] Stats → Volume total mis à jour
```

---

## Checklist Membre 5

- [ ] URI MongoDB Atlas communiquée à Membre 1 avant Jour 1 midi
- [ ] Toutes les 28 issues créées et assignées sur GitHub
- [ ] Postman : 31 tests passants (vert) avant la démo
- [ ] Swagger : toutes les routes documentées et testables
- [ ] README : URL Railway et Vercel mises à jour
- [ ] Comptes de test créés manuellement ou via script
- [ ] Slides prêtes la veille de la démo
- [ ] Scénario démo répété au moins 2 fois
