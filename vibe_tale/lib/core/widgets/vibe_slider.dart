import 'package:flutter/material.dart';
import 'package:vibe_tale/core/constants/app_colors.dart';
import 'package:vibe_tale/core/constants/app_dimensions.dart';
import 'package:vibe_tale/core/constants/app_typography.dart';

/// Custom amber slider with icon row and percentage label.
/// Matches the Ambiance Control bottom sheet in the mockup.
///
/// Usage:
/// ```dart
/// VibeSlider(
///   label: 'Ses Seviyesi',
///   value: 0.65,
///   onChanged: (v) => ref.read(readerProvider.notifier).setVolume(v),
///   leadingIcon: Icons.volume_off,
///   trailingIcon: Icons.volume_up,
/// )
/// ```
class VibeSlider extends StatelessWidget {
  const VibeSlider({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.leadingIcon,
    this.trailingIcon,
    this.min = 0.0,
    this.max = 1.0,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final double min;
  final double max;

  String get _percentage => '${((value - min) / (max - min) * 100).round()}%';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label + percentage
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTypography.titleMedium),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primaryGlow,
                borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
              ),
              child: Text(
                _percentage,
                style: AppTypography.tagLabel.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spaceXS),

        // Slider row with side icons
        Row(
          children: [
            if (leadingIcon != null)
              Icon(leadingIcon, size: 18, color: AppColors.textSecondary),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 3,
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: AppColors.glassBorder,
                  thumbColor: AppColors.primary,
                  overlayColor: AppColors.primaryGlow,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 8,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 16,
                  ),
                ),
                child: Slider(
                  value: value.clamp(min, max),
                  min: min,
                  max: max,
                  onChanged: onChanged,
                ),
              ),
            ),
            if (trailingIcon != null)
              Icon(trailingIcon, size: 18, color: AppColors.textSecondary),
          ],
        ),
      ],
    );
  }
}
