# Flutter WhiteLabel Configuration System

This Flutter project has been converted from JavaScript config.js to a comprehensive Dart configuration system that supports multiple whitelabels and environments.

## Overview

The configuration system supports:
- **4 WhiteLabels**: GPSINA, XTRACK, STARTRACK, SOUNDSTREAM
- **4 Environments**: Production, Staging, Development, Local
- **Centralized Configuration**: All settings in one place
- **Type Safety**: Full Dart type checking
- **Validation**: Configuration validation with error reporting

## Files Structure

```
lib/
├── config.dart                 # Main configuration file
├── config_helper.dart          # Helper utilities and theme support
├── config_usage_example.dart   # Usage examples
└── constants/
    └── flavours.dart           # Updated to use centralized config
```

## Quick Start

### 1. Switching WhiteLabels

Edit `lib/config.dart` and change the `currentAppType`:

```dart
// Change this line to switch whitelabels
static const int currentAppType = GPSINA;  // 0=GPSINA, 1=XTRACK, 2=STARTRACK, 3=SOUNDSTREAM
```

### 2. Switching Environments

Edit `lib/config.dart` and change the `currentEnvironment`:

```dart
// Change this line to switch environments
static const Environment currentEnvironment = Environment.production;
```

### 3. Using Configuration in Your Code

```dart
import 'config.dart';

// Get current app information
String appName = AppConfig.appName;          // "GPSINA", "XTRACK", etc.
String version = AppConfig.version;          // "3.0.56", etc.
String apiUrl = AppConfig.apiUrl;            // Current environment API URL
String socketUrl = AppConfig.socketUrl;      // Current environment Socket URL

// Get Google API Key
String googleKey = AppConfig.googleApiKey;

// Get logo asset
String logo = AppConfig.logoAsset;           // "assets/gpsinaLogo.png", etc.
```

## Configuration Details

### WhiteLabel Configurations

| WhiteLabel  | App Type | Version | Google API Key (partial)          | Logo Asset                |
|-------------|----------|---------|-----------------------------------|---------------------------|
| GPSINA      | 0        | 3.0.56  | AIzaSyCXpBbmHe03lJIZq2FmzR51... | assets/gpsinaLogo.png     |
| XTRACK      | 1        | 3.0.39  | AIzaSyAXirFoyVPJ8PukzAO2qXdK... | assets/xtrackLogo.png     |
| STARTRACK   | 2        | 3.0.14  | AIzaSyAwPn0hJUpwiZhoIk7x2G3X... | assets/startrackLogo.png  |
| SOUNDSTREAM | 3        | 3.0.18  | AIzaSyAxOw4_wsjwoNJzfjxuT6sc... | assets/soundstreamLogo.png|

### Environment Configurations

| Environment | API URL                                    | Socket URL                               |
|-------------|-------------------------------------------|------------------------------------------|
| Production  | https://api2tt.gpsina.com/api/           | wss://mobilecommunicator.gpsina.com:8000 |
| Staging     | https://apistg.gpsina.com/api/           | ws://gpnlbstg.gpsina.com:8000            |
| Development | http://192.168.1.110:8080/api/           | ws://192.168.1.110:8000                  |
| Local       | http://gpsinalocalsock.ddns.net:8080/api/| ws://gpsinalocalsock.ddns.net:8000       |

## Advanced Features

### Configuration Validation

```dart
import 'config_helper.dart';

final validation = ConfigHelper.validateConfiguration();
if (!validation.isValid) {
  print('Issues: ${validation.issues}');
}
```

### Theme Support

The system includes automatic theme generation based on whitelabel:

```dart
import 'config_helper.dart';

final theme = ConfigHelper.theme;
// Automatic colors: GPSINA=Blue, XTRACK=Green, STARTRACK=Red, SOUNDSTREAM=Purple
```

### Debug Information

```dart
import 'config_helper.dart';

// Print current configuration
print(ConfigHelper.getCurrentConfigInfo());

// Get debug map
Map<String, dynamic> debugInfo = ConfigHelper.getDebugConfig();
```

## Build Configuration

### For Different WhiteLabels

You can create different build configurations for each whitelabel:

1. **Create flavor-specific config files** (optional):
   - `lib/config_gpsina.dart`
   - `lib/config_xtrack.dart`
   - etc.

2. **Use build arguments** to set the configuration at build time.

3. **Environment variables** can be used to switch configurations.

### Android Build Flavors

Add to `android/app/build.gradle`:

```gradle
android {
    flavorDimensions "app"
    productFlavors {
        gpsina {
            dimension "app"
            applicationId "com.gpsina.app"
            resValue "string", "app_name", "GPSINA"
        }
        xtrack {
            dimension "app"
            applicationId "com.xtrack.app"
            resValue "string", "app_name", "XTRACK"
        }
        startrack {
            dimension "app"
            applicationId "com.startrack.app"
            resValue "string", "app_name", "STARTRACK"
        }
        soundstream {
            dimension "app"
            applicationId "com.soundstream.app"
            resValue "string", "app_name", "SOUNDSTREAM"
        }
    }
}
```

## Migration from JavaScript config.js

The original JavaScript config:

```javascript
const Config = {
  version: "3.0.56",
  google_api_key: 'AIzaSyCXpBbmHe03lJIZq2FmzR51YeniR1dsBgs',
  appType: 0,
  et_api_url: 'https://api2tt.gpsina.com/api/',
  // ... other settings
};
```

Is now:

```dart
// Access the same values
String version = AppConfig.version;                    // "3.0.56"
String googleApiKey = AppConfig.googleApiKey;          // Google API key
int appType = AppConfig.appType;                       // 0
String apiUrl = AppConfig.apiUrl;                      // API URL
```

## Common Usage Patterns

### API Service

```dart
class ApiService {
  static String get baseUrl => AppConfig.apiUrl;
  
  Future<Response> get(String endpoint) async {
    return http.get(Uri.parse('$baseUrl$endpoint'));
  }
}
```

### WebSocket Service

```dart
class SocketService {
  static String get socketUrl => AppConfig.socketUrl;
  
  void connect() {
    final channel = WebSocketChannel.connect(Uri.parse(socketUrl));
  }
}
```

### Google Maps

```dart
class MapsService {
  static String get apiKey => AppConfig.googleApiKey;
  
  void initializeMaps() {
    GoogleMap(
      // Use the API key
    );
  }
}
```

## Troubleshooting

### Configuration Issues

1. **Missing API Key**: Check that `googleApiKey` is not empty
2. **Invalid URLs**: Ensure API and Socket URLs are properly formatted
3. **Wrong App Type**: Verify `currentAppType` matches your intended whitelabel

### Build Issues

1. **Import Errors**: Make sure to import `'config.dart'` in files using the configuration
2. **Asset Errors**: Verify logo assets exist in the `assets/` folder
3. **Type Errors**: The new system is type-safe, so fix any type mismatches

## Future Enhancements

- **Remote Configuration**: Load configuration from remote server
- **Feature Flags**: Add per-whitelabel feature toggles
- **A/B Testing**: Support for different configuration variants
- **Configuration UI**: Admin panel for changing configurations
- **Encrypted Keys**: Secure storage of sensitive configuration data

## Support

If you encounter any issues with the configuration system, check:

1. Configuration validation output
2. Debug information in console
3. Asset file existence
4. Import statements