import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'web_hls_view_registry.dart'; // ✅ new import (this will resolve correctly)

class WebHLSPlayer extends StatelessWidget {
  final String url;
  final String viewType;

  WebHLSPlayer({super.key, required this.url})
      : viewType = 'hls-player-${url.hashCode}' {
    if (kIsWeb) {
      registerHlsViewFactory(viewType, url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: viewType);
  }
}
