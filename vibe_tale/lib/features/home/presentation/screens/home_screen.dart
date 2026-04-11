import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_tale/core/constants/app_colors.dart';
import 'package:vibe_tale/core/constants/app_dimensions.dart';
import 'package:vibe_tale/core/constants/app_typography.dart';
import 'package:vibe_tale/core/providers/app_settings_provider.dart';
import 'package:vibe_tale/core/router/app_router.dart';
import 'package:vibe_tale/core/widgets/book_cover_card.dart';
import 'package:vibe_tale/core/theme/app_theme_colors.dart';
import 'package:vibe_tale/core/widgets/themed_background.dart';
import 'package:vibe_tale/features/library/domain/book_model.dart';

// ── Shared bottom nav helper — used by HomeScreen & LibraryScreen ─────────────

class AppBottomNavBar extends ConsumerWidget {
  const AppBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  static const _iconData = [
    (Icons.home_outlined, Icons.home_rounded),
    (Icons.menu_book_outlined, Icons.menu_book_rounded),
    (Icons.add_circle_outline_rounded, Icons.add_circle_rounded),
    (Icons.bar_chart_outlined, Icons.bar_chart_rounded),
    (Icons.person_outline_rounded, Icons.person_rounded),
  ];

  /// Shared navigation logic — call from any screen's onItemSelected.
  static void navigate(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
        break;
      case 1:
        context.go(AppRoutes.library);
        break;
      case 2:
        context.push(AppRoutes.fileUpload);
        break;
      case 3:
        context.go(AppRoutes.stats);
        break;
      case 4:
        context.go(AppRoutes.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appStringsProvider);
    final labels = [s.navHome, s.navLibrary, s.navNew, s.navStats, s.navProfile];
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final c = context.vColors;

    return Container(
      height: AppDimensions.bottomNavHeight + bottomPadding,
      decoration: BoxDecoration(
        color: c.navBg,
        border: Border(
          top: BorderSide(color: c.glassBorder, width: 0.5),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Row(
          children: List.generate(_iconData.length, (index) {
            final (icon, activeIcon) = _iconData[index];
            final isSelected = index == selectedIndex;
            final isAddButton = index == 2;

            return Expanded(
              child: GestureDetector(
                onTap: () => onItemSelected(index),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isAddButton)
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: AppColors.amberGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryGlow,
                              blurRadius: 14,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: AppColors.backgroundDeep,
                          size: 26,
                        ),
                      )
                    else
                      Icon(
                        isSelected ? activeIcon : icon,
                        color: isSelected ? AppColors.primary : c.textSecondary,
                        size: 24,
                      ),
                    if (!isAddButton) ...[
                      const SizedBox(height: 3),
                      Text(
                        labels[index],
                        style: AppTypography.labelSmall.copyWith(
                          color: isSelected ? AppColors.primary : c.textSecondary,
                          fontSize: 10,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ── Home Screen ───────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedFilter = 0;

  static const _filters = [
    'Daha fazla keşfet',
    'Klasikler',
    'Masallar',
    'Roman',
    'Fantastik',
  ];

  void _onBookTap(Book book) => context.push('/book/${book.id}');

  void _openSearch() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Search',
      barrierColor: Colors.black.withValues(alpha: 0.75),
      transitionDuration: const Duration(milliseconds: 220),
      transitionBuilder: (ctx, anim, secondAnim, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.1),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
        child: FadeTransition(opacity: anim, child: child),
      ),
      pageBuilder: (ctx, anim, secondAnim) => const HomeSearchDialog(),
    );
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HomeTopBar(onSearchTap: _openSearch),
              Expanded(
                child: _DiscoveryContent(
                  filters: _filters,
                  selectedFilter: _selectedFilter,
                  onFilterChanged: (i) => setState(() => _selectedFilter = i),
                  onBookTap: _onBookTap,
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: AppBottomNavBar(
          selectedIndex: 0,
          onItemSelected: (i) => AppBottomNavBar.navigate(context, i),
        ),
      ),
    );
  }
}

// ── Home Top Bar ──────────────────────────────────────────────────────────────

class _HomeTopBar extends ConsumerWidget {
  const _HomeTopBar({required this.onSearchTap});

  final VoidCallback onSearchTap;

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
      child: Row(
        children: [
          const Icon(
            Icons.auto_stories_rounded,
            color: AppColors.primary,
            size: 28,
          ),
          const SizedBox(width: AppDimensions.spaceSM),
          Text(
            s.discover,
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onSearchTap,
            child: Builder(
              builder: (ctx) {
                final c = ctx.vColors;
                return Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: c.inputFill,
                    border: Border.all(color: c.glassBorder, width: 1),
                  ),
                  child: Icon(
                    Icons.search_rounded,
                    color: c.textPrimary,
                    size: 20,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Discovery Content (scrollable body) ──────────────────────────────────────

class _DiscoveryContent extends ConsumerWidget {
  const _DiscoveryContent({
    required this.filters,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.onBookTap,
  });

  final List<String> filters;
  final int selectedFilter;
  final ValueChanged<int> onFilterChanged;
  final ValueChanged<Book> onBookTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appStringsProvider);
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return ListView(
      padding: EdgeInsets.only(
        bottom: AppDimensions.bottomNavHeight + bottomPadding + 16,
      ),
      children: [
        const SizedBox(height: AppDimensions.spaceSM),
        _FilterChipsRow(
          filters: filters,
          selectedIndex: selectedFilter,
          onChanged: onFilterChanged,
        ),
        const SizedBox(height: AppDimensions.spaceMD),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPaddingH,
          ),
          child: _HeroBanner(
            book: DummyBooks.featured,
            onReadTap: () => onBookTap(DummyBooks.featured),
          ),
        ),
        const SizedBox(height: AppDimensions.spaceXL),
        _BookSection(
          title: s.weeklyPicks,
          books: DummyBooks.haftaninOnerileri,
          onBookTap: onBookTap,
          onSeeAll: () {},
        ),
        const SizedBox(height: AppDimensions.spaceXL),
        _BookSection(
          title: s.darkPast,
          books: DummyBooks.karanlikGecmis,
          onBookTap: onBookTap,
          onSeeAll: () {},
        ),
        const SizedBox(height: AppDimensions.spaceXL),
        _BookSection(
          title: s.popularAuthors,
          books: DummyBooks.popularYazarlar,
          onBookTap: onBookTap,
          onSeeAll: () {},
        ),
      ],
    );
  }
}

// ── Filter Chips ──────────────────────────────────────────────────────────────

class _FilterChipsRow extends StatelessWidget {
  const _FilterChipsRow({
    required this.filters,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> filters;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.screenPaddingH,
        ),
        itemCount: filters.length,
        separatorBuilder: (_, _) =>
            const SizedBox(width: AppDimensions.spaceSM),
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          final c = context.vColors;
          return GestureDetector(
            onTap: () => onChanged(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                border: Border.all(
                  color: isSelected ? AppColors.primary : c.glassBorder,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Text(
                filters[index],
                style: AppTypography.tagLabel.copyWith(
                  color: isSelected ? AppColors.primary : c.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 12,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Hero Banner ───────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.book, required this.onReadTap});

  final Book book;
  final VoidCallback onReadTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
      child: SizedBox(
        height: 260,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFD4900A),
                    Color(0xFFEFBF25),
                    Color(0xFFF5C842),
                    Color(0xFFEAB820),
                  ],
                  stops: [0.0, 0.3, 0.7, 1.0],
                ),
              ),
            ),
            Opacity(
              opacity: 0.12,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [Colors.white, Colors.transparent],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.spaceMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (book.series != null)
                    Text(
                      book.series!.toUpperCase(),
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.backgroundDeep.withValues(alpha: 0.65),
                        letterSpacing: 2.0,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Center(
                      child: Text(
                        book.title,
                        style: AppTypography.headlineLarge.copyWith(
                          color: AppColors.backgroundDeep,
                          fontWeight: FontWeight.w900,
                          fontSize: 34,
                          height: 1.1,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              book.title,
                              style: AppTypography.titleMedium.copyWith(
                                color: AppColors.backgroundDeep,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${book.series ?? book.genre} • Popüler',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.backgroundDeep.withValues(
                                  alpha: 0.7,
                                ),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spaceMD),
                      GestureDetector(
                        onTap: onReadTap,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundDeep,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusPill,
                            ),
                          ),
                          child: Text(
                            'ŞİMDİ OKU',
                            style: AppTypography.buttonLabel.copyWith(
                              color: AppColors.primary,
                              fontSize: 12,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ],
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

// ── Book Section ──────────────────────────────────────────────────────────────

class _BookSection extends StatelessWidget {
  const _BookSection({
    required this.title,
    required this.books,
    required this.onBookTap,
    required this.onSeeAll,
  });

  final String title;
  final List<Book> books;
  final ValueChanged<Book> onBookTap;
  final VoidCallback onSeeAll;

  static const _cardWidth = 115.0;
  static const _sectionHeight = 222.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPaddingH,
          ),
          child: GestureDetector(
            onTap: onSeeAll,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
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
        ),
        const SizedBox(height: AppDimensions.spaceMD),
        SizedBox(
          height: _sectionHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.screenPaddingH,
            ),
            itemCount: books.length,
            separatorBuilder: (_, _) =>
                const SizedBox(width: AppDimensions.spaceMD),
            itemBuilder: (context, index) {
              final book = books[index];
              return BookCoverCard(
                imageUrl: book.coverUrl,
                title: book.title,
                subtitle: book.genre,
                isNew: book.isNew,
                width: _cardWidth,
                onTap: () => onBookTap(book),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Search Dialog (exported for reuse) ───────────────────────────────────────

class HomeSearchDialog extends StatefulWidget {
  const HomeSearchDialog({super.key});

  @override
  State<HomeSearchDialog> createState() => _HomeSearchDialogState();
}

class _HomeSearchDialogState extends State<HomeSearchDialog> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  String _query = '';

  static final _allBooks = [
    ...DummyBooks.haftaninOnerileri,
    ...DummyBooks.karanlikGecmis,
    ...DummyBooks.popularYazarlar,
    DummyBooks.featured,
  ];

  List<Book> get _results {
    if (_query.isEmpty) return [];
    final q = _query.toLowerCase();
    return _allBooks
        .where(
          (b) =>
              b.title.toLowerCase().contains(q) ||
              b.author.toLowerCase().contains(q) ||
              b.genre.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;
    final c = context.vColors;
    return Align(
      alignment: Alignment.topCenter,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          decoration: BoxDecoration(
            color: c.cardSurface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
            border: Border.all(color: c.glassBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
                child: Row(
                  children: [
                    Icon(
                      Icons.search_rounded,
                      color: c.textSecondary,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        style: AppTypography.bodyLarge.copyWith(
                          color: c.textPrimary,
                          fontSize: 15,
                        ),
                        cursorColor: AppColors.primary,
                        decoration: InputDecoration(
                          hintText: 'Kitap, yazar veya kategori ara...',
                          hintStyle: AppTypography.bodyMedium.copyWith(
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (v) => setState(() => _query = v),
                      ),
                    ),
                    if (_query.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _controller.clear();
                          setState(() => _query = '');
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.close_rounded,
                            color: c.textSecondary,
                            size: 20,
                          ),
                        ),
                      )
                    else
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'İptal',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Divider(color: c.glassBorder, height: 1),
              if (_query.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        color: c.textSecondary,
                        size: 36,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Kitap, yazar veya kategori gir',
                        style: AppTypography.bodyMedium,
                      ),
                    ],
                  ),
                )
              else if (results.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        color: c.textSecondary,
                        size: 36,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '"$_query" için sonuç bulunamadı',
                        style: AppTypography.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: results.length,
                    separatorBuilder: (_, _) => Divider(
                      color: c.glassBorder,
                      height: 1,
                      indent: 72,
                    ),
                    itemBuilder: (context, index) {
                      final book = results[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: SizedBox(
                            width: 40,
                            height: 58,
                            child: Image.network(
                              book.coverUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                color: c.cardElevated,
                                child: Icon(
                                  Icons.book_outlined,
                                  color: c.textSecondary,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          book.title,
                          style: AppTypography.titleMedium.copyWith(
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${book.author} • ${book.genre}',
                          style: AppTypography.bodyMedium.copyWith(
                            fontSize: 11,
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          context.push('/book/${book.id}');
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
