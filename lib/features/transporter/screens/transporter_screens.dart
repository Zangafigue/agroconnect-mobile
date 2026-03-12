import 'package:flutter/material.dart';

class TransporterDashboardScreen extends StatelessWidget {
  const TransporterDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tableau de Bord Transporteur')),
      body: const Center(child: Text('Accès aux missions rapides et solde Wallet')),
    );
  }
}

class MissionsScreen extends StatelessWidget {
  const MissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Missions Disponibles')),
      body: const Center(child: Text('Liste des appels doffres de livraison')),
    );
  }
}

class MyOffersScreen extends StatelessWidget {
  const MyOffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes Offres Soumises')),
      body: const Center(child: Text('Suivi de l\'acceptation par l\'acheteur')),
    );
  }
}

class MyDeliveriesScreen extends StatelessWidget {
  const MyDeliveriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes Livraisons')),
      body: const Center(child: Text('Suivi des statuts (IN_TRANSIT, DELIVERED)')),
    );
  }
}
