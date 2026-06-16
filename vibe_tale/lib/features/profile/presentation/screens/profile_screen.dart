import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibe_tale/core/constants/app_colors.dart';
import 'package:vibe_tale/core/constants/app_dimensions.dart';
import 'package:vibe_tale/core/constants/app_typography.dart';
import 'package:vibe_tale/core/providers/app_settings_provider.dart';
import 'package:vibe_tale/core/router/app_router.dart';
import 'package:vibe_tale/core/theme/app_theme_colors.dart';
import 'package:vibe_tale/core/widgets/glass_card.dart';
import 'package:vibe_tale/core/widgets/themed_background.dart';
import 'package:vibe_tale/features/home/presentation/screens/home_screen.dart';
import 'package:vibe_tale/features/library/application/books_provider.dart';
import 'package:vibe_tale/features/profile/application/me_provider.dart';
import 'package:vibe_tale/features/profile/domain/models/user_profile.dart';

const _monthsTr = [
  'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
  'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
];

/// Builds a [UserProfile] from the signed-in Supabase user. Reading stats that
/// have no dedicated backend endpoint yet fall back to derived/placeholder values.
UserProfile _profileFromSession(WidgetRef ref) {
  final user = Supabase.instance.client.auth.currentUser;
  final meta = user?.userMetadata;
  final email = user?.email ?? '';
  final name = (meta?['username'] ?? meta?['display_name']) as String? ??
      (email.contains('@') ? email.split('@').first : 'Okuyucu');

  String memberSince = '';
  final created = user?.createdAt;
  if (created != null) {
    final d = DateTime.tryParse(created);
    if (d != null) memberSince = '${_monthsTr[d.month - 1]} ${d.year}';
  }

  final booksRead = ref.watch(booksProvider).valueOrNull?.length ?? 0;

  return UserProfile(
    name: name,
    email: email,
    booksRead: booksRead,
    memberSince: memberSince,
  );
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = _profileFromSession(ref);
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

class _ProfileTopBar extends ConsumerWidget {
  const _ProfileTopBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appStringsProvider);
    final c = context.vColors;
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
            s.myProfile,
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
                color: c.inputFill,
                border: Border.all(color: c.glassBorder, width: 1),
              ),
              child: Icon(
                Icons.settings_outlined,
                color: c.textPrimary,
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

class _ProfileHeader extends ConsumerWidget {
  const _ProfileHeader({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appStringsProvider);
    final c = context.vColors;
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
              color: c.cardElevated,
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
            '${profile.memberSince} ${s.memberSince}',
            style: AppTypography.bodyMedium.copyWith(
              fontSize: 11,
              color: c.textHint,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceMD),
          // Edit profile pill button
          GestureDetector(
            onTap: () => context.push(AppRoutes.profileSettings),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: c.inputFill,
                borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                border: Border.all(color: c.glassBorder, width: 1),
              ),
              child: Text(
                s.editProfile,
                style: AppTypography.labelSmall.copyWith(
                  color: c.textSecondary,
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

class _ReadingStatsRow extends ConsumerWidget {
  const _ReadingStatsRow({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appStringsProvider);
    final stats = ref.watch(statsProvider).valueOrNull;
    final booksRead = stats?.booksRead ?? profile.booksRead;
    final booksCompleted = stats?.booksCompleted ?? 0;
    final hours = stats?.totalReadingHours ?? 0;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPaddingH,
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              value: '$booksRead',
              label: s.booksRead,
              icon: Icons.book_outlined,
            ),
          ),
          const SizedBox(width: AppDimensions.spaceMD),
          Expanded(
            child: _StatCard(
              value: '$booksCompleted',
              label: s.booksCompleted,
              icon: Icons.check_circle_outline_rounded,
            ),
          ),
          const SizedBox(width: AppDimensions.spaceMD),
          Expanded(
            child: _StatCard(
              value: '$hours${s.hoursSuffix}',
              label: s.totalHours,
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

class _AchievementSection extends ConsumerWidget {
  const _AchievementSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appStringsProvider);
    final achievements =
        ref.watch(achievementsProvider).valueOrNull ?? const [];
    bool earned(String key) =>
        achievements.any((a) => a.key == key && a.earned);
    final badges = [
      _Badge(icon: Icons.local_fire_department_rounded, label: s.badgeStreak7, earned: earned('streak_7')),
      _Badge(icon: Icons.speed_rounded, label: s.badgeFastReader, earned: earned('speed_reader')),
      _Badge(icon: Icons.auto_stories_rounded, label: s.badgeFirstBook, earned: earned('first_book')),
      _Badge(icon: Icons.star_rounded, label: s.badgeSuperReader, earned: earned('super_reader')),
      _Badge(icon: Icons.emoji_events_rounded, label: s.badgeMonthRecord, earned: earned('month_record')),
    ];
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
                s.achievements,
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
            itemCount: badges.length,
            separatorBuilder: (_, _) =>
                const SizedBox(width: AppDimensions.spaceMD),
            itemBuilder: (context, index) =>
                _AchievementBadge(badge: badges[index]),
          ),
        ),
      ],
    );
  }
}

class _Badge {
  const _Badge({required this.icon, required this.label, this.earned = true});

  final IconData icon;
  final String label;
  final bool earned;
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
            gradient: badge.earned ? AppColors.amberGradient : null,
            color: badge.earned ? null : context.vColors.inputFill,
            border: badge.earned
                ? null
                : Border.all(color: context.vColors.glassBorder),
            boxShadow: badge.earned
                ? [
                    BoxShadow(
                      color: AppColors.primaryGlow,
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Icon(
            badge.icon,
            color: badge.earned
                ? AppColors.backgroundDeep
                : context.vColors.textSecondary,
            size: 28,
          ),
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

class _ReadingActivitySection extends ConsumerWidget {
  const _ReadingActivitySection({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appStringsProvider);
    final weekDays = s.weekDays;
    final c = context.vColors;
    final activity =
        ref.watch(statsProvider).valueOrNull?.weeklyActivity ?? const [];
    final weekMinutes = List<int>.generate(
        7, (i) => i < activity.length ? activity[i].minutes : 0);
    final maxMinutes = weekMinutes.fold<int>(1, (m, v) => v > m ? v : m).toDouble();
    final todayIndex = DateTime.now().weekday - 1;
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
                  s.thisWeek,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Text(
                  '${weekMinutes.fold(0, (a, b) => a + b)} ${s.minutes}',
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
                children: List.generate(weekDays.length, (i) {
                  final ratio = weekMinutes[i] / maxMinutes;
                  final isToday = i == todayIndex;
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
                              color: ratio == 0 ? c.glassBorder : null,
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
                            weekDays[i],
                            style: AppTypography.labelSmall.copyWith(
                              fontSize: 9,
                              color: isToday
                                  ? AppColors.primary
                                  : c.textSecondary,
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
