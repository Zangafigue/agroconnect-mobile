import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_provider.dart';

// Imports des écrans auth

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/verify_otp_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';

import '../../features/shared/layouts/farmer_layout.dart';
import '../../features/shared/layouts/buyer_layout.dart';
import '../../features/shared/layouts/transporter_layout.dart';

import '../../features/farmer/screens/farmer_screens.dart';
import '../../features/buyer/screens/buyer_screens.dart';
import '../../features/transporter/screens/transporter_screens.dart';
import '../../features/shared/screens/shared_screens.dart';

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
      GoRoute(path: '/login',            builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register',         builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/verify-otp',       builder: (_, __) => const VerifyOtpScreen()),
      GoRoute(path: '/forgot-password',  builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(path: '/reset-password',   builder: (_, __) => const ResetPasswordScreen()),

      // Farmer
      ShellRoute(
        builder: (_, __, child) => FarmerLayout(child: child),
        routes: [
          GoRoute(path: '/farmer',               builder: (_, __) => const FarmerDashboardScreen()),
          GoRoute(path: '/farmer/products',      builder: (_, __) => const FarmerProductsScreen()),
          GoRoute(path: '/farmer/products/new',  builder: (_, __) => const ProductFormScreen()),
          GoRoute(path: '/farmer/orders',        builder: (_, __) => const FarmerOrdersScreen()),
          GoRoute(path: '/farmer/orders/:id',    builder: (_, s) => OrderDetailScreen(orderId: s.pathParameters['id']!)),
          GoRoute(path: '/farmer/messages',      builder: (_, __) => const MessagingScreen()),
          GoRoute(path: '/farmer/wallet',        builder: (_, __) => const WalletScreen()),
          GoRoute(path: '/farmer/profile',       builder: (_, __) => const ProfileScreen()),
        ],
      ),

      // Buyer
      ShellRoute(
        builder: (_, __, child) => BuyerLayout(child: child),
        routes: [
          GoRoute(path: '/buyer',                      builder: (_, __) => const BuyerDashboardScreen()),
          GoRoute(path: '/buyer/orders',               builder: (_, __) => const BuyerOrdersScreen()),
          GoRoute(path: '/buyer/orders/:id',           builder: (_, s) => OrderDetailScreen(orderId: s.pathParameters['id']!)),
          GoRoute(path: '/buyer/orders/:id/transport', builder: (_, s) => TransportOffersScreen(orderId: s.pathParameters['id']!)),
          GoRoute(path: '/buyer/orders/:id/payment',   builder: (_, s) => PaymentScreen(orderId: s.pathParameters['id']!)),
          GoRoute(path: '/buyer/messages',             builder: (_, __) => const MessagingScreen()),
          GoRoute(path: '/buyer/profile',              builder: (_, __) => const ProfileScreen()),
        ],
      ),

      // Transporter
      ShellRoute(
        builder: (_, __, child) => TransporterLayout(child: child),
        routes: [
          GoRoute(path: '/transporter',            builder: (_, __) => const TransporterDashboardScreen()),
          GoRoute(path: '/transporter/missions',   builder: (_, __) => const MissionsScreen()),
          GoRoute(path: '/transporter/offers',     builder: (_, __) => const MyOffersScreen()),
          GoRoute(path: '/transporter/deliveries', builder: (_, __) => const MyDeliveriesScreen()),
          GoRoute(path: '/transporter/messages',   builder: (_, __) => const MessagingScreen()),
          GoRoute(path: '/transporter/wallet',     builder: (_, __) => const WalletScreen()),
          GoRoute(path: '/transporter/profile',    builder: (_, __) => const ProfileScreen()),
        ],
      ),
    ],
  );
});
