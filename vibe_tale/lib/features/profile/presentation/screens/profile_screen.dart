import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_tale/core/constants/app_colors.dart';
import 'package:vibe_tale/core/constants/app_dimensions.dart';
import 'package:vibe_tale/core/constants/app_typography.dart';
import 'package:vibe_tale/core/router/app_router.dart';
import 'package:vibe_tale/core/widgets/glass_card.dart';
import 'package:vibe_tale/core/widgets/themed_background.dart';
import 'package:vibe_tale/features/home/presentation/screens/home_screen.dart';
import 'package:vibe_tale/features/profile/domain/models/user_profile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = DummyProfile.current;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProfileTopBar(),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.only(
                    bottom: AppDimensions.bottomNavHeight + bottomPadding + 16,
                  ),
                  children: [
                    const SizedBox(height: AppDimensions.spaceMD),
                    _ProfileHeader(profile: profile),
                    const SizedBox(height: AppDimensions.spaceXL),
                    _ReadingStatsRow(profile: profile),
                    const SizedBox(height: AppDimensions.spaceXL),
                    _AchievementSection(),
                    const SizedBox(height: AppDimensions.spaceXL),
                    _ReadingActivitySection(profile: profile),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: AppBottomNavBar(
          selectedIndex: 4,
          onItemSelected: (i) => AppBottomNavBar.navigate(context, i),
        ),
      ),
    );
  }
}

// ── Profile Top Bar ───────────────────────────────────────────────────────────

class _ProfileTopBar extends StatelessWidget {
  const _ProfileTopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.screenPaddingH,
        AppDimensions.spaceMD,
        AppDimensions.screenPaddingH,
        AppDimensions.spaceSM,
      ),
      child: Row(
        children: [
          const Icon(Icons.person_rounded, color: AppColors.primary, size: 28),
          const SizedBox(width: AppDimensions.spaceSM),
          Text(
            'Profilim',
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => context.push(AppRoutes.profileSettings),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.inputFill,
                border: Border.all(color: AppColors.glassBorder, width: 1),
              ),
              child: const Icon(
                Icons.settings_outlined,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Profile Header ────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPaddingH,
      ),
      child: Column(
        children: [
          // Avatar with amber ring
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2.5),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A3A40), Color(0xFF0E2A2E)],
              ),
            ),
            child: profile.avatarUrl != null
                ? ClipOval(
                    child: Image.network(
                      profile.avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          _AvatarPlaceholder(name: profile.name),
                    ),
                  )
                : _AvatarPlaceholder(name: profile.name),
          ),
          const SizedBox(height: AppDimensions.spaceMD),
          Text(
            profile.name,
            style: AppTypography.headlineMedium.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            profile.email,
            style: AppTypography.bodyMedium.copyWith(fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            '${profile.memberSince} tarihinden beri üye',
            style: AppTypography.bodyMedium.copyWith(
              fontSize: 11,
              color: AppColors.textHint,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceMD),
          // Edit profile pill button
          GestureDetector(
            onTap: () => context.push(AppRoutes.profileSettings),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                border: Border.all(color: AppColors.glassBorder, width: 1),
              ),
              child: Text(
                'Profili Düzenle',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final initials = name
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();
    return Center(
      child: Text(
        initials,
        style: AppTypography.headlineLarge.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
          fontSize: 32,
        ),
      ),
    );
  }
}

// ── Reading Stats Row ─────────────────────────────────────────────────────────

class _ReadingStatsRow extends StatelessWidget {
  const _ReadingStatsRow({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPaddingH,
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              value: '${profile.booksRead}',
              label: 'Okunan',
              icon: Icons.book_outlined,
            ),
          ),
          const SizedBox(width: AppDimensions.spaceMD),
          Expanded(
            child: _StatCard(
              value: '${profile.booksCompleted}',
              label: 'Tamamlanan',
              icon: Icons.check_circle_outline_rounded,
            ),
          ),
          const SizedBox(width: AppDimensions.spaceMD),
          Expanded(
            child: _StatCard(
              value: '${profile.totalReadingHours.toInt()}s',
              label: 'Toplam Saat',
              icon: Icons.schedule_outlined,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceSM,
        vertical: AppDimensions.spaceMD,
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTypography.headlineLarge.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              fontSize: 10,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Achievement Section ───────────────────────────────────────────────────────

class _AchievementSection extends StatelessWidget {
  const _AchievementSection();

  static const _badges = [
    _Badge(icon: Icons.local_fire_department_rounded, label: '7 Gün Serisi'),
    _Badge(icon: Icons.speed_rounded, label: 'Hızlı Okuyucu'),
    _Badge(icon: Icons.auto_stories_rounded, label: 'İlk Kitap'),
    _Badge(icon: Icons.star_rounded, label: 'Süper Okuyucu'),
    _Badge(icon: Icons.emoji_events_rounded, label: 'Ay Rekoru'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPaddingH,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Başarımlar',
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.spaceMD),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.screenPaddingH,
            ),
            itemCount: _badges.length,
            separatorBuilder: (_, _) =>
                const SizedBox(width: AppDimensions.spaceMD),
            itemBuilder: (context, index) =>
                _AchievementBadge(badge: _badges[index]),
          ),
        ),
      ],
    );
  }
}

class _Badge {
  const _Badge({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class _AchievementBadge extends StatelessWidget {
  const _AchievementBadge({required this.badge});

  final _Badge badge;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.amberGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGlow,
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon(badge.icon, color: AppColors.backgroundDeep, size: 28),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 70,
          child: Text(
            badge.label,
            style: AppTypography.labelSmall.copyWith(
              fontSize: 10,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ── Reading Activity Section ──────────────────────────────────────────────────

class _ReadingActivitySection extends StatelessWidget {
  const _ReadingActivitySection({required this.profile});

  final UserProfile profile;

  static const _weekDays = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
  static const _weekMinutes = [0, 45, 30, 0, 60, 90, 20];
  static const _maxMinutes = 90.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPaddingH,
      ),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bu Hafta',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Text(
                  '${_weekMinutes.fold(0, (a, b) => a + b)} dk',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spaceMD),
            SizedBox(
              height: 80,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(_weekDays.length, (i) {
                  final ratio = _weekMinutes[i] / _maxMinutes;
                  final isToday = i == 3; // Perşembe placeholder
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AnimatedContainer(
                            duration: Duration(milliseconds: 300 + i * 50),
                            height: ratio * 52 + 4,
                            decoration: BoxDecoration(
                              gradient: ratio > 0
                                  ? AppColors.amberGradient
                                  : null,
                              color: ratio == 0 ? AppColors.glassBorder : null,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: ratio > 0
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primaryGlow,
                                        blurRadius: 6,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _weekDays[i],
                            style: AppTypography.labelSmall.copyWith(
                              fontSize: 9,
                              color: isToday
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              fontWeight: isToday
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
