import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:vibe_tale/core/constants/app_colors.dart';
import 'package:vibe_tale/core/constants/app_dimensions.dart';
import 'package:vibe_tale/core/constants/app_typography.dart';
import 'package:vibe_tale/core/router/app_router.dart';
import 'package:vibe_tale/features/library/application/books_provider.dart';
import 'package:vibe_tale/features/reader/application/ambient_audio_controller.dart';
import 'package:vibe_tale/features/reader/application/reader_settings.dart';
import 'package:vibe_tale/features/reader/application/reading_provider.dart';
import 'package:vibe_tale/features/reader/data/chunk_dto.dart';
import 'package:vibe_tale/features/reader/data/reader_media.dart';
import 'package:vibe_tale/features/reader/presentation/widgets/reader_sheets.dart';

/// Fraction of the viewport treated as the "reading focus line": the chunk
/// crossing this line drives the active scene (audio + image + emotion). Kept
/// near the top so the first (short) chunk is the focus at the very start.
const double _kFocusLine = 0.25;

Color _emotionColor(String? emotion) => switch (emotion) {
  'wonder' => const Color(0xFF35C2C1),
  'tense' => const Color(0xFFE5533D),
  'mysterious' => const Color(0xFF7A5CC0),
  'melancholic' => const Color(0xFF4A6FA5),
  'hopeful' => const Color(0xFFE0A92E),
  'calm' => const Color(0xFF3FA37A),
  _ => AppColors.primary,
};

/// Caps fling velocity so a single flick can't shoot to the bottom — the reader
/// descends gradually. Normal dragging speed is unchanged (drag isn't a fling).
class _LimitedFlingPhysics extends BouncingScrollPhysics {
  const _LimitedFlingPhysics({super.parent, this.maxFlingVelocity = 2200});

  final double maxFlingVelocity;

  @override
  _LimitedFlingPhysics applyTo(ScrollPhysics? ancestor) => _LimitedFlingPhysics(
    parent: buildParent(ancestor),
    maxFlingVelocity: maxFlingVelocity,
  );

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    final clamped = velocity.clamp(-maxFlingVelocity, maxFlingVelocity);
    return super.createBallisticSimulation(position, clamped);
  }
}

class ImmersiveReadScreen extends ConsumerStatefulWidget {
  const ImmersiveReadScreen({super.key, required this.bookId});

  final String bookId;

  @override
  ConsumerState<ImmersiveReadScreen> createState() =>
      _ImmersiveReadScreenState();
}

class _ImmersiveReadScreenState extends ConsumerState<ImmersiveReadScreen> {
  final ItemScrollController _itemScroll = ItemScrollController();
  final ItemPositionsListener _positions = ItemPositionsListener.create();
  final AmbientAudioController _audio = AmbientAudioController();
  final ValueNotifier<double> _progress = ValueNotifier(0);

  List<ChunkDto> _chunks = [];
  bool _loading = true;
  String? _error;
  String _bookTitle = '';

  int _activeIndex = -1;
  final Map<int, AmbianceDto> _ambiance = {};
  AmbianceDto? _currentAmbiance;

  double _audioVolume = 0.65;
  double _visualIntensity = 0.80;
  bool _isBookmarked = false;
  bool _chromeVisible = true;
  bool _completed = false;

  Timer? _ambianceTimer;
  Timer? _saveTimer;
  String? _sessionId;
  DateTime? _sessionStart;

  static const int _wordsPerMinute = 200;

  @override
  void initState() {
    super.initState();
    _positions.itemPositions.addListener(_onPositions);
    _loadContent();
  }

  @override
  void dispose() {
    _endSession();
    _positions.itemPositions.removeListener(_onPositions);
    _ambianceTimer?.cancel();
    _saveTimer?.cancel();
    _audio.dispose();
    _progress.dispose();
    super.dispose();
  }

  // ── Loading ──────────────────────────────────────────────────────────────

