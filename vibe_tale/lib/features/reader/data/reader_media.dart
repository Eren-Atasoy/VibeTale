import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:just_audio/just_audio.dart';

/// Resolves ambiance media URLs that may be either bundled assets
/// (`asset://assets/...`, used by the dummy source) or real backend storage
/// URLs (`http(s)://...`). The same helpers drive both, so swapping the data
/// source to the backend needs no UI changes.
abstract final class ReaderMedia {
  static const _assetScheme = 'asset://';

  /// Local Supabase storage returns `127.0.0.1` URLs that the Android emulator
  /// cannot reach; rewrite the host so backend media works out of the box.
  static String _rewriteHost(String url) => url
      .replaceFirst('127.0.0.1', '10.0.2.2')
      .replaceFirst('localhost', '10.0.2.2');

  static bool _isAsset(String url) => url.startsWith(_assetScheme);

  static String _assetPath(String url) => url.substring(_assetScheme.length);

  /// Builds a [just_audio] source for an ambiance audio URL.
  static AudioSource audioSource(String url) {
    if (_isAsset(url)) return AudioSource.asset(_assetPath(url));
    return AudioSource.uri(Uri.parse(_rewriteHost(url)));
  }

  /// Builds an [ImageProvider] for an ambiance image URL.
  static ImageProvider imageProvider(String url) {
    if (_isAsset(url)) return AssetImage(_assetPath(url));
    return CachedNetworkImageProvider(_rewriteHost(url));
  }
}
