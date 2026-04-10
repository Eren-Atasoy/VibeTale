import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_tale/core/constants/app_colors.dart';
import 'package:vibe_tale/core/constants/app_dimensions.dart';
import 'package:vibe_tale/core/constants/app_typography.dart';
import 'package:vibe_tale/core/router/app_router.dart';
import 'package:vibe_tale/core/widgets/glass_card.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  bool _notificationsOn = true;
  bool _readingReminder = false;
  bool _isDarkMode = true;
  String _selectedLanguage = 'Türkçe';

  // ── Switch helper ─────────────────────────────────────────────────────────

  Switch _buildSwitch(bool value, ValueChanged<bool> onChanged) {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppColors.primary,
      activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
      inactiveThumbColor: AppColors.textSecondary,
      inactiveTrackColor: AppColors.glassBorder,
    );
  }

  // ── Bottom sheet & dialog helpers ─────────────────────────────────────────

  void _showLanguageSheet() {
    final languages = ['Türkçe', 'English', 'Deutsch', 'Español', 'Français'];
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomSheetContainer(
        title: 'Dil Seç',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((lang) {
            final isSelected = lang == _selectedLanguage;
            return _SheetOptionTile(
              label: lang,
              isSelected: isSelected,
              onTap: () {
                setState(() => _selectedLanguage = lang);
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showAccountSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomSheetContainer(
        title: 'Hesap Bilgileri',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _InfoRow(label: 'Ad Soyad', value: 'Eren Atasoy'),
            _InfoRow(label: 'E-posta', value: 'eren@vibetale.com'),
            _InfoRow(label: 'Üyelik', value: 'Ocak 2025'),
            _InfoRow(label: 'Plan', value: 'Ücretsiz'),
            const SizedBox(height: AppDimensions.spaceMD),
            _SheetActionButton(
              label: 'Hesabı Düzenle',
              icon: Icons.edit_outlined,
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacySheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _BottomSheetContainer(
        title: 'Gizlilik',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SheetOptionTile(
              label: 'Okuma Geçmişini Gizle',
              trailing: _buildSwitch(false, (_) {}),
              onTap: null,
            ),
            _SheetOptionTile(
              label: 'Profili Herkese Açık Göster',
              trailing: _buildSwitch(true, (_) {}),
              onTap: null,
            ),
            _SheetOptionTile(
              label: 'Başarımları Paylaş',
              trailing: _buildSwitch(true, (_) {}),
              onTap: null,
            ),
            const SizedBox(height: AppDimensions.spaceMD),
            _SheetActionButton(
              label: 'Verileri İndir',
              icon: Icons.download_outlined,
              onTap: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: AppDimensions.spaceSM),
            _SheetActionButton(
              label: 'Hesabı Sil',
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
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomSheetContainer(
        title: 'Yardım & Destek',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SheetOptionTile(
              label: 'Sık Sorulan Sorular',
              icon: Icons.quiz_outlined,
              onTap: () => Navigator.of(context).pop(),
            ),
            _SheetOptionTile(
              label: 'Bize Ulaşın',
              icon: Icons.mail_outline_rounded,
              onTap: () => Navigator.of(context).pop(),
            ),
            _SheetOptionTile(
              label: 'Geri Bildirim Gönder',
              icon: Icons.feedback_outlined,
              onTap: () => Navigator.of(context).pop(),
            ),
            _SheetOptionTile(
              label: 'Hata Bildir',
              icon: Icons.bug_report_outlined,
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomSheetContainer(
        title: 'Hakkında',
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
            Text('Versiyon 1.0.0', style: AppTypography.bodyMedium),
            const SizedBox(height: AppDimensions.spaceMD),
            const Divider(color: AppColors.glassBorder),
            const SizedBox(height: AppDimensions.spaceSM),
            _InfoRow(label: 'Geliştirici', value: 'VibeTale Team'),
            _InfoRow(label: 'Lisans', value: 'MIT'),
            _InfoRow(label: 'Yapı Tarihi', value: 'Ocak 2025'),
            const SizedBox(height: AppDimensions.spaceMD),
          ],
        ),
      ),
    );
  }

  void _confirmLogout() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F2A30),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
        title: Text('Çıkış Yap', style: AppTypography.titleLarge),
        content: Text(
          'Hesabından çıkmak istediğine emin misin?',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'İptal',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go(AppRoutes.login);
            },
            child: Text(
              'Çıkış Yap',
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
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
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
                    // ── Genel ─────────────────────────────────────────────────
                    _SettingsGroup(
                      title: 'GENEL',
                      tiles: [
                        _SettingsTile(
                          icon: Icons.notifications_outlined,
                          label: 'Bildirimler',
                          trailing: _buildSwitch(
                            _notificationsOn,
                            (v) => setState(() => _notificationsOn = v),
                          ),
                        ),
                        _SettingsTile(
                          icon: Icons.alarm_outlined,
                          label: 'Okuma Hatırlatıcısı',
                          trailing: _buildSwitch(
                            _readingReminder,
                            (v) => setState(() => _readingReminder = v),
                          ),
                        ),
                        _SettingsTile(
                          icon: _isDarkMode
                              ? Icons.dark_mode_outlined
                              : Icons.light_mode_outlined,
                          label: 'Tema',
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _isDarkMode ? 'Karanlık' : 'Aydınlık',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildSwitch(
                                _isDarkMode,
                                (v) => setState(() => _isDarkMode = v),
                              ),
                            ],
                          ),
                        ),
                        _SettingsTile(
                          icon: Icons.language_outlined,
                          label: 'Dil',
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _selectedLanguage,
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: AppColors.textSecondary,
                                size: 20,
                              ),
                            ],
                          ),
                          onTap: _showLanguageSheet,
                        ),
                      ],
                    ),

                    const SizedBox(height: AppDimensions.spaceLG),

                    // ── Hesap ─────────────────────────────────────────────────
                    _SettingsGroup(
                      title: 'HESAP',
                      tiles: [
                        _SettingsTile(
                          icon: Icons.person_outline_rounded,
                          label: 'Hesap Bilgileri',
                          trailing: const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          onTap: _showAccountSheet,
                        ),
                        _SettingsTile(
                          icon: Icons.lock_outline_rounded,
                          label: 'Gizlilik',
                          trailing: const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          onTap: _showPrivacySheet,
                        ),
                        _SettingsTile(
                          icon: Icons.help_outline_rounded,
                          label: 'Yardım & Destek',
                          trailing: const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          onTap: _showHelpSheet,
                        ),
                        _SettingsTile(
                          icon: Icons.info_outline_rounded,
                          label: 'Hakkında',
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'v1.0.0',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: AppColors.textSecondary,
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

class _SettingsTopBar extends StatelessWidget {
  const _SettingsTopBar();

  @override
  Widget build(BuildContext context) {
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
                color: AppColors.inputFill,
                border: Border.all(color: AppColors.glassBorder, width: 1),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.spaceMD),
          Text(
            'Ayarlar',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: AppDimensions.spaceSM),
          child: Text(
            title,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
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
                  const Divider(
                    height: 1,
                    color: AppColors.glassBorder,
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
                  color: AppColors.textPrimary,
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
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F2A30),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLG),
        ),
        border: Border(
          top: BorderSide(color: AppColors.glassBorder, width: 1),
          left: BorderSide(color: AppColors.glassBorder, width: 0.5),
          right: BorderSide(color: AppColors.glassBorder, width: 0.5),
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
              color: AppColors.glassBorder,
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
          const Divider(height: 1, color: AppColors.glassBorder),
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
                      : AppColors.textPrimary,
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary,
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

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
              'Çıkış Yap',
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
