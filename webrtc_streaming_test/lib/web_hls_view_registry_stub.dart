import 'package:flutter/foundation.dart';

/// ✅ Stub, so mobile/macOS/desktop builds won’t fail
final ValueNotifier<bool> videoIsPlayingNotifier = ValueNotifier(false);
final ValueNotifier<Duration?> videoSeekNotifier = ValueNotifier(null);

void registerHlsViewFactory(String viewType, String url) {
  // no-op for mobile/desktop
}

dynamic getVideoElement(String viewType) {
  // no-op on mobile/desktop → always return null
  return null;
}