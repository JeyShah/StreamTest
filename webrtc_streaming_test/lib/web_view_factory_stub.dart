// lib/web_view_factory_stub.dart

typedef ViewFactory = dynamic Function(int viewId);

void registerWebViewFactory(String viewId, ViewFactory cb) {
  // No-op on non-web
}