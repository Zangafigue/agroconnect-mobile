import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BuyerLayout extends ConsumerWidget {
  final Widget child;
  const BuyerLayout({super.key, required this.child});

  @override Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;

    final tabs = [
      (path: '/buyer',          icon: Icons.home_rounded,    label: 'Accueil'),
      (path: '/buyer/orders',   icon: Icons.shopping_cart,   label: 'Commandes'),
      (path: '/buyer/messages', icon: Icons.chat_bubble,     label: 'Messages'),
      (path: '/buyer/profile',  icon: Icons.person,          label: 'Profil'),
    ];

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: tabs.indexWhere((t) => location.startsWith(t.path)).clamp(0, tabs.length - 1),
        selectedItemColor: const Color(0xFF16a34a),
        unselectedItemColor: const Color(0xFF9ca3af),
        type: BottomNavigationBarType.fixed,
        onTap: (i) => context.go(tabs[i].path),
        items: tabs.map((t) => BottomNavigationBarItem(
          icon: Icon(t.icon), label: t.label,
        )).toList(),
      ),
    );
  }
}
