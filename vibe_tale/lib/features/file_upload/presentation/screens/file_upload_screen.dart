import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_tale/core/constants/app_colors.dart';
import 'package:vibe_tale/core/constants/app_dimensions.dart';
import 'package:vibe_tale/core/constants/app_typography.dart';
import 'package:vibe_tale/core/localization/app_strings.dart';
import 'package:vibe_tale/core/providers/app_settings_provider.dart';
import 'package:vibe_tale/core/theme/app_theme_colors.dart';
import 'package:vibe_tale/core/widgets/themed_background.dart';
import 'package:vibe_tale/features/library/application/books_provider.dart';
// ── File Upload Screen ────────────────────────────────────────────────────────

class FileUploadScreen extends ConsumerStatefulWidget {
  const FileUploadScreen({super.key});

  @override
  ConsumerState<FileUploadScreen> createState() => _FileUploadScreenState();
}

enum _UploadState { idle, picked, uploading, done, error }

/// Formats the backend can ingest — validated on the client for instant
/// feedback before any upload round-trip. Keep in sync with the backend
/// file validator.
const _supportedExtensions = {'epub', 'pdf', 'docx', 'txt'};

class _FileUploadScreenState extends ConsumerState<FileUploadScreen>
    with SingleTickerProviderStateMixin {
  _UploadState _state = _UploadState.idle;
  String? _fileName;
  double _progress = 0;
  String? _uploadedBookId;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    HapticFeedback.lightImpact();

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _supportedExtensions.toList(),
      );

      if (result == null || result.files.isEmpty) return;

      final picked = result.files.first;
      final path = picked.path;
      if (path == null) {
        setState(() => _state = _UploadState.error);
        return;
      }

      // Guard against files slipping past the picker filter (e.g. "all files"
      // mode on some platforms). Reject unsupported formats before uploading.
      final extension = (picked.extension ?? picked.name.split('.').last)
          .toLowerCase();
      if (!_supportedExtensions.contains(extension)) {
        if (!mounted) return;
        _showUnsupportedFormat();
        setState(() => _state = _UploadState.idle);
        return;
      }

      setState(() {
        _state = _UploadState.picked;
        _fileName = picked.name;
      });
      await Future.delayed(const Duration(milliseconds: 300));
      await _uploadFile(path, picked.name);
    } on Exception {
      if (mounted) {
        setState(() => _state = _UploadState.error);
      }
    }
  }

  void _showUnsupportedFormat() {
    final s = ref.read(appStringsProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(s.unsupportedFormat),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        ),
      ),
    );
  }

  Future<void> _uploadFile(String path, String fileName) async {
    setState(() {
      _state = _UploadState.uploading;
      _progress = 0;
    });
    try {
      final book = await ref
          .read(bookRepositoryProvider)
          .uploadBook(path, fileName);
      if (!mounted) return;
      // Refresh the library so the new book appears.
      ref.invalidate(booksProvider);
      setState(() {
        _uploadedBookId = book.id;
        _progress = 1;
        _state = _UploadState.done;
      });
      HapticFeedback.mediumImpact();
    } catch (e) {
      if (!mounted) return;
      setState(() => _state = _UploadState.error);
    }
  }

  void _reset() {
    setState(() {
      _state = _UploadState.idle;
      _fileName = null;
      _progress = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(appStringsProvider);
    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _AppBar(),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.screenPaddingH,
            ),
            child: Column(
              children: [
                const SizedBox(height: AppDimensions.spaceLG),

                // ── Main Upload Card
                Expanded(
                  child: _UploadCard(
                    state: _state,
                    fileName: _fileName,
                    progress: _progress,
                    pulseAnim: _pulseAnim,
                    onPickFile: _pickFile,
                    onReset: _reset,
                    onFinish: () {
                      final id = _uploadedBookId;
                      if (id != null) {
                        context.pushReplacement('/vibe-analysis/$id');
                      } else {
                        context.pop();
                      }
                    },
                  ),
                ),

                const SizedBox(height: AppDimensions.spaceLG),

                // ── Supported Formats
                Text(
                  s.supportedFormats,
                  style: AppTypography.bodyMedium.copyWith(
                    fontSize: 11,
                    color: context.vColors.textHint,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppDimensions.spaceMD),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── App Bar ───────────────────────────────────────────────────────────────────

class _AppBar extends ConsumerWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appStringsProvider);
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_rounded,
          color: context.vColors.textPrimary,
        ),
        onPressed: () => context.pop(),
      ),
      title: Text(
        s.addToLibrary,
        style: AppTypography.titleLarge.copyWith(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
          color: context.vColors.textPrimary,
        ),
      ),
      centerTitle: true,
    );
  }
}

// ── Main Upload Card ──────────────────────────────────────────────────────────

class _UploadCard extends ConsumerWidget {
  const _UploadCard({
    required this.state,
    required this.fileName,
    required this.progress,
    required this.pulseAnim,
    required this.onPickFile,
    required this.onReset,
    required this.onFinish,
  });

