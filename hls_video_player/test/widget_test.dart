// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:hls_video_player/main.dart';

void main() {
  testWidgets('HLS Video Player app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HLSVideoPlayerApp());

    // Verify that our app contains expected text.
    expect(find.text('HLS Video Player'), findsOneWidget);
    expect(find.text('Stream URL'), findsOneWidget);
    expect(find.text('Play Stream'), findsOneWidget);
  });
}
