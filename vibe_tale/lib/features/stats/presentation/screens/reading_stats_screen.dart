
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibe_tale/core/constants/app_colors.dart';
import 'package:vibe_tale/core/constants/app_dimensions.dart';
import 'package:vibe_tale/core/constants/app_typography.dart';
import 'package:vibe_tale/core/providers/app_settings_provider.dart';
import 'package:vibe_tale/core/theme/app_theme_colors.dart';
import 'package:vibe_tale/features/home/presentation/screens/home_screen.dart';
import 'package:vibe_tale/core/widgets/themed_background.dart';

// ── Dummy Leaderboard Data ────────────────────────────────────────────────────

class LeaderboardUser {
  const LeaderboardUser({
    required this.rank,
    required this.name,
    required this.username,
    required this.avatarSeed,
    required this.booksRead,
    required this.pagesRead,
    required this.readingStreak,
    required this.badge,
    this.isCurrentUser = false,
  });

  final int rank;
  final String name;
  final String username;
  final String avatarSeed;
  final int booksRead;
  final int pagesRead;
  final int readingStreak;
  final String badge;
  final bool isCurrentUser;

  String get avatarUrl =>
      'https://api.dicebear.com/7.x/avataaars/svg?seed=$avatarSeed';
}

const _leaderboardUsers = [
  LeaderboardUser(
    rank: 1,
    name: 'Zeynep Kara',
    username: '@zeynepkara',
    avatarSeed: 'zeynep',
    booksRead: 47,
    pagesRead: 14328,
    readingStreak: 82,
    badge: '🏆',
  ),
  LeaderboardUser(
    rank: 2,
    name: 'Mert Yıldız',
    username: '@mertyildiz',
    avatarSeed: 'mert',
    booksRead: 39,
    pagesRead: 11904,
    readingStreak: 61,
    badge: '🥈',
  ),
  LeaderboardUser(
    rank: 3,
    name: 'Elif Şahin',
    username: '@elif_s',
    avatarSeed: 'elif',
    booksRead: 34,
    pagesRead: 10220,
    readingStreak: 45,
    badge: '🥉',
  ),
  LeaderboardUser(
    rank: 4,
    name: 'Burak Demir',
    username: '@burakd',
    avatarSeed: 'burak',
    booksRead: 28,
    pagesRead: 8610,
    readingStreak: 33,
    badge: '📚',
  ),
  LeaderboardUser(
    rank: 5,
    name: 'Selin Arslan',
    username: '@selin_a',
    avatarSeed: 'selin',
    booksRead: 25,
    pagesRead: 7890,
    readingStreak: 28,
    badge: '📖',
  ),
  LeaderboardUser(
    rank: 6,
    name: 'Can Öztürk',
    username: '@can_oz',
    avatarSeed: 'can',
    booksRead: 21,
    pagesRead: 6540,
    readingStreak: 19,
    badge: '✨',
  ),
  LeaderboardUser(
    rank: 7,
    name: 'Ayşe Yılmaz',
    username: '@ayse_y',
    avatarSeed: 'ayse',
    booksRead: 18,
    pagesRead: 5230,
    readingStreak: 14,
    badge: '🌟',
  ),
  LeaderboardUser(
    rank: 8,
    name: 'Sen',
    username: '@ben',
    avatarSeed: 'me',
    booksRead: 6,
    pagesRead: 1820,
    readingStreak: 7,
    badge: '🔥',
    isCurrentUser: true,
  ),
  LeaderboardUser(
    rank: 9,
    name: 'Deniz Kurt',
    username: '@denizkurt',
    avatarSeed: 'deniz',
    booksRead: 5,
    pagesRead: 1540,
    readingStreak: 3,
    badge: '📝',
  ),
  LeaderboardUser(
    rank: 10,
    name: 'Hasan Çelik',
    username: '@hasanc',
    avatarSeed: 'hasan',
    booksRead: 3,
    pagesRead: 924,
    readingStreak: 1,
    badge: '🌱',
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class ReadingStatsScreen extends ConsumerStatefulWidget {
  const ReadingStatsScreen({super.key});

  @override
  ConsumerState<ReadingStatsScreen> createState() => _ReadingStatsScreenState();
}

enum _Period { weekly, monthly, allTime }

class _ReadingStatsScreenState extends ConsumerState<ReadingStatsScreen>
    with SingleTickerProviderStateMixin {
  _Period _period = _Period.monthly;
  late final AnimationController _podiumController;
  late final Animation<double> _podiumAnim;

  @override
  void initState() {
    super.initState();
    _podiumController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _podiumAnim = CurvedAnimation(
      parent: _podiumController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _podiumController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    AppBottomNavBar.navigate(context, index);
  }

  @override
  Widget build(BuildContext context) {
    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _TopBar(period: _period, onPeriodChanged: (p) {
                setState(() {
                  _period = p;
                  _podiumController
                    ..reset()
                    ..forward();
                });
              }),
              Expanded(
                child: _LeaderboardBody(
                  users: _leaderboardUsers,
                  podiumAnim: _podiumAnim,
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: AppBottomNavBar(
          selectedIndex: 3,
          onItemSelected: _onNavTap,
        ),
      ),
    );
  }
}

// ── Top Bar ───────────────────────────────────────────────────────────────────

class _TopBar extends ConsumerWidget {
  const _TopBar({required this.period, required this.onPeriodChanged});

  final _Period period;
  final ValueChanged<_Period> onPeriodChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appStringsProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.screenPaddingH,
        AppDimensions.spaceMD,
        AppDimensions.screenPaddingH,
        AppDimensions.spaceSM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events_rounded,
                  color: AppColors.primary, size: 28),
              const SizedBox(width: AppDimensions.spaceSM),
              Text(
                s.leaderboard,
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
              const Spacer(),
              // Period selector
              Container(
                decoration: BoxDecoration(
                  color: context.vColors.inputFill,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusPill),
                  border: Border.all(color: context.vColors.glassBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _PeriodChip(
                      label: s.periodWeek,
                      isSelected: period == _Period.weekly,
                      onTap: () => onPeriodChanged(_Period.weekly),
                    ),
                    _PeriodChip(
                      label: s.periodMonth,
                      isSelected: period == _Period.monthly,
                      onTap: () => onPeriodChanged(_Period.monthly),
                    ),
                    _PeriodChip(
                      label: s.periodAll,
                      isSelected: period == _Period.allTime,
                      onTap: () => onPeriodChanged(_Period.allTime),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  const _PeriodChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
        ),
        child: Text(
          label,
          style: AppTypography.tagLabel.copyWith(
            color: isSelected
                ? AppColors.backgroundDeep
                : (context.isDark
                    ? context.vColors.textSecondary
                    : context.vColors.textPrimary.withValues(alpha: 0.7)),
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}

// ── Leaderboard Body ──────────────────────────────────────────────────────────

class _LeaderboardBody extends ConsumerWidget {
  const _LeaderboardBody({
    required this.users,
    required this.podiumAnim,
  });

  final List<LeaderboardUser> users;
  final Animation<double> podiumAnim;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appStringsProvider);
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final currentUser = users.firstWhere((u) => u.isCurrentUser);
    final top3 = users.take(3).toList();
    final rest = users.skip(3).toList();

    return ListView(
      padding: EdgeInsets.only(
        bottom: AppDimensions.bottomNavHeight + bottomPadding + 16,
      ),
      children: [
        // My stats card
        _MyStatsCard(user: currentUser),
        const SizedBox(height: AppDimensions.spaceLG),

        // Podium — top 3
        _Podium(top3: top3, animation: podiumAnim),
        const SizedBox(height: AppDimensions.spaceXL),

        // Section label
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPaddingH,
          ),
          child: Row(
            children: [
              Text(
                s.ranking,
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Text(
                s.booksReadLabel,
                style: AppTypography.bodyMedium.copyWith(
                  fontSize: 11,
                  color: context.vColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.spaceMD),

        // Rank list
        ...rest.map((u) => _RankRow(user: u)),
      ],
    );
  }
}

// ── My Stats Card ─────────────────────────────────────────────────────────────

class _MyStatsCard extends ConsumerWidget {
  const _MyStatsCard({required this.user});

  final LeaderboardUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appStringsProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPaddingH,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spaceMD),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: context.isDark
                ? [const Color(0xFF1A3540), const Color(0xFF0F2530)]
                : [Colors.white, const Color(0xFFF0F4F2)],
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: context.isDark ? 0.35 : 0.6),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            _Avatar(seed: user.avatarSeed, size: 52, hasBorder: true),
            const SizedBox(width: AppDimensions.spaceMD),
            // Name + rank
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.myStatus,
                    style: AppTypography.labelSmall.copyWith(
                      color: context.vColors.textSecondary,
                      fontSize: 10,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    user.name,
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    user.username,
                    style: AppTypography.bodyMedium.copyWith(
                      fontSize: 11,
                      color: context.vColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Rank badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusPill),
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.4)),
              ),
              child: Column(
                children: [
                  Text(
                    '#${user.rank}',
                    style: AppTypography.headlineMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    s.rankLabel,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primary.withValues(alpha: 0.7),
                      fontSize: 9,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Podium ────────────────────────────────────────────────────────────────────

class _Podium extends StatelessWidget {
  const _Podium({required this.top3, required this.animation});

  final List<LeaderboardUser> top3;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final first = top3[0];
    final second = top3[1];
    final third = top3[2];

    return SizedBox(
      height: 280,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Glow under podium
              Positioned(
                bottom: 0,
                child: Container(
                  width: 260,
                  height: 30,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: (context.isDark ? 0.20 : 0.12) * animation.value),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // 2nd place (left)
              Positioned(
                left: 0,
                bottom: 0,
                child: _PodiumColumn(
                  user: second,
                  height: 110 * animation.value,
                  color: const Color(0xFF9BA5B4),
                  crownColor: const Color(0xFFBDC8D3),
                  rankLabel: '2',
                  avatarSize: 52,
                  width: 110,
                ),
              ),

              // 1st place (center) — tallest
              Positioned(
                bottom: 0,
                child: _PodiumColumn(
                  user: first,
                  height: 150 * animation.value,
                  color: AppColors.primary,
                  crownColor: AppColors.primaryDark,
                  rankLabel: '1',
                  avatarSize: 64,
                  width: 120,
                  showCrown: true,
                ),
              ),

              // 3rd place (right)
              Positioned(
                right: 0,
                bottom: 0,
                child: _PodiumColumn(
                  user: third,
                  height: 80 * animation.value,
                  color: const Color(0xFFB87333),
                  crownColor: const Color(0xFFCD8B4A),
                  rankLabel: '3',
                  avatarSize: 46,
                  width: 100,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PodiumColumn extends ConsumerWidget {
  const _PodiumColumn({
    required this.user,
    required this.height,
    required this.color,
    required this.crownColor,
    required this.rankLabel,
    required this.avatarSize,
    required this.width,
    this.showCrown = false,
  });

  final LeaderboardUser user;
  final double height;
  final Color color;
  final Color crownColor;
  final String rankLabel;
  final double avatarSize;
  final double width;
  final bool showCrown;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appStringsProvider);
    return SizedBox(
      width: width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Crown for 1st
          if (showCrown)
            const Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Text('👑', style: TextStyle(fontSize: 22)),
            ),
          // Avatar
          _Avatar(seed: user.avatarSeed, size: avatarSize, hasBorder: false),
          const SizedBox(height: 6),
          // Name
          Text(
            user.name.split(' ').first,
            style: AppTypography.labelSmall.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          // Books count
          Text(
            '${user.booksRead} ${s.booksWord}',
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          // Podium block
          Container(
            height: height.clamp(0.0, 9999),
            width: width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  color.withValues(alpha: context.isDark ? 0.85 : 0.70),
                  color.withValues(alpha: context.isDark ? 0.55 : 0.40),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(10),
              ),
            ),
            child: Center(
              child: Text(
                rankLabel,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Rank Row (4th+) ───────────────────────────────────────────────────────────

class _RankRow extends ConsumerWidget {
  const _RankRow({required this.user});

  final LeaderboardUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appStringsProvider);
    final isMe = user.isCurrentUser;
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPaddingH,
        vertical: 4,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceMD,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: isMe
            ? AppColors.primary.withValues(alpha: 0.10)
            : context.vColors.cardElevated,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(
          color: isMe
              ? AppColors.primary.withValues(alpha: 0.35)
              : context.vColors.glassBorder,
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          // Rank number
          SizedBox(
            width: 32,
            child: Text(
              '#${user.rank}',
              style: AppTypography.titleMedium.copyWith(
                color: isMe ? AppColors.primary : context.vColors.textSecondary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          // Avatar
          _Avatar(seed: user.avatarSeed, size: 38, hasBorder: false),
          const SizedBox(width: AppDimensions.spaceSM),
          // Name + username
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user.name,
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: isMe ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 13,
                        color: isMe ? AppColors.primary : context.vColors.textPrimary,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          s.youBadge,
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.backgroundDeep,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  s.streakLine(user.readingStreak, user.pagesRead),
                  style: AppTypography.bodyMedium.copyWith(
                    fontSize: 10,
                    color: context.vColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Books read
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${user.booksRead}',
                style: AppTypography.titleLarge.copyWith(
                  color: isMe ? AppColors.primary : context.vColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              Text(
                s.booksWord,
                style: AppTypography.labelSmall.copyWith(
                  color: context.vColors.textSecondary,
                  fontSize: 9,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Avatar Widget ─────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.seed,
    required this.size,
    required this.hasBorder,
  });

  final String seed;
  final double size;
  final bool hasBorder;

  // Fallback: colored circle with first-letter initials using seed as color seed
  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFF1F6E78),
      const Color(0xFF2D5016),
      const Color(0xFF5B2D8E),
      const Color(0xFF8E2D2D),
      const Color(0xFF1A4A6E),
    ];
    final colorIndex = seed.codeUnits.fold(0, (a, b) => a + b) % colors.length;
    final bg = colors[colorIndex];
    final letter = seed.isNotEmpty ? seed[0].toUpperCase() : '?';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bg,
        border: hasBorder
            ? Border.all(color: AppColors.primary, width: 2.5)
            : Border.all(color: context.vColors.glassBorder, width: 0.8),
        boxShadow: hasBorder
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.38,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
