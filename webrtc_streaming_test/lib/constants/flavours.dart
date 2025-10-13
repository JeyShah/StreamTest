import '../config.dart';

class FlavorConfig {
  // Use the centralized AppConfig for app type
  static int get appType => AppConfig.currentAppType;

  static const List<String> appLogos = [
    "assets/gpsinaLogo.png",
    "assets/xtrackLogo.png",
    "assets/startrackLogo.png",
    "assets/soundstreamLogo.png",
  ];

  // Use the centralized configuration for current logo
  static String get currentAppLogo => AppConfig.logoAsset;
  
  // Keep backward compatibility
  static String getAppLogo(int type) => appLogos[type];
}