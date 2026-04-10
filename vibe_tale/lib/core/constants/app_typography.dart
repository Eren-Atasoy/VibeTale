import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// VibeTale Typography — Poppins (Google Fonts)
abstract final class AppTypography {
  // ── Display ────────────────────────────────────────────────────────────────
  /// App logo / hero titles (e.g., "VibeTale")
  static TextStyle get displayLarge => GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  /// Screen titles (e.g., "Yolculuğuna Başla")
  static TextStyle get displayMedium => GoogleFonts.poppins(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  // ── Headlines ──────────────────────────────────────────────────────────────
  /// Section headers, book titles in detail view
  static TextStyle get headlineLarge => GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// Card titles, chapter headings
  static TextStyle get headlineMedium => GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // ── Titles ─────────────────────────────────────────────────────────────────
  /// List section labels (e.g., "Haftanın Önerileri")
  static TextStyle get titleLarge => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// Sub-section titles
  static TextStyle get titleMedium => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  // ── Body ───────────────────────────────────────────────────────────────────
  /// Immersive reading body text — slightly larger for legibility
  static TextStyle get readingBody => GoogleFonts.poppins(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.8,
  );

  /// Standard body text
  static TextStyle get bodyLarge => GoogleFonts.poppins(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.6,
  );

  /// Secondary / description body text
  static TextStyle get bodyMedium => GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  // ── Labels ─────────────────────────────────────────────────────────────────
  /// Button labels
  static TextStyle get buttonLabel => GoogleFonts.poppins(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.backgroundDeep,
    letterSpacing: 0.5,
  );

  /// Small caps labels (e.g., "VEYA ŞUNUNLA DEVAM ET")
  static TextStyle get labelSmall => GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 1.2,
  );

  /// Tag / chip labels
  static TextStyle get tagLabel => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  /// Tagline / subtitle under logo
  static TextStyle get tagline => GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    letterSpacing: 2.0,
  );
}
