import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibe_tale/core/constants/app_colors.dart';
import 'package:vibe_tale/core/constants/app_dimensions.dart';
import 'package:vibe_tale/core/constants/app_typography.dart';
import 'package:vibe_tale/core/theme/app_theme_colors.dart';
import 'package:vibe_tale/features/reader/application/reader_settings.dart';

/// Ambiance controls — wired to the live audio player + scene-image treatment.
class AmbianceSheet extends StatefulWidget {
  const AmbianceSheet({
    super.key,
    required this.audioVolume,
    required this.visualIntensity,
    required this.onAudioChanged,
    required this.onVisualChanged,
    required this.onReset,
  });

  final double audioVolume;
  final double visualIntensity;
  final ValueChanged<double> onAudioChanged;
  final ValueChanged<double> onVisualChanged;
  final VoidCallback onReset;

  @override
  State<AmbianceSheet> createState() => _AmbianceSheetState();
}

class _AmbianceSheetState extends State<AmbianceSheet> {
  late double _audio = widget.audioVolume;
  late double _visual = widget.visualIntensity;

  @override
  Widget build(BuildContext context) {
    final c = context.vColors;
    return _SheetShell(
      title: 'ORTAM',
      children: [
        ReaderSliderRow(
          label: 'Ses Seviyesi',
          value: _audio,
          leadingIcon: Icons.volume_mute_rounded,
          trailingIcon: Icons.volume_up_rounded,
          onChanged: (v) {
            setState(() => _audio = v);
            widget.onAudioChanged(v);
          },
        ),
        const SizedBox(height: AppDimensions.spaceLG),
        ReaderSliderRow(
          label: 'Görsel Yoğunluk',
          value: _visual,
          leadingIcon: Icons.brightness_low_rounded,
          trailingIcon: Icons.brightness_high_rounded,
          onChanged: (v) {
            setState(() => _visual = v);
            widget.onVisualChanged(v);
          },
        ),
        const SizedBox(height: AppDimensions.spaceXL),
        SizedBox(
          width: double.infinity,
          height: AppDimensions.buttonHeight,
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _audio = 0.65;
                _visual = 0.80;
              });
              widget.onReset();
            },
            icon: const Icon(Icons.refresh_rounded, size: 18, color: AppColors.primary),
            label: Text(
              'Varsayılana Dön',
              style: AppTypography.buttonLabel.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
              ),
            ),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).padding.bottom),
        const SizedBox(height: AppDimensions.spaceMD),
        Text(
          'Sahne sesi ve görseli, okuduğun bölüme göre değişir.',
          style: AppTypography.labelSmall.copyWith(color: c.textHint, fontSize: 10),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Reading appearance controls — theme, font size, typeface. Persisted.
class ReaderSettingsSheet extends ConsumerWidget {
  const ReaderSettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(readerSettingsProvider);
    final notifier = ref.read(readerSettingsProvider.notifier);
    final c = context.vColors;

    return _SheetShell(
      title: 'OKUMA AYARLARI',
      children: [
        // Theme selector
        Align(
          alignment: Alignment.centerLeft,
          child: Text('Tema', style: AppTypography.titleMedium.copyWith(color: c.textPrimary)),
        ),
        const SizedBox(height: AppDimensions.spaceSM),
        Row(
          children: [
            for (final theme in ReaderTheme.values) ...[
              Expanded(
                child: _ThemeSwatch(
                  theme: theme,
                  selected: settings.theme == theme,
                  onTap: () => notifier.setTheme(theme),
                ),
              ),
              if (theme != ReaderTheme.values.last)
                const SizedBox(width: AppDimensions.spaceMD),
            ],
          ],
        ),
        const SizedBox(height: AppDimensions.spaceLG),

        // Font size
        ReaderSliderRow(
          label: 'Yazı Boyutu',
          value: (settings.fontScale - 0.8) / (1.6 - 0.8),
          leadingIcon: Icons.text_decrease_rounded,
          trailingIcon: Icons.text_increase_rounded,
          percentageOverride: '${(settings.fontScale * 100).round()}%',
          onChanged: (v) => notifier.setFontScale(0.8 + v * (1.6 - 0.8)),
        ),
        const SizedBox(height: AppDimensions.spaceLG),

        // Typeface toggle
        Row(
          children: [
            Text('Yazı Tipi', style: AppTypography.titleMedium.copyWith(color: c.textPrimary)),
            const Spacer(),
            _SegToggle(
              left: 'Serif',
              right: 'Sans',
              isLeft: settings.serif,
              onChanged: (left) => notifier.setSerif(left),
            ),
          ],
        ),
        SizedBox(height: MediaQuery.of(context).padding.bottom + AppDimensions.spaceMD),
      ],
    );
  }
}

