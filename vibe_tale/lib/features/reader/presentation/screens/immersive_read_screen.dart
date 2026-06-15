import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_tale/core/constants/app_colors.dart';
import 'package:vibe_tale/core/constants/app_dimensions.dart';
import 'package:vibe_tale/core/constants/app_typography.dart';
import 'package:vibe_tale/core/theme/app_theme_colors.dart';
import 'package:vibe_tale/core/widgets/themed_background.dart';
import 'package:vibe_tale/features/library/application/books_provider.dart';
import 'package:vibe_tale/features/reader/application/reading_provider.dart';
import 'package:vibe_tale/features/reader/data/chunk_dto.dart';

class ImmersiveReadScreen extends ConsumerStatefulWidget {
  final String bookId;
  const ImmersiveReadScreen({super.key, required this.bookId});

  @override
  ConsumerState<ImmersiveReadScreen> createState() =>
      _ImmersiveReadScreenState();
}

class _ImmersiveReadScreenState extends ConsumerState<ImmersiveReadScreen> {
  final ScrollController _scrollController = ScrollController();
  double _progress = 0.0;
  bool _isBookmarked = false;

  // Ambiance settings (0.0 – 1.0)
  double _audioVolume = 0.65;
  double _visualIntensity = 0.80;

  // Content loaded from backend
  List<ChunkDto> _chunks = [];
  bool _chunksLoading = true;
  String? _chunksError;
  String _bookTitle = '';
  Timer? _progressSaveTimer;

  // Derived reading stats
  static const int _wordsPerMinute = 200;

  String get _storyContent =>
      _chunks.map((c) => c.content).join('\n\n');

  String get _chapterLabel {
    if (_chunks.isEmpty) return '';
    final num = _chunks.first.chapterNumber;
    return num != null ? 'BÖLÜM $num' : 'BÖLÜM';
  }

  String get _chapterTitle {
    if (_chunks.isEmpty) return '';
    final num = _chunks.first.chapterNumber;
    return num != null ? 'Bölüm $num' : 'Başlangıç';
  }

  int get _totalPages => (_displayContent.split(' ').length / 250).ceil().clamp(1, 9999);
  int get _currentPage => (_progress * _totalPages).ceil().clamp(1, _totalPages);
  int get _wordsLeft =>
      (_displayContent.split(' ').length * (1 - _progress)).round();
  int get _minutesLeft => (_wordsLeft / _wordsPerMinute).ceil();

  // Returns real content when loaded, placeholder otherwise
  String get _displayContent =>
      _chunks.isNotEmpty ? _storyContent : _placeholderContent;

