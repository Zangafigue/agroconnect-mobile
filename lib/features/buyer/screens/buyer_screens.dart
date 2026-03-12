import 'package:flutter/material.dart';

class BuyerDashboardScreen extends StatelessWidget {
  const BuyerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catalogue Agricole')),
      body: const Center(
        child: Text('Catalogue des produits disponibles avec filtrage'),
      ),
    );
  }
}

class BuyerOrdersScreen extends StatelessWidget {
  const BuyerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes Commandes')),
      body: const Center(child: Text('Liste des achats (Livraison en cours, Historique)')),
    );
  }
}

class TransportOffersScreen extends StatelessWidget {
  final String orderId;
  const TransportOffersScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Offres Transport pour #$orderId')),
      body: const Center(child: Text('Liste des offres reçues par les transporteurs')),
    );
  }
}

class PaymentScreen extends StatelessWidget {
  final String orderId;
  const PaymentScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Paiement Commande #$orderId')),
      body: const Center(child: Text('Simulation CinetPay V1 (Escrow)')),
    );
  }
}
