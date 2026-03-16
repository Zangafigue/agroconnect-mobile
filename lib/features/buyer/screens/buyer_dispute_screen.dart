import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agroconnect_bf/core/config.dart';

class BuyerDisputeScreen extends StatefulWidget {
  final String orderId;
  const BuyerDisputeScreen({super.key, required this.orderId});

  @override
  State<BuyerDisputeScreen> createState() => _BuyerDisputeScreenState();
}

class _BuyerDisputeScreenState extends State<BuyerDisputeScreen> {
  String? _selectedReason;
  final List<String> _reasons = [
    'Produit non conforme',
    'Produit endommagé',
    'Quantité insuffisante',
    'Retard de livraison important',
    'Autre'
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppConfig.bgDark : AppConfig.bgLight,
      appBar: AppBar(
        title: const Text('Signaler un litige', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? AppConfig.surfaceDark : Colors.white,
        elevation: 0,
        centerTitle: true,
        foregroundColor: isDark ? Colors.white : AppConfig.textMainLight,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Recap
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppConfig.primaryColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppConfig.primaryColor.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.receipt_long, color: AppConfig.primaryColor),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Commande #${widget.orderId}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Text('Kaboré Amadou - Maïs sec', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            const Text(
              'Quelle est la raison du litige ?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? AppConfig.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppConfig.borderDark : AppConfig.borderLight),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedReason,
                  hint: const Text('Sélectionner une raison'),
                  isExpanded: true,
                  dropdownColor: isDark ? AppConfig.surfaceDark : Colors.white,
                  items: _reasons.map((String reason) {
                    return DropdownMenuItem<String>(
                      value: reason,
                      child: Text(reason),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedReason = value;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Description du problème',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            TextField(
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Expliquez en détail le problème rencontré...',
                filled: true,
                fillColor: isDark ? AppConfig.surfaceDark : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: isDark ? AppConfig.borderDark : AppConfig.borderLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: isDark ? AppConfig.borderDark : AppConfig.borderLight),
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Preuves photos (recommandé)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildAddPhotoButton(isDark),
                const SizedBox(width: 12),
                _buildAddPhotoButton(isDark),
              ],
            ),
            const SizedBox(height: 48),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedReason == null ? null : () {
                  // Logic to submit dispute
                  context.pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Litige envoyé. Notre équipe va examiner votre demande.'),
                      backgroundColor: AppConfig.error,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConfig.error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('LANCER LE LITIGE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => context.pop(),
                child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddPhotoButton(bool isDark) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: isDark ? AppConfig.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppConfig.borderDark : AppConfig.borderLight, style: BorderStyle.none),
      ),
      child: Material(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(16),
          child: const Icon(Icons.add_a_photo_outlined, color: Colors.grey),
        ),
      ),
    );
  }
}
