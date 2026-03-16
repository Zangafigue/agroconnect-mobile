import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agroconnect_bf/core/config.dart';
import '../providers/auth_provider.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key, required this.email});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSuccess = false;

  @override
  void dispose() {
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate()) return;

    final otp = _otpController.text.trim();
    final password = _passwordController.text;

    await ref.read(authProvider.notifier).resetPassword(widget.email, otp, password);

    final authState = ref.read(authProvider);
    if (authState.error != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authState.error!), backgroundColor: Colors.red),
        );
      }
    } else {
      setState(() => _isSuccess = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isSuccess) {
      return _buildSuccessState();
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: isDark ? AppConfig.bgDark : AppConfig.bgLight,
      appBar: AppBar(
        title: const Text('Réinitialisation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Icon(Icons.lock_open_rounded, size: 80, color: AppConfig.primaryColor),
                const SizedBox(height: 24),
                Text(
                  'Réinitialisation pour ${widget.email}',
                  style: TextStyle(color: isDark ? AppConfig.textSubDark : AppConfig.textSubLight, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // OTP Field
                _buildInputField(
                  controller: _otpController,
                  label: 'Code reçu par email',
                  hint: 'Code à 6 chiffres',
                  isDark: isDark,
                  keyboardType: TextInputType.number,
                  validator: (v) => v != null && v.length == 6 ? null : 'Le code doit avoir 6 chiffres',
                ),
                const SizedBox(height: 24),

                // New Password
                _buildInputField(
                  controller: _passwordController,
                  label: 'Nouveau mot de passe',
                  hint: '••••••••',
                  isDark: isDark,
                  isPassword: true,
                  obscure: _obscurePassword,
                  toggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                  validator: (v) => v != null && v.length >= 6 ? null : 'Min. 6 caractères',
                ),
                const SizedBox(height: 24),

                // Confirm Password
                _buildInputField(
                  controller: _confirmPasswordController,
                  label: 'Confirmer le mot de passe',
                  hint: '••••••••',
                  isDark: isDark,
                  isPassword: true,
                  obscure: true, // Fixed confirm password obscure
                  validator: (v) => v == _passwordController.text ? null : 'Les mots de passe ne correspondent pas',
                ),
                const SizedBox(height: 48),

                ElevatedButton(
                  onPressed: authState.isLoading ? null : _handleReset,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConfig.primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: authState.isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Réinitialiser le mot de passe', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isDark,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? toggleVisibility,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.5) : Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            validator: validator,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[500]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              suffixIcon: isPassword ? IconButton(icon: Icon(obscure ? Icons.visibility : Icons.visibility_off), onPressed: toggleVisibility) : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessState() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) context.go('/login');
    });

    return Scaffold(
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
                'Succès !',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 16),
              const Text(
                'Votre mot de passe a été réinitialisé.\nVous pouvez maintenant vous connecter.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey, height: 1.5),
              ),
              const SizedBox(height: 60),
              const Text(
                'Redirection vers la connexion dans 3 secondes...',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 60),
              TextButton.icon(
                onPressed: () => context.go('/login'),
                icon: const Text('Se connecter maintenant', style: TextStyle(color: AppConfig.primaryColor, fontWeight: FontWeight.bold)),
                label: const Icon(Icons.arrow_forward, color: AppConfig.primaryColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
