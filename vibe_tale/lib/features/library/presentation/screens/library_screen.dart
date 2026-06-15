import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_tale/core/constants/app_colors.dart';
import 'package:vibe_tale/core/constants/app_dimensions.dart';
import 'package:vibe_tale/core/constants/app_typography.dart';
import 'package:vibe_tale/core/providers/app_settings_provider.dart';
import 'package:vibe_tale/core/theme/app_theme_colors.dart';
import 'package:vibe_tale/core/widgets/book_cover_card.dart';
import 'package:vibe_tale/core/widgets/themed_background.dart';
import 'package:vibe_tale/features/home/presentation/screens/home_screen.dart';
import 'package:vibe_tale/features/library/application/books_provider.dart';
import 'package:vibe_tale/features/library/domain/book_model.dart';

// ── Library Screen (Personal Collection) ─────────────────────────────────────

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final booksAsync = ref.watch(booksProvider);

    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LibraryTopBar(),
              _LibraryTabBar(controller: _tabController),
              Expanded(
                child: booksAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                  error: (e, _) => _ErrorState(message: e.toString()),
                  data: (books) => TabBarView(
                    controller: _tabController,
                    children: [
                      _ReadingTab(
                        books: books,
                        onBookTap: (b) => context.push('/book/${b.id}'),
                      ),
                      _CompletedTab(
                        books: const [],
                        onBookTap: (b) => context.push('/book/${b.id}'),
                      ),
                      _SavedTab(
                        books: const [],
                        onBookTap: (b) => context.push('/book/${b.id}'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: AppBottomNavBar(
          selectedIndex: 1,
          onItemSelected: (i) => AppBottomNavBar.navigate(context, i),
        ),
      ),
    );
  }
}

// ── Library Top Bar ───────────────────────────────────────────────────────────

class _LibraryTopBar extends ConsumerWidget {
  const _LibraryTopBar();

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
          const Icon(
            Icons.menu_book_rounded,
            color: AppColors.primary,
            size: 28,
          ),
          const SizedBox(width: AppDimensions.spaceSM),
          Text(
            s.myLibrary,
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          const Spacer(),
          // Total book count badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: c.inputFill,
              borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
              border: Border.all(color: c.glassBorder),
            ),
            child: Text(
              '${ref.watch(booksProvider).valueOrNull?.length ?? 0} ${ref.watch(appStringsProvider).books}',
              style: AppTypography.tagLabel.copyWith(
                color: c.textSecondary,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Library Tab Bar ───────────────────────────────────────────────────────────

class _LibraryTabBar extends ConsumerWidget {
  const _LibraryTabBar({required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appStringsProvider);
    final c = context.vColors;
    return TabBar(
      controller: controller,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPaddingH,
      ),
      indicatorColor: AppColors.primary,
      indicatorWeight: 2.5,
      indicatorSize: TabBarIndicatorSize.label,
      labelColor: AppColors.primary,
      unselectedLabelColor: c.textSecondary,
      labelStyle: AppTypography.titleMedium.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: AppColors.primary,
      ),
      unselectedLabelStyle: AppTypography.titleMedium.copyWith(
        fontWeight: FontWeight.w400,
        fontSize: 14,
      ),
      dividerColor: c.glassBorder,
      tabs: [
        Tab(text: s.tabReading),
        Tab(text: s.tabCompleted),
        Tab(text: s.tabSaved),
      ],
    );
  }
}

// ── Okuyorum Tab ──────────────────────────────────────────────────────────────

class _ReadingTab extends ConsumerWidget {
  const _ReadingTab({required this.books, required this.onBookTap});

  final List<Book> books;
  final ValueChanged<Book> onBookTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appStringsProvider);
    if (books.isEmpty) {
      return _EmptyState(
        icon: Icons.import_contacts_rounded,
        message: s.readingEmpty,
        subtitle: s.readingEmptySub,
      );
    }
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.screenPaddingH,
        AppDimensions.spaceMD,
        AppDimensions.screenPaddingH,
        AppDimensions.bottomNavHeight + bottomPadding + 16,
      ),
      itemCount: books.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppDimensions.spaceMD),
      itemBuilder: (context, index) {
        final book = books[index];
        return _ReadingCard(book: book, onTap: () => onBookTap(book));
      },
    );
  }
}

// ── Reading Card (with progress bar) ─────────────────────────────────────────

class _ReadingCard extends ConsumerWidget {
  const _ReadingCard({required this.book, required this.onTap});

