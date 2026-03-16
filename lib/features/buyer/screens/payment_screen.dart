import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agroconnect_bf/core/config.dart';

class PaymentScreen extends StatefulWidget {
  final String orderId;
  const PaymentScreen({super.key, required this.orderId});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMethod = 'OM'; // Default method

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppConfig.bgDark : AppConfig.bgLight,
      appBar: AppBar(
        title: const Text('Paiement', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? AppConfig.surfaceDark : Colors.white,
        elevation: 1,
        centerTitle: true,
        foregroundColor: isDark ? Colors.white : AppConfig.textMainLight,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppConfig.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? AppConfig.borderDark : AppConfig.borderLight),
                boxShadow: [
                  if (!isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 8))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Résumé de la commande', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? AppConfig.textMainDark : AppConfig.textMainLight)),
                  const SizedBox(height: 20),
                  _buildSummaryRow('Achat (Maïs sec)', '25 000 FCFA', isDark),
                  const SizedBox(height: 12),
                  _buildSummaryRow('Transport (Kaya → Oua)', '12 500 FCFA', isDark),
                  const SizedBox(height: 12),
                  _buildSummaryRow('Frais de plateforme', '1 500 FCFA', isDark),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total à payer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? AppConfig.textMainDark : AppConfig.textMainLight)),
                      const Text('39 000 FCFA', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppConfig.primaryColor)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Payment Methods
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 16),
              child: Text('Moyen de paiement', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? AppConfig.textMainDark : AppConfig.textMainLight)),
            ),
            _buildPaymentMethodTile(
              method: 'OM',
              title: 'Orange Money',
              subtitle: 'Payer avec Orange Money',
              iconColor: Colors.orange,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildPaymentMethodTile(
              method: 'Moov',
              title: 'Moov Money',
              subtitle: 'Payer avec Moov Money',
              iconColor: Colors.blue,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildPaymentMethodTile(
              method: 'Card',
              title: 'Carte Bancaire',
              subtitle: 'Visa / Mastercard',
              iconColor: Colors.indigo,
              isDark: isDark,
            ),
            const SizedBox(height: 48),

            // Pay Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _simulatePayment(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConfig.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                ),
                child: const Text('Confirmer le paiement', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
             const SizedBox(height: 20),
             Center(
               child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     Icon(Icons.lock_outline, size: 14, color: isDark ? AppConfig.textSubDark : AppConfig.textSubLight),
                     const SizedBox(width: 8),
                     Text('Paiement sécurisé par simulation Escrow', style: TextStyle(color: isDark ? AppConfig.textSubDark : AppConfig.textSubLight, fontSize: 12)),
                  ],
               ),
             ),
             const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: isDark ? AppConfig.textSubDark : AppConfig.textSubLight, fontSize: 14, fontWeight: FontWeight.w500)),
        Text(value, style: TextStyle(color: isDark ? AppConfig.textMainDark : AppConfig.textMainLight, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildPaymentMethodTile({
    required String method,
    required String title,
    required String subtitle,
    required Color iconColor,
    required bool isDark,
  }) {
    final isSelected = _selectedMethod == method;

    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = method),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppConfig.primaryColor.withValues(alpha: 0.05) : (isDark ? AppConfig.surfaceDark : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppConfig.primaryColor : (isDark ? AppConfig.borderDark : AppConfig.borderLight),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(Icons.account_balance_wallet, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? AppConfig.textMainDark : AppConfig.textMainLight)),
                  Text(subtitle, style: TextStyle(color: isDark ? AppConfig.textSubDark : AppConfig.textSubLight, fontSize: 13)),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? AppConfig.primaryColor : (isDark ? AppConfig.textSubDark : AppConfig.textSubLight),
            ),
          ],
        ),
      ),
    );
  }

  void _simulatePayment(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppConfig.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: AppConfig.primaryColor),
            const SizedBox(height: 24),
            Text(
              'Initialisation du paiement...',
              style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? AppConfig.textMainDark : AppConfig.textMainLight),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (!context.mounted) return;
      Navigator.pop(context); // Close loading

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppConfig.surfaceDark : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppConfig.success.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.check_circle, color: AppConfig.success, size: 56),
              ),
              const SizedBox(height: 24),
              Text(
                'Paiement Réussi !',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? AppConfig.textMainDark : AppConfig.textMainLight),
              ),
              const SizedBox(height: 16),
              Text(
                'Les fonds sont sécurisés. Le transporteur va être notifié pour démarrer la livraison.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? AppConfig.textSubDark : AppConfig.textSubLight, height: 1.5, fontSize: 14),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    context.go('/buyer/orders');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConfig.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                  ),
                  child: const Text('Voir mes commandes', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      );
    });
  }
}
