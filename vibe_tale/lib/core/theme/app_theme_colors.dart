import 'package:flutter/material.dart';
import 'package:vibe_tale/core/constants/app_colors.dart';

/// Semantic color tokens that adapt between dark and light themes.
///
/// Register in both [ThemeData.extensions] (see [AppTheme]).
/// Access via [BuildContext.vColors] shortcut.
class VibeTaleColors extends ThemeExtension<VibeTaleColors> {
  const VibeTaleColors({
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.glassFill,
    required this.glassBorder,
    required this.inputFill,
    required this.navBg,
    required this.cardSurface,
    required this.cardElevated,
  });

  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color glassFill;
  final Color glassBorder;
  final Color inputFill;
  /// Bottom nav bar background color.
  final Color navBg;
  /// Card / sheet surface color.
  final Color cardSurface;
  /// Elevated card / nested container color.
  final Color cardElevated;

  // ── Dark palette (matches current AppColors) ──────────────────────────────
  static const dark = VibeTaleColors(
    textPrimary:   AppColors.textPrimary,        // #FFFFFF
    textSecondary: AppColors.textSecondary,      // #8A9E8F
    textHint:      AppColors.textHint,           // #5A6E5F
    glassFill:     AppColors.glassFill,          // rgba(fff, 8%)
    glassBorder:   AppColors.glassBorder,        // rgba(fff, 15%)
    inputFill:     AppColors.inputFill,          // rgba(fff, 10%)
    navBg:         Color(0xF70A1A1E),            // backgroundDeep 97%
    cardSurface:   AppColors.backgroundSurface,  // #1A2E20
    cardElevated:  AppColors.backgroundElevated, // #243320
  );

  // ── Light palette ─────────────────────────────────────────────────────────
  static const light = VibeTaleColors(
    textPrimary:   Color(0xFF1A2520),  // near-black warm teal
    textSecondary: Color(0xFF4A6058),  // medium forest green — readable on white
    textHint:      Color(0xFF8A9E93),  // sage green
    glassFill:     Color(0x0D000000),  // black 5%  — subtle card tint
    glassBorder:   Color(0x1F000000),  // black 12% — visible border
    inputFill:     Color(0x12000000),  // black 7%  — subtle input bg
    navBg:         Color(0xF7EDF2F0),  // light gray-teal 97%
    cardSurface:   Color(0xFFFFFFFF),  // pure white cards
    cardElevated:  Color(0xFFF0F4F2),  // very light teal-white elevated
  );

  @override
  VibeTaleColors copyWith({
    Color? textPrimary,
    Color? textSecondary,
    Color? textHint,
    Color? glassFill,
    Color? glassBorder,
    Color? inputFill,
    Color? navBg,
    Color? cardSurface,
    Color? cardElevated,
  }) => VibeTaleColors(
    textPrimary:   textPrimary   ?? this.textPrimary,
    textSecondary: textSecondary ?? this.textSecondary,
    textHint:      textHint      ?? this.textHint,
    glassFill:     glassFill     ?? this.glassFill,
    glassBorder:   glassBorder   ?? this.glassBorder,
    inputFill:     inputFill     ?? this.inputFill,
    navBg:         navBg         ?? this.navBg,
    cardSurface:   cardSurface   ?? this.cardSurface,
    cardElevated:  cardElevated  ?? this.cardElevated,
  );

  @override
  VibeTaleColors lerp(VibeTaleColors? other, double t) {
    if (other is! VibeTaleColors) return this;
    return VibeTaleColors(
      textPrimary:   Color.lerp(textPrimary,   other.textPrimary,   t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textHint:      Color.lerp(textHint,      other.textHint,      t)!,
      glassFill:     Color.lerp(glassFill,     other.glassFill,     t)!,
      glassBorder:   Color.lerp(glassBorder,   other.glassBorder,   t)!,
      inputFill:     Color.lerp(inputFill,     other.inputFill,     t)!,
      navBg:         Color.lerp(navBg,         other.navBg,         t)!,
      cardSurface:   Color.lerp(cardSurface,   other.cardSurface,   t)!,
      cardElevated:  Color.lerp(cardElevated,  other.cardElevated,  t)!,
    );
  }
}

/// Quick access shortcut: `context.vColors.textPrimary`
extension AppThemeX on BuildContext {
  VibeTaleColors get vColors =>
      Theme.of(this).extension<VibeTaleColors>() ?? VibeTaleColors.dark;

  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
