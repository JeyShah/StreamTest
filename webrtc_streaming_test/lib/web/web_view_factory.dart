// lib/web/web_view_factory.dart

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

// platformViewRegistry is only available on web, so import conditionally
// This only works on web
// ignore: undefined_prefixed_name
import 'dart:ui' as ui;
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;

typedef ViewFactory = html.Element Function(int viewId);

void registerWebViewFactory(String viewId, ViewFactory cb) {
  // ignore: undefined_prefixed_name
  // Register the view factory for the elementId
  // Use the global "platformViewRegistry" if available
  // It works because the compiler understands this name on web
  ui_web.platformViewRegistry.registerViewFactory(viewId, cb);
}