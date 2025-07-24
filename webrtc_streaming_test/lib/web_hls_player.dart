// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Conditional import
import 'web/web_view_factory.dart'
    if (dart.library.io) 'web_view_factory_stub.dart';

class WebHLSPlayer extends StatelessWidget {
  final String url;
  final String viewId;

  WebHLSPlayer({super.key, required this.url})
      : viewId = 'hls-player-${DateTime.now().millisecondsSinceEpoch}' {
    if (kIsWeb) {
      registerWebViewFactory(viewId, (int _) {
        final videoElement = html.VideoElement()
          ..src = ''
          ..autoplay = true
          ..controls = true
          ..style.border = 'none'
          ..id = 'video-$viewId';

        final script = html.ScriptElement()
          ..type = 'application/javascript'
          ..innerHtml = """
            if (window.Hls && Hls.isSupported()) {
              var hls = new Hls();
              hls.loadSource("$url");
              hls.attachMedia(document.getElementById('video-$viewId'));
            } else {
              var video = document.getElementById('video-$viewId');
              video.src = "$url";
            }
          """;

        html.document.body?.append(script);
        return videoElement;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: viewId);
  }
}