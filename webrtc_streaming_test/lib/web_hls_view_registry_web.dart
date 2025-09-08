import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/foundation.dart';

final ValueNotifier<bool> videoIsPlayingNotifier = ValueNotifier(false);
final ValueNotifier<Duration?> videoSeekNotifier = ValueNotifier(null);

// 🔹 store video elements by viewType
final Map<String, html.VideoElement> _videoElements = {};

void registerHlsViewFactory(String viewType, String url) {
  ui_web.platformViewRegistry.registerViewFactory(
    viewType,
    (int viewId) {
      final video = html.VideoElement()
        ..src = url
        ..autoplay = true
        ..controls = true
        ..muted = true // 🔹 Chrome autoplay fix
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%';

      video.onPlay.listen((_) => videoIsPlayingNotifier.value = true);
      video.onPause.listen((_) => videoIsPlayingNotifier.value = false);

      video.onSeeked.listen((event) {
        videoSeekNotifier.value = Duration(seconds: video.currentTime.floor());
      });

      _videoElements[viewType] = video; // ✅ keep reference

      return video;
    },
  );
}

// expose getter for Flutter side
html.VideoElement? getVideoElement(String viewType) => _videoElements[viewType];