  final Book book;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appStringsProvider);
    final c = context.vColors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spaceMD),
        decoration: BoxDecoration(
          color: c.inputFill,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(color: c.glassBorder, width: 0.8),
        ),
        child: Row(
          children: [
            // Book cover
            BookCoverCard(imageUrl: book.coverUrl, width: 72, onTap: onTap),
            const SizedBox(width: AppDimensions.spaceMD),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    book.author,
                    style: AppTypography.bodyMedium.copyWith(fontSize: 12),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    book.genre,
                    style: AppTypography.bodyMedium.copyWith(
                      fontSize: 11,
                      color: c.textHint,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spaceMD),
                  // Progress bar
                  Stack(
                    children: [
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: c.glassBorder,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusPill,
                          ),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: book.readingProgress,
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            gradient: AppColors.amberGradient,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusPill,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        s.percentDone((book.readingProgress * 100).toInt()),
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontSize: 10,
                          letterSpacing: 0.2,
                        ),
                      ),
                      Text(
                        s.pagesProgress(
                          (book.pageCount * book.readingProgress).toInt(),
                          book.pageCount,
                        ),
                        style: AppTypography.labelSmall.copyWith(
                          fontSize: 10,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Continue arrow
            Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(left: AppDimensions.spaceSM),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tamamladım Tab ────────────────────────────────────────────────────────────

class _CompletedTab extends ConsumerWidget {
  const _CompletedTab({required this.books, required this.onBookTap});

  final List<Book> books;
  final ValueChanged<Book> onBookTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appStringsProvider);
    if (books.isEmpty) {
      return _EmptyState(
        icon: Icons.check_circle_outline_rounded,
        message: s.completedEmpty,
        subtitle: s.completedEmptySub,
      );
    }
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.screenPaddingH,
        AppDimensions.spaceMD,
        AppDimensions.screenPaddingH,
        AppDimensions.bottomNavHeight + bottomPadding + 16,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        // cover(1/0.68 ≈ 1.47) + spacer(8) + title(~28) + gap(2) + genre(~14) ≈ 52px text
        // childAspectRatio = width / (width/0.68 + 52) — set generous value
        childAspectRatio: 0.50,
        crossAxisSpacing: AppDimensions.spaceMD,
        mainAxisSpacing: AppDimensions.spaceLG,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return _GridBookCard(
          book: book,
          onTap: () => onBookTap(book),
        );
      },
    );
  }
}

// ── Grid Book Card — uses Expanded so image fills available space ─────────────

class _GridBookCard extends StatelessWidget {
  const _GridBookCard({required this.book, required this.onTap});

  final Book book;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image fills all remaining vertical space — no overflow possible
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
              child: CachedNetworkImage(
                imageUrl: book.coverUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (_, _) => Container(
                  color: context.vColors.cardElevated,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  ),
                ),
                errorWidget: (_, _, _) => Container(
                  color: context.vColors.cardElevated,
                  child: Icon(
                    Icons.book_outlined,
                    color: context.vColors.textSecondary,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spaceSM),
          Text(
            book.title,
            style: AppTypography.titleMedium.copyWith(fontSize: 11),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            book.genre,
            style: AppTypography.bodyMedium.copyWith(fontSize: 10),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}


// ── Kaydedilenler Tab ─────────────────────────────────────────────────────────

class _SavedTab extends ConsumerWidget {
  const _SavedTab({required this.books, required this.onBookTap});

  final List<Book> books;
  final ValueChanged<Book> onBookTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appStringsProvider);
    if (books.isEmpty) {
      return _EmptyState(
        icon: Icons.bookmark_outline_rounded,
        message: s.savedEmpty,
        subtitle: s.savedEmptySub,
      );
    }
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.screenPaddingH,
        AppDimensions.spaceMD,
        AppDimensions.screenPaddingH,
        AppDimensions.bottomNavHeight + bottomPadding + 16,
      ),
      itemCount: books.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppDimensions.spaceMD),
      itemBuilder: (context, index) {
        final book = books[index];
        return _SavedCard(book: book, onTap: () => onBookTap(book));
      },
    );
  }
}

// ── Saved Card ────────────────────────────────────────────────────────────────

class _SavedCard extends StatelessWidget {
  const _SavedCard({required this.book, required this.onTap});

  final Book book;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.vColors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spaceMD),
        decoration: BoxDecoration(
          color: c.inputFill,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(color: c.glassBorder, width: 0.8),
        ),
        child: Row(
          children: [
            BookCoverCard(imageUrl: book.coverUrl, width: 60, onTap: onTap),
            const SizedBox(width: AppDimensions.spaceMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    book.author,
                    style: AppTypography.bodyMedium.copyWith(fontSize: 12),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    book.genre,
                    style: AppTypography.bodyMedium.copyWith(
                      fontSize: 11,
                      color: c.textHint,
                    ),
                  ),
                ],
              ),
            ),
            // Bookmark icon
            const Icon(
              Icons.bookmark_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Error State ───────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final c = context.vColors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spaceXXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, color: c.textSecondary, size: 48),
            const SizedBox(height: AppDimensions.spaceMD),
            Text(
              'Bağlantı hatası',
              style: AppTypography.titleMedium.copyWith(fontSize: 15),
            ),
            const SizedBox(height: AppDimensions.spaceSM),
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(fontSize: 12),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.message,
    required this.subtitle,
  });

  final IconData icon;
  final String message;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final c = context.vColors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spaceXXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: c.inputFill,
                shape: BoxShape.circle,
                border: Border.all(color: c.glassBorder),
              ),
              child: Icon(icon, color: c.textSecondary, size: 34),
            ),
            const SizedBox(height: AppDimensions.spaceMD),
            Text(
              message,
              style: AppTypography.titleMedium.copyWith(fontSize: 15),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spaceSM),
            Text(
              subtitle,
              style: AppTypography.bodyMedium.copyWith(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
