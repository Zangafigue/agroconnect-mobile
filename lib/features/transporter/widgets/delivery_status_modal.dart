import 'package:flutter/material.dart';
import '../../../core/config.dart';

class DeliveryStatusModal extends StatelessWidget {
  final String orderId;

  const DeliveryStatusModal({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppConfig.surfaceDark : AppConfig.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppConfig.borderDark : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Illustration
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppConfig.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.task_alt_rounded,
              size: 64,
              color: AppConfig.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          // Header
          Text(
            'Livraison réussie pour $orderId ?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22, 
              fontWeight: FontWeight.bold,
              color: isDark ? AppConfig.textMainDark : AppConfig.textMainLight,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'En validant, vous confirmez que les marchandises ont été remises à l\'acheteur en bon état.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: isDark ? AppConfig.textSubDark : AppConfig.textSubLight),
          ),
          const SizedBox(height: 24),
          // Info Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppConfig.primaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppConfig.primaryColor.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.flash_on, color: Colors.amber, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PAIEMENT INSTANTANÉ',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? AppConfig.textSubDark : Colors.grey),
                      ),
                      Text(
                        'Les fonds seront transférés sur votre compte sous 2h.',
                        style: TextStyle(
                          fontSize: 13, 
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppConfig.textMainDark : AppConfig.textMainLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Pas encore'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Feedback logic
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConfig.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('Confirmer la livraison', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
