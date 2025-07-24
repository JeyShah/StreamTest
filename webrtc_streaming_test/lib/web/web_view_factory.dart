// lib/web/web_view_factory.dart

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

typedef ViewFactory = html.Element Function(int viewId);

void registerWebViewFactory(String viewId, ViewFactory cb) {
  // Use JS interop to safely register the view factory
  try {
    // Check if platformViewRegistry is available
    if (js.context.hasProperty('flutter')) {
      final flutter = js.context['flutter'];
      if (flutter != null && flutter.hasProperty('platformViewRegistry')) {
        final registry = flutter['platformViewRegistry'];
        if (registry != null && registry.hasProperty('registerViewFactory')) {
          registry.callMethod('registerViewFactory', [viewId, js.allowInterop(cb)]);
          return;
        }
      }
    }
    
    // Fallback: do nothing if platformViewRegistry is not available
    print('Warning: platformViewRegistry not available, view factory not registered');
  } catch (e) {
    print('Error registering view factory: $e');
  }
}