import 'package:flutter/material.dart';

/// VibeTale Cinematic Dark Mode — Amber/Teal palette
/// Derived directly from UI mockups.
abstract final class AppColors {
  // ── Backgrounds ────────────────────────────────────────────────────────────
  /// Deepest background — matches gradient bottom
  static const Color backgroundDeep = Color(0xFF030F12);

  /// Primary surface — dark teal-green cards and containers
  static const Color backgroundSurface = Color(0xFF1A2E20);

  /// Elevated surface — slightly lighter for nested cards
  static const Color backgroundElevated = Color(0xFF243320);

  // ── Primary Accent — Amber/Yellow ──────────────────────────────────────────
  /// Primary accent — amber/golden yellow (buttons, active states)
  static const Color primary = Color(0xFFF5C842);

  /// Primary pressed/darker state
  static const Color primaryDark = Color(0xFFD4A832);

  /// Primary glow — for BoxShadow neon effects
  static const Color primaryGlow = Color(0x66F5C842);

  // ── Text ───────────────────────────────────────────────────────────────────
  /// Primary text — high contrast white
  static const Color textPrimary = Color(0xFFFFFFFF);

  /// Secondary text — muted light gray-green
  static const Color textSecondary = Color(0xFF8A9E8F);

  /// Hint text — very muted for placeholder text
  static const Color textHint = Color(0xFF5A6E5F);

  /// Accent text — amber used for highlights (e.g., italic "Başlat")
  static const Color textAccent = Color(0xFFF5C842);

  // ── Glassmorphism ──────────────────────────────────────────────────────────
  /// Glass card fill — white with very low opacity
  static const Color glassFill = Color(0x14FFFFFF);

  /// Glass border — white with low opacity
  static const Color glassBorder = Color(0x26FFFFFF);

  /// Input field fill — semi-transparent dark
  static const Color inputFill = Color(0x1AFFFFFF);

  // ── Semantic ───────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFCF6679);
  static const Color success = Color(0xFF4CAF50);

  // ── Gradients ──────────────────────────────────────────────────────────────
  /// Smooth cinematic dark gradient — 5 stops to eliminate banding.
  /// #0B3B42 (teal top) → #030F12 (near-black bottom)
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0B3B42), // 0%   — teal top
      Color(0xFF082C32), // 22%  — teal-dark
      Color(0xFF061E24), // 45%  — mid transition
      Color(0xFF041318), // 68%  — deep dark
      Color(0xFF030F12), // 100% — near-black
    ],
    stops: [0.0, 0.22, 0.45, 0.68, 1.0],
  );

  static const LinearGradient amberGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF5C842), Color(0xFFD4A832)],
  );
}
