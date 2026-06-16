import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_tale/core/constants/app_colors.dart';
import 'package:vibe_tale/core/constants/app_dimensions.dart';
import 'package:vibe_tale/core/constants/app_typography.dart';
import 'package:vibe_tale/core/error/auth_error.dart';
import 'package:vibe_tale/core/providers/app_settings_provider.dart';
import 'package:vibe_tale/core/theme/app_theme_colors.dart';
import 'package:vibe_tale/core/widgets/neon_button.dart';
import 'package:vibe_tale/core/widgets/themed_background.dart';
import 'package:vibe_tale/core/widgets/vibe_text_field.dart';
import 'package:vibe_tale/features/auth/application/auth_provider.dart';

String? _validateEmail(String value) {
  if (value.isEmpty) return null;
  final emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');
  if (!emailRegex.hasMatch(value)) return 'Geçerli bir e-posta adresi gir.';
  return null;
}

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  String? _emailError;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onEmailChanged(String value) {
    final error = _validateEmail(value);
    if (_emailError != error) setState(() => _emailError = error);
  }

  Future<void> _handleSend() async {
    final s = ref.read(appStringsProvider);
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _emailError = s.errEmailEmpty);
      return;
    }
    final emailErr = _validateEmail(email);
    if (emailErr != null) {
      setState(() => _emailError = emailErr);
      return;
    }

    final notifier = ref.read(authNotifierProvider.notifier);
    final success = await notifier.resetPassword(email: email);

    if (!mounted) return;
    if (success) {
      setState(() => _emailSent = true);
    } else {
      final state = ref.read(authNotifierProvider);
      final msg = s.authErrorMessage(
        state is AuthError ? state.code : AuthErrorCode.unknown,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            msg,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.backgroundDeep,
            ),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is AuthLoading;
    final s = ref.watch(appStringsProvider);

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
                        const SizedBox(height: AppDimensions.spaceXL),
                        _emailSent
                            ? _SuccessView(s: s)
                            : _FormView(
                                s: s,
                                emailController: _emailController,
                                emailError: _emailError,
                                isLoading: isLoading,
                                onEmailChanged: _onEmailChanged,
                                onSend: _handleSend,
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
    );
  }
}

// ── Top bar ───────────────────────────────────────────────────────────────────

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
            child: Icon(
              Icons.arrow_back,
              color: context.vColors.textPrimary,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Form view ─────────────────────────────────────────────────────────────────

class _FormView extends StatelessWidget {
  const _FormView({
    required this.s,
    required this.emailController,
    required this.emailError,
    required this.isLoading,
    required this.onEmailChanged,
    required this.onSend,
  });

  final dynamic s;
  final TextEditingController emailController;
  final String? emailError;
  final bool isLoading;
  final ValueChanged<String> onEmailChanged;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.forgotPasswordTitle,
          style: AppTypography.displayMedium.copyWith(
            color: context.vColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.spaceSM),
        Text(
          s.forgotPasswordSubtitle,
          style: AppTypography.bodyMedium.copyWith(
            color: context.vColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppDimensions.spaceXXL),
        VibeTextField(
          hint: s.emailLabel,
          controller: emailController,
          suffixIcon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          onChanged: onEmailChanged,
          errorText: emailError,
        ),
        const SizedBox(height: AppDimensions.spaceLG),
        NeonButton(
          label: s.sendResetLink,
          onPressed: onSend,
          isLoading: isLoading,
        ),
      ],
    );
  }
}

// ── Success view ──────────────────────────────────────────────────────────────

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.s});

  final dynamic s;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: AppDimensions.spaceXXL),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            color: AppColors.primary,
            size: 36,
          ),
        ),
        const SizedBox(height: AppDimensions.spaceXL),
        Text(
          s.emailSentTitle,
          style: AppTypography.displayMedium.copyWith(
            color: context.vColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.spaceSM),
        Text(
          s.emailSentSubtitle,
          style: AppTypography.bodyMedium.copyWith(
            color: context.vColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.spaceXXL),
        NeonButton.outlined(
          label: s.backToLogin,
          onPressed: () => context.pop(),
          icon: Icons.arrow_back_rounded,
        ),
      ],
    );
  }
}
