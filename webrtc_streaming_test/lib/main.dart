import 'package:flutter/material.dart';
import 'hls_player_page.dart';

void main() {
  runApp(const HLSPlayerApp());
}

class HLSPlayerApp extends StatelessWidget {
  const HLSPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HLS Video Player',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HLSPlayerPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
