import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_tale/core/constants/app_colors.dart';
import 'package:vibe_tale/core/constants/app_dimensions.dart';
import 'package:vibe_tale/core/constants/app_typography.dart';
import 'package:vibe_tale/core/router/app_router.dart';
import 'package:vibe_tale/core/widgets/neon_button.dart';
import 'package:vibe_tale/core/widgets/vibe_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    setState(() => _isLoading = true);
    // TODO: wire up auth provider
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      context.go(AppRoutes.library);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.screenPaddingH,
            ),
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
                      isLoading: _isLoading,
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
    required this.isLoading,
    required this.onLogin,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Yolculuğuna Başla', style: AppTypography.displayMedium),
        const SizedBox(height: AppDimensions.spaceSM),
        Text(
          'Devam etmek için bilgilerini gir.',
          style: AppTypography.bodyMedium,
        ),
        const SizedBox(height: AppDimensions.spaceXL),
        VibeTextField(
          hint: 'E-posta Adresi',
          controller: emailController,
          suffixIcon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppDimensions.spaceMD),
        VibeTextField.password(
          hint: 'Şifre',
          controller: passwordController,
          onSubmitted: (_) => onLogin(),
        ),
        const SizedBox(height: AppDimensions.spaceLG),
        NeonButton(
          label: 'GİRİŞ YAP',
          onPressed: onLogin,
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
              child: const Icon(
                Icons.face_outlined,
                color: AppColors.textSecondary,
                size: 22,
              ),
            ),
            const SizedBox(width: AppDimensions.spaceMD),
            Expanded(
              child: NeonButton.outlined(
                label: 'Sihirli Bağlantı',
                onPressed: () {},
                icon: Icons.mail_outline_rounded,
              ),
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
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
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
