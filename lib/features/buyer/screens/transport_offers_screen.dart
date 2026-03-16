import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agroconnect_bf/core/config.dart';

class TransportOffersScreen extends StatelessWidget {
  final String orderId;
  const TransportOffersScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppConfig.bgDark : AppConfig.bgLight,
      appBar: AppBar(
        title: Text('Offres pour #$orderId', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? AppConfig.surfaceDark : Colors.white,
        elevation: 1,
        centerTitle: true,
        foregroundColor: isDark ? Colors.white : AppConfig.textMainLight,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : AppConfig.bgLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppConfig.borderDark : AppConfig.borderLight),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppConfig.primaryColor, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Trajet: Kaya → Ouagadougou\nDistance: ~100 km',
                    style: TextStyle(
                      color: isDark ? AppConfig.textMainDark : AppConfig.textMainLight, 
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              '3 Offres reçues',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppConfig.textMainDark : AppConfig.textMainLight,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildTransportOfferCard(
            context: context,
            transporterName: 'Traoré Logistique',
            rating: 4.8,
            price: '15 000 FCFA',
            estimatedTime: 'Livraison demain à 14h',
            isDark: isDark,
            isBestOffer: true,
          ),
           _buildTransportOfferCard(
            context: context,
            transporterName: 'Express Faso',
            rating: 4.2,
            price: '12 500 FCFA',
            estimatedTime: 'Livraison dans 2 jours',
            isDark: isDark,
            isBestOffer: false,
          ),
           _buildTransportOfferCard(
            context: context,
            transporterName: 'Ouedraogo Transport',
            rating: 4.5,
            price: '18 000 FCFA',
            estimatedTime: 'Livraison demain matin',
            isDark: isDark,
            isBestOffer: false,
          ),
        ],
      ),
    );
  }

  Widget _buildTransportOfferCard({
    required BuildContext context,
    required String transporterName,
    required double rating,
    required String price,
    required String estimatedTime,
    required bool isDark,
    required bool isBestOffer,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppConfig.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isBestOffer ? AppConfig.primaryColor : (isDark ? AppConfig.borderDark : AppConfig.borderLight),
          width: isBestOffer ? 2 : 1,
        ),
        boxShadow: [
          if (!isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          if (isBestOffer)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                color: AppConfig.primaryColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: const Center(
                child: Text('MEILLEURE OFFRE (QUALITÉ/PRIX)', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                         Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppConfig.info.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.local_shipping, color: AppConfig.info, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(transporterName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? AppConfig.textMainDark : AppConfig.textMainLight)),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 14),
                                const SizedBox(width: 4),
                                Text(rating.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(price, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppConfig.primaryColor)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: isDark ? AppConfig.textSubDark : AppConfig.textSubLight),
                    const SizedBox(width: 8),
                    Text(estimatedTime, style: TextStyle(color: isDark ? AppConfig.textSubDark : AppConfig.textSubLight, fontSize: 13, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                           ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Offre refusée.'), backgroundColor: AppConfig.error)
                           );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppConfig.error,
                          side: const BorderSide(color: AppConfig.error),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Refuser', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showAcceptConfirmation(context, transporterName, price, isDark),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConfig.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                        ),
                        child: const Text('Accepter', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAcceptConfirmation(BuildContext context, String transporter, String price, bool isDark) {
     showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppConfig.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, -10))
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Confirmer l\'offre', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? AppConfig.textMainDark : AppConfig.textMainLight)),
            const SizedBox(height: 16),
            Text(
              'Vous êtes sur le point d\'accepter l\'offre de transport de $transporter pour un montant de $price. Une fois confirmée, vous pourrez procéder au paiement de la commande.',
              style: TextStyle(color: isDark ? AppConfig.textSubDark : AppConfig.textSubLight, height: 1.5, fontSize: 14),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('Annuler', style: TextStyle(color: isDark ? AppConfig.textSubDark : AppConfig.textSubLight, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.push('/buyer/payment/$orderId');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConfig.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    child: const Text('Confirmer', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
