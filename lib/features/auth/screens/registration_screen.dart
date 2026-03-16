import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:agroconnect_bf/core/config.dart';
import 'package:agroconnect_bf/features/auth/providers/auth_provider.dart';
import '../../shared/widgets/double_back_to_exit.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Input values
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  
  bool _obscurePassword = true;
  String _selectedRole = 'FARMER';

  // Password strength states
  bool _hasMin8Chars = false;
  bool _hasUppercase = false;
  bool _hasDigit = false;
  bool _hasSpecialChar = false;

  void _onPasswordChanged(String value) {
    setState(() {
      _password = value;
      _hasMin8Chars = value.length >= 8;
      _hasUppercase = value.contains(RegExp(r'[A-Z]'));
      _hasDigit = value.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>+-]'));
    });
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(authProvider.notifier).register({
        'firstName': _firstName,
        'lastName': _lastName,
        'email': _email,
        'password': _password,
        'confirmPassword': _confirmPassword,
        'role': _selectedRole,
      });

      if (mounted) {
        final authState = ref.read(authProvider);
        if (authState.error == null && authState.token != null) {
          context.go('/verify');
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
    final bgColor = isDark ? AppConfig.bgDark : AppConfig.bgLight;

    return DoubleBackToExit(
      child: Scaffold(
        backgroundColor: bgColor,
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo Section
                // Logo Section
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 60,
                      height: 60,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'AgroConnect BF',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Créer votre compte',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Rejoignez la communauté agricole',
                  style: TextStyle(color: isDark ? AppConfig.textSubDark : AppConfig.textSubLight),
                ),
                const SizedBox(height: 40),

                // Name fields in a row
                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        label: 'Prénom',
                        hint: 'Moussa',
                        isDark: isDark,
                        onChanged: (v) => _firstName = v,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInputField(
                        label: 'Nom',
                        hint: 'Traoré',
                        isDark: isDark,
                        onChanged: (v) => _lastName = v,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Email field
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
                const SizedBox(height: 20),

                // Password field
                _buildInputField(
                  label: 'Mot de passe',
                  hint: '••••••••',
                  isDark: isDark,
                  isPassword: true,
                  obscure: _obscurePassword,
                  onChanged: _onPasswordChanged,
                  toggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                const SizedBox(height: 20),

                // Confirm Password field
                _buildInputField(
                  label: 'Confirmer le mot de passe',
                  hint: '••••••••',
                  isDark: isDark,
                  isPassword: true,
                  obscure: true, // Always obscure confirm
                  onChanged: (v) => _confirmPassword = v,
                ),
                const SizedBox(height: 16),

                // Strength Indicators
                _buildStrengthProgress(),
                const SizedBox(height: 12),
                _buildStrengthRules(),
                const SizedBox(height: 32),

                // Role Selection
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Je suis un :',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildRoleCard('FARMER', Icons.psychology_alt, 'AGRICULTEUR'),
                    _buildRoleCard('BUYER', Icons.shopping_cart, 'ACHETEUR'),
                    _buildRoleCard('TRANSPORTER', Icons.local_shipping, 'TRANSPORTEUR'),
                  ],
                ),
                const SizedBox(height: 40),

                // Submit Button
                ElevatedButton(
                  onPressed: authState.isLoading ? null : _handleRegister,
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
                      : const Text(
                          'Créer mon compte',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),
                const SizedBox(height: 24),

                // Switch to login
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: RichText(
                    text: TextSpan(
                      text: 'Déjà un compte ? ',
                      style: TextStyle(color: isDark ? AppConfig.textSubDark : AppConfig.textSubLight),
                      children: const [
                        TextSpan(
                          text: 'Se connecter →',
                          style: TextStyle(color: AppConfig.primaryColor, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
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

  Widget _buildStrengthProgress() {
    int score = 0;
    if (_hasMin8Chars) score++;
    if (_hasUppercase) score++;
    if (_hasDigit) score++;
    if (_hasSpecialChar) score++;

    return Row(
      children: List.generate(4, (index) {
        bool isActive = index < score;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: index == 3 ? 0 : 4),
            decoration: BoxDecoration(
              color: isActive ? AppConfig.primaryColor : Colors.grey[800],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStrengthRules() {
    return Column(
      children: [
        Row(
          children: [
            _buildRuleItem('8 caractères minimum', _hasMin8Chars),
            const SizedBox(width: 16),
            _buildRuleItem('Un chiffre', _hasDigit),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildRuleItem('Une majuscule', _hasUppercase),
            const SizedBox(width: 16),
            _buildRuleItem('Un caractère spécial', _hasSpecialChar),
          ],
        ),
      ],
    );
  }

  Widget _buildRuleItem(String text, bool isValid) {
    return Expanded(
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check : Icons.close,
            size: 14,
            color: isValid ? AppConfig.primaryColor : Colors.grey[600],
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: isValid ? AppConfig.primaryColor : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard(String role, IconData icon, String label) {
    bool isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? AppConfig.primaryColor.withAlpha(25) : const Color(0xFF1E293B).withAlpha(127),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppConfig.primaryColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppConfig.primaryColor : Colors.grey[500],
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppConfig.primaryColor : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
