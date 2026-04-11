import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibe_tale/core/constants/app_colors.dart';

/// VibeTale Typography — Poppins (Google Fonts).
///
/// Colors are intentionally omitted from most styles so they inherit from
/// [ThemeData.textTheme], which differs between dark and light modes.
/// Use `.copyWith(color: ...)` at call site for explicit overrides.
abstract final class AppTypography {
  // ── Display ────────────────────────────────────────────────────────────────
  static TextStyle get displayLarge => GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  static TextStyle get displayMedium => GoogleFonts.poppins(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
  );

  // ── Headlines ──────────────────────────────────────────────────────────────
  static TextStyle get headlineLarge => GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get headlineMedium => GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  // ── Titles ─────────────────────────────────────────────────────────────────
  static TextStyle get titleLarge => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get titleMedium => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  // ── Body ───────────────────────────────────────────────────────────────────
  static TextStyle get readingBody => GoogleFonts.poppins(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.8,
  );

  static TextStyle get bodyLarge => GoogleFonts.poppins(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  /// Secondary / description body text — color comes from [ThemeData.textTheme].
  static TextStyle get bodyMedium => GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  // ── Labels ─────────────────────────────────────────────────────────────────
  /// Button labels — always dark so it contrasts the amber background.
  static TextStyle get buttonLabel => GoogleFonts.poppins(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.backgroundDeep,
    letterSpacing: 0.5,
  );

  static TextStyle get labelSmall => GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.2,
  );

  static TextStyle get tagLabel => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get tagline => GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 2.0,
  );
}
