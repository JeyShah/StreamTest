import 'package:flutter/material.dart';
import 'hls_player_page.dart';
import 'locator.dart';
import 'video_player_wrapper.dart';

void main() {
  setupLocator();
  VideoPlayerWrapper.register(); // Safe across all platforms
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HLSPlayerPage(),
  ));
}