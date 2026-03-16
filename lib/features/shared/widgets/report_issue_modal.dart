import 'package:flutter/material.dart';
import '../../../core/config.dart';

class ReportIssueModal extends StatefulWidget {
  final String orderId;
  const ReportIssueModal({super.key, required this.orderId});

  @override
  State<ReportIssueModal> createState() => _ReportIssueModalState();
}

class _ReportIssueModalState extends State<ReportIssueModal> {
  String _selectedIssue = 'Panne';
  final List<String> _issues = ['Panne', 'Accident', 'Retard', 'Route barrée', 'Litige', 'Autre'];
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppConfig.surfaceDark : AppConfig.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: Colors.red.withValues(alpha: 0.1)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 12,
        left: 24,
        right: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppConfig.borderDark : AppConfig.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.report_problem_rounded, color: Colors.red, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                'Signaler un problème', 
                style: TextStyle(
                  fontSize: 20, 
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppConfig.textMainDark : AppConfig.textMainLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Concernant la livraison ${widget.orderId}',
            style: TextStyle(color: isDark ? AppConfig.textSubDark : Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 24),
          const Text('TYPE DE PROBLÈME', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _issues.map((issue) {
              final isSelected = _selectedIssue == issue;
              return GestureDetector(
                onTap: () => setState(() => _selectedIssue = issue),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.red.withValues(alpha: 0.1) : (isDark ? Colors.white.withValues(alpha: 0.05) : AppConfig.bgLight),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Colors.red.withValues(alpha: 0.3) : Colors.transparent,
                    ),
                  ),
                  child: Text(
                    issue,
                    style: TextStyle(
                      color: isSelected ? Colors.red : (isDark ? AppConfig.textMainDark : AppConfig.textMainLight),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          const Text('DESCRIPTION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Décrivez brièvement la situation...',
              hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
              filled: true,
              fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : AppConfig.bgLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: isDark ? Colors.white10 : Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.add_a_photo_outlined, color: Colors.grey),
                      SizedBox(height: 4),
                      Text('Ajouter photo', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Signalement envoyé. Le support vous contactera si nécessaire.'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('Envoyer le signalement', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
