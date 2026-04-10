import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_tale/core/constants/app_colors.dart';
import 'package:vibe_tale/core/constants/app_dimensions.dart';
import 'package:vibe_tale/core/constants/app_typography.dart';
import 'package:vibe_tale/core/router/app_router.dart';
import 'package:vibe_tale/core/widgets/neon_button.dart';
import 'package:vibe_tale/core/widgets/vibe_text_field.dart';

// ── Validation helpers ────────────────────────────────────────────────────────

String? _validateEmail(String value) {
  if (value.isEmpty) return 'E-posta adresi boş bırakılamaz.';
  final emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');
  if (!emailRegex.hasMatch(value)) return 'Geçerli bir e-posta adresi gir.';
  return null;
}

String? _validatePassword(String value) {
  if (value.isEmpty) return 'Şifre boş bırakılamaz.';
  if (value.length < 6) return 'Şifre en az 6 karakter olmalı.';
  return null;
}

// ── Screen ────────────────────────────────────────────────────────────────────

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _emailError;
  String? _passwordError;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onEmailChanged(String value) {
    final error = _validateEmail(value);
    if (_emailError != error) setState(() => _emailError = error);
  }

  void _onPasswordChanged(String value) {
    final error = _validatePassword(value);
    if (_passwordError != error) setState(() => _passwordError = error);
  }

  bool _validateAll() {
    final emailErr = _validateEmail(_emailController.text);
    final passErr = _validatePassword(_passwordController.text);
    setState(() {
      _emailError = emailErr;
      _passwordError = passErr;
    });
    return emailErr == null && passErr == null;
  }

  void _handleLogin() {
    if (!_validateAll()) return;
    setState(() => _isLoading = true);
    // TODO: wire up auth provider / REST API
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      context.go(AppRoutes.library);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Gradient wraps Scaffold so it covers the entire screen — including
    // the system navigation bar area and bottom safe-area inset.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: true,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.screenPaddingH),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: AppDimensions.spaceXXL),
                      _LogoSection(),
                      const SizedBox(height: AppDimensions.spaceXXL),
                      _FormSection(
                        emailController: _emailController,
                        passwordController: _passwordController,
                        emailError: _emailError,
                        passwordError: _passwordError,
                        isLoading: _isLoading,
                        onEmailChanged: _onEmailChanged,
                        onPasswordChanged: _onPasswordChanged,
                        onLogin: _handleLogin,
                      ),
                      const SizedBox(height: AppDimensions.spaceLG),
                      _SocialSection(),
                      const Spacer(),
                      _FooterLinks(),
                      const SizedBox(height: AppDimensions.spaceLG),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Logo Section ──────────────────────────────────────────────────────────────

class _LogoSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('VibeTale', style: AppTypography.displayLarge),
        const SizedBox(height: AppDimensions.spaceSM),
        Text('SÜRÜKLEYİCİ KÜTÜPHANENİZ', style: AppTypography.tagline),
      ],
    );
  }
}

// ── Form Section ──────────────────────────────────────────────────────────────

class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.emailController,
    required this.passwordController,
    required this.emailError,
    required this.passwordError,
    required this.isLoading,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.onLogin,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final String? emailError;
  final String? passwordError;
  final bool isLoading;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPasswordChanged;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Yolculuğuna Başla', style: AppTypography.displayMedium),
        const SizedBox(height: AppDimensions.spaceSM),
        Text('Devam etmek için bilgilerini gir.', style: AppTypography.bodyMedium),
        const SizedBox(height: AppDimensions.spaceXL),
        VibeTextField(
          hint: 'E-posta Adresi',
          controller: emailController,
          suffixIcon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onChanged: onEmailChanged,
          errorText: emailError,
        ),
        const SizedBox(height: AppDimensions.spaceMD),
        VibeTextField.password(
          hint: 'Şifre',
          controller: passwordController,
          onChanged: onPasswordChanged,
          onSubmitted: (_) => onLogin(),
          errorText: passwordError,
        ),
        const SizedBox(height: AppDimensions.spaceLG),
        NeonButton(label: 'GİRİŞ YAP', onPressed: onLogin, isLoading: isLoading),
      ],
    );
  }
}

// ── Social Section ────────────────────────────────────────────────────────────

class _SocialSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _DividerWithText(label: 'VEYA ŞUNUNLA DEVAM ET'),
        const SizedBox(height: AppDimensions.spaceLG),
        Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.glassBorder, width: 1),
              ),
              child: const Icon(Icons.face_outlined, color: AppColors.textSecondary, size: 22),
            ),
            const SizedBox(width: AppDimensions.spaceMD),
            Expanded(
              child: NeonButton.outlined(label: 'Sihirli Bağlantı', onPressed: () {}, icon: Icons.mail_outline_rounded),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Footer Links ──────────────────────────────────────────────────────────────

class _FooterLinks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {},
          child: Text('Şifremi Unuttum?', style: AppTypography.bodyMedium),
        ),
        const SizedBox(height: AppDimensions.spaceMD),
        GestureDetector(
          onTap: () => context.push(AppRoutes.signup),
          child: RichText(
            text: TextSpan(
              style: AppTypography.bodyMedium,
              children: [
                const TextSpan(text: 'Yeni misin? '),
                TextSpan(
                  text: 'Hesap Oluştur',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Divider with Label ────────────────────────────────────────────────────────

class _DividerWithText extends StatelessWidget {
  const _DividerWithText({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 0.5, color: AppColors.glassBorder)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spaceMD),
          child: Text(label, style: AppTypography.labelSmall),
        ),
        Expanded(child: Container(height: 0.5, color: AppColors.glassBorder)),
      ],
    );
  }
}
