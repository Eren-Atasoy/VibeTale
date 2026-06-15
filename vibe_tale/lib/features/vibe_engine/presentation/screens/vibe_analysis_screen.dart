import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_tale/core/constants/app_colors.dart';
import 'package:vibe_tale/core/constants/app_dimensions.dart';
import 'package:vibe_tale/core/constants/app_typography.dart';
import 'package:vibe_tale/core/theme/app_theme_colors.dart';
import 'package:vibe_tale/core/widgets/glass_card.dart';
import 'package:vibe_tale/core/widgets/neon_button.dart';
import 'package:vibe_tale/core/widgets/themed_background.dart';
import 'package:vibe_tale/features/library/application/books_provider.dart';
import 'package:vibe_tale/features/library/domain/book_model.dart';

// ── Scene processing states ──────────────────────────────────────────────────

enum _SceneStatus { waiting, processing, done }

enum _ProviderStatus { ready, generating, tagged }

class _SceneItem {
  _SceneItem({
    required this.title,
    required this.description,
    required this.statusLabel,
    required this.status,
    this.progress,
    this.hasAudio = false,
    this.hasImage = false,
  });

  final String title;
  final String description;
  final String statusLabel;
  _SceneStatus status;
  double? progress;
  bool hasAudio;
  bool hasImage;
}

// ── Main Screen ───────────────────────────────────────────────────────────────

class VibeAnalysisScreen extends ConsumerStatefulWidget {
  final String bookId;
  const VibeAnalysisScreen({super.key, required this.bookId});

  @override
  ConsumerState<VibeAnalysisScreen> createState() => _VibeAnalysisScreenState();
}

