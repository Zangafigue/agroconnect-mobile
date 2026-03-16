import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_provider.dart';

// Layouts
import '../../features/shared/layouts/farmer_layout.dart';
import '../../features/shared/layouts/buyer_layout.dart';
import '../../features/shared/layouts/transporter_layout.dart';
import '../../features/shared/layouts/visitor_layout.dart';

// Screens
import 'package:agroconnect_bf/features/auth/screens/login_screen.dart';
import 'package:agroconnect_bf/features/auth/screens/registration_screen.dart';
import 'package:agroconnect_bf/features/auth/screens/verification_screen.dart';
import 'package:agroconnect_bf/features/auth/screens/forgot_password_screen.dart';
import 'package:agroconnect_bf/features/auth/screens/reset_password_screen.dart';
import 'package:agroconnect_bf/features/shared/screens/visitor_home_screen.dart';
import 'package:agroconnect_bf/features/shared/screens/visitor_catalogue_screen.dart';
import 'package:agroconnect_bf/features/shared/screens/product_detail_screen.dart';
import 'package:agroconnect_bf/features/shared/screens/visitor_profile_screen.dart';
import 'package:agroconnect_bf/features/shared/screens/visitor_placeholder_screen.dart';

import '../../features/farmer/screens/farmer_screens.dart';
import '../../features/buyer/screens/buyer_screens.dart';
import '../../features/transporter/screens/transporter_screens.dart';
import '../../features/shared/screens/shared_screens.dart';
import '../../features/shared/screens/notifications_screen.dart';
import '../../features/shared/screens/admin_dashboard_screen.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen(authProvider, (_, __) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isLoggedIn = authState.isLoggedIn;
      
      // Routes publiques accessibles sans connexion
      final isPublicRoute = [
        '/', 
        '/visitor-catalogue',
        '/visitor-orders', 
        '/visitor-messages', 
        '/visitor-profile',
        '/login', 
        '/register', 
        '/verify',
        '/forgot-password', 
        '/reset-password',
      ].contains(state.matchedLocation) || state.matchedLocation.startsWith('/product/');

      if (!isLoggedIn && !isPublicRoute) {
        return '/login';
      }

      // Guard: Si connecté mais non vérifié
      if (isLoggedIn && !authState.isVerified) {
        // Bloquer l'accès aux fonctionnalités critiques (commandes, messages privées)
        // Mais autoriser l'accès au Dashboard général
        final isCriticalRoute = state.matchedLocation.contains('/orders') || 
                                state.matchedLocation.contains('/messages') ||
                                state.matchedLocation.contains('/wallet');
        
        final isOnAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/register';

        if (isOnAuthRoute) return '/verify';
        
        if (isCriticalRoute && state.matchedLocation != '/verify') {
          return '/verify';
        }
      }

      // Si l'utilisateur est connecté, vérifié et se trouve sur une route visiteur (sauf notifications), 
      // on le redirige vers son dashboard spécifique.
      if (isLoggedIn && authState.isVerified && (state.matchedLocation == '/' || state.matchedLocation.startsWith('/visitor'))) {
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
      // Visitor / Public Routes
      ShellRoute(
        builder: (_, __, child) => VisitorLayout(child: child),
        routes: [
          GoRoute(path: '/', builder: (_, __) => const VisitorHomeScreen()),
          GoRoute(path: '/visitor-catalogue', builder: (_, __) => const VisitorCatalogueScreen()),
          GoRoute(
            path: '/visitor-orders', 
            builder: (_, __) => const VisitorPlaceholderScreen(
              title: "Commandes",
              icon: Icons.inventory_2_outlined,
              description: "Les utilisateurs inscrits peuvent gérer leurs achats agricoles, consulter l'historique de paiement et suivre leurs livraisons en temps réel. Connectez-vous pour commencer.",
            )
          ),
          GoRoute(
            path: '/visitor-messages', 
            builder: (_, __) => const VisitorPlaceholderScreen(
              title: "Messages",
              icon: Icons.forum_outlined,
              description: "Démarrez des conversations avec les agriculteurs et les transporteurs une fois connecté à votre compte.",
              isLocked: true,
            )
          ),
          GoRoute(path: '/visitor-profile', builder: (_, __) => const VisitorProfileScreen()),
          
        ],
      ),

      // Product Detail (Global)
      GoRoute(
        path: '/product/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ProductDetailScreen(productId: id);
        },
      ),

      // Auth
      GoRoute(path: '/login',            builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register',         builder: (_, __) => const RegistrationScreen()),
      GoRoute(path: '/verify',           builder: (_, __) => const VerificationScreen()),
      GoRoute(path: '/forgot-password',  builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return ResetPasswordScreen(email: email);
        },
      ),
      GoRoute(path: '/notifications',    builder: (_, __) => const NotificationsScreen()),
      GoRoute(path: '/admin',            builder: (_, __) => const AdminDashboardScreen()),

      // Farmer
      ShellRoute(
        builder: (_, __, child) => FarmerLayout(child: child),
        routes: [
          GoRoute(path: '/farmer',               builder: (_, __) => const FarmerDashboardScreen()),
          GoRoute(path: '/farmer/products',      builder: (_, __) => const FarmerProductsScreen()),
          GoRoute(path: '/farmer/products/new',  builder: (_, __) => const ProductFormScreen()),
          GoRoute(path: '/farmer/orders',        builder: (_, __) => const FarmerOrdersScreen()),
          GoRoute(path: '/farmer/orders/:id',    builder: (_, s) => OrderDetailScreen(orderId: s.pathParameters['id']!)),
          GoRoute(
            path: '/farmer/messages',
            builder: (_, __) => const MessagingScreen(),
            routes: [
              GoRoute(
                path: ':chatId',
                builder: (_, state) => NegotiationChatScreen(chatId: state.pathParameters['chatId']!),
              ),
            ],
          ),
          GoRoute(path: '/farmer/wallet',        builder: (_, __) => const WalletScreen()),
          GoRoute(path: '/farmer/profile',       builder: (_, __) => const FarmerProfileScreen()),
          GoRoute(path: '/farmer/settings',      builder: (_, __) => const FarmerSettingsScreen()),
          GoRoute(path: '/farmer/statistics',    builder: (_, __) => const FarmerStatisticsScreen()),
        ],
      ),

      // Buyer
      ShellRoute(
        builder: (_, __, child) => BuyerLayout(child: child),
        routes: [
          GoRoute(path: '/buyer',                      builder: (_, __) => const BuyerHomeScreen()),
          GoRoute(path: '/buyer/catalogue',            builder: (_, __) => const BuyerCatalogueScreen()),
          GoRoute(path: '/buyer/orders',               builder: (_, __) => const BuyerOrdersScreen()),
          GoRoute(path: '/buyer/orders/:id',           builder: (_, s) => OrderDetailScreen(orderId: s.pathParameters['id']!)),
          GoRoute(path: '/buyer/orders/:id/transport', builder: (_, s) => TransportOffersScreen(orderId: s.pathParameters['id']!)),
          GoRoute(path: '/buyer/orders/:id/payment',   builder: (_, s) => PaymentScreen(orderId: s.pathParameters['id']!)),
          GoRoute(
            path: '/buyer/messages', 
            builder: (_, __) => const MessagingScreen(),
            routes: [
              GoRoute(
                path: ':chatId',
                builder: (_, state) => NegotiationChatScreen(chatId: state.pathParameters['chatId']!),
              ),
            ],
          ),
          GoRoute(path: '/buyer/profile',              builder: (_, __) => const BuyerProfileScreen()),
          GoRoute(path: '/buyer/settings',             builder: (_, __) => const BuyerSettingsScreen()),
        ],
      ),

      // Transporter
      ShellRoute(
        builder: (_, __, child) => TransporterLayout(child: child),
        routes: [
          GoRoute(path: '/transporter',            builder: (_, __) => const TransporterDashboardScreen()),
          GoRoute(path: '/transporter/missions',   builder: (_, __) => const MissionsMarketScreen()),
          GoRoute(path: '/transporter/deliveries', builder: (_, __) => const TransporterDeliveriesScreen()),
          GoRoute(path: '/transporter/messages',   builder: (_, __) => const TransporterChatListScreen()),
          GoRoute(path: '/transporter/messages/:id', builder: (_, s) => TransporterChatDetailScreen(chatId: s.pathParameters['id']!)),
          GoRoute(path: '/transporter/wallet',     builder: (_, __) => const TransporterWalletScreen()),
          GoRoute(path: '/transporter/offers',     builder: (_, __) => const TransporterOffersScreen()),
          GoRoute(path: '/transporter/deliveries/:id', builder: (_, s) => TransporterDeliveryDetailScreen(orderId: s.pathParameters['id']!)),
          GoRoute(path: '/transporter/profile',    builder: (_, __) => const TransporterProfileScreen()),
          GoRoute(path: '/transporter/settings',   builder: (_, __) => const TransporterSettingsScreen()),
        ],
      ),
    ],
  );
});
