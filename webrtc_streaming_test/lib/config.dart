/// App Configuration for WhiteLabel Support
/// Supports: GPSINA, XTRACK, STARTRACK, SOUNDSTREAM
class AppConfig {
  // App Types
  static const int GPSINA = 0;
  static const int XTRACK = 1;
  static const int STARTRACK = 2;
  static const int SOUNDSTREAM = 3;

  // Current active configuration - change this to switch whitelabels
  static const int currentAppType = GPSINA;

  // WhiteLabel Configurations
  static const Map<int, WhiteLabelConfig> _whiteLabelConfigs = {
    GPSINA: WhiteLabelConfig(
      appType: GPSINA,
      name: 'GPSINA',
      version: '3.0.56',
      googleApiKey: 'AIzaSyCXpBbmHe03lJIZq2FmzR51YeniR1dsBgs',
      logoAsset: 'assets/gpsinaLogo.png',
    ),
    XTRACK: WhiteLabelConfig(
      appType: XTRACK,
      name: 'XTRACK',
      version: '3.0.39',
      googleApiKey: 'AIzaSyAXirFoyVPJ8PukzAO2qXdK6IbL-XeW2wc',
      logoAsset: 'assets/xtrackLogo.png',
    ),
    STARTRACK: WhiteLabelConfig(
      appType: STARTRACK,
      name: 'STARTRACK',
      version: '3.0.14',
      googleApiKey: 'AIzaSyAwPn0hJUpwiZhoIk7x2G3XbcrjAyqZSMQ',
      logoAsset: 'assets/startrackLogo.png',
    ),
    SOUNDSTREAM: WhiteLabelConfig(
      appType: SOUNDSTREAM,
      name: 'SOUNDSTREAM',
      version: '3.0.18',
      googleApiKey: 'AIzaSyAxOw4_wsjwoNJzfjxuT6sc5I17I9DJ1O8',
      logoAsset: 'assets/soundstreamLogo.png',
    ),
  };

  // Environment Configurations
  static const Map<Environment, ServerEnvironmentConfig> _environmentConfigs = {
    Environment.production: ServerEnvironmentConfig(
      apiUrl: 'https://api2tt.gpsina.com/api/',
      socketUrl: 'wss://mobilecommunicator.gpsina.com:8000',
      installerApiUrl: 'https://installer-app.gpsina.com/api/',
    ),
    Environment.staging: ServerEnvironmentConfig(
      apiUrl: 'https://apistg.gpsina.com/api/',
      socketUrl: 'ws://gpnlbstg.gpsina.com:8000',
      installerApiUrl: 'https://webst.gpsina.com/api/',
    ),
    Environment.development: ServerEnvironmentConfig(
      apiUrl: 'http://192.168.1.110:8080/api/',
      socketUrl: 'ws://192.168.1.110:8000',
      installerApiUrl: 'http://192.168.1.110:8080/api/',
    ),
    Environment.local: ServerEnvironmentConfig(
      apiUrl: 'http://gpsinalocalsock.ddns.net:8080/api/',
      socketUrl: 'ws://gpsinalocalsock.ddns.net:8000',
      installerApiUrl: 'http://gpsinalocalsock.ddns.net:8080/api/',
    ),
  };

  // Current environment - change this to switch environments
  static const Environment currentEnvironment = Environment.production;

  // Common Settings
  static const String fcmKey = "testFcmKey";
  static const bool isCorporate = false;
  static const int notificationDaysBeforeDeviceExpire = 30;
  static const bool justLogin = false;
  static const int backgroundWaitTime = 60000; // 1 minute
  static const bool dev = false;

  // Getters for current configuration
  static WhiteLabelConfig get currentWhiteLabel => _whiteLabelConfigs[currentAppType]!;
  static ServerEnvironmentConfig get currentEnvironment => _environmentConfigs[AppConfig.currentEnvironment]!;

  // Convenience getters
  static String get version => currentWhiteLabel.version;
  static String get googleApiKey => currentWhiteLabel.googleApiKey;
  static int get appType => currentWhiteLabel.appType;
  static String get appName => currentWhiteLabel.name;
  static String get logoAsset => currentWhiteLabel.logoAsset;

  static String get apiUrl => currentEnvironment.apiUrl;
  static String get socketUrl => currentEnvironment.socketUrl;
  static String get installerApiUrl => currentEnvironment.installerApiUrl;

  // Utility methods
  static WhiteLabelConfig getWhiteLabelConfig(int appType) {
    return _whiteLabelConfigs[appType] ?? _whiteLabelConfigs[GPSINA]!;
  }

  static ServerEnvironmentConfig getEnvironmentConfig(Environment environment) {
    return _environmentConfigs[environment] ?? _environmentConfigs[Environment.production]!;
  }

  static List<WhiteLabelConfig> get allWhiteLabels => _whiteLabelConfigs.values.toList();
  static List<String> get allWhiteLabelNames => _whiteLabelConfigs.values.map((config) => config.name).toList();

  // Configuration validation
  static bool isValidConfiguration() {
    final whiteLabel = currentWhiteLabel;
    final environment = currentEnvironment;
    
    return whiteLabel.googleApiKey.isNotEmpty &&
           whiteLabel.version.isNotEmpty &&
           environment.apiUrl.isNotEmpty &&
           environment.socketUrl.isNotEmpty;
  }

  // Debug information
  static Map<String, dynamic> toDebugMap() {
    return {
      'currentAppType': currentAppType,
      'appName': appName,
      'version': version,
      'environment': AppConfig.currentEnvironment.name,
      'apiUrl': apiUrl,
      'socketUrl': socketUrl,
      'googleApiKey': '${googleApiKey.substring(0, 10)}...',
      'isValidConfiguration': isValidConfiguration(),
    };
  }
}

/// WhiteLabel Configuration Class
class WhiteLabelConfig {
  final int appType;
  final String name;
  final String version;
  final String googleApiKey;
  final String logoAsset;

  const WhiteLabelConfig({
    required this.appType,
    required this.name,
    required this.version,
    required this.googleApiKey,
    required this.logoAsset,
  });

  @override
  String toString() => 'WhiteLabelConfig(name: $name, version: $version, appType: $appType)';
}

/// Server Environment Configuration Class
class ServerEnvironmentConfig {
  final String apiUrl;
  final String socketUrl;
  final String installerApiUrl;

  const ServerEnvironmentConfig({
    required this.apiUrl,
    required this.socketUrl,
    required this.installerApiUrl,
  });

  @override
  String toString() => 'ServerEnvironmentConfig(apiUrl: $apiUrl)';
}

/// Environment Enum
enum Environment {
  production,
  staging,
  development,
  local;

  String get name {
    switch (this) {
      case Environment.production:
        return 'Production';
      case Environment.staging:
        return 'Staging';
      case Environment.development:
        return 'Development';
      case Environment.local:
        return 'Local';
    }
  }
}