class _VibeAnalysisScreenState extends ConsumerState<VibeAnalysisScreen>
    with TickerProviderStateMixin {
  // ── Book ──────────────────────────────────────────────────────────────────
  Book? _book;

  // ── Provider statuses ─────────────────────────────────────────────────────
  final _ProviderStatus _audioStatus = _ProviderStatus.ready;
  final _ProviderStatus _visualStatus = _ProviderStatus.generating;
  final _ProviderStatus _weatherStatus = _ProviderStatus.tagged;
  double _visualProgress = 0.45;

  // ── Scenes ────────────────────────────────────────────────────────────────
  late List<_SceneItem> _scenes;

  // ── Download progress ─────────────────────────────────────────────────────
  double _downloadProgress = 0.35;
  double _downloadedMb = 45;
  final double _totalMb = 120;

  // ── Real processing status ─────────────────────────────────────────────────
  bool _processingCompleted = false;
  bool _processingFailed = false;
  Timer? _statusPollTimer;

  // ── Animation ─────────────────────────────────────────────────────────────
  late AnimationController _pulseController;
  Timer? _progressTimer;

  @override
  void initState() {
    super.initState();

    _loadBook();
    _startStatusPolling();

    _scenes = [
      _SceneItem(
        title: 'Parti başladı...',
        description:
            'Orkestral caz müziği başlar. Misafirler gelirken sıcak kehribar rengi ışık yoğunlaşır.',
        statusLabel: 'HAZIR',
        status: _SceneStatus.done,
        hasAudio: true,
        hasImage: true,
      ),
      _SceneItem(
        title: 'Nick kalabalığı gözlemliyor...',
        description: 'Sentezleme tamamlandı',
        statusLabel: 'YÜKSEK DRAM',
        status: _SceneStatus.done,
        progress: 1.0,
        hasAudio: true,
        hasImage: false,
      ),
      _SceneItem(
        title: "Gatsby'nin girişi...",
        description: 'Bekleniyor',
        statusLabel: 'SIRADA',
        status: _SceneStatus.waiting,
      ),
      _SceneItem(
        title: 'Sahne 4',
        description: 'Kuyruğa alındı',
        statusLabel: 'SIRADA',
        status: _SceneStatus.waiting,
      ),
    ];

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Simulated progress tick
    _progressTimer = Timer.periodic(const Duration(milliseconds: 400), (_) {
      if (!mounted) return;
      setState(() {
        if (_downloadProgress < 1.0) {
          _downloadProgress = math.min(_downloadProgress + 0.002, 1.0);
          _downloadedMb = _downloadProgress * _totalMb;
        }
        if (_visualProgress < 1.0) {
          _visualProgress = math.min(_visualProgress + 0.003, 1.0);
        }
      });
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressTimer?.cancel();
    _statusPollTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadBook() async {
    try {
      final book = await ref
          .read(bookRepositoryProvider)
          .getBook(widget.bookId);
      if (!mounted) return;
      setState(() => _book = book);
    } catch (_) {
      // Book info is decorative on this screen; ignore errors
    }
  }

  void _startStatusPolling() {
    _checkStatus(); // initial check immediately
    _statusPollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      _checkStatus();
    });
  }

  Future<void> _checkStatus() async {
    try {
      final status = await ref
          .read(bookRepositoryProvider)
          .getBookStatus(widget.bookId);
      if (!mounted) return;
      if (status.isCompleted && !_processingCompleted) {
        _statusPollTimer?.cancel();
        _progressTimer?.cancel();
        setState(() {
          _processingCompleted = true;
          _downloadProgress = 1.0;
          _downloadedMb = _totalMb;
          for (final scene in _scenes) {
            scene.status = _SceneStatus.done;
            scene.hasAudio = true;
          }
        });
      } else if (status.isFailed && !_processingFailed) {
        _statusPollTimer?.cancel();
        _progressTimer?.cancel();
        setState(() => _processingFailed = true);
      }
    } catch (_) {
      // ignore transient polling errors
    }
  }

  // ── Play action ───────────────────────────────────────────────────────────
  void _playAvailableScenes() {
    context.push('/read/${widget.bookId}');
  }

  @override
  Widget build(BuildContext context) {
    final c = context.vColors;
    final completedCount = _scenes.where((s) => s.status == _SceneStatus.done).length;
    final canPlay = _processingCompleted || completedCount > 0;

    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildAppBar(context, c, _statusLabel),
        body: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.screenPaddingH,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: AppDimensions.spaceMD),
                        if (_book != null) _BookHeader(book: _book!),
                        const SizedBox(height: AppDimensions.spaceLG),
                        _ProviderStatusRow(
                          audioStatus: _audioStatus,
                          visualStatus: _visualStatus,
                          visualProgress: _visualProgress,
                          weatherStatus: _weatherStatus,
                          pulseController: _pulseController,
                        ),
                        const SizedBox(height: AppDimensions.spaceLG),
                        // Scene list header
                        Text(
                          'SAHNELER',
                          style: AppTypography.labelSmall.copyWith(
                            color: c.textHint,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spaceSM),
                      ]),
                    ),
                  ),

                  // Scene timeline
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.screenPaddingH,
                    ),
                    sliver: SliverList.separated(
                      itemCount: _scenes.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppDimensions.spaceSM),
                      itemBuilder: (context, index) => _SceneCard(
                        scene: _scenes[index],
                        index: index,
                        pulseController: _pulseController,
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppDimensions.spaceXXL),
                  ),
                ],
              ),
            ),

            // ── Bottom bar ──────────────────────────────────────────────────
            _BottomBar(
              downloadedMb: _downloadedMb,
              totalMb: _totalMb,
              downloadProgress: _downloadProgress,
              canPlay: canPlay,
              onPlay: _playAvailableScenes,
            ),
          ],
        ),
      ),
    );
  }

  String get _statusLabel => _processingFailed
      ? 'HATA'
      : _processingCompleted
          ? 'TAMAMLANDI'
          : 'İŞLENİYOR';

  AppBar _buildAppBar(BuildContext context, VibeTaleColors c, String statusLabel) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: c.textPrimary, size: 20),
        onPressed: () => context.pop(),
      ),
      title: Column(
        children: [
          Text(
            'VibeMotoru',
            style: AppTypography.titleLarge.copyWith(color: c.textPrimary),
          ),
          const SizedBox(height: 2),
          _StatusDot(label: statusLabel, controller: _pulseController),
        ],
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.more_horiz_rounded, color: c.textSecondary),
          onPressed: () {},
        ),
      ],
    );
  }
}

// ── Status dot with pulse ─────────────────────────────────────────────────────

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.label, required this.controller});
  final String label;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, _) {
        final opacity = 0.5 + controller.value * 0.5;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: opacity),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGlow.withValues(alpha: opacity * 0.6),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primary.withValues(alpha: opacity),
                fontSize: 10,
                letterSpacing: 1.0,
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Book header ───────────────────────────────────────────────────────────────

