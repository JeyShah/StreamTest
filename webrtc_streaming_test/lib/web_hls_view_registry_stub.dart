import 'package:flutter/foundation.dart';

/// ✅ Stub, so mobile build won’t fail
final ValueNotifier<bool> videoIsPlayingNotifier = ValueNotifier(false);

void registerHlsViewFactory(String viewType, String url) {
  // no-op for mobile
}