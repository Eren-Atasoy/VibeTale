import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Selectable reading themes for the immersive reader.
enum ReaderTheme { dark, light }

/// Colour palette + image treatment for a [ReaderTheme].
///
/// Legibility is decoupled from atmosphere: [scrim] is a *light* readability
/// veil whose strength is driven by the visual-intensity slider, while
/// [textShadow] is a halo that keeps text crisp over any background, so the
/// scene image can be vivid without washing out the words.
class ReaderPalette {
  const ReaderPalette({
    required this.base,
    required this.text,
    required this.secondaryText,
    required this.scrim,
    required this.textShadow,
    required this.imageOpacityCap,
  });

  final Color base;
  final Color text;
  final Color secondaryText;
  final Color scrim;
  final Color textShadow;
  final double imageOpacityCap;

  static ReaderPalette of(ReaderTheme theme) => switch (theme) {
    ReaderTheme.dark => const ReaderPalette(
      base: Color(0xFF0E1418),
      text: Color(0xFFEDEBE5),
      secondaryText: Color(0xFFA8B0B5),
      scrim: Color(0xFF05080A),
      textShadow: Color(0xCC04070A),
      imageOpacityCap: 1.0,
    ),
    ReaderTheme.light => const ReaderPalette(
      base: Color(0xFFF3F0E8),
      text: Color(0xFF221E18),
      secondaryText: Color(0xFF6E665A),
      scrim: Color(0xFFF6F3EC),
      textShadow: Color(0xE6FBF8F1),
      imageOpacityCap: 0.7,
    ),
  };
}

@immutable
class ReaderSettings {
  const ReaderSettings({
    this.theme = ReaderTheme.dark,
    this.fontScale = 1.0,
    this.serif = true,
  });

  final ReaderTheme theme;

  /// Multiplier applied to the base reading font size (0.8 – 1.6).
  final double fontScale;

  /// Serif (literary) vs sans-serif reading typeface.
  final bool serif;

  ReaderSettings copyWith({
    ReaderTheme? theme,
    double? fontScale,
    bool? serif,
  }) => ReaderSettings(
    theme: theme ?? this.theme,
    fontScale: fontScale ?? this.fontScale,
    serif: serif ?? this.serif,
  );
}

/// Persists reader preferences across sessions via [SharedPreferences].
class ReaderSettingsNotifier extends Notifier<ReaderSettings> {
  static const _kTheme = 'reader_theme';
  static const _kScale = 'reader_font_scale';
  static const _kSerif = 'reader_serif';

  @override
  ReaderSettings build() {
    _load();
    return const ReaderSettings();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final themeIndex = (p.getInt(_kTheme) ?? 0)
        .clamp(0, ReaderTheme.values.length - 1);
    state = ReaderSettings(
      theme: ReaderTheme.values[themeIndex],
      fontScale: p.getDouble(_kScale) ?? 1.0,
      serif: p.getBool(_kSerif) ?? true,
    );
  }

  Future<void> _persist() async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kTheme, state.theme.index);
    await p.setDouble(_kScale, state.fontScale);
    await p.setBool(_kSerif, state.serif);
  }

  void setTheme(ReaderTheme theme) {
    state = state.copyWith(theme: theme);
    _persist();
  }

  void setFontScale(double scale) {
    state = state.copyWith(fontScale: scale.clamp(0.8, 1.6));
    _persist();
  }

  void setSerif(bool serif) {
    state = state.copyWith(serif: serif);
    _persist();
  }
}

final readerSettingsProvider =
    NotifierProvider<ReaderSettingsNotifier, ReaderSettings>(
      ReaderSettingsNotifier.new,
    );
