import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TransporterLayout extends ConsumerWidget {
  final Widget child;
  const TransporterLayout({super.key, required this.child});

  @override Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;

    final tabs = [
      (path: '/transporter',            icon: Icons.home_rounded,    label: 'Accueil'),
      (path: '/transporter/missions',   icon: Icons.map,             label: 'Missions'),
      (path: '/transporter/deliveries', icon: Icons.local_shipping,  label: 'Livraisons'),
      (path: '/transporter/messages',   icon: Icons.chat_bubble,     label: 'Messages'),
      (path: '/transporter/profile',    icon: Icons.person,          label: 'Profil'),
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
