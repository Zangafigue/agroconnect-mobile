import 'package:flutter/material.dart';
import '../../../../core/config.dart';

class WithdrawalModal extends StatefulWidget {
  const WithdrawalModal({super.key});

  @override
  State<WithdrawalModal> createState() => _WithdrawalModalState();
}

class _WithdrawalModalState extends State<WithdrawalModal> {
  String _selectedMethod = 'Orange Money';
  final _amountController = TextEditingController();
  final _phoneController = TextEditingController();

  final List<Map<String, dynamic>> _methods = [
    {'name': 'Orange Money', 'icon': Icons.phone_android, 'color': Colors.orange},
    {'name': 'Moov Money', 'icon': Icons.phone_android, 'color': Colors.blue},
    {'name': 'Virement Bancaire', 'icon': Icons.account_balance, 'color': Colors.green},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 12,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppConfig.surfaceDark : AppConfig.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: isDark ? AppConfig.borderDark : AppConfig.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Text(
                'Retrait de fonds',
                style: TextStyle(
                  fontSize: 22, 
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppConfig.textMainDark : AppConfig.textMainLight,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Balance Display (Standardized)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppConfig.primaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppConfig.primaryColor.withValues(alpha: 0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SOLDE DISPONIBLE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppConfig.textSubDark : AppConfig.textSubLight,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '185 000 FCFA',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: AppConfig.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          const Text(
            'Choisir le mode de retrait',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Row(
            children: _methods.map((method) {
              final isSelected = _selectedMethod == method['name'];
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedMethod = method['name']!),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? AppConfig.primaryColor.withValues(alpha: 0.1) 
                          : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100]),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppConfig.primaryColor : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          method['icon'] as IconData,
                          color: isSelected ? AppConfig.primaryColor : Colors.grey,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          method['name'] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? AppConfig.primaryColor : (isDark ? AppConfig.textSubDark : Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 24),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              labelText: 'Montant à retirer',
              hintText: '0',
              suffixText: 'FCFA',
              prefixIcon: const Icon(Icons.payments_outlined, color: AppConfig.primaryColor),
              filled: true,
              fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: _selectedMethod == 'Virement Bancaire' ? 'Numéro de compte' : 'Numéro de téléphone',
              hintText: _selectedMethod == 'Virement Bancaire' ? 'BF0123...' : '+226 XX XX XX XX',
              prefixIcon: Icon(
                _selectedMethod == 'Virement Bancaire' ? Icons.account_balance_outlined : Icons.phone_android_outlined,
                color: AppConfig.primaryColor,
              ),
              filled: true,
              fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          // Info Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppConfig.primaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppConfig.primaryColor, size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Le transfert sera traité sous 24h ouvrées.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppConfig.textSubDark : Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 12),
                      Text('Demande de retrait confirmée !'),
                    ],
                  ),
                  backgroundColor: AppConfig.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConfig.primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Text('Confirmer le retrait', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
