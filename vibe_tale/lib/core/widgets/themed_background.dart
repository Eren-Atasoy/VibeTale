import 'package:flutter/material.dart';
import 'package:vibe_tale/core/constants/app_colors.dart';

/// Wraps [child] in a gradient background that responds to the current theme.
/// Use this instead of hardcoding [AppColors.backgroundGradient] in each screen.
class ThemedBackground extends StatelessWidget {
  const ThemedBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: isDark
            ? AppColors.backgroundGradient
            : AppColors.backgroundGradientLight,
      ),
      child: child,
    );
  }
}
