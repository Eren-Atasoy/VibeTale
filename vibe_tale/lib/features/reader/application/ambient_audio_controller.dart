import 'dart:async';

import 'package:just_audio/just_audio.dart';
import 'package:vibe_tale/features/reader/data/reader_media.dart';

/// Plays per-chunk looping ambient audio for the immersive reader and
/// **crossfades** between scenes as the reader moves.
///
/// Two players are used so the outgoing track fades out while the incoming one
/// fades in. Upcoming audio can be [preload]ed into the idle player so a scene
/// change switches **instantly** (no waiting for the asset/network to buffer).
/// Repeated urls across consecutive chunks are a no-op, so a single-scene run
/// keeps playing seamlessly, and "latest target wins" guards against stale
/// switches during fast scrolling.
class AmbientAudioController {
  final AudioPlayer _a = AudioPlayer();
  final AudioPlayer _b = AudioPlayer();

  late AudioPlayer _active = _a;
  AudioPlayer get _idle => identical(_active, _a) ? _b : _a;

  String? _currentUrl; // playing on _active
  String? _preloadedUrl; // buffered on _idle, ready to play
  String? _targetUrl; // latest requested scene
  double _masterVolume = 0.65;
  Timer? _fadeTimer;
  bool _disposed = false;

  double get volume => _masterVolume;

  /// Pre-buffer [url] into the idle player so the next [setScene] is instant.
  Future<void> preload(String url) async {
    if (_disposed || url == _currentUrl || url == _preloadedUrl) return;
    try {
      await _idle.setAudioSource(ReaderMedia.audioSource(url));
      await _idle.setLoopMode(LoopMode.one);
      await _idle.setVolume(0);
      if (!_disposed) _preloadedUrl = url;
    } catch (_) {
      // Best-effort prebuffer.
    }
  }

  /// Switch the ambient bed to [url]. First scene starts at full volume; later
  /// scene changes crossfade. Uses the preloaded buffer when available.
  Future<void> setScene(String url) async {
    if (_disposed || url == _currentUrl) return;
    _targetUrl = url;
    final isFirst = _currentUrl == null;
    final from = isFirst ? null : _active;
    final to = _idle;

    if (_preloadedUrl != url) {
      try {
        await to.setAudioSource(ReaderMedia.audioSource(url));
        await to.setLoopMode(LoopMode.one);
        await to.setVolume(0);
      } catch (_) {
        return; // Best-effort.
      }
    }
    // Latest-target-wins: a newer scene was requested while we were loading.
    if (_disposed || _targetUrl != url) return;

    _preloadedUrl = null;
    _currentUrl = url;
    _active = to;

    if (isFirst) {
      await to.setVolume(_masterVolume);
      unawaited(to.play());
    } else {
      unawaited(to.play());
      _crossfade(from!, to);
    }
  }

  /// Set the master volume; applies to the audible track immediately.
  void setMasterVolume(double v) {
    _masterVolume = v.clamp(0.0, 1.0);
    if (!_disposed) _active.setVolume(_masterVolume);
  }

  void _crossfade(AudioPlayer from, AudioPlayer to) {
    _fadeTimer?.cancel();
    const steps = 22; // ~550ms at 25ms/step
    var i = 0;
    _fadeTimer = Timer.periodic(const Duration(milliseconds: 25), (t) {
      if (_disposed) {
        t.cancel();
        return;
      }
      i++;
      final p = (i / steps).clamp(0.0, 1.0);
      to.setVolume(_masterVolume * p);
      from.setVolume(_masterVolume * (1 - p));
      if (i >= steps) {
        t.cancel();
        _fadeTimer = null;
        from.pause();
      }
    });
  }

  Future<void> pause() async {
    if (!_disposed) await _active.pause();
  }

  void dispose() {
    _disposed = true;
    _fadeTimer?.cancel();
    _a.dispose();
    _b.dispose();
  }
}
