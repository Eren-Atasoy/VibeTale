import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_tale/core/constants/app_colors.dart';
import 'package:vibe_tale/core/constants/app_dimensions.dart';
import 'package:vibe_tale/core/constants/app_typography.dart';
import 'package:vibe_tale/core/widgets/book_cover_card.dart';
import 'package:vibe_tale/features/home/presentation/screens/home_screen.dart';
import 'package:vibe_tale/features/library/domain/book_model.dart';

// ── Library Screen (Personal Collection) ─────────────────────────────────────

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
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
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
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
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _ReadingTab(
                      books: DummyBooks.currentlyReading,
                      onBookTap: (b) => context.push('/book/${b.id}'),
                    ),
                    _CompletedTab(
                      books: DummyBooks.completed,
                      onBookTap: (b) => context.push('/book/${b.id}'),
                    ),
                    _SavedTab(
                      books: DummyBooks.saved,
                      onBookTap: (b) => context.push('/book/${b.id}'),
                    ),
                  ],
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

class _LibraryTopBar extends StatelessWidget {
  const _LibraryTopBar();

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
          const Icon(Icons.menu_book_rounded,
              color: AppColors.primary, size: 28),
          const SizedBox(width: AppDimensions.spaceSM),
          Text(
            'Kütüphanem',
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
              color: AppColors.inputFill,
              borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Text(
              '${DummyBooks.currentlyReading.length + DummyBooks.completed.length + DummyBooks.saved.length} kitap',
              style: AppTypography.tagLabel.copyWith(
                color: AppColors.textSecondary,
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

class _LibraryTabBar extends StatelessWidget {
  const _LibraryTabBar({required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
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
      unselectedLabelColor: AppColors.textSecondary,
      labelStyle: AppTypography.titleMedium.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: AppColors.primary,
      ),
      unselectedLabelStyle: AppTypography.titleMedium.copyWith(
        fontWeight: FontWeight.w400,
        fontSize: 14,
      ),
      dividerColor: AppColors.glassBorder,
      tabs: const [
        Tab(text: 'Okuyorum'),
        Tab(text: 'Tamamladım'),
        Tab(text: 'Kaydedilenler'),
      ],
    );
  }
}

// ── Okuyorum Tab ──────────────────────────────────────────────────────────────

class _ReadingTab extends StatelessWidget {
  const _ReadingTab({required this.books, required this.onBookTap});

  final List<Book> books;
  final ValueChanged<Book> onBookTap;

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) {
      return _EmptyState(
        icon: Icons.import_contacts_rounded,
        message: 'Henüz okumaya başlamadın',
        subtitle: 'Keşfet sekmesinden bir kitap seç',
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
      separatorBuilder: (_, __) =>
          const SizedBox(height: AppDimensions.spaceMD),
      itemBuilder: (context, index) {
        final book = books[index];
        return _ReadingCard(book: book, onTap: () => onBookTap(book));
      },
    );
  }
}

// ── Reading Card (with progress bar) ─────────────────────────────────────────

class _ReadingCard extends StatelessWidget {
  const _ReadingCard({required this.book, required this.onTap});

  final Book book;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spaceMD),
        decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(color: AppColors.glassBorder, width: 0.8),
        ),
        child: Row(
          children: [
            // Book cover
            BookCoverCard(
              imageUrl: book.coverUrl,
              width: 72,
              onTap: onTap,
            ),
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
                      color: AppColors.textHint,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spaceMD),
                  // Progress bar
                  Stack(
                    children: [
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.glassBorder,
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusPill),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: book.readingProgress,
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            gradient: AppColors.amberGradient,
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusPill),
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
                        '${(book.readingProgress * 100).toInt()}% tamamlandı',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontSize: 10,
                          letterSpacing: 0.2,
                        ),
                      ),
                      Text(
                        '${(book.pageCount * book.readingProgress).toInt()}/${book.pageCount} sf.',
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

class _CompletedTab extends StatelessWidget {
  const _CompletedTab({required this.books, required this.onBookTap});

  final List<Book> books;
  final ValueChanged<Book> onBookTap;

  static const _cardWidth = 100.0;

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) {
      return _EmptyState(
        icon: Icons.check_circle_outline_rounded,
        message: 'Henüz kitap tamamlamadın',
        subtitle: 'Okuduğun kitaplar burada görünecek',
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
        childAspectRatio: 0.58,
        crossAxisSpacing: AppDimensions.spaceMD,
        mainAxisSpacing: AppDimensions.spaceLG,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return BookCoverCard(
          imageUrl: book.coverUrl,
          title: book.title,
          subtitle: book.genre,
          width: _cardWidth,
          onTap: () => onBookTap(book),
        );
      },
    );
  }
}

// ── Kaydedilenler Tab ─────────────────────────────────────────────────────────

class _SavedTab extends StatelessWidget {
  const _SavedTab({required this.books, required this.onBookTap});

  final List<Book> books;
  final ValueChanged<Book> onBookTap;

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) {
      return _EmptyState(
        icon: Icons.bookmark_outline_rounded,
        message: 'Kaydedilen kitap yok',
        subtitle: 'Kitap detayından kaydet butonuna bas',
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
      separatorBuilder: (_, __) =>
          const SizedBox(height: AppDimensions.spaceMD),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spaceMD),
        decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(color: AppColors.glassBorder, width: 0.8),
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
                      color: AppColors.textHint,
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
                color: AppColors.inputFill,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Icon(icon, color: AppColors.textSecondary, size: 34),
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
