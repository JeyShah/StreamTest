import 'package:flutter/material.dart';
import 'hls_player_page.dart';
import 'splash_screen.dart';
import 'locator.dart';
import 'video_player_wrapper.dart';
import 'config.dart';
import 'config_helper.dart';

void main() {
  // Validate configuration before starting the app
  final validation = ConfigHelper.validateConfiguration();
  if (!validation.isValid) {
    print('Configuration issues: ${validation.issues}');
  }
  
  // Print current configuration in debug mode
  if (AppConfig.dev) {
    print(ConfigHelper.getCurrentConfigInfo());
  }
  
  setupLocator();
  VideoPlayerWrapper.register(); // Safe across all platforms
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = ConfigHelper.theme;
    
    return MaterialApp(
      title: theme.appName,
      debugShowCheckedModeBanner: AppConfig.dev,
      theme: ThemeData(
        primarySwatch: MaterialColor(
          theme.colors.primary,
          _createMaterialColorSwatch(theme.colors.primary),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // home: SplashScreen(),
      home: HLSPlayerPage(),
    );
  }

  // Helper method to create MaterialColor swatch
  Map<int, Color> _createMaterialColorSwatch(int primaryColor) {
    final color = Color(primaryColor);
    return {
      50: color.withOpacity(0.1),
      100: color.withOpacity(0.2),
      200: color.withOpacity(0.3),
      300: color.withOpacity(0.4),
      400: color.withOpacity(0.5),
      500: color.withOpacity(0.6),
      600: color.withOpacity(0.7),
      700: color.withOpacity(0.8),
      800: color.withOpacity(0.9),
      900: color.withOpacity(1.0),
    };
  }
}