  Future<void> _loadContent() async {
    try {
      final source = ref.read(readerContentSourceProvider);
      final chunks = await source.getChunks(widget.bookId);
      final title = await _resolveTitle();
      if (!mounted) return;
      setState(() {
        _chunks = chunks;
        _bookTitle = title;
        _loading = false;
      });
      // The first ItemPositions notification (after layout) commits the scene
      // at the focus line — single source of truth, so there's no glitchy
      // double-switch at the start.
      await _restoreProgress();
      _startSession();
      // Safety net: ensure the opening scene commits even if no scroll happens.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _activeIndex < 0) _onPositions();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<String> _resolveTitle() async {
    if (kUseDummyReaderData) return 'Keloğlan ve Dev';
    try {
      final book = await ref.read(bookRepositoryProvider).getBook(widget.bookId);
      return book.title;
    } catch (_) {
      return 'VibeTale';
    }
  }

  Future<void> _restoreProgress() async {
    if (kUseDummyReaderData) return;
    try {
      final progress =
          await ref.read(readingRepositoryProvider).getProgress(widget.bookId);
      final chunkId = progress?['current_chunk_id'] as String?;
      if (chunkId == null) return;
      final index = _chunks.indexWhere((c) => c.chunkId == chunkId);
      if (index <= 0) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_itemScroll.isAttached) {
          _itemScroll.jumpTo(index: index, alignment: 0.15);
        }
      });
    } catch (_) {}
  }

  // ── Reading-position sync ──────────────────────────────────────────────────

  void _onPositions() {
    if (_chunks.isEmpty) return;
    final positions = _positions.itemPositions.value
        .where((p) => p.itemTrailingEdge > 0 && p.itemLeadingEdge < 1)
        .toList()
      ..sort((a, b) => a.index.compareTo(b.index));
    if (positions.isEmpty) return;

    // The chunk whose body crosses the focus line is the one being read.
    var focus = positions.first;
    for (final p in positions) {
      if (p.itemLeadingEdge <= _kFocusLine) focus = p;
      if (p.itemLeadingEdge > _kFocusLine) break;
    }

    final span = focus.itemTrailingEdge - focus.itemLeadingEdge;
    final within = span > 0
        ? ((_kFocusLine - focus.itemLeadingEdge) / span).clamp(0.0, 1.0)
        : 0.0;
    _progress.value = ((focus.index + within) / _chunks.length).clamp(0.0, 1.0);

    final chunkIndex = focus.index.clamp(0, _chunks.length - 1);
    if (chunkIndex != _activeIndex) _scheduleAmbiance(chunkIndex);
    _debounceSave();
  }

  /// Debounce scene commits so fast scrolling doesn't thrash audio/visuals.
  void _scheduleAmbiance(int index) {
    _ambianceTimer?.cancel();
    _ambianceTimer =
        Timer(const Duration(milliseconds: 150), () => _commitAmbiance(index));
  }

  Future<void> _commitAmbiance(int index) async {
    _activeIndex = index;
    final amb = await _fetchAmbiance(index);
    if (amb == null || !mounted) return;
    setState(() => _currentAmbiance = amb);
    final url = amb.audioUrl;
    if (url != null) _audio.setScene(url);
    _prefetch(index);
  }

  Future<AmbianceDto?> _fetchAmbiance(int index) async {
    if (index < 0 || index >= _chunks.length) return null;
    final cached = _ambiance[index];
    if (cached != null) return cached;
    try {
      final amb = await ref
          .read(readerContentSourceProvider)
          .getAmbiance(_chunks[index].chunkId);
      _ambiance[index] = amb;
      return amb;
    } catch (_) {
      return null;
    }
  }

  /// Warm the cache for upcoming scenes so transitions are instant: preload the
  /// next scene's audio into the idle player and precache the next images.
  Future<void> _prefetch(int index) async {
    final next = index + 1;
    if (next < _chunks.length) {
      final amb = await _fetchAmbiance(next);
      final audio = amb?.audioUrl;
      if (audio != null) unawaited(_audio.preload(audio));
      final img = amb?.imageUrl;
      if (img != null && mounted) {
        unawaited(precacheImage(ReaderMedia.imageProvider(img), context));
      }
    }
    final next2 = index + 2;
    if (next2 < _chunks.length) {
      final amb = await _fetchAmbiance(next2);
      final img = amb?.imageUrl;
      if (img != null && mounted) {
        unawaited(precacheImage(ReaderMedia.imageProvider(img), context));
      }
    }
  }

  // ── Persistence (backend only) ─────────────────────────────────────────────

  void _debounceSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(seconds: 2), _saveProgress);
  }

  Future<void> _saveProgress() async {
    if (kUseDummyReaderData || _chunks.isEmpty) return;
    final chunk = _chunks[_activeIndex.clamp(0, _chunks.length - 1)];
    try {
      await ref.read(readingRepositoryProvider).saveProgress(
            bookId: widget.bookId,
            currentChunkId: chunk.chunkId,
            chapterNumber: chunk.chapterNumber ?? 1,
            offset: 0,
          );
    } catch (_) {}
  }

  Future<void> _startSession() async {
    if (kUseDummyReaderData) return;
    try {
      _sessionId =
          await ref.read(readingRepositoryProvider).createSession(widget.bookId);
      _sessionStart = DateTime.now();
    } catch (_) {}
  }

  void _endSession() {
    final id = _sessionId;
    final start = _sessionStart;
    if (id == null || start == null) return;
    final elapsed = DateTime.now().difference(start).inSeconds;
    unawaited(
      ref.read(readingRepositoryProvider).updateSession(
            sessionId: id,
            durationSeconds: elapsed,
          ),
    );
    _sessionId = null;
    _sessionStart = null;
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  void _toggleChrome() {
    HapticFeedback.selectionClick();
    setState(() => _chromeVisible = !_chromeVisible);
  }

  void _setAudioVolume(double v) {
    setState(() => _audioVolume = v);
    _audio.setMasterVolume(v);
  }

  Future<void> _toggleBookmark() async {
    HapticFeedback.lightImpact();
    final next = !_isBookmarked;
    setState(() => _isBookmarked = next);
    if (next && !kUseDummyReaderData && _chunks.isNotEmpty) {
      final chunk = _chunks[_activeIndex.clamp(0, _chunks.length - 1)];
      try {
        await ref.read(readingRepositoryProvider).createBookmark(
              bookId: widget.bookId,
              chunkId: chunk.chunkId,
              chapterNumber: chunk.chapterNumber ?? 1,
              offset: 0,
            );
      } catch (_) {
        if (mounted) setState(() => _isBookmarked = false);
        return;
      }
    }
    if (mounted) _snack(next ? 'Yer imi eklendi' : 'Yer imi kaldırıldı');
  }

  void _markCompleted() {
    if (_completed) return;
    setState(() => _completed = true);
    HapticFeedback.mediumImpact();
    _endSession();
    // NOTE: persistent "completed" needs the backend `reading_status` field
    // (currently missing). Until then this is a local/session-level mark.
    _snack('Kitabı tamamladın 🎉');
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          text,
          style: AppTypography.bodyMedium.copyWith(color: AppColors.backgroundDeep),
        ),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        ),
      ),
    );
  }

  void _openAmbiance() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AmbianceSheet(
        audioVolume: _audioVolume,
        visualIntensity: _visualIntensity,
        onAudioChanged: _setAudioVolume,
        onVisualChanged: (v) => setState(() => _visualIntensity = v),
        onReset: () {
          _setAudioVolume(0.65);
          setState(() => _visualIntensity = 0.80);
        },
      ),
    );
  }

  void _openSettings() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ReaderSettingsSheet(),
    );
  }

  int get _totalWords =>
      _chunks.fold(0, (sum, c) => sum + c.content.split(' ').length);
  int get _chapterNumber =>
      _chunks.isEmpty ? 1 : (_chunks[_activeIndex.clamp(0, _chunks.length - 1)].chapterNumber ?? 1);

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(readerSettingsProvider);
    final palette = ReaderPalette.of(settings.theme);
    final isLight = settings.theme == ReaderTheme.light;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isLight ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: palette.base,
        body: Stack(
          children: [
            _SceneBackground(
              ambiance: _currentAmbiance,
              palette: palette,
              intensity: _visualIntensity,
            ),
            // Non-positioned so it sizes the Stack to fullscreen.
            GestureDetector(
              onTap: _toggleChrome,
              child: _buildContent(settings, palette),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _TopBar(
                visible: _chromeVisible,
                title: _bookTitle,
                scene: _currentAmbiance?.scene,
                isBookmarked: _isBookmarked,
                palette: palette,
                onBack: () => context.canPop()
                    ? context.pop()
                    : context.go(AppRoutes.home),
                onAmbiance: _openAmbiance,
                onSettings: _openSettings,
                onBookmark: _toggleBookmark,
              ),
            ),
            _BottomBar(
              visible: _chromeVisible,
              progress: _progress,
              chapter: _chapterNumber,
              totalWords: _totalWords,
              wpm: _wordsPerMinute,
              palette: palette,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ReaderSettings settings, ReaderPalette palette) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'İçerik yüklenemedi:\n$_error',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(color: palette.text),
          ),
        ),
      );
    }

    final topPad = MediaQuery.of(context).padding.top + 96;
    final bottomPad = MediaQuery.of(context).padding.bottom + 96;
    final style = _readingStyle(settings, palette);

    return ScrollablePositionedList.builder(
      itemScrollController: _itemScroll,
      itemPositionsListener: _positions,
      physics: const _LimitedFlingPhysics(),
      padding: EdgeInsets.fromLTRB(
        AppDimensions.screenPaddingH * 1.4,
        topPad,
        AppDimensions.screenPaddingH * 1.4,
        bottomPad,
      ),
      itemCount: _chunks.length + 1,
      itemBuilder: (context, i) {
        if (i == _chunks.length) {
          return _EndCard(
            completed: _completed,
            palette: palette,
            onComplete: _markCompleted,
          );
        }
        final chunk = _chunks[i];
        final showHeader =
            i == 0 || chunk.chapterNumber != _chunks[i - 1].chapterNumber;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showHeader) _ChapterHeader(number: chunk.chapterNumber, palette: palette),
            Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.spaceLG),
              child: Text(chunk.content, style: style, textAlign: TextAlign.justify),
            ),
          ],
        );
      },
    );
  }

  TextStyle _readingStyle(ReaderSettings s, ReaderPalette p) {
    final size = 17.0 * s.fontScale;
    final shadows = [
      Shadow(color: p.textShadow, blurRadius: 6),
      Shadow(color: p.textShadow, blurRadius: 14),
    ];
    return s.serif
        ? GoogleFonts.lora(fontSize: size, height: 1.9, color: p.text, shadows: shadows)
        : GoogleFonts.inter(fontSize: size, height: 1.9, color: p.text, shadows: shadows);
  }
}

