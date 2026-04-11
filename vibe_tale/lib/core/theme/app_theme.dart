import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibe_tale/core/constants/app_colors.dart';
import 'package:vibe_tale/core/constants/app_dimensions.dart';
import 'package:vibe_tale/core/theme/app_theme_colors.dart';

abstract final class AppTheme {
  // ── Shared helpers ─────────────────────────────────────────────────────────

  static TextTheme _buildTextTheme(TextTheme base) =>
      GoogleFonts.poppinsTextTheme(base);

  // ── Dark ───────────────────────────────────────────────────────────────────

  static ThemeData get dark {
    final base = _buildTextTheme(ThemeData.dark().textTheme).copyWith(
      // Explicit secondary-text color for dark mode
      bodyMedium: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.5,
      ),
      labelSmall: GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        letterSpacing: 1.2,
      ),
    );

    return ThemeData.dark(useMaterial3: true).copyWith(
      scaffoldBackgroundColor: AppColors.backgroundDeep,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.backgroundDeep,
        secondary: AppColors.primary,
        onSecondary: AppColors.backgroundDeep,
        surface: AppColors.backgroundSurface,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
      ),
      textTheme: base,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: 1.5,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.backgroundDeep,
          minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          minimumSize: const Size.fromHeight(AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
          ),
          side: const BorderSide(color: AppColors.glassBorder, width: 1),
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceMD,
          vertical: AppDimensions.spaceMD,
        ),
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
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        hintStyle: GoogleFonts.poppins(fontSize: 14, color: AppColors.textHint),
        suffixIconColor: AppColors.textSecondary,
        prefixIconColor: AppColors.textSecondary,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.backgroundSurface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.inputFill,
        selectedColor: AppColors.primary,
        labelStyle: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        side: const BorderSide(color: AppColors.glassBorder),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.glassBorder,
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primaryGlow,
        trackHeight: 3,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.glassBorder,
        thickness: 0.5,
      ),
      iconTheme: const IconThemeData(color: AppColors.textSecondary),
      extensions: const [VibeTaleColors.dark],
    );
  }

  // ── Light ──────────────────────────────────────────────────────────────────

  static const _lightPrimary = Color(0xFFD4A832);
  static const _lightTextPrimary = Color(0xFF1A2520);
  static const _lightTextSecondary = Color(0xFF4A6058);
  static const _lightTextHint = Color(0xFF8A9E93);

  static ThemeData get light {
    final base = _buildTextTheme(ThemeData.light().textTheme).copyWith(
      // Match the dark-mode secondary color convention in light tone
      bodyMedium: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: _lightTextSecondary,
        height: 1.5,
      ),
      labelSmall: GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: _lightTextSecondary,
        letterSpacing: 1.2,
      ),
    );

    return ThemeData.light(useMaterial3: true).copyWith(
      scaffoldBackgroundColor: const Color(0xFFF4F6F5),
      colorScheme: const ColorScheme.light(
        primary: _lightPrimary,
        onPrimary: Colors.white,
        secondary: _lightPrimary,
        onSecondary: Colors.white,
        surface: Color(0xFFFFFFFF),
        onSurface: _lightTextPrimary,
        error: Color(0xFFB00020),
      ),
      textTheme: base,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: _lightTextPrimary,
          letterSpacing: 1.5,
        ),
        iconTheme: const IconThemeData(color: _lightTextPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _lightPrimary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _lightTextPrimary,
          minimumSize: const Size.fromHeight(AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
          ),
          side: const BorderSide(color: Color(0x1F000000), width: 1),
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0x12000000),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceMD,
          vertical: AppDimensions.spaceMD,
        ),
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
          borderSide: const BorderSide(color: _lightPrimary, width: 1.5),
        ),
        hintStyle: GoogleFonts.poppins(fontSize: 14, color: _lightTextHint),
        suffixIconColor: _lightTextSecondary,
        prefixIconColor: _lightTextSecondary,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFFEDF2F0),
        selectedItemColor: _lightPrimary,
        unselectedItemColor: _lightTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0x12000000),
        selectedColor: _lightPrimary,
        labelStyle: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: _lightTextPrimary,
        ),
        side: const BorderSide(color: Color(0x1F000000)),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: _lightPrimary,
        inactiveTrackColor: const Color(0x1F000000),
        thumbColor: _lightPrimary,
        overlayColor: AppColors.primaryGlow,
        trackHeight: 3,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0x1F000000),
        thickness: 0.5,
      ),
      iconTheme: const IconThemeData(color: _lightTextSecondary),
      extensions: const [VibeTaleColors.light],
    );
  }
}
