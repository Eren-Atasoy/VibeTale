import 'package:flutter/material.dart';
import 'package:vibe_tale/core/constants/app_colors.dart';
import 'package:vibe_tale/core/constants/app_dimensions.dart';
import 'package:vibe_tale/core/constants/app_typography.dart';

/// Glassmorphic dark input field matching the VibeTale mockup style.
///
/// Usage:
/// ```dart
/// VibeTextField(
///   controller: _emailController,
///   hint: 'E-posta Adresi',
///   prefixIcon: Icons.email_outlined,
/// )
///
/// VibeTextField.password(
///   controller: _passController,
///   hint: 'Şifre',
/// )
/// ```
class VibeTextField extends StatefulWidget {
  const VibeTextField({
    super.key,
    required this.hint,
    this.controller,
    this.prefixIcon,
    this.suffixIcon,
    this.isPassword = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.label,
    this.autofocus = false,
  });

  const VibeTextField.password({
    super.key,
    required this.hint,
    this.controller,
    this.label,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
  }) : isPassword = true,
       prefixIcon = Icons.lock_outline_rounded,
       suffixIcon = null,
       keyboardType = TextInputType.visiblePassword,
       textInputAction = TextInputAction.done;

  final String hint;
  final TextEditingController? controller;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool isPassword;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? label;
  final bool autofocus;

  @override
  State<VibeTextField> createState() => _VibeTextFieldState();
}

class _VibeTextFieldState extends State<VibeTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: AppTypography.bodyMedium),
          const SizedBox(height: AppDimensions.spaceSM),
        ],
        SizedBox(
          height: AppDimensions.inputHeight,
          child: TextField(
            controller: widget.controller,
            obscureText: widget.isPassword && _obscure,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            autofocus: widget.autofocus,
            style: AppTypography.bodyLarge,
            cursorColor: AppColors.primary,
            decoration: InputDecoration(
              hintText: widget.hint,
              prefixIcon: widget.prefixIcon != null
                  ? Icon(widget.prefixIcon, size: 18)
                  : null,
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    )
                  : widget.suffixIcon != null
                  ? Icon(widget.suffixIcon, size: 18)
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
