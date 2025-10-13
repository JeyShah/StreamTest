import 'config.dart';

/// Configuration Helper for easy access to app configurations
class ConfigHelper {
  /// Get the current app configuration as a formatted string
  static String getCurrentConfigInfo() {
    final config = AppConfig.toDebugMap();
    return '''
Current Configuration:
- App: ${config['appName']} (Type: ${config['currentAppType']})
- Version: ${config['version']}
- Environment: ${config['environment']}
- API URL: ${config['apiUrl']}
- Socket URL: ${config['socketUrl']}
- Valid Configuration: ${config['isValidConfiguration']}
''';
  }

  /// Check if we're in debug mode
  static bool get isDebug => AppConfig.dev;

  /// Check if we're in production
  static bool get isProduction => AppConfig.currentEnvironment == Environment.production;

  /// Get app-specific colors (you can customize these per whitelabel)
  static AppColors get colors {
    switch (AppConfig.currentAppType) {
      case AppConfig.GPSINA:
        return const AppColors(
          primary: 0xFF1976D2,  // Blue
          secondary: 0xFF424242,
          accent: 0xFF03DAC6,
        );
      case AppConfig.XTRACK:
        return const AppColors(
          primary: 0xFF388E3C,  // Green
          secondary: 0xFF424242,
          accent: 0xFF03DAC6,
        );
      case AppConfig.STARTRACK:
        return const AppColors(
          primary: 0xFFD32F2F,  // Red
          secondary: 0xFF424242,
          accent: 0xFF03DAC6,
        );
      case AppConfig.SOUNDSTREAM:
        return const AppColors(
          primary: 0xFF7B1FA2,  // Purple
          secondary: 0xFF424242,
          accent: 0xFF03DAC6,
        );
      default:
        return const AppColors(
          primary: 0xFF1976D2,
          secondary: 0xFF424242,
          accent: 0xFF03DAC6,
        );
    }
  }

  /// Get app-specific theme settings
  static AppTheme get theme {
    return AppTheme(
      appName: AppConfig.appName,
      logoAsset: AppConfig.logoAsset,
      colors: colors,
      useDarkMode: false, // You can make this configurable per whitelabel
    );
  }

  /// Validate current configuration
  static ConfigValidationResult validateConfiguration() {
    final issues = <String>[];
    
    if (AppConfig.googleApiKey.isEmpty) {
      issues.add('Google API Key is missing');
    }
    
    if (AppConfig.version.isEmpty) {
      issues.add('Version is missing');
    }
    
    if (AppConfig.apiUrl.isEmpty) {
      issues.add('API URL is missing');
    }
    
    if (AppConfig.socketUrl.isEmpty) {
      issues.add('Socket URL is missing');
    }

    return ConfigValidationResult(
      isValid: issues.isEmpty,
      issues: issues,
    );
  }

  /// Get configuration for debugging purposes
  static Map<String, dynamic> getDebugConfig() {
    return {
      ...AppConfig.toDebugMap(),
      'colors': {
        'primary': '0x${colors.primary.toRadixString(16).toUpperCase()}',
        'secondary': '0x${colors.secondary.toRadixString(16).toUpperCase()}',
        'accent': '0x${colors.accent.toRadixString(16).toUpperCase()}',
      },
      'theme': {
        'appName': theme.appName,
        'logoAsset': theme.logoAsset,
        'useDarkMode': theme.useDarkMode,
      },
    };
  }
}

/// App Colors Configuration
class AppColors {
  final int primary;
  final int secondary;
  final int accent;

  const AppColors({
    required this.primary,
    required this.secondary,
    required this.accent,
  });
}

/// App Theme Configuration
class AppTheme {
  final String appName;
  final String logoAsset;
  final AppColors colors;
  final bool useDarkMode;

  const AppTheme({
    required this.appName,
    required this.logoAsset,
    required this.colors,
    required this.useDarkMode,
  });
}

/// Configuration Validation Result
class ConfigValidationResult {
  final bool isValid;
  final List<String> issues;

  const ConfigValidationResult({
    required this.isValid,
    required this.issues,
  });

  @override
  String toString() {
    if (isValid) {
      return 'Configuration is valid';
    } else {
      return 'Configuration issues: ${issues.join(', ')}';
    }
  }
}