import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:agroconnect_bf/core/config.dart';
import 'package:agroconnect_bf/features/auth/providers/auth_provider.dart';
import '../../shared/widgets/double_back_to_exit.dart';

class VerificationScreen extends ConsumerStatefulWidget {
  const VerificationScreen({super.key});

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  Timer? _timer;
  int _secondsRemaining = 600; // 10 minutes

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _onOtpChanged(String value, int index) {
    if (value.isNotEmpty) {
      setState(() {}); // Update border color
    }
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _verifyAccount() async {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer le code complet')),
      );
      return;
    }

    await ref.read(authProvider.notifier).verifyOtp(otp);

    if (mounted) {
      final authState = ref.read(authProvider);
      if (authState.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authState.error!),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _showChangeEmailDialog() {
    final controller = TextEditingController(text: ref.read(authProvider).user?.email ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier l\'email'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Nouvel email',
              hintText: 'exemple@domaine.com',
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'L\'email est requis';
              final emailRegex = RegExp(r'^[\w\.\-\+]+@([\w\-]+\.)+[\w\-]{2,}$');
              if (!emailRegex.hasMatch(v)) return 'Format invalide';
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final newEmail = controller.text.trim();
                Navigator.pop(context);
                await ref.read(authProvider.notifier).changeEmail(newEmail);
                if (context.mounted) {
                  final authState = ref.read(authProvider);
                  if (authState.error == null) {
                    setState(() {
                      _secondsRemaining = 600;
                    });
                    _startTimer();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Email mis à jour avec succès')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(authState.error!), backgroundColor: Colors.red),
                    );
                  }
                }
              }
            },
            child: const Text('Modifier'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    if (authState.isVerified) {
      return _buildSuccessState(authState.user?.fullName ?? '');
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppConfig.bgDark : AppConfig.bgLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Email Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppConfig.primaryColor.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.email_rounded, size: 60, color: AppConfig.primaryColor),
            ),
            const SizedBox(height: 40),
            const Text(
              'Vérifiez votre email',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: 'Un code à 6 chiffres a été envoyé à\n',
                style: TextStyle(color: isDark ? AppConfig.textSubDark : AppConfig.textSubLight, height: 1.5),
                children: [
                  TextSpan(
                    text: authState.user?.email ?? 'votre adresse email',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppConfig.primaryColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: authState.isLoading ? null : _showChangeEmailDialog,
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: const Text('Modifier l\'adresse email'),
              style: TextButton.styleFrom(
                foregroundColor: AppConfig.primaryColor,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(height: 32),

            // OTP Inputs
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return _buildOtpBox(index, isDark);
              }),
            ),
            const SizedBox(height: 24),

            // Timer
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timer_outlined, size: 16, color: isDark ? AppConfig.textSubDark : AppConfig.textSubLight),
                const SizedBox(width: 8),
                Text(
                  'Le code expire dans ${_formatTime(_secondsRemaining)}',
                  style: TextStyle(
                    color: _secondsRemaining < 60 ? Colors.redAccent : (isDark ? AppConfig.textSubDark : AppConfig.textSubLight),
                    fontSize: 13,
                    fontWeight: _secondsRemaining < 60 ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),

            // Verify Button
            ElevatedButton(
              onPressed: authState.isLoading ? null : _verifyAccount,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConfig.primaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: authState.isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Vérifier mon compte', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 32),

            // Resend link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Vous n'avez pas reçu le code ? ",
                  style: TextStyle(color: isDark ? AppConfig.textSubDark : AppConfig.textSubLight),
                ),
                TextButton(
                  onPressed: authState.isLoading ? null : () async {
                    await ref.read(authProvider.notifier).resendOtp();
                    if (context.mounted) {
                      final newState = ref.read(authProvider);
                      if (newState.error == null) {
                        setState(() {
                          _secondsRemaining = 600;
                        });
                        _startTimer();
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(newState.error ?? 'Un nouveau code a été envoyé'),
                          backgroundColor: newState.error != null ? Colors.red : Colors.green,
                        ),
                      );
                    }
                  },
                  child: const Text('Renvoyer', style: TextStyle(color: AppConfig.primaryColor, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B).withAlpha(127) : Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.withAlpha(51)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        'EN ATTENDANT LA VÉRIFICATION',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildLockedItem(Icons.check_circle, 'Parcourir le catalogue de produits', true),
                  const SizedBox(height: 10),
                  _buildLockedItem(Icons.cancel, 'Passer une commande', false),
                  const SizedBox(height: 10),
                  _buildLockedItem(Icons.cancel, 'Envoyer des messages', false),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // Skip for now
            TextButton(
              onPressed: () {
                final authState = ref.read(authProvider);
                final destination = switch (authState.role) {
                  'FARMER'      => '/farmer',
                  'BUYER'       => '/buyer',
                  'TRANSPORTER' => '/transporter',
                  _             => '/',
                };
                context.push(destination); // Use push to allow going back if needed, or go if strict
              },
              child: Text(
                'Vérifier plus tard',
                style: TextStyle(
                  color: isDark ? AppConfig.textSubDark : AppConfig.textSubLight,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpBox(int index, bool isDark) {
    return Container(
      width: 48,
      height: 56,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B).withAlpha(127) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _controllers[index].text.isNotEmpty ? AppConfig.primaryColor : Colors.grey[800]!,
          width: 2,
        ),
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        onChanged: (text) => _onOtpChanged(text, index),
      ),
    );
  }

  Widget _buildLockedItem(IconData icon, String text, bool isUnlocked) {
    return Row(
      children: [
        Icon(icon, size: 18, color: isUnlocked ? AppConfig.primaryColor : Colors.grey[600]),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: isUnlocked ? Colors.grey[300] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessState(String userName) {
    // Immediate role-based redirection
    Future.microtask(() {
      if (mounted) {
        final authState = ref.read(authProvider);
        final destination = switch (authState.role) {
          'FARMER'      => '/farmer',
          'BUYER'       => '/buyer',
          'TRANSPORTER' => '/transporter',
          _             => '/',
        };
        context.go(destination);
      }
    });

    return DoubleBackToExit(
      child: Scaffold(
        backgroundColor: AppConfig.bgDark,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: AppConfig.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 60, color: Colors.white),
              ),
              const SizedBox(height: 40),
              const Text(
                'Compte vérifié !',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                'Bienvenue sur AgroConnect BF,\n$userName 👋',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, color: Colors.grey, height: 1.5),
              ),
              const SizedBox(height: 60),
              const Text(
                'Redirection en cours...',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: index == 0 ? AppConfig.primaryColor : Colors.grey[800],
                    shape: BoxShape.circle,
                  ),
                )),
              ),
              const SizedBox(height: 60),
              TextButton.icon(
                onPressed: () => context.go('/'),
                icon: const Text('Aller à mon dashboard maintenant', style: TextStyle(color: AppConfig.primaryColor, fontWeight: FontWeight.bold)),
                label: const Icon(Icons.arrow_forward, color: AppConfig.primaryColor),
              ),
            ],
          ),
        ), // Center
      ), // Scaffold
    ), // DoubleBackToExit
  ); // build
}
}