// ── Shared building blocks ────────────────────────────────────────────────────

class _SheetShell extends StatelessWidget {
  const _SheetShell({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = context.vColors;
    return Container(
      decoration: BoxDecoration(
        color: c.cardSurface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLG),
        ),
        border: Border(top: BorderSide(color: c.glassBorder, width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.screenPaddingH,
        AppDimensions.spaceMD,
        AppDimensions.screenPaddingH,
        AppDimensions.spaceLG,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: c.glassBorder,
                borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spaceLG),
          Text(
            title,
            style: AppTypography.labelSmall.copyWith(
              color: c.textSecondary,
              letterSpacing: 2.5,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceLG),
          ...children,
        ],
      ),
    );
  }
}

class ReaderSliderRow extends StatelessWidget {
  const ReaderSliderRow({
    super.key,
    required this.label,
    required this.value,
    required this.leadingIcon,
    required this.trailingIcon,
    required this.onChanged,
    this.percentageOverride,
  });

  final String label;
  final double value;
  final IconData leadingIcon;
  final IconData trailingIcon;
  final ValueChanged<double> onChanged;
  final String? percentageOverride;

  @override
  Widget build(BuildContext context) {
    final c = context.vColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTypography.titleMedium.copyWith(color: c.textPrimary)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spaceSM, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primaryGlow,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
              ),
              child: Text(
                percentageOverride ?? '${(value * 100).round()}%',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spaceSM),
        Row(
          children: [
            Icon(leadingIcon, size: 18, color: c.textHint),
            Expanded(
              child: SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: c.glassBorder,
                  thumbColor: AppColors.primary,
                  overlayColor: AppColors.primaryGlow,
                  trackHeight: 3,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                ),
                child: Slider(value: value.clamp(0.0, 1.0), onChanged: onChanged),
              ),
            ),
            Icon(trailingIcon, size: 18, color: c.textSecondary),
          ],
        ),
      ],
    );
  }
}

class _ThemeSwatch extends StatelessWidget {
  const _ThemeSwatch({
    required this.theme,
    required this.selected,
    required this.onTap,
  });

  final ReaderTheme theme;
  final bool selected;
  final VoidCallback onTap;

  String get _label => switch (theme) {
    ReaderTheme.dark => 'Koyu',
    ReaderTheme.light => 'Açık',
  };

  @override
  Widget build(BuildContext context) {
    final palette = ReaderPalette.of(theme);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 56,
            decoration: BoxDecoration(
              color: palette.base,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              border: Border.all(
                color: selected ? AppColors.primary : context.vColors.glassBorder,
                width: selected ? 2 : 1,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              'Aa',
              style: TextStyle(
                color: palette.text,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _label,
            style: AppTypography.labelSmall.copyWith(
              color: selected ? AppColors.primary : context.vColors.textSecondary,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _SegToggle extends StatelessWidget {
  const _SegToggle({
    required this.left,
    required this.right,
    required this.isLeft,
    required this.onChanged,
  });

  final String left;
  final String right;
  final bool isLeft;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.vColors;
    return Container(
      decoration: BoxDecoration(
        color: c.inputFill,
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
        border: Border.all(color: c.glassBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _seg(context, left, isLeft, () => onChanged(true)),
          _seg(context, right, !isLeft, () => onChanged(false)),
        ],
      ),
    );
  }

  Widget _seg(BuildContext context, String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: active ? AppColors.backgroundDeep : context.vColors.textSecondary,
            fontWeight: active ? FontWeight.w700 : FontWeight.w400,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