// ── Scene background (readability decoupled from atmosphere) ───────────────────

class _SceneBackground extends StatelessWidget {
  const _SceneBackground({
    required this.ambiance,
    required this.palette,
    required this.intensity,
  });

  final AmbianceDto? ambiance;
  final ReaderPalette palette;
  final double intensity;

  @override
  Widget build(BuildContext context) {
    final imageUrl = ambiance?.imageUrl;
    final imageOpacity = intensity * palette.imageOpacityCap;
    // Light readability veil that the visual-intensity slider drives.
    final veil = 0.16 + intensity * 0.34;

    return Positioned.fill(
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: palette.base),
          if (imageUrl != null && imageOpacity > 0.02)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 800),
              child: Opacity(
                key: ValueKey(imageUrl),
                opacity: imageOpacity,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                  child: Image(image: ReaderMedia.imageProvider(imageUrl), fit: BoxFit.cover),
                ),
              ),
            ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            color: _emotionColor(ambiance?.emotion).withValues(alpha: 0.14 * intensity),
          ),
          ColoredBox(color: palette.scrim.withValues(alpha: veil)),
        ],
      ),
    );
  }
}

// ── Chapter header (animated on appearance) ───────────────────────────────────

class _ChapterHeader extends StatelessWidget {
  const _ChapterHeader({required this.number, required this.palette});

