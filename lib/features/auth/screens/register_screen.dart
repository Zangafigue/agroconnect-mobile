import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  String _role = 'FARMER';

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ref.read(authProvider.notifier).register({
        'email': _emailCtrl.text,
        'password': _passCtrl.text,
        'firstName': _firstNameCtrl.text,
        'lastName': _lastNameCtrl.text,
        'role': _role,
      }).then((_) {
        if (!mounted) return;
        // En cas de succès, aller vérifier le code
        if (ref.read(authProvider).error == null) {
           context.push('/verify-otp');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Inscription')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (authState.error != null) Text(authState.error!, style: const TextStyle(color: Colors.red)),
              DropdownButtonFormField<String>(
                initialValue: _role,
                items: const [
                  DropdownMenuItem(value: 'FARMER', child: Text('Agriculteur')),
                  DropdownMenuItem(value: 'BUYER', child: Text('Acheteur')),
                  DropdownMenuItem(value: 'TRANSPORTER', child: Text('Transporteur')),
                ],
                onChanged: (v) => setState(() => _role = v.toString()),
              ),
              TextFormField(controller: _firstNameCtrl, decoration: const InputDecoration(labelText: 'Prénom')),
              TextFormField(controller: _lastNameCtrl, decoration: const InputDecoration(labelText: 'Nom')),
              TextFormField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
              TextFormField(controller: _passCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Mot de passe')),
              const SizedBox(height: 20),
              authState.isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(onPressed: _submit, child: const Text('S\'inscrire')),
            ],
          ),
        ),
      ),
    );
  }
}
