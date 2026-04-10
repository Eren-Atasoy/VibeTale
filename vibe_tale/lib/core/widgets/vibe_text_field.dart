import 'package:flutter/material.dart';
import 'package:vibe_tale/core/constants/app_colors.dart';
import 'package:vibe_tale/core/constants/app_dimensions.dart';
import 'package:vibe_tale/core/constants/app_typography.dart';

/// Glassmorphic dark input field matching the VibeTale mockup style.
///
/// Displays [errorText] below the field when non-null; clears automatically
/// when the parent sets it back to null.
///
/// Usage:
/// ```dart
/// VibeTextField(
///   controller: _emailController,
///   hint: 'E-posta Adresi',
///   suffixIcon: Icons.email_outlined,
///   errorText: _emailError,
///   onChanged: _validateEmail,
/// )
///
/// VibeTextField.password(
///   controller: _passController,
///   hint: 'Şifre',
///   errorText: _passwordError,
///   onChanged: _validatePassword,
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
    this.errorText,
    this.autofocus = false,
  });

  const VibeTextField.password({
    super.key,
    required this.hint,
    this.controller,
    this.label,
    this.onChanged,
    this.onSubmitted,
    this.errorText,
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

  /// When non-null, shows a red error message directly below the field.
  /// Set to null to clear the error.
  final String? errorText;
  final bool autofocus;

  @override
  State<VibeTextField> createState() => _VibeTextFieldState();
}

class _VibeTextFieldState extends State<VibeTextField> {
  bool _obscure = true;
  bool _hasFocus = false;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()
      ..addListener(() {
        setState(() => _hasFocus = _focusNode.hasFocus);
      });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  bool get _hasError =>
      widget.errorText != null && widget.errorText!.isNotEmpty;

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
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: AppDimensions.inputHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
            border: Border.all(
              color: _hasError
                  ? AppColors.error
                  : _hasFocus
                  ? AppColors.primary
                  : Colors.transparent,
              width: _hasError || _hasFocus ? 1.5 : 0,
            ),
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
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
                  ? Icon(
                      widget.suffixIcon,
                      size: 18,
                      color: _hasError
                          ? AppColors.error
                          : AppColors.textSecondary,
                    )
                  : null,
              // Border handled by AnimatedContainer above
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        // Error message — animated in/out
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SizeTransition(sizeFactor: animation, child: child),
          ),
          child: _hasError
              ? Padding(
                  key: ValueKey(widget.errorText),
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 13,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.errorText!,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.error,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
