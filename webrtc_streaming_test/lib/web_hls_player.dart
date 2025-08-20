import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'web_hls_view_registry.dart';

class WebHLSPlayer extends StatefulWidget {
  final String url;
  final String viewType;
  final Function(bool isPlaying)? onPlayPauseChanged;

  WebHLSPlayer({super.key, required this.url, this.onPlayPauseChanged})
      : viewType = 'hls-player-${url.hashCode}' {
    if (kIsWeb) {
      registerHlsViewFactory(viewType, url);
    }
  }

  @override
  State<WebHLSPlayer> createState() => _WebHLSPlayerState();
}

class _WebHLSPlayerState extends State<WebHLSPlayer> {
  @override
  void initState() {
    super.initState();
    // ✅ listen for play/pause changes
    videoIsPlayingNotifier.addListener(_onNotifierChanged);
  }

  void _onNotifierChanged() {
    // ✅ notify parent when state changes
    widget.onPlayPauseChanged?.call(videoIsPlayingNotifier.value);
  }

  @override
  void dispose() {
    videoIsPlayingNotifier.removeListener(_onNotifierChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: widget.viewType);
  }
}