  final int? number;
  final ReaderPalette palette;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spaceLG),
      child: Column(
        children: [
          Text(
            number != null ? 'BÖLÜM $number' : 'BÖLÜM',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.primary,
              letterSpacing: 2.0,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spaceMD),
          Row(
            children: [
              Expanded(child: Container(height: 1, color: palette.secondaryText.withValues(alpha: 0.3))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spaceMD),
                child: Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.primary.withValues(alpha: 0.7)),
              ),
              Expanded(child: Container(height: 1, color: palette.secondaryText.withValues(alpha: 0.3))),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceLG),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 450.ms, curve: Curves.easeOut)
        .slideY(begin: 0.12, end: 0, duration: 450.ms, curve: Curves.easeOutCubic);
  }
}

// ── End-of-book completion card ───────────────────────────────────────────────

class _EndCard extends StatelessWidget {
  const _EndCard({
    required this.completed,
    required this.palette,
    required this.onComplete,
  });

  final bool completed;
  final ReaderPalette palette;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spaceXXL),
      child: Column(
        children: [
          Icon(
            completed ? Icons.verified_rounded : Icons.auto_stories_rounded,
            color: AppColors.primary,
            size: 40,
          ),
          const SizedBox(height: AppDimensions.spaceMD),
          Text(
            completed ? 'Tamamlandı' : 'Hikâyenin Sonu',
            style: AppTypography.titleLarge.copyWith(color: palette.text, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppDimensions.spaceSM),
          Text(
            completed
                ? 'Bu kitabı bitirdin. Tebrikler!'
                : 'Bu bölümün sonuna geldin.',
            style: AppTypography.bodyMedium.copyWith(color: palette.secondaryText),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spaceLG),
          if (!completed)
            SizedBox(
              width: 200,
              height: AppDimensions.buttonHeight,
              child: ElevatedButton.icon(
                onPressed: onComplete,
                icon: const Icon(Icons.check_rounded, size: 18, color: AppColors.backgroundDeep),
                label: Text(
                  'Tamamla',
                  style: AppTypography.buttonLabel.copyWith(
                    color: AppColors.backgroundDeep,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                  ),
                  elevation: 0,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Top bar (hide-able chrome) ────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.visible,
    required this.title,
    required this.scene,
    required this.isBookmarked,
    required this.palette,
    required this.onBack,
    required this.onAmbiance,
    required this.onSettings,
    required this.onBookmark,
  });

  final bool visible;
  final String title;
  final String? scene;
  final bool isBookmarked;
  final ReaderPalette palette;
  final VoidCallback onBack;
  final VoidCallback onAmbiance;
  final VoidCallback onSettings;
  final VoidCallback onBookmark;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 220),
      opacity: visible ? 1 : 0,
      child: IgnorePointer(
        ignoring: !visible,
        child: Container(
          padding: EdgeInsets.only(top: topInset + 4, left: 4, right: 4, bottom: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                palette.base.withValues(alpha: 0.97),
                palette.base.withValues(alpha: 0.92),
                palette.base.withValues(alpha: 0.0),
              ],
              stops: const [0.0, 0.6, 1.0],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_rounded, color: palette.text),
                    onPressed: onBack,
                  ),
                  Expanded(
                    child: Text(
                      title.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: AppTypography.labelSmall.copyWith(
                        color: palette.secondaryText,
                        letterSpacing: 1.4,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.tune_rounded, color: palette.secondaryText, size: 20),
                    tooltip: 'Ortam',
                    onPressed: onAmbiance,
                  ),
                  IconButton(
                    icon: Icon(Icons.text_fields_rounded, color: palette.secondaryText, size: 20),
                    tooltip: 'Okuma Ayarları',
                    onPressed: onSettings,
                  ),
                  IconButton(
                    icon: Icon(
                      isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                      color: isBookmarked ? AppColors.primary : palette.secondaryText,
                      size: 20,
                    ),
                    onPressed: onBookmark,
                  ),
                ],
              ),
              if (scene != null && scene!.isNotEmpty)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: Padding(
                    key: ValueKey(scene),
                    padding: const EdgeInsets.only(top: 2),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: palette.scrim.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                      ),
                      child: Text(
                        scene!,
                        style: AppTypography.labelSmall.copyWith(
                          color: palette.text.withValues(alpha: 0.9),
                          fontSize: 10,
                          letterSpacing: 0.5,
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

// ── Bottom progress bar (rebuilds only on scroll via ValueListenable) ─────────

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.visible,
    required this.progress,
    required this.chapter,
    required this.totalWords,
    required this.wpm,
    required this.palette,
  });

  final bool visible;
  final ValueListenable<double> progress;
  final int chapter;
  final int totalWords;
  final int wpm;
  final ReaderPalette palette;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 220),
        opacity: visible ? 1 : 0,
        child: IgnorePointer(
          ignoring: !visible,
          child: Container(
            padding: EdgeInsets.fromLTRB(
              AppDimensions.screenPaddingH,
              AppDimensions.spaceLG,
              AppDimensions.screenPaddingH,
              MediaQuery.of(context).padding.bottom + AppDimensions.spaceMD,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  palette.scrim.withValues(alpha: 0.9),
                  palette.scrim.withValues(alpha: 0.0),
                ],
              ),
            ),
            child: ValueListenableBuilder<double>(
              valueListenable: progress,
              builder: (context, p, _) {
                final minutesLeft = (totalWords * (1 - p) / wpm).ceil();
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('BÖLÜM $chapter',
                            style: AppTypography.labelSmall
                                .copyWith(color: palette.secondaryText, fontSize: 10)),
                        Text('$minutesLeft DK KALDI',
                            style: AppTypography.labelSmall
                                .copyWith(color: palette.secondaryText, fontSize: 10)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text('${(p * 100).round()}%',
                            style: AppTypography.labelSmall.copyWith(
                              color: palette.text,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            )),
                        const SizedBox(width: AppDimensions.spaceMD),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                            child: LinearProgressIndicator(
                              value: p,
                              backgroundColor: palette.secondaryText.withValues(alpha: 0.25),
                              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                              minHeight: 4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
