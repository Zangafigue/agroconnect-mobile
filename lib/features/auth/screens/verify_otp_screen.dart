import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../providers/auth_provider.dart';

class VerifyOtpScreen extends ConsumerStatefulWidget {
  const VerifyOtpScreen({super.key});

  @override
  ConsumerState<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends ConsumerState<VerifyOtpScreen> {
  final _otpCtrl = TextEditingController();

  void _submit() {
    ref.read(authProvider.notifier).verifyOtp(_otpCtrl.text).then((_) {
      if (!mounted) return;
      if (ref.read(authProvider).error == null) {
        context.go('/'); // Redirige automatiquement selon le rôle !
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Code de Vérification')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text('Veuillez entrer le code à 6 chiffres reçu par email.'),
            const SizedBox(height: 30),
            PinCodeTextField(
              appContext: context,
              length: 6,
              controller: _otpCtrl,
              keyboardType: TextInputType.number,
              onChanged: (val) {},
            ),
            const SizedBox(height: 20),
            if (authState.error != null) Text(authState.error!, style: const TextStyle(color: Colors.red)),
            authState.isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(onPressed: _submit, child: const Text('Vérifier')),
          ],
        ),
      ),
    );
  }
}
