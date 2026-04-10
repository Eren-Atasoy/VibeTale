import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibe_tale/core/localization/app_strings.dart';

/// Controls the app's theme mode (dark / light).
final themeModeProvider = StateProvider<ThemeMode>(
  (ref) => ThemeMode.dark,
);

/// Controls the app's display language: 'tr' or 'en'.
final appLanguageProvider = StateProvider<String>(
  (ref) => 'tr',
);

/// Derives the current [AppStrings] from [appLanguageProvider].
final appStringsProvider = Provider<AppStrings>((ref) {
  final lang = ref.watch(appLanguageProvider);
  return AppStrings(lang);
});
