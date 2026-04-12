import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_tale/core/constants/app_colors.dart';
import 'package:vibe_tale/core/constants/app_dimensions.dart';
import 'package:vibe_tale/core/constants/app_typography.dart';
import 'package:vibe_tale/core/providers/app_settings_provider.dart';
import 'package:vibe_tale/core/router/app_router.dart';
import 'package:vibe_tale/core/theme/app_theme_colors.dart';
import 'package:vibe_tale/core/widgets/glass_card.dart';
import 'package:vibe_tale/core/widgets/themed_background.dart';

class ProfileSettingsScreen extends ConsumerStatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  ConsumerState<ProfileSettingsScreen> createState() =>
      _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState
    extends ConsumerState<ProfileSettingsScreen> {
  bool _notificationsOn = true;
  bool _readingReminder = false;
  // themeMode and language are managed by Riverpod providers

  // ── Switch helper ─────────────────────────────────────────────────────────

  Switch _buildSwitch(
    BuildContext context,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    final c = context.vColors;
    return Switch(
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppColors.primary,
      activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
      inactiveThumbColor: c.textSecondary,
      inactiveTrackColor: c.glassBorder,
    );
  }

  // ── Bottom sheet & dialog helpers ─────────────────────────────────────────

  void _showLanguageSheet() {
    const languages = [
      ('Türkçe', 'tr'),
      ('English', 'en'),
    ];
    final s = ref.read(appStringsProvider);
    final currentLang = ref.read(appLanguageProvider);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomSheetContainer(
        title: s.selectLanguage,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((entry) {
            final (label, code) = entry;
            final isSelected = code == currentLang;
            return _SheetOptionTile(
              label: label,
              isSelected: isSelected,
              onTap: () {
                ref.read(appLanguageProvider.notifier).state = code;
                Navigator.of(context).pop();
                _showSnackBar(
                  code == 'tr' ? s.languageChangedTr : s.languageChangedEn,
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppTypography.bodyMedium),
        backgroundColor: const Color(0xFF0F2A30),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
          side: BorderSide(color: context.vColors.glassBorder),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAccountSheet() {
    final s = ref.read(appStringsProvider);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomSheetContainer(
        title: s.accountInfo,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _InfoRow(label: s.fullName, value: 'Eren Atasoy'),
            _InfoRow(label: s.emailField, value: 'eren@vibetale.com'),
            _InfoRow(label: s.membership, value: 'Ocak 2025'),
            _InfoRow(label: s.plan, value: s.planFree),
            const SizedBox(height: AppDimensions.spaceMD),
            _SheetActionButton(
              label: s.editAccount,
              icon: Icons.edit_outlined,
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacySheet() {
    final s = ref.read(appStringsProvider);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _BottomSheetContainer(
        title: s.privacy,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SheetOptionTile(
              label: s.hideReadingHistory,
              trailing: _buildSwitch(context, false, (_) {}),
              onTap: null,
            ),
            _SheetOptionTile(
              label: s.publicProfile,
              trailing: _buildSwitch(context, true, (_) {}),
              onTap: null,
            ),
            _SheetOptionTile(
              label: s.shareAchievements,
              trailing: _buildSwitch(context, true, (_) {}),
              onTap: null,
            ),
            const SizedBox(height: AppDimensions.spaceMD),
            _SheetActionButton(
              label: s.downloadData,
              icon: Icons.download_outlined,
              onTap: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: AppDimensions.spaceSM),
            _SheetActionButton(
              label: s.deleteAccount,
              icon: Icons.delete_outline_rounded,
              isDestructive: true,
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpSheet() {
    final s = ref.read(appStringsProvider);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomSheetContainer(
        title: s.helpSupport,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SheetOptionTile(
              label: s.faq,
              icon: Icons.quiz_outlined,
              onTap: () => Navigator.of(context).pop(),
            ),
            _SheetOptionTile(
              label: s.contactUs,
              icon: Icons.mail_outline_rounded,
              onTap: () => Navigator.of(context).pop(),
            ),
            _SheetOptionTile(
              label: s.sendFeedback,
              icon: Icons.feedback_outlined,
              onTap: () => Navigator.of(context).pop(),
            ),
            _SheetOptionTile(
              label: s.reportBug,
              icon: Icons.bug_report_outlined,
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutSheet() {
    final s = ref.read(appStringsProvider);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomSheetContainer(
        title: s.about,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppDimensions.spaceSM),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: AppColors.amberGradient,
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusMD),
              ),
              child: const Icon(
                Icons.auto_stories_rounded,
                color: AppColors.backgroundDeep,
                size: 36,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceMD),
            Text(
              'VibeTale',
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(s.versionLabel, style: AppTypography.bodyMedium),
            const SizedBox(height: AppDimensions.spaceMD),
            const Divider(),
            const SizedBox(height: AppDimensions.spaceSM),
            _InfoRow(label: s.developer, value: 'VibeTale Team'),
            _InfoRow(label: s.license, value: 'MIT'),
            _InfoRow(label: s.buildDate, value: s.buildDateValue),
            const SizedBox(height: AppDimensions.spaceMD),
          ],
        ),
      ),
    );
  }

  void _confirmLogout() {
    final s = ref.read(appStringsProvider);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.vColors.cardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          side: BorderSide(color: context.vColors.glassBorder),
        ),
        title: Text(s.logoutConfirmTitle, style: AppTypography.titleLarge),
        content: Text(
          s.logoutConfirmBody,
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              s.cancel,
              style: AppTypography.bodyMedium.copyWith(
                color: context.vColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go(AppRoutes.login);
            },
            child: Text(
              s.logout,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(appStringsProvider);
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final currentLang = ref.watch(appLanguageProvider);
    final langLabel = currentLang == 'tr' ? 'Türkçe' : 'English';

    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const _SettingsTopBar(),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    AppDimensions.screenPaddingH,
                    AppDimensions.spaceMD,
                    AppDimensions.screenPaddingH,
                    bottomPadding + AppDimensions.spaceXXL,
                  ),
                  children: [
                    // ── General ───────────────────────────────────────────────
                    _SettingsGroup(
                      title: s.sectionGeneral,
                      tiles: [
                        _SettingsTile(
                          icon: Icons.notifications_outlined,
                          label: s.notifications,
                          trailing: _buildSwitch(
                            context,
                            _notificationsOn,
                            (v) => setState(() => _notificationsOn = v),
                          ),
                        ),
                        _SettingsTile(
                          icon: Icons.alarm_outlined,
                          label: s.readingReminder,
                          trailing: _buildSwitch(
                            context,
                            _readingReminder,
                            (v) => setState(() => _readingReminder = v),
                          ),
                        ),
                        _SettingsTile(
                          icon: isDark
                              ? Icons.dark_mode_outlined
                              : Icons.light_mode_outlined,
                          label: s.theme,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isDark ? s.themeDark : s.themeLight,
                                style: AppTypography.bodyMedium.copyWith(
                                  color: context.vColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildSwitch(
                                context,
                                isDark,
                                (v) => ref
                                    .read(themeModeProvider.notifier)
                                    .state = v
                                    ? ThemeMode.dark
                                    : ThemeMode.light,
                              ),
                            ],
                          ),
                        ),
                        _SettingsTile(
                          icon: Icons.language_outlined,
                          label: s.language,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                langLabel,
                                style: AppTypography.bodyMedium.copyWith(
                                  color: context.vColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: context.vColors.textSecondary,
                                size: 20,
                              ),
                            ],
                          ),
                          onTap: _showLanguageSheet,
                        ),
                      ],
                    ),

                    const SizedBox(height: AppDimensions.spaceLG),

                    // ── Account ───────────────────────────────────────────────
                    _SettingsGroup(
                      title: s.sectionAccount,
                      tiles: [
                        _SettingsTile(
                          icon: Icons.person_outline_rounded,
                          label: s.accountInfo,
                          trailing: Icon(
                            Icons.chevron_right_rounded,
                            color: context.vColors.textSecondary,
                            size: 20,
                          ),
                          onTap: _showAccountSheet,
                        ),
                        _SettingsTile(
                          icon: Icons.lock_outline_rounded,
                          label: s.privacy,
                          trailing: Icon(
                            Icons.chevron_right_rounded,
                            color: context.vColors.textSecondary,
                            size: 20,
                          ),
                          onTap: _showPrivacySheet,
                        ),
                        _SettingsTile(
                          icon: Icons.help_outline_rounded,
                          label: s.helpSupport,
                          trailing: Icon(
                            Icons.chevron_right_rounded,
                            color: context.vColors.textSecondary,
                            size: 20,
                          ),
                          onTap: _showHelpSheet,
                        ),
                        _SettingsTile(
                          icon: Icons.info_outline_rounded,
                          label: s.about,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'v1.0.0',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: context.vColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: context.vColors.textSecondary,
                                size: 20,
                              ),
                            ],
                          ),
                          onTap: _showAboutSheet,
                        ),
                      ],
                    ),

                    const SizedBox(height: AppDimensions.spaceXL),

                    // ── Çıkış Yap ─────────────────────────────────────────────
                    _LogoutButton(onTap: _confirmLogout),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Settings Top Bar ──────────────────────────────────────────────────────────

class _SettingsTopBar extends ConsumerWidget {
  const _SettingsTopBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appStringsProvider);
    final c = context.vColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spaceMD,
        AppDimensions.spaceMD,
        AppDimensions.screenPaddingH,
        AppDimensions.spaceSM,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.inputFill,
                border: Border.all(color: c.glassBorder, width: 1),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: c.textPrimary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.spaceMD),
          Text(
            s.settings,
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Settings Group ────────────────────────────────────────────────────────────

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.title, required this.tiles});

  final String title;
  final List<_SettingsTile> tiles;

  @override
  Widget build(BuildContext context) {
    final c = context.vColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: AppDimensions.spaceSM),
          child: Text(
            title,
            style: AppTypography.labelSmall.copyWith(
              color: c.textSecondary,
              letterSpacing: 1.5,
              fontSize: 11,
            ),
          ),
        ),
        GlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (int i = 0; i < tiles.length; i++) ...[
                tiles[i],
                if (i < tiles.length - 1)
                  Divider(
                    height: 1,
                    color: c.glassBorder,
                    indent: 52,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ── Settings Tile ─────────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.vColors;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceMD,
          vertical: 14,
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
              ),
              child: Icon(icon, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: AppDimensions.spaceMD),
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyMedium.copyWith(
                  color: c.textPrimary,
                  fontSize: 14,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

// ── Bottom Sheet Container ────────────────────────────────────────────────────

class _BottomSheetContainer extends StatelessWidget {
  const _BottomSheetContainer({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final c = context.vColors;
    return Container(
      decoration: BoxDecoration(
        color: c.cardSurface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLG),
        ),
        border: Border(
          top: BorderSide(color: c.glassBorder, width: 1),
          left: BorderSide(color: c.glassBorder, width: 0.5),
          right: BorderSide(color: c.glassBorder, width: 0.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: c.glassBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.screenPaddingH,
              4,
              AppDimensions.screenPaddingH,
              AppDimensions.spaceMD,
            ),
            child: Text(
              title,
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Divider(height: 1, color: c.glassBorder),
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppDimensions.screenPaddingH,
              AppDimensions.spaceSM,
              AppDimensions.screenPaddingH,
              bottomPadding + AppDimensions.spaceMD,
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}

// ── Sheet Option Tile ─────────────────────────────────────────────────────────

class _SheetOptionTile extends StatelessWidget {
  const _SheetOptionTile({
    required this.label,
    this.icon,
    this.trailing,
    this.isSelected = false,
    this.onTap,
  });

  final String label;
  final IconData? icon;
  final Widget? trailing;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: AppDimensions.spaceMD),
            ],
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyMedium.copyWith(
                  color: isSelected
                      ? AppColors.primary
                      : context.vColors.textPrimary,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 14,
                ),
              ),
            ),
            if (trailing != null)
              trailing!
            else if (isSelected)
              const Icon(
                Icons.check_rounded,
                color: AppColors.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

// ── Info Row ──────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.vColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: c.textSecondary,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              color: c.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sheet Action Button ───────────────────────────────────────────────────────

class _SheetActionButton extends StatelessWidget {
  const _SheetActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: AppDimensions.spaceSM),
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Logout Button ─────────────────────────────────────────────────────────────

class _LogoutButton extends ConsumerWidget {
  const _LogoutButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appStringsProvider);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(
            color: AppColors.error.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
            const SizedBox(width: AppDimensions.spaceSM),
            Text(
              s.logout,
              style: AppTypography.buttonLabel.copyWith(
                color: AppColors.error,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
