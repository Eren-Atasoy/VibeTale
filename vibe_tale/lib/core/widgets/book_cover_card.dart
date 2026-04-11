import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:vibe_tale/core/constants/app_colors.dart';
import 'package:vibe_tale/core/constants/app_dimensions.dart';
import 'package:vibe_tale/core/constants/app_typography.dart';
import 'package:vibe_tale/core/theme/app_theme_colors.dart';

/// Book cover card with amber glow shadow and optional "YENİ" badge.
class BookCoverCard extends StatelessWidget {
  const BookCoverCard({
    super.key,
    required this.imageUrl,
    this.title,
    this.subtitle,
    this.onTap,
    this.isNew = false,
    this.width = 110,
    this.showGlow = false,
  });

  final String imageUrl;
  final String? title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool isNew;
  final double width;
  final bool showGlow;

  @override
  Widget build(BuildContext context) {
    final height = width / AppDimensions.bookCoverAspectRatio;
    final c = context.vColors;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Container(
                  width: width,
                  height: height,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusSM),
                    boxShadow: showGlow
                        ? [
                            BoxShadow(
                              color: AppColors.primaryGlow,
                              blurRadius: 16,
                              spreadRadius: 1,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusSM),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: c.cardElevated,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: c.cardElevated,
                        child: Icon(
                          Icons.book_outlined,
                          color: c.textSecondary,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),

                if (isNew)
                  Positioned(
                    top: AppDimensions.spaceSM,
                    left: AppDimensions.spaceSM,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusPill,
                        ),
                      ),
                      child: Text(
                        'YENİ',
                        style: AppTypography.tagLabel.copyWith(
                          fontSize: 10,
                          color: AppColors.backgroundDeep,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            if (title != null) ...[
              const SizedBox(height: AppDimensions.spaceSM),
              Text(
                title!,
                style: AppTypography.titleMedium.copyWith(
                  fontSize: 12,
                  color: c.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                style: AppTypography.bodyMedium.copyWith(
                  fontSize: 11,
                  color: c.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
