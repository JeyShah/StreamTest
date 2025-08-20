import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;
import 'package:flutter/foundation.dart';

/// ✅ Make this public so other files can use it
final ValueNotifier<bool> videoIsPlayingNotifier = ValueNotifier(false);

void registerHlsViewFactory(String viewType, String url) {
  ui_web.platformViewRegistry.registerViewFactory(
    viewType,
    (int viewId) {
      final video = html.VideoElement()
        ..src = url
        ..autoplay = true
        ..controls = true
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%';

      video.onPlay.listen((event) {
        videoIsPlayingNotifier.value = true;
      });
      video.onPause.listen((event) {
        videoIsPlayingNotifier.value = false;
      });

      return video;
    },
  );
}