class _BookHeader extends StatelessWidget {
  const _BookHeader({required this.book});
  final Book book;

  @override
  Widget build(BuildContext context) {
    final c = context.vColors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                book.title,
                style: AppTypography.displayMedium.copyWith(
                  color: c.textPrimary,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: AppDimensions.spaceSM),
              Row(
                children: [
                  Icon(
                    Icons.menu_book_rounded,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppDimensions.spaceXS),
                  Text(
                    'Bölüm 3 Analizi',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: AppDimensions.spaceMD),
        // Book cover thumbnail
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
          child: Image.network(
            book.coverUrl,
            width: 64,
            height: 88,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              width: 64,
              height: 88,
              color: AppColors.backgroundSurface,
              child: const Icon(Icons.book_rounded, color: AppColors.textSecondary),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Provider status row ───────────────────────────────────────────────────────

class _ProviderStatusRow extends StatelessWidget {
  const _ProviderStatusRow({
    required this.audioStatus,
    required this.visualStatus,
    required this.visualProgress,
    required this.weatherStatus,
    required this.pulseController,
  });

  final _ProviderStatus audioStatus;
  final _ProviderStatus visualStatus;
  final double visualProgress;
  final _ProviderStatus weatherStatus;
  final AnimationController pulseController;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ProviderCard(
            icon: Icons.graphic_eq_rounded,
            label: 'SES',
            status: audioStatus,
            controller: pulseController,
          ),
        ),
        const SizedBox(width: AppDimensions.spaceSM),
        Expanded(
          child: _ProviderCard(
            icon: Icons.image_rounded,
            label: 'GÖRSELLER',
            status: visualStatus,
            progress: visualProgress,
            controller: pulseController,
          ),
        ),
        const SizedBox(width: AppDimensions.spaceSM),
        Expanded(
          child: _ProviderCard(
            icon: Icons.auto_awesome_rounded,
            label: 'HAVA',
            status: weatherStatus,
            controller: pulseController,
          ),
        ),
      ],
    );
  }
}

class _ProviderCard extends StatelessWidget {
  const _ProviderCard({
    required this.icon,
    required this.label,
    required this.status,
    required this.controller,
    this.progress,
  });

  final IconData icon;
  final String label;
  final _ProviderStatus status;
  final AnimationController controller;
  final double? progress;

  String get _statusText {
    switch (status) {
      case _ProviderStatus.ready:
        return 'Hazır';
      case _ProviderStatus.generating:
        return progress != null
            ? '${(progress! * 100).toInt()}%'
            : 'Oluşturuluyor';
      case _ProviderStatus.tagged:
        return 'Etiketlendi';
    }
  }

