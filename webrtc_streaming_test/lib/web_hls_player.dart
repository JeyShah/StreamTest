import 'package:flutter/material.dart';
import 'web_hls_view_registry.dart';

class WebHLSPlayer extends StatefulWidget {
  final String url;
  final String viewType;
  final Function(bool isPlaying)? onPlayPauseChanged;

  final ValueChanged<Duration>? onSeek;

  WebHLSPlayer({
    super.key,
    required this.url,
    this.onPlayPauseChanged,
    this.onSeek,
  }) : viewType = 'hls-player-${url.hashCode}' {
    registerHlsViewFactory(viewType, url);
  }

  @override
  State<WebHLSPlayer> createState() => WebHLSPlayerState();
}

class WebHLSPlayerState extends State<WebHLSPlayer> {
  @override
  void initState() {
    super.initState();
    videoIsPlayingNotifier.addListener(_onNotifierChanged);
    videoSeekNotifier.addListener(_onSeekChanged); 
  }

  void _onNotifierChanged() {
    widget.onPlayPauseChanged?.call(videoIsPlayingNotifier.value);
  }

  void _onSeekChanged() {
    print("seeking");
    final pos = videoSeekNotifier.value;
    if (pos != null) {
      widget.onSeek?.call(pos);
    }
  }

  @override
  void dispose() {
    videoIsPlayingNotifier.removeListener(_onNotifierChanged);
    videoSeekNotifier.removeListener(_onSeekChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: widget.viewType);
  }

  // ✅ now actually controls the DOM <video>
  void seekBy(Duration offset) {
    final video = getVideoElement(widget.viewType);
    if (video == null) return;

    final newTime = video.currentTime + offset.inSeconds;
    if (newTime < 0) {
      video.currentTime = 0;
    } else if (newTime > video.duration) {
      video.currentTime = video.duration;
    } else {
      video.currentTime = newTime;
    }
  }
}