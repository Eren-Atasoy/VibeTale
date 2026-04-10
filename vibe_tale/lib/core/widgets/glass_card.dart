import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:vibe_tale/core/constants/app_colors.dart';
import 'package:vibe_tale/core/constants/app_dimensions.dart';

/// A glassmorphism card using [BackdropFilter] and a semi-transparent surface.
///
/// Usage:
/// ```dart
/// GlassCard(
///   child: Text('Hello'),
/// )
/// ```
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.fillColor,
    this.borderColor,
    this.blurSigma = AppDimensions.glassBlur,
    this.width,
    this.height,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Color? fillColor;
  final Color? borderColor;
  final double blurSigma;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final radius =
        borderRadius ?? BorderRadius.circular(AppDimensions.radiusLG);

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          width: width,
          height: height,
          padding: padding ?? const EdgeInsets.all(AppDimensions.spaceMD),
          decoration: BoxDecoration(
            color: fillColor ?? AppColors.glassFill,
            borderRadius: radius,
            border: Border.all(
              color: borderColor ?? AppColors.glassBorder,
              width: 1.0,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