  Color get _statusColor {
    switch (status) {
      case _ProviderStatus.ready:
        return AppColors.success;
      case _ProviderStatus.generating:
        return AppColors.primary;
      case _ProviderStatus.tagged:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGenerating = status == _ProviderStatus.generating;

    return GlassCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceSM,
        vertical: AppDimensions.spaceSM + 4,
      ),
      borderColor: isGenerating ? AppColors.primaryGlow : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedBuilder(
            animation: controller,
            builder: (_, _) {
              final color = isGenerating
                  ? AppColors.primary.withValues(alpha: 0.6 + controller.value * 0.4)
                  : _statusColor;
              return Icon(icon, size: 18, color: color);
            },
          ),
          const SizedBox(height: AppDimensions.spaceXS),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: context.vColors.textHint,
              fontSize: 9,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _statusText,
            style: AppTypography.bodyMedium.copyWith(
              color: _statusColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Scene card ────────────────────────────────────────────────────────────────

class _SceneCard extends StatelessWidget {
  const _SceneCard({
    required this.scene,
    required this.index,
    required this.pulseController,
  });

  final _SceneItem scene;
  final int index;
  final AnimationController pulseController;

  Color _statusColor(BuildContext context) {
    switch (scene.status) {
      case _SceneStatus.done:
        return AppColors.primary;
      case _SceneStatus.processing:
        return AppColors.primary;
      case _SceneStatus.waiting:
        return context.vColors.textHint;
    }
  }

  Color _statusBgColor(BuildContext context) {
    switch (scene.status) {
      case _SceneStatus.done:
        return AppColors.primaryGlow;
      case _SceneStatus.processing:
        return AppColors.primaryGlow;
      case _SceneStatus.waiting:
        return context.vColors.glassFill;
    }
  }

  Widget _buildStatusIcon(BuildContext context) {
    switch (scene.status) {
      case _SceneStatus.done:
        return const Icon(Icons.check_circle_rounded,
            size: 20, color: AppColors.primary);
      case _SceneStatus.processing:
        return AnimatedBuilder(
          animation: pulseController,
          builder: (_, _) => SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              value: scene.progress,
              strokeWidth: 2.5,
              color: AppColors.primary,
              backgroundColor: AppColors.glassFill,
            ),
          ),
        );
      case _SceneStatus.waiting:
        return Icon(Icons.hourglass_empty_rounded,
            size: 20, color: context.vColors.textHint);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.vColors;
    final isDone = scene.status == _SceneStatus.done;
    final isWaiting = scene.status == _SceneStatus.waiting;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            _buildStatusIcon(context),
            if (index < 3)
              Container(
                width: 2,
                height: 60,
                margin: const EdgeInsets.symmetric(vertical: 4),
                color: isDone
                    ? AppColors.primary.withValues(alpha: 0.3)
                    : c.glassBorder,
              ),
          ],
        ),
        const SizedBox(width: AppDimensions.spaceMD),

        // Card content
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(AppDimensions.spaceMD),
            fillColor: isWaiting ? null : AppColors.glassFill,
            borderColor: isDone ? AppColors.primaryGlow : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status badge + actions row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spaceSM,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _statusBgColor(context),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                      ),
                      child: Text(
                        'SAHNE ${index + 1} • ${scene.statusLabel}',
                        style: AppTypography.labelSmall.copyWith(
                          color: _statusColor(context),
                          fontSize: 9,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (scene.hasAudio)
                      Icon(Icons.volume_up_rounded,
                          size: 16, color: c.textSecondary),
                    if (scene.hasAudio) const SizedBox(width: 8),
                    if (scene.hasImage)
                      Icon(Icons.visibility_rounded,
                          size: 16, color: c.textSecondary),
                    if (scene.progress != null && scene.progress! < 1.0) ...[
                      const SizedBox(width: 8),
                      Text(
                        '${(scene.progress! * 100).toInt()}%',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppDimensions.spaceSM),

                // Title
                Text(
                  scene.title,
                  style: AppTypography.titleMedium.copyWith(
                    color: isWaiting ? c.textHint : c.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceXS),

                // Description / sub-info
                if (isDone && scene.description.isNotEmpty)
                  Text(
                    scene.description,
                    style: AppTypography.bodyMedium.copyWith(
                      color: c.textSecondary,
                      fontSize: 12,
                    ),
                  ),

                if (!isDone && scene.description.isNotEmpty)
                  Row(
                    children: [
                      Icon(Icons.schedule_rounded,
                          size: 12, color: c.textHint),
                      const SizedBox(width: 4),
                      Text(
                        scene.description,
                        style: AppTypography.bodyMedium.copyWith(
                          color: c.textHint,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Bottom bar ────────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.downloadedMb,
    required this.totalMb,
    required this.downloadProgress,
    required this.canPlay,
    required this.onPlay,
  });

  final double downloadedMb;
  final double totalMb;
  final double downloadProgress;
  final bool canPlay;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final c = context.vColors;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.screenPaddingH,
        AppDimensions.spaceMD,
        AppDimensions.screenPaddingH,
        AppDimensions.spaceMD + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundDeep.withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(color: c.glassBorder, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress info row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOPLAM KAYNAKLAR',
                style: AppTypography.labelSmall.copyWith(
                  color: c.textHint,
                  fontSize: 9,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                '${downloadedMb.toStringAsFixed(0)}MB / ${totalMb.toStringAsFixed(0)}MB indirildi',
                style: AppTypography.labelSmall.copyWith(
                  color: c.textSecondary,
                  fontSize: 10,
                ),
              ),
              Text(
                '${(downloadProgress * 100).toInt()}%',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceSM),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
            child: LinearProgressIndicator(
              value: downloadProgress,
              backgroundColor: c.glassFill,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceMD),

          // CTA button
          NeonButton(
            label: 'Mevcut Sahneleri Oynat',
            icon: Icons.play_arrow_rounded,
            onPressed: canPlay ? onPlay : null,
          ),
        ],
      ),
    );
  }
}
