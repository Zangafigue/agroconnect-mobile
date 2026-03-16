import 'package:flutter/material.dart';
import '../../../core/config.dart';

class SubmitOfferModal extends StatefulWidget {
  final String orderId;
  final String initialPrice;

  const SubmitOfferModal({
    super.key,
    required this.orderId,
    required this.initialPrice,
  });

  @override
  State<SubmitOfferModal> createState() => _SubmitOfferModalState();
}

class _SubmitOfferModalState extends State<SubmitOfferModal> {
  late TextEditingController _priceController;
  late TextEditingController _messageController;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(text: widget.initialPrice.replaceAll(' FCFA', '').replaceAll(' ', ''));
    _messageController = TextEditingController(text: 'Je suis disponible dès demain matin pour le chargement.');
  }

  @override
  void dispose() {
    _priceController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppConfig.surfaceDark : AppConfig.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: AppConfig.primaryColor.withValues(alpha: 0.1)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppConfig.borderDark : Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                const Icon(Icons.edit_note, color: AppConfig.primaryColor, size: 28),
                const SizedBox(width: 12),
                Text('Soumettre une offre', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? AppConfig.textMainDark : AppConfig.textMainLight)),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: isDark ? AppConfig.textSubDark : Colors.grey),
                ),
              ],
            ),
          ),
          Divider(color: isDark ? AppConfig.borderDark : Colors.black12),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mission Summary Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black.withValues(alpha: 0.2) : AppConfig.bgLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : AppConfig.borderLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('MISSION ${widget.orderId}', style: const TextStyle(color: AppConfig.primaryColor, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: AppConfig.primaryColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                              child: const Text('Disponible', style: TextStyle(color: AppConfig.primaryColor, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text('Bobo-Dioulasso → Ouagadougou', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildMiniStat(context, Icons.route, '360 km'),
                            _buildMiniStat(context, Icons.schedule, '4h 30m'),
                            _buildMiniStat(context, Icons.monitor_weight_outlined, '500 kg'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Form Fields
                  const Text('Votre tarif de livraison', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppConfig.primaryColor),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDark ? Colors.black.withValues(alpha: 0.2) : AppConfig.bgLight,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.grey[800]! : AppConfig.borderLight)),
                      suffixIcon: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('FCFA', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Fourchette habituelle sur ce trajet : 12 000 – 18 000 FCFA',
                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  const Text('Message pour l\'acheteur (optionnel)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _messageController,
                    maxLines: 4,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDark ? Colors.black.withValues(alpha: 0.2) : AppConfig.bgLight,
                      hintText: 'Précisez vos disponibilités...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.grey[800]! : AppConfig.borderLight)),
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
                            side: BorderSide(color: Colors.grey[800]!),
                          ),
                          child: Text('Annuler', style: TextStyle(color: isDark ? AppConfig.textSubDark : Colors.grey, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Offre envoyée avec succès !'), backgroundColor: AppConfig.primaryColor),
                            );
                          },
                          icon: const Icon(Icons.send, size: 18),
                          label: const Text('Envoyer mon offre'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConfig.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(BuildContext context, IconData icon, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(icon, size: 14, color: isDark ? AppConfig.textSubDark : Colors.grey),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12, color: isDark ? AppConfig.textSubDark : Colors.grey)),
      ],
    );
  }
}
