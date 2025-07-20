// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:webrtc_streaming_test/main.dart';

void main() {
  testWidgets('WebRTC Streaming App launches correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const WebRTCStreamingApp());

    // Verify that our app title is correct.
    expect(find.text('WebRTC Streaming Test'), findsOneWidget);
    expect(find.text('WebRTC Streaming Test App'), findsOneWidget);

    // Verify that the video camera icon is present.
    expect(find.byIcon(Icons.videocam), findsOneWidget);

    // Verify the main description text.
    expect(find.text('Test WebRTC streaming capabilities'), findsOneWidget);
  });

  testWidgets('App has required buttons', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const WebRTCStreamingApp());

    // Wait for the widget to settle
    await tester.pumpAndSettle();

    // Look for either the Start WebRTC Test button or Check Permissions button text
    final hasStartButton = find.text('Start WebRTC Test').evaluate().isNotEmpty;
    final hasCheckButton = find.text('Check Permissions').evaluate().isNotEmpty;
    
    // At least one of these buttons should be present
    expect(hasStartButton || hasCheckButton, isTrue);
  });
}
