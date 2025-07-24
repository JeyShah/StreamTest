// lib/web/web_view_factory.dart

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

typedef ViewFactory = html.Element Function(int viewId);

void registerWebViewFactory(String viewId, ViewFactory cb) {
  // Use JS interop to safely register the view factory
  try {
    // Check if we're actually on web platform
    if (!identical(0, 0.0)) {
      print('Not on web platform, skipping view factory registration');
      return;
    }
    
    // Try different ways to access platformViewRegistry
    dynamic registry;
    
    // Method 1: Direct access
    try {
      registry = js.context['platformViewRegistry'];
    } catch (e) {
      // Ignore and try next method
    }
    
    // Method 2: Through flutter object
    if (registry == null) {
      try {
        if (js.context.hasProperty('flutter')) {
          final flutter = js.context['flutter'];
          if (flutter != null && flutter.hasProperty('platformViewRegistry')) {
            registry = flutter['platformViewRegistry'];
          }
        }
      } catch (e) {
        // Ignore and try next method
      }
    }
    
    // Method 3: Through window object
    if (registry == null) {
      try {
        final window = js.context['window'];
        if (window != null && window.hasProperty('flutter')) {
          final flutter = window['flutter'];
          if (flutter != null && flutter.hasProperty('platformViewRegistry')) {
            registry = flutter['platformViewRegistry'];
          }
        }
      } catch (e) {
        // Ignore
      }
    }
    
    // If we found a registry, try to register
    if (registry != null && registry.hasProperty('registerViewFactory')) {
      try {
        registry.callMethod('registerViewFactory', [viewId, js.allowInterop(cb)]);
        print('Successfully registered view factory: $viewId');
        return;
      } catch (e) {
        print('Error calling registerViewFactory: $e');
      }
    }
    
    // Fallback: do nothing if platformViewRegistry is not available
    print('Warning: platformViewRegistry not available, view factory not registered for $viewId');
  } catch (e) {
    print('Error registering view factory: $e');
  }
}