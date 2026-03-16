import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:agroconnect_bf/core/config.dart';
import 'package:agroconnect_bf/features/auth/providers/auth_provider.dart';
import '../../shared/widgets/double_back_to_exit.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _obscurePassword = true;

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(authProvider.notifier).login(_email, _password);
      
      if (mounted) {
        final authState = ref.read(authProvider);
        if (authState.error == null && authState.token != null) {
          context.go('/');
        } else if (authState.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authState.error!),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DoubleBackToExit(
      child: Scaffold(
        backgroundColor: isDark ? AppConfig.bgDark : AppConfig.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Logo
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 80,
                      height: 80,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'AgroConnect BF',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 48),
                const Text(
                  'Bienvenue !',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  'Connectez-vous à votre compte',
                  style: TextStyle(color: isDark ? AppConfig.textSubDark : AppConfig.textSubLight),
                ),
                const SizedBox(height: 48),

                // Email Input
                _buildInputField(
                  label: 'Email',
                  hint: 'votre@email.com',
                  isDark: isDark,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (v) => _email = v,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'L\'email est requis';
                    final emailRegex = RegExp(r'^[\w\.\-\+]+@([\w\-]+\.)+[\w\-]{2,}$');
                    if (!emailRegex.hasMatch(v)) return 'Format d\'email invalide';
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Password Input
                _buildInputField(
                  label: 'Mot de passe',
                  hint: '••••••••',
                  isDark: isDark,
                  isPassword: true,
                  obscure: _obscurePassword,
                  onChanged: (v) => _password = v,
                  toggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                
                // Forgot Password link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    child: const Text(
                      'Mot de passe oublié ?',
                      style: TextStyle(color: AppConfig.primaryColor, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Login Button
                ElevatedButton(
                  onPressed: authState.isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConfig.primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: authState.isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Se connecter', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 32),

                // Unverified Alert
                if (authState.isLoggedIn && !authState.isVerified)
                  Container(
                    margin: const EdgeInsets.only(top: 24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withAlpha(12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withAlpha(51)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.warning_rounded, color: Colors.orange, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  text: "Votre email n'est pas encore vérifié. Vous avez un accès limité à la plateforme. ",
                                  style: TextStyle(color: isDark ? Colors.orange[200] : Colors.orange[900], fontSize: 13, height: 1.4),
                                  children: [
                                    TextSpan(
                                      text: '\nRenvoyer le code de vérification →',
                                      style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () async {
                                          await ref.read(authProvider.notifier).resendOtp();
                                          if (context.mounted) {
                                            final newState = ref.read(authProvider);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(newState.error ?? 'Un nouveau code a été envoyé'),
                                                backgroundColor: newState.error != null ? Colors.red : Colors.green,
                                              ),
                                            );
                                          }
                                        },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 48),
                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[800])),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('ou', style: TextStyle(color: Colors.grey)),
                    ),
                    Expanded(child: Divider(color: Colors.grey[800])),
                  ],
                ),
                const SizedBox(height: 32),

                // Register Button
                OutlinedButton(
                  onPressed: () => context.push('/register'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark ? Colors.white : Colors.black87,
                    minimumSize: const Size(double.infinity, 60),
                    side: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Créer un compte', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 48),

                // Footer
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: 'En continuant, vous acceptez nos ',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12, height: 1.5),
                      children: const [
                        TextSpan(
                          text: 'Conditions d\'utilisation',
                          style: TextStyle(color: Colors.grey, decoration: TextDecoration.underline),
                        ),
                        TextSpan(text: ' et notre '),
                        TextSpan(
                          text: 'Politique de confidentialité',
                          style: TextStyle(color: Colors.grey, decoration: TextDecoration.underline),
                        ),
                        TextSpan(text: '.'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ), // SingleChildScrollView
      ), // SafeArea
    ), // Scaffold
  ); // DoubleBackToExit
}

  Widget _buildInputField({
    required String label,
    required String hint,
    required bool isDark,
    bool isPassword = false,
    bool obscure = false,
    TextInputType? keyboardType,
    Function(String)? onChanged,
    String? Function(String?)? validator,
    VoidCallback? toggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B).withAlpha(127) : Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            obscureText: obscure,
            onChanged: onChanged,
            validator: validator,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[500]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                      onPressed: toggleVisibility,
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