  final _UploadState state;
  final String? fileName;
  final double progress;
  final Animation<double> pulseAnim;
  final VoidCallback onPickFile;
  final VoidCallback onReset;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appStringsProvider);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.vColors.cardSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(
          color: state == _UploadState.done
              ? AppColors.success.withValues(alpha: 0.4)
              : context.vColors.glassBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDark ? 0.3 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // ── Corner badge (top-right)
          Positioned(top: 14, right: 14, child: _CornerBadge(state: state)),

          // ── Body content
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spaceLG,
              vertical: AppDimensions.spaceLG,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Upload icon / progress / success
                if (state == _UploadState.uploading)
                  _ProgressRing(progress: progress)
                else
                  _FileIcon(state: state, pulseAnim: pulseAnim),

                const SizedBox(height: AppDimensions.spaceLG),

                // Title
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _titleFor(s, state),
                    key: ValueKey(state),
                    style: AppTypography.headlineMedium.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: AppDimensions.spaceSM),

                // Subtitle / filename
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _subtitleFor(s, state, fileName),
                    key: ValueKey('$state-$fileName'),
                    style: AppTypography.bodyMedium.copyWith(
                      height: 1.5,
                      color: context.vColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                if (state == _UploadState.uploading) ...[
                  const SizedBox(height: AppDimensions.spaceLG),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusPill,
                    ),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: context.vColors.glassBorder.withValues(
                        alpha: 0.3,
                      ),
                      valueColor: const AlwaysStoppedAnimation(
                        AppColors.primary,
                      ),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spaceSM),
                  Text(
                    '${(progress * 100).round()}%',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],

                const SizedBox(height: AppDimensions.spaceXL),

                // CTA Button
                if (state == _UploadState.idle || state == _UploadState.error)
                  _PrimaryButton(label: s.browseFiles, onPressed: onPickFile)
                else if (state == _UploadState.done)
                  Column(
                    children: [
                      _PrimaryButton(
                        label: s.goToLibrary,
                        icon: Icons.library_books_rounded,
                        onPressed: onFinish,
                      ),
                      const SizedBox(height: AppDimensions.spaceSM),
                      TextButton(
                        onPressed: onReset,
                        child: Text(
                          s.addAnotherFile,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: AppDimensions.spaceMD),

                // VibeEngine badge
                if (state == _UploadState.idle)
                  _VibeEngineBadge(label: s.vibeEngineReady),
                if (state == _UploadState.done)
                  _VibeEngineBadge(label: s.vibeEngineAnalyzed, success: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _titleFor(AppStrings s, _UploadState state) => switch (state) {
    _UploadState.idle => s.uploadTitle,
    _UploadState.picked => s.uploadPreparing,
    _UploadState.uploading => s.uploadUploading,
    _UploadState.done => s.uploadDone,
    _UploadState.error => s.uploadError,
  };

  String _subtitleFor(AppStrings s, _UploadState state, String? name) =>
      switch (state) {
        _UploadState.idle => s.uploadIdleSubtitle,
        _UploadState.picked => name ?? '',
        _UploadState.uploading => name != null ? s.uploadingSubtitle(name) : '',
        _UploadState.done => s.uploadDoneSubtitle(name ?? ''),
        _UploadState.error => s.uploadErrorSubtitle,
      };
}

// ── File Icon with pulse ──────────────────────────────────────────────────────

class _FileIcon extends StatelessWidget {
  const _FileIcon({required this.state, required this.pulseAnim});

  final _UploadState state;
  final Animation<double> pulseAnim;

  @override
  Widget build(BuildContext context) {
    if (state == _UploadState.done) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.success.withValues(alpha: 0.15),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
        ),
        child: const Icon(
          Icons.check_rounded,
          color: AppColors.success,
          size: 40,
        ),
      );
    }

    if (state == _UploadState.error) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.error.withValues(alpha: 0.15),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
        ),
        child: const Icon(
          Icons.error_outline_rounded,
          color: AppColors.error,
          size: 40,
        ),
      );
    }

    return ScaleTransition(
      scale: pulseAnim,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withValues(alpha: 0.15),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.35),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.18),
              blurRadius: 20,
              spreadRadius: 4,
            ),
          ],
        ),
        child: const Icon(
          Icons.upload_file_rounded,
          color: AppColors.primary,
          size: 36,
        ),
      ),
    );
  }
}

// ── Progress Ring ─────────────────────────────────────────────────────────────

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            backgroundColor: context.vColors.glassBorder.withValues(alpha: 0.3),
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            strokeWidth: 5,
            strokeCap: StrokeCap.round,
          ),
          const Icon(
            Icons.upload_file_rounded,
            color: AppColors.primary,
            size: 28,
          ),
        ],
      ),
    );
  }
}

// ── Corner Badge ──────────────────────────────────────────────────────────────

class _CornerBadge extends StatelessWidget {
  const _CornerBadge({required this.state});

  final _UploadState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.vColors.glassFill,
        border: Border.all(color: context.vColors.glassBorder, width: 0.8),
      ),
      child: Icon(
        state == _UploadState.done
            ? Icons.check_circle_outline_rounded
            : Icons.description_outlined,
        color: state == _UploadState.done
            ? AppColors.success
            : context.vColors.textSecondary,
        size: 16,
      ),
    );
  }
}

// ── VibeEngine Badge ──────────────────────────────────────────────────────────

class _VibeEngineBadge extends StatelessWidget {
  const _VibeEngineBadge({required this.label, this.success = false});

  final String label;
  final bool success;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            success ? Icons.auto_awesome : Icons.auto_awesome_outlined,
            color: AppColors.primary,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 11,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Primary Button ────────────────────────────────────────────────────────────

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppDimensions.buttonHeight,
      child: ElevatedButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          onPressed();
        },
        style:
            ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.backgroundDeep,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
              ),
              elevation: 0,
              shadowColor: Colors.transparent,
            ).copyWith(
              overlayColor: WidgetStatePropertyAll(
                AppColors.backgroundDeep.withValues(alpha: 0.08),
              ),
            ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: AppColors.backgroundDeep),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.backgroundDeep,
                fontWeight: FontWeight.w700,
                fontSize: 15,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
