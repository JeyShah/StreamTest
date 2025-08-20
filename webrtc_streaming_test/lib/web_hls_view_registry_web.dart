import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;

void registerHlsViewFactory(String viewType, String url) {
  ui_web.platformViewRegistry.registerViewFactory(
    viewType,
    (int viewId) {
      final video = html.VideoElement()
        ..src = url
        ..autoplay = true
        ..controls = true
        ..style.border = 'none';
      return video;
    },
  );
}