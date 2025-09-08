class FlavorConfig {
  static const int appType = 3; // 0 = Gpsina, 1 = Xtrack, 2 = Startrack

  static const List<String> appLogos = [
    "assets/gpsinaLogo.png",
    "assets/xtrackLogo.png",
    "assets/startrackLogo.png",
    "assets/soundstreamLogo.png",
  ];

  static String get currentAppLogo => appLogos[appType];
}