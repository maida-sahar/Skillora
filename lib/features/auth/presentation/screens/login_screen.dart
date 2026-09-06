import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import '../../../../core/utils/input_validators.dart';
import '../../../../shared/widgets/google_logo.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/buttons/custom_button.dart';

// Local light-theme palette for this screen. Centralize these in
// AppColors once the rest of the app is migrated to the light theme —
// for now they live here so this screen doesn't depend on the old
// dark tokens (which is what caused the invisible text + mismatched
// dark card you saw).
class _LoginColors {
  static const Color pageBackground = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF0F172A); // near-black
  static const Color textSecondary = Color(0xFF64748B); // muted gray
  static const Color purple = Color(0xFF6C5CE7);
  static const Color purpleLight = Color(0xFF8B7CF6);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFEDEBFB);
  static const Color fieldBorder = Color(0xFFE7E4F8);
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signInWithEmailAndPassword(
      _emailController.text,
      _passwordController.text,
    );

    if (success && mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (!success && mounted && authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage!),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _onGoogleSignIn() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signInWithGoogle();

    if (success && mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (!success && mounted && authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage!),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: _LoginColors.pageBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Lock badge on a soft purple glow — no white sticker box
                  Center(
                    child: SizedBox(
                      height: 130,
                      width: 130,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  _LoginColors.purple.withValues(alpha: 0.18),
                                  _LoginColors.purple.withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [_LoginColors.purple, _LoginColors.purpleLight],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _LoginColors.purple.withValues(alpha: 0.35),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.lock_outline_rounded, color: Colors.white, size: 34),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Fixed: was white text on a white page (invisible).
                  // Now uses the dark text color so it actually shows.
                  const Text(
                    'SKILLORA',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 3.0,
                      color: _LoginColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Cybernetic Skill Platform',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _LoginColors.purple,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Fixed: was a leftover dark navy card sitting on a
                  // white page. Now a white card with a soft shadow,
                  // matching the rest of the light theme.
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: _LoginColors.cardBackground,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: _LoginColors.cardBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Sign In to Account',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: _LoginColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Access real-time skill scores, career intelligence & scholarship grants.',
                          style: TextStyle(fontSize: 12.5, color: _LoginColors.textSecondary, height: 1.4),
                        ),
                        const SizedBox(height: 24),

                        AppTextField(
                          label: 'Email Address',
                          hint: 'name@example.com',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
                          validator: InputValidators.validateEmail,
                        ),
                        const SizedBox(height: 16),

                        AppTextField(
                          label: 'Password',
                          hint: '••••••••',
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          prefixIcon: Icons.lock_outline,
                          validator: InputValidators.validatePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: _LoginColors.textSecondary,
                              size: 20,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        const SizedBox(height: 12),

                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: authProvider.isLoading
                                ? null
                                : () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                                    );
                                  },
                            child: const Text(
                              'Forgot password?',
                              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: _LoginColors.purple),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Purple gradient primary button
                        InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: authProvider.isLoading ? null : _onLogin,
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              gradient: LinearGradient(
                                colors: [_LoginColors.purple, _LoginColors.purpleLight],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _LoginColors.purple.withValues(alpha: 0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Center(
                              child: authProvider.isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Explore Account',
                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        Row(
                          children: [
                            const Expanded(child: Divider(color: _LoginColors.fieldBorder)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'OR',
                                style: TextStyle(fontSize: 11, color: _LoginColors.textSecondary, fontWeight: FontWeight.w600),
                              ),
                            ),
                            const Expanded(child: Divider(color: _LoginColors.fieldBorder)),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Outlined secondary button (light border, not dark)
                        InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: authProvider.isLoading ? null : _onGoogleSignIn,
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: _LoginColors.fieldBorder, width: 1.2),
                            ),
                            child: const Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GoogleLogo(size: 18),
                                  SizedBox(width: 10),
                                  Text(
                                    'Continue with Google',
                                    style: TextStyle(color: _LoginColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(fontSize: 13, color: _LoginColors.textSecondary),
                      ),
                      GestureDetector(
                        onTap: authProvider.isLoading
                            ? null
                            : () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const SignupScreen()),
                                );
                              },
                        child: const Text(
                          'Sign up',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _LoginColors.purple),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}