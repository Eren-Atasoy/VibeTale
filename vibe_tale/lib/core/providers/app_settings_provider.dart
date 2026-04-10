import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Controls the app's theme mode (dark / light).
final themeModeProvider = StateProvider<ThemeMode>(
  (ref) => ThemeMode.dark,
);

/// Controls the app's display language: 'tr' or 'en'.
final appLanguageProvider = StateProvider<String>(
  (ref) => 'tr',
);
