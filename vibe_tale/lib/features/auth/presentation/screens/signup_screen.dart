import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_tale/core/constants/app_colors.dart';
import 'package:vibe_tale/core/constants/app_dimensions.dart';
import 'package:vibe_tale/core/constants/app_typography.dart';
import 'package:vibe_tale/core/router/app_router.dart';
import 'package:vibe_tale/core/widgets/neon_button.dart';
import 'package:vibe_tale/core/widgets/vibe_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignup() {
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
                        isLoading: _isLoading,
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
          // Balance the row width
          const SizedBox(width: 22),
        ],
      ),
    );
  }
}

/// Amber dash for active step, small circles for inactive — matches mockup.
class _PageIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Active — amber elongated dash
        Container(
          width: 28,
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
          ),
        ),
        const SizedBox(width: 6),
        // Inactive dots
        for (int i = 0; i < 3; i++) ...[
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
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
        // "Hikayeni Başlat" — white + amber italic
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
    required this.isLoading,
    required this.onSignup,
  });

  final TextEditingController emailController;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool isLoading;
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
        ),
        const SizedBox(height: AppDimensions.spaceMD),
        VibeTextField(
          hint: '@bookworm',
          label: 'Kullanıcı Adı',
          controller: usernameController,
          prefixIcon: Icons.circle_outlined,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppDimensions.spaceMD),
        VibeTextField.password(
          hint: '••••••••',
          label: 'Şifre',
          controller: passwordController,
          onSubmitted: (_) => onSignup(),
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
        _DividerWithText(label: 'Veya şununla hızlandır:'),
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

/// Dark-outlined social button matching mockup (dark bg, white text, icon).
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
