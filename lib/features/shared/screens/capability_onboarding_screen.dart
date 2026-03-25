import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';

class CapabilitiesScreen extends ConsumerWidget {
  const CapabilitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Capacités'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Faites évoluer votre compte',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Activez de nouvelles fonctionnalités pour tirer le meilleur parti d\'AgroConnect.',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 32),

            // Seller Card
            _buildCapabilityCard(
              context,
              title: 'Devenir Vendeur',
              description: 'Vendez vos produits agricoles directement sur la marketplace.',
              icon: Icons.agriculture,
              color: const Color(0xFF16a34a),
              status: user.canSellStatus,
              isApproved: user.canSell,
              onAction: () async {
                if (user.canSellStatus == 'none') {
                  await ref.read(authProvider.notifier).requestSell();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Demande envoyée avec succès !')),
                    );
                  }
                }
              },
            ),

            const SizedBox(height: 20),

            // Deliverer Card
            _buildCapabilityCard(
              context,
              title: 'Devenir Livreur',
              description: 'Gagnez de l\'argent en livrant des produits aux acheteurs.',
              icon: Icons.local_shipping,
              color: const Color(0xFF0284c7),
              status: user.canDeliver ? 'approved' : 'none',
              isApproved: user.canDeliver,
              onAction: () async {
                if (!user.canDeliver) {
                  await ref.read(authProvider.notifier).activateDeliver();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Mode livreur activé !')),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCapabilityCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required String status,
    required bool isApproved,
    required VoidCallback onAction,
  }) {
    String buttonText = 'Activer';
    bool isDisabled = isApproved;
    Color buttonColor = color;

    if (status == 'pending') {
      buttonText = 'En attente...';
      isDisabled = true;
      buttonColor = Colors.orange;
    } else if (isApproved) {
      buttonText = 'Déjà activé';
      isDisabled = true;
      buttonColor = Colors.grey;
    } else if (status == 'rejected') {
      buttonText = 'Rejeté (Réessayer)';
      isDisabled = false;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              if (isApproved)
                const Icon(Icons.check_circle, color: Colors.green, size: 24),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isDisabled ? null : onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                buttonText,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
