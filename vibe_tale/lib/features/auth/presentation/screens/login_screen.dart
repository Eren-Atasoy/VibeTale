import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_tale/core/constants/app_colors.dart';
import 'package:vibe_tale/core/constants/app_dimensions.dart';
import 'package:vibe_tale/core/constants/app_typography.dart';
import 'package:vibe_tale/core/localization/app_strings.dart';
import 'package:vibe_tale/core/providers/app_settings_provider.dart';
import 'package:vibe_tale/core/router/app_router.dart';
import 'package:vibe_tale/core/theme/app_theme_colors.dart';
import 'package:vibe_tale/features/auth/application/auth_provider.dart';
import 'package:vibe_tale/core/widgets/neon_button.dart';
import 'package:vibe_tale/core/widgets/themed_background.dart';
import 'package:vibe_tale/core/widgets/vibe_text_field.dart';

// ── Validation helpers ────────────────────────────────────────────────────────

String? _validateEmail(String value, AppStrings s) {
  if (value.isEmpty) return s.errEmailEmpty;
  final emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');
  if (!emailRegex.hasMatch(value)) return s.errEmailInvalid;
  return null;
}

String? _validatePassword(String value, AppStrings s) {
  if (value.isEmpty) return s.errPasswordEmpty;
  if (value.length < 6) return s.errPasswordMin6;
  return null;
}

// ── Screen ────────────────────────────────────────────────────────────────────

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
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
    final s = ref.read(appStringsProvider);
    final error = _validateEmail(value, s);
    if (_emailError != error) setState(() => _emailError = error);
  }

  void _onPasswordChanged(String value) {
    final s = ref.read(appStringsProvider);
    final error = _validatePassword(value, s);
    if (_passwordError != error) setState(() => _passwordError = error);
  }

  bool _validateAll() {
    final s = ref.read(appStringsProvider);
    final emailErr = _validateEmail(_emailController.text, s);
    final passErr = _validatePassword(_passwordController.text, s);
    setState(() {
      _emailError = emailErr;
      _passwordError = passErr;
    });
    return emailErr == null && passErr == null;
  }

  Future<void> _handleLogin() async {
    if (!_validateAll()) return;
    setState(() => _isLoading = true);

    final success = await ref.read(authNotifierProvider.notifier).signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!success) {
      final authState = ref.read(authNotifierProvider);
      final msg = authState is AuthError ? authState.message : 'Giriş başarısız.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
          ),
        ),
      );
    }
    // On success: GoRouter redirect fires automatically via _AuthChangeNotifier
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarContrastEnforced: false,
      ),
      child: ThemedBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: true,
          body: SafeArea(
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

class _LogoSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appStringsProvider);
    return Column(
      children: [
        Text(
          'VibeTale',
          style: AppTypography.displayLarge.copyWith(
            color: context.vColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.spaceSM),
        Text(
          s.appTagline,
          style: AppTypography.tagline.copyWith(
            color: context.vColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ── Form Section ──────────────────────────────────────────────────────────────

class _FormSection extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appStringsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          s.startYourJourney,
          style: AppTypography.displayMedium.copyWith(
            color: context.vColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.spaceSM),
        Text(
          s.loginSubtitle,
          style: AppTypography.bodyMedium.copyWith(
            color: context.vColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppDimensions.spaceXL),
        VibeTextField(
          hint: s.emailLabel,
          controller: emailController,
          suffixIcon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onChanged: onEmailChanged,
          errorText: emailError,
        ),
        const SizedBox(height: AppDimensions.spaceMD),
        VibeTextField.password(
          hint: s.passwordLabel,
          controller: passwordController,
          onChanged: onPasswordChanged,
          onSubmitted: (_) => onLogin(),
          errorText: passwordError,
        ),
        const SizedBox(height: AppDimensions.spaceLG),
        NeonButton(
          label: s.loginButton,
          onPressed: onLogin,
          isLoading: isLoading,
        ),
      ],
    );
  }
}

// ── Social Section ────────────────────────────────────────────────────────────

class _SocialSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appStringsProvider);
    final c = context.vColors;
    return Column(
      children: [
        _DividerWithText(label: s.orContinueWith),
        const SizedBox(height: AppDimensions.spaceLG),
        Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: c.inputFill,
                shape: BoxShape.circle,
                border: Border.all(color: c.glassBorder, width: 1),
              ),
              child: Icon(
                Icons.face_outlined,
                color: c.textSecondary,
                size: 22,
              ),
            ),
            const SizedBox(width: AppDimensions.spaceMD),
            Expanded(
              child: NeonButton.outlined(
                label: s.magicLink,
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

class _FooterLinks extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appStringsProvider);
    return Column(
      children: [
        GestureDetector(
          onTap: () => context.push(AppRoutes.forgotPassword),
          child: Text(
            s.forgotPassword,
            style: AppTypography.bodyMedium.copyWith(
              color: context.vColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spaceMD),
        GestureDetector(
          onTap: () => context.push(AppRoutes.signup),
          child: RichText(
            text: TextSpan(
              style: AppTypography.bodyMedium.copyWith(
                color: context.vColors.textSecondary,
              ),
              children: [
                TextSpan(text: s.newHere),
                TextSpan(
                  text: s.createAccount,
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
        Expanded(child: Container(height: 0.5, color: context.vColors.glassBorder)),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceMD,
          ),
          child: Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: context.vColors.textSecondary,
            ),
          ),
        ),
        Expanded(child: Container(height: 0.5, color: context.vColors.glassBorder)),
      ],
    );
  }
}
