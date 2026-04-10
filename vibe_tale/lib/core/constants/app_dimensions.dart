/// VibeTale Spacing & Dimension Constants
abstract final class AppDimensions {
  // ── Spacing ────────────────────────────────────────────────────────────────
  static const double spaceXS = 4.0;
  static const double spaceSM = 8.0;
  static const double spaceMD = 16.0;
  static const double spaceLG = 24.0;
  static const double spaceXL = 32.0;
  static const double spaceXXL = 48.0;

  // ── Border Radius ──────────────────────────────────────────────────────────
  /// Input fields, small chips
  static const double radiusSM = 12.0;

  /// Standard cards
  static const double radiusMD = 16.0;

  /// Large cards, dialogs, bottom sheets
  static const double radiusLG = 20.0;

  /// Pill-shaped buttons and tags
  static const double radiusPill = 100.0;

  // ── Elevation / Blur ───────────────────────────────────────────────────────
  /// Glass blur sigma — used in BackdropFilter
  static const double glassBlur = 10.0;

  /// Stronger blur (e.g., immersive read background)
  static const double strongBlur = 20.0;

  // ── Component Sizes ────────────────────────────────────────────────────────
  /// Primary button height
  static const double buttonHeight = 52.0;

  /// Input field height
  static const double inputHeight = 52.0;

  /// Bottom navigation bar height
  static const double bottomNavHeight = 64.0;

  /// Book cover aspect ratio (portrait)
  static const double bookCoverAspectRatio = 0.68;

  /// Hero banner height
  static const double heroBannerHeight = 200.0;

  // ── Padding ────────────────────────────────────────────────────────────────
  /// Standard horizontal screen padding
  static const double screenPaddingH = 20.0;

  /// Standard vertical screen padding
  static const double screenPaddingV = 24.0;

  // ── Glow Effects ───────────────────────────────────────────────────────────
  /// Neon button glow blur radius
  static const double glowBlurRadius = 20.0;

  /// Neon button glow spread radius
  static const double glowSpreadRadius = 2.0;
}
