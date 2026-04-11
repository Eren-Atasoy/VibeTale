import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_tale/core/constants/app_colors.dart';
import 'package:vibe_tale/core/constants/app_dimensions.dart';
import 'package:vibe_tale/core/constants/app_typography.dart';
import 'package:vibe_tale/core/theme/app_theme_colors.dart';
import 'package:vibe_tale/core/widgets/neon_button.dart';
import 'package:vibe_tale/core/widgets/themed_background.dart';
import 'package:vibe_tale/features/library/domain/book_model.dart';

class BookDetailsScreen extends StatelessWidget {
  const BookDetailsScreen({super.key, required this.bookId});

  final String bookId;

  Book? _findBook() {
    final all = [
      DummyBooks.featured,
      ...DummyBooks.haftaninOnerileri,
      ...DummyBooks.karanlikGecmis,
    ];
    try {
      return all.firstWhere((b) => b.id == bookId);
    } on StateError {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final book = _findBook();
    if (book == null) {
      return _NotFoundView(bookId: bookId);
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: AppColors.backgroundDeep,
        extendBodyBehindAppBar: true,
        extendBody: true,
        body: Stack(
          children: [
            // Blurred cover as full-screen background
            _BlurredHeroBackground(imageUrl: book.coverUrl),
            // Dark overlay
            Container(color: AppColors.backgroundDeep.withValues(alpha: 0.75)),
            // Content
            CustomScrollView(
              slivers: [
                _CoverAppBar(book: book),
                SliverToBoxAdapter(child: _DetailsPanel(book: book)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Blurred hero background ───────────────────────────────────────────────────

class _BlurredHeroBackground extends StatelessWidget {
  const _BlurredHeroBackground({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (_, _) =>
                Container(color: AppColors.backgroundSurface),
            errorWidget: (_, _, _) =>
                Container(color: AppColors.backgroundSurface),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: AppDimensions.strongBlur,
              sigmaY: AppDimensions.strongBlur,
            ),
            child: const SizedBox.expand(),
          ),
        ],
      ),
    );
  }
}

// ── Cover AppBar (collapsible) ────────────────────────────────────────────────

class _CoverAppBar extends StatelessWidget {
  const _CoverAppBar({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      leading: GestureDetector(
        onTap: () => context.pop(),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.backgroundDeep.withValues(alpha: 0.6),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.backgroundDeep.withValues(alpha: 0.6),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(
              Icons.bookmark_border_rounded,
              color: AppColors.textPrimary,
              size: 20,
            ),
            onPressed: () {},
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        collapseMode: CollapseMode.pin,
        background: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80), // account for status bar
              // Book cover
              Container(
                width: 130,
                height: 192,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 24,
                      spreadRadius: 4,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                  child: CachedNetworkImage(
                    imageUrl: book.coverUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, _) =>
                        Container(color: AppColors.backgroundElevated),
                    errorWidget: (_, _, _) => Container(
                      color: AppColors.backgroundElevated,
                      child: const Icon(
                        Icons.book_outlined,
                        color: AppColors.textSecondary,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Details Panel ─────────────────────────────────────────────────────────────

class _DetailsPanel extends StatelessWidget {
  const _DetailsPanel({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.screenPaddingH,
        AppDimensions.spaceLG,
        AppDimensions.screenPaddingH,
        120,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title & Author
          if (book.series != null)
            Text(
              book.series!,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primary,
                letterSpacing: 1.2,
              ),
            ),
          const SizedBox(height: AppDimensions.spaceSM),
          Text(book.title, style: AppTypography.headlineLarge),
          const SizedBox(height: AppDimensions.spaceSM),
          Text(
            book.author,
            style: AppTypography.bodyMedium.copyWith(fontSize: 14),
          ),
          const SizedBox(height: AppDimensions.spaceMD),

          // Rating + Genre + Page count row
          _MetaRow(book: book),

          const SizedBox(height: AppDimensions.spaceXL),

          // Synopsis
          if (book.synopsis.isNotEmpty) ...[
            Text('Özet', style: AppTypography.titleLarge),
            const SizedBox(height: AppDimensions.spaceSM),
            Text(book.synopsis, style: AppTypography.bodyMedium),
            const SizedBox(height: AppDimensions.spaceXL),
          ],

          // CTA buttons
          NeonButton(
            label: 'OKUMAYA BAŞLA',
            onPressed: () => context.push('/read/${book.id}'),
          ),
          const SizedBox(height: AppDimensions.spaceMD),
          NeonButton.outlined(
            label: 'Kütüphaneye Ekle',
            onPressed: () {},
            icon: Icons.add_rounded,
          ),
        ],
      ),
    );
  }
}

// ── Meta Row ──────────────────────────────────────────────────────────────────

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Rating
        if (book.rating > 0) ...[
          const Icon(Icons.star_rounded, color: AppColors.primary, size: 16),
          const SizedBox(width: 4),
          Text(
            book.rating.toStringAsFixed(1),
            style: AppTypography.titleMedium.copyWith(color: AppColors.primary),
          ),
          _Dot(),
        ],
        // Genre chip
        _Chip(label: book.genre),
        // Page count
        if (book.pageCount > 0) ...[
          _Dot(),
          Text('${book.pageCount} sayfa', style: AppTypography.bodyMedium),
        ],
        // New badge
        if (book.isNew) ...[_Dot(), _Chip(label: 'YENİ', isAccent: true)],
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        width: 3,
        height: 3,
        decoration: const BoxDecoration(
          color: AppColors.textSecondary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, this.isAccent = false});

  final String label;
  final bool isAccent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: isAccent
            ? AppColors.primary.withValues(alpha: 0.15)
            : AppColors.glassFill,
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
        border: Border.all(
          color: isAccent ? AppColors.primary : AppColors.glassBorder,
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: AppTypography.tagLabel.copyWith(
          fontSize: 11,
          color: isAccent ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }
}

// ── Not Found ─────────────────────────────────────────────────────────────────

class _NotFoundView extends StatelessWidget {
  const _NotFoundView({required this.bookId});

  final String bookId;

  @override
  Widget build(BuildContext context) {
    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: context.vColors.textPrimary,
            ),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off_rounded,
                color: context.vColors.textSecondary,
                size: 48,
              ),
              const SizedBox(height: AppDimensions.spaceMD),
              Text('Kitap bulunamadı', style: AppTypography.titleLarge),
              const SizedBox(height: AppDimensions.spaceSM),
              Text(bookId, style: AppTypography.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