  // Placeholder shown while chunks are loading
  static const String _placeholderContent = '''
Keloğlan, mağaranın derinliklerindeki gizemli parıltıya doğru ilerledi. Elindeki değneğin ışığı, nemli duvarlardaki tuhaf sembolleri aydınlatıyordu. Kalbi heyecanla çarparken, onu bekleyen sırrın büyüklüğünü hissedebiliyordu.

Mağaranın içi, dışarıdan göründüğünden çok daha genişti. Tavanından sarkan dev sarkıtlar, kristal bir orman gibi parıldıyordu. Her adımda ayaklarının altındaki taş, boş ve derin bir sesin yankısını gönderiyordu derinliklere. Keloğlan duraksadı; o sesin ne kadar aşağılara indiğini hesaplamaya çalıştı, ama yankı hiç bitmiyordu sanki.

Köyde büyükler hep demişti: "Mağaraya girme, Keloğlan! Orada uyuyan bir dev var, üç yüz yıldır uykuda. Kim onu uyandırırsa, o kişi ya bir kahraman olur ya da yok olup gider." Keloğlan gülmüştü o zamanlar. Şimdi ise o gülüş, boğazında bir düğüme dönüşmüştü.

Birden, sol taraftan garip bir ses duydu. Bir hışırtı mıydı, yoksa rüzgârın kayalara çarpmasından mı kaynaklanıyordu, anlayamadı. Değneğini o yöne doğrulttu. Karanlık, ışığını yutuyordu adeta. Ardından her şey durdu; ses, hareket, hatta zamanın kendisi bile soluklanmayı bıraktı sanki.

Keloğlan geri adım atmak istedi, ama bacakları taş kesilmişti. O an, mağaranın tabanından tırmanan bir titreşim hissetti. Hafif, ama kararlı. Bir nesnenin uyanışının sesi miydi bu? Yoksa sadece kendi kalbinin deli gibi çarptığı mıydı?

Gözlerini kırpıştırarak önüne odaklandı. Işığın erişebildiği son noktada, kocaman, kıllı bir el duruyordu. Parmakları, bir insanın kolundan kalındı. Ve o el, yavaş yavaş açılıp kapanmaya başlıyordu.

Keloğlan tüm cesaretini toplayıp değneğe doğru uzandı, ancak tam o sırada devin devasa eli omzuna dokundu. Soğuk, ağır ve yorgun bir dokunuştu bu. Sanki o el de uyumaktan bıkmıştı.

"Yine mi geldiniz?" dedi dev, sesi mağaranın duvarlarında yankılanan kısık bir gürültüyle. "Kaç yüzyıldır kimse gelmemişti buraya."

Keloğlan dili tutulmuş gibi baktı. Büyükler, devin kükreyeceğini söylemişti. Oysa bu ses, yorgundu. Neredeyse hüzünlüydü.

"Ben..." dedi Keloğlan, sesi titreyerek. "Ben sizi uyandırmak istemedim, efendim. Sadece yolumu kaybettim."

Dev, gözlerini açtı. Gözleri, iki küçük ay gibiydi; sarı ve sakin. Uzun bir süre Keloğlan'a baktı. Sonra güldü. Güldü ve mağaranın tavanından birkaç sarkıt düşerek paramparça oldu.

"Yolunu kaybeden biri," dedi dev, "benim için en iyi misafirdir. Çünkü yolunu bulmuş olanlar asla gelmez buraya."

Keloğlan, değneğini tutmayı bile unuttu. Dev, yerinden kalkmaya başlamıştı. O kadar büyüktü ki, doğrulurken başı tavana değdi ve bir sarkıtı daha kırdı. Tozu, Keloğlan'ın gözlerine doldu.

"Otur," dedi dev, taş bir blok göstererek. "Sana bir hikâye anlatacağım. Ama dikkat et; bu hikâyeyi duymak isteyip istemediğinden emin ol önce. Çünkü bir kez duyduktan sonra, onu unutamazsın."

Keloğlan yutkundu. Köye dönmek, annesinin sıcak çorbasını içmek istedi bir an için. Ama sonra, hayatında ilk kez, bir şeyin peşinden gitmenin korkusunun ta kendisi olduğunu anladı.

Oturdu.

Dev gülümsedi. Ve anlatmaya başladı.
''';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadContent();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _progressSaveTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadContent() async {
    try {
      final book = await ref
          .read(bookRepositoryProvider)
          .getBook(widget.bookId);
      final chunks = await ref
          .read(readingRepositoryProvider)
          .getChunks(widget.bookId);
      if (!mounted) return;
      setState(() {
        _bookTitle = book.title;
        _chunks = chunks;
        _chunksLoading = false;
      });
      _restoreProgress();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _chunksError = e.toString();
        _chunksLoading = false;
      });
    }
  }

  Future<void> _restoreProgress() async {
    try {
      // Progress restore via scroll position deferred to future UX improvement
      await ref.read(readingRepositoryProvider).getProgress(widget.bookId);
    } catch (_) {}
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    final cur = _scrollController.position.pixels;
    if (max > 0) {
      setState(() => _progress = (cur / max).clamp(0.0, 1.0));
      _debounceProgressSave();
    }
  }

  void _debounceProgressSave() {
    _progressSaveTimer?.cancel();
    _progressSaveTimer =
        Timer(const Duration(seconds: 2), _saveProgress);
  }

  Future<void> _saveProgress() async {
    if (_chunks.isEmpty) return;
    final idx = (_progress * _chunks.length)
        .floor()
        .clamp(0, _chunks.length - 1);
    final chunk = _chunks[idx];
    try {
      await ref.read(readingRepositoryProvider).saveProgress(
            bookId: widget.bookId,
            currentChunkId: chunk.chunkId,
            chapterNumber: chunk.chapterNumber ?? 1,
            offset: 0,
          );
    } catch (_) {}
  }

  Future<void> _toggleBookmark() async {
    HapticFeedback.lightImpact();
    final next = !_isBookmarked;
    setState(() => _isBookmarked = next);

    if (next && _chunks.isNotEmpty) {
      final idx = (_progress * _chunks.length)
          .floor()
          .clamp(0, _chunks.length - 1);
      try {
        await ref.read(readingRepositoryProvider).createBookmark(
              bookId: widget.bookId,
              chunkId: _chunks[idx].chunkId,
            );
      } catch (_) {
        if (mounted) setState(() => _isBookmarked = false);
        return;
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          next ? 'Yer imi eklendi' : 'Yer imi kaldırıldı',
          style: AppTypography.bodyMedium
              .copyWith(color: AppColors.backgroundDeep),
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

  void _showAmbianceSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AmbianceSheet(
        audioVolume: _audioVolume,
        visualIntensity: _visualIntensity,
        onAudioChanged: (v) => setState(() => _audioVolume = v),
        onVisualChanged: (v) => setState(() => _visualIntensity = v),
        onReset: () => setState(() {
          _audioVolume = 0.65;
          _visualIntensity = 0.80;
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.vColors;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            context.isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
      ),
      child: ThemedBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          body: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                // ── Reading area ─────────────────────────────────────────────
                CustomScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverAppBar(
                      floating: true,
                      backgroundColor: context.isDark
                          ? AppColors.backgroundDeep.withValues(alpha: 0.95)
                          : const Color(0xFFF4F6F5).withValues(alpha: 0.95),
                      elevation: 0,
                      leading: IconButton(
                        icon: Icon(Icons.arrow_back_rounded,
                            color: c.textPrimary),
                        onPressed: () => context.pop(),
                      ),
                      title: Text(
                        _bookTitle.toUpperCase(),
                        style: AppTypography.labelSmall.copyWith(
                          color: c.textSecondary,
                          letterSpacing: 1.5,
                          fontSize: 11,
                        ),
                      ),
                      centerTitle: true,
                      actions: [
                        // Ambiance button
                        IconButton(
                          icon: Icon(
                            Icons.tune_rounded,
                            color: c.textSecondary,
                            size: 20,
                          ),
                          tooltip: 'Ortam Ayarları',
                          onPressed: _showAmbianceSheet,
                        ),
                        // Bookmark
                        IconButton(
                          icon: Icon(
                            _isBookmarked
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            color: _isBookmarked
                                ? AppColors.primary
                                : c.textSecondary,
                            size: 20,
                          ),
                          onPressed: _toggleBookmark,
                        ),
                      ],
                    ),

                    // Chapter header + text content
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.screenPaddingH * 1.4,
                          vertical: AppDimensions.spaceLG,
                        ),
                        child: Column(
                          children: [
                            // Chapter label
                            if (_chapterLabel.isNotEmpty)
                            Text(
                              _chapterLabel,
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.primary,
                                letterSpacing: 2.0,
                                fontSize: 11,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppDimensions.spaceSM),

                            // Chapter title
                            Text(
                              _chapterTitle,
                              style: AppTypography.displayMedium.copyWith(
                                color: c.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppDimensions.spaceLG),

                            // Decorative divider
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: c.glassBorder,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: AppDimensions.spaceMD),
                                  child: Icon(
                                    Icons.auto_awesome_rounded,
                                    size: 14,
                                    color: AppColors.primary.withValues(alpha: 0.6),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: c.glassBorder,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppDimensions.spaceLG),

                            // Story text
                            if (_chunksLoading)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(32),
                                  child: CircularProgressIndicator(
                                    color: AppColors.primary,
                                  ),
                                ),
                              )
                            else if (_chunksError != null)
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  'İçerik yüklenemedi: $_chunksError',
                                  style: AppTypography.bodyMedium,
                                  textAlign: TextAlign.center,
                                ),
                              )
                            else
                            Text(
                              _displayContent,
                              style: AppTypography.readingBody.copyWith(
                                color: c.textPrimary,
                                height: 1.9,
                                fontSize: 17,
                              ),
                              textAlign: TextAlign.justify,
                            ),

                            // Bottom spacing for progress bar
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // ── Footer progress bar ───────────────────────────────────────
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(
                      AppDimensions.screenPaddingH,
                      AppDimensions.spaceLG,
                      AppDimensions.screenPaddingH,
                      MediaQuery.of(context).padding.bottom + AppDimensions.spaceSM,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          (context.isDark
                                  ? AppColors.backgroundDeep
                                  : const Color(0xFFF4F6F5))
                              .withValues(alpha: 0.98),
                          (context.isDark
                                  ? AppColors.backgroundDeep
                                  : const Color(0xFFF4F6F5))
                              .withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Page + time info
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'SAYFA $_currentPage',
                              style: AppTypography.labelSmall.copyWith(
                                color: context.vColors.textHint,
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              '$_minutesLeft DK KALDI',
                              style: AppTypography.labelSmall.copyWith(
                                color: context.vColors.textHint,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Progress track
                        Row(
                          children: [
                            Text(
                              '${(_progress * 100).toInt()}%',
                              style: AppTypography.labelSmall.copyWith(
                                color: context.vColors.textSecondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(width: AppDimensions.spaceMD),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusPill),
                                child: LinearProgressIndicator(
                                  value: _progress,
                                  backgroundColor:
                                      context.vColors.glassBorder,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          AppColors.primary),
                                  minHeight: 4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Ambiance bottom sheet ─────────────────────────────────────────────────────

class _AmbianceSheet extends StatefulWidget {
  const _AmbianceSheet({
    required this.audioVolume,
    required this.visualIntensity,
    required this.onAudioChanged,
    required this.onVisualChanged,
    required this.onReset,
  });

  final double audioVolume;
  final double visualIntensity;
  final ValueChanged<double> onAudioChanged;
  final ValueChanged<double> onVisualChanged;
  final VoidCallback onReset;

  @override
  State<_AmbianceSheet> createState() => _AmbianceSheetState();
}

class _AmbianceSheetState extends State<_AmbianceSheet> {
  late double _audio;
  late double _visual;

  @override
  void initState() {
    super.initState();
    _audio = widget.audioVolume;
    _visual = widget.visualIntensity;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.vColors;

    return Container(
      decoration: BoxDecoration(
        color: c.cardSurface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLG),
        ),
        border: Border(
          top: BorderSide(color: c.glassBorder, width: 1),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        AppDimensions.screenPaddingH,
        AppDimensions.spaceMD,
        AppDimensions.screenPaddingH,
        MediaQuery.of(context).padding.bottom + AppDimensions.spaceLG,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: c.glassBorder,
                borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spaceLG),

          // Title
          Text(
            'ORTAM',
            style: AppTypography.labelSmall.copyWith(
              color: c.textSecondary,
              letterSpacing: 2.5,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceLG),

          // Audio slider
          _SliderRow(
            label: 'Ses Seviyesi',
            value: _audio,
            leadingIcon: Icons.volume_mute_rounded,
            trailingIcon: Icons.volume_up_rounded,
            percentage: '${(_audio * 100).toInt()}%',
            onChanged: (v) {
              setState(() => _audio = v);
              widget.onAudioChanged(v);
            },
          ),
          const SizedBox(height: AppDimensions.spaceLG),

          // Visual slider
          _SliderRow(
            label: 'Görsel Yoğunluk',
            value: _visual,
            leadingIcon: Icons.brightness_low_rounded,
            trailingIcon: Icons.brightness_high_rounded,
            percentage: '${(_visual * 100).toInt()}%',
            onChanged: (v) {
              setState(() => _visual = v);
              widget.onVisualChanged(v);
            },
          ),
          const SizedBox(height: AppDimensions.spaceXL),

          // Reset button
          SizedBox(
            width: double.infinity,
            height: AppDimensions.buttonHeight,
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _audio = 0.65;
                  _visual = 0.80;
                });
                widget.onReset();
              },
              icon: const Icon(Icons.refresh_rounded,
                  size: 18, color: AppColors.primary),
              label: Text(
                'Varsayılana Dön',
                style: AppTypography.buttonLabel.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusPill),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.leadingIcon,
    required this.trailingIcon,
    required this.percentage,
    required this.onChanged,
  });

  final String label;
  final double value;
  final IconData leadingIcon;
  final IconData trailingIcon;
  final String percentage;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.vColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTypography.titleMedium.copyWith(color: c.textPrimary),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spaceSM, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primaryGlow,
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusSM),
              ),
              child: Text(
                percentage,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spaceSM),
        Row(
          children: [
            Icon(leadingIcon, size: 18, color: c.textHint),
            Expanded(
              child: SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: c.glassBorder,
                  thumbColor: AppColors.primary,
                  overlayColor: AppColors.primaryGlow,
                  trackHeight: 3,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 10),
                ),
                child: Slider(
                  value: value,
                  onChanged: onChanged,
                ),
              ),
            ),
            Icon(trailingIcon, size: 18, color: c.textSecondary),
          ],
        ),
      ],
    );
  }
}
