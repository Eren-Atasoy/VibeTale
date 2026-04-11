import 'package:flutter/material.dart';
import 'package:vibe_tale/core/constants/app_colors.dart';
import 'package:vibe_tale/core/constants/app_dimensions.dart';
import 'package:vibe_tale/core/constants/app_typography.dart';
import 'package:vibe_tale/core/theme/app_theme_colors.dart';

enum NeonButtonVariant { filled, outlined }

/// Primary amber button with neon glow effect.
class NeonButton extends StatelessWidget {
  const NeonButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.variant = NeonButtonVariant.filled,
    this.width = double.infinity,
  });

  const NeonButton.outlined({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width = double.infinity,
  }) : variant = NeonButtonVariant.outlined;

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final NeonButtonVariant variant;
  final double width;

  @override
  Widget build(BuildContext context) {
    final isFilled = variant == NeonButtonVariant.filled;
    final c = context.vColors;

    return Container(
      width: width,
      height: AppDimensions.buttonHeight,
      decoration: isFilled
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGlow,
                  blurRadius: AppDimensions.glowBlurRadius,
                  spreadRadius: AppDimensions.glowSpreadRadius,
                  offset: const Offset(0, 4),
                ),
              ],
            )
          : null,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
          child: Ink(
            decoration: BoxDecoration(
              color: isFilled ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
              border: isFilled
                  ? null
                  : Border.all(color: c.glassBorder, width: 1.5),
            ),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: isFilled
                            ? AppColors.backgroundDeep
                            : c.textPrimary,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(
                            icon,
                            size: 18,
                            color: isFilled
                                ? AppColors.backgroundDeep
                                : c.textPrimary,
                          ),
                          const SizedBox(width: AppDimensions.spaceSM),
                        ],
                        Text(
                          label,
                          style: isFilled
                              ? AppTypography.buttonLabel
                              : AppTypography.buttonLabel.copyWith(
                                  color: c.textPrimary,
                                  fontWeight: FontWeight.w500,
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
}
