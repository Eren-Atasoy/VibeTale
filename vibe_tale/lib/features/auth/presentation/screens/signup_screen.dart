import 'package:flutter/material.dart';
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

String? _validateUsername(String value) {
  if (value.isEmpty) return 'Kullanıcı adı boş bırakılamaz.';
  if (value.length < 3) return 'Kullanıcı adı en az 3 karakter olmalı.';
  final usernameRegex = RegExp(r'^@?[a-zA-Z0-9_.]+$');
  if (!usernameRegex.hasMatch(value)) {
    return 'Sadece harf, rakam, nokta ve alt çizgi kullanılabilir.';
  }
  return null;
}

String? _validatePassword(String value) {
  if (value.isEmpty) return 'Şifre boş bırakılamaz.';
  if (value.length < 8) return 'Şifre en az 8 karakter olmalı.';
  return null;
}

// ── Screen ────────────────────────────────────────────────────────────────────

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _emailError;
  String? _usernameError;
  String? _passwordError;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onEmailChanged(String value) {
    final error = _validateEmail(value);
    if (_emailError != error) setState(() => _emailError = error);
  }

  void _onUsernameChanged(String value) {
    final error = _validateUsername(value);
    if (_usernameError != error) setState(() => _usernameError = error);
  }

  void _onPasswordChanged(String value) {
    final error = _validatePassword(value);
    if (_passwordError != error) setState(() => _passwordError = error);
  }

  bool _validateAll() {
    final emailErr = _validateEmail(_emailController.text);
    final usernameErr = _validateUsername(_usernameController.text);
    final passErr = _validatePassword(_passwordController.text);
    setState(() {
      _emailError = emailErr;
      _usernameError = usernameErr;
      _passwordError = passErr;
    });
    return emailErr == null && usernameErr == null && passErr == null;
  }

  void _handleSignup() {
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
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              _TopBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.screenPaddingH,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppDimensions.spaceLG),
                      _HeadingSection(),
                      const SizedBox(height: AppDimensions.spaceXL),
                      _FormSection(
                        emailController: _emailController,
                        usernameController: _usernameController,
                        passwordController: _passwordController,
                        emailError: _emailError,
                        usernameError: _usernameError,
                        passwordError: _passwordError,
                        isLoading: _isLoading,
                        onEmailChanged: _onEmailChanged,
                        onUsernameChanged: _onUsernameChanged,
                        onPasswordChanged: _onPasswordChanged,
                        onSignup: _handleSignup,
                      ),
                      const SizedBox(height: AppDimensions.spaceLG),
                      _SocialSection(),
                      const SizedBox(height: AppDimensions.spaceXL),
                      _FooterLink(),
                      const SizedBox(height: AppDimensions.spaceLG),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Top Bar: Back + Page Indicator ───────────────────────────────────────────

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPaddingH,
        vertical: AppDimensions.spaceMD,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const Icon(
              Icons.arrow_back,
              color: AppColors.textPrimary,
              size: 22,
            ),
          ),
          Expanded(child: _PageIndicator()),
          const SizedBox(width: 22),
        ],
      ),
    );
  }
}

/// Amber dash for active step, small grey circles for inactive.
class _PageIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 28,
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
          ),
        ),
        const SizedBox(width: 6),
        for (int i = 0; i < 3; i++) ...[
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.glassBorder,
              shape: BoxShape.circle,
            ),
          ),
          if (i < 2) const SizedBox(width: 6),
        ],
      ],
    );
  }
}

// ── Heading Section ───────────────────────────────────────────────────────────

class _HeadingSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: AppTypography.displayMedium,
            children: [
              const TextSpan(text: 'Hikayeni '),
              TextSpan(
                text: 'Başlat',
                style: AppTypography.displayMedium.copyWith(
                  color: AppColors.primary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.spaceSM),
        Text(
          'Kütüphaneni düzenlememize izin ver.\nKişiselleştirmeye başlamak için bilgilerini gir.',
          style: AppTypography.bodyMedium,
        ),
      ],
    );
  }
}

// ── Form Section ──────────────────────────────────────────────────────────────

class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.emailController,
    required this.usernameController,
    required this.passwordController,
    required this.emailError,
    required this.usernameError,
    required this.passwordError,
    required this.isLoading,
    required this.onEmailChanged,
    required this.onUsernameChanged,
    required this.onPasswordChanged,
    required this.onSignup,
  });

  final TextEditingController emailController;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final String? emailError;
  final String? usernameError;
  final String? passwordError;
  final bool isLoading;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onUsernameChanged;
  final ValueChanged<String> onPasswordChanged;
  final VoidCallback onSignup;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        VibeTextField(
          hint: 'name@example.com',
          label: 'E-posta Adresi',
          controller: emailController,
          prefixIcon: Icons.circle_outlined,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onChanged: onEmailChanged,
          errorText: emailError,
        ),
        const SizedBox(height: AppDimensions.spaceMD),
        VibeTextField(
          hint: '@bookworm',
          label: 'Kullanıcı Adı',
          controller: usernameController,
          prefixIcon: Icons.circle_outlined,
          textInputAction: TextInputAction.next,
          onChanged: onUsernameChanged,
          errorText: usernameError,
        ),
        const SizedBox(height: AppDimensions.spaceMD),
        VibeTextField.password(
          hint: '••••••••',
          label: 'Şifre',
          controller: passwordController,
          onChanged: onPasswordChanged,
          onSubmitted: (_) => onSignup(),
          errorText: passwordError,
        ),
        const SizedBox(height: AppDimensions.spaceLG),
        NeonButton(
          label: 'Devam Et  →',
          onPressed: onSignup,
          isLoading: isLoading,
        ),
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
        const _DividerWithText(label: 'Veya şununla hızlandır:'),
        const SizedBox(height: AppDimensions.spaceLG),
        Row(
          children: [
            Expanded(
              child: _SocialOutlineButton(
                label: 'Google',
                icon: Icons.g_mobiledata_rounded,
                onPressed: () {},
              ),
            ),
            const SizedBox(width: AppDimensions.spaceMD),
            Expanded(
              child: _SocialOutlineButton(
                label: 'Apple',
                icon: Icons.person_outline_rounded,
                onPressed: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SocialOutlineButton extends StatelessWidget {
  const _SocialOutlineButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimensions.buttonHeight,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.inputFill,
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.glassBorder, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
          ),
        ),
        icon: Icon(icon, size: 20, color: AppColors.textPrimary),
        label: Text(label, style: AppTypography.titleMedium),
      ),
    );
  }
}

// ── Footer Link ───────────────────────────────────────────────────────────────

class _FooterLink extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => context.pop(),
        child: RichText(
          text: TextSpan(
            style: AppTypography.bodyMedium,
            children: [
              const TextSpan(text: 'Zaten üye misin? '),
              TextSpan(
                text: 'Giriş Yap',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
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
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceMD,
          ),
          child: Text(label, style: AppTypography.labelSmall),
        ),
        Expanded(child: Container(height: 0.5, color: AppColors.glassBorder)),
      ],
    );
  }
}
