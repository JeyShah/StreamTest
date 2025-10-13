// Example file showing how to use the new configuration system
import 'package:flutter/material.dart';
import 'config.dart';
import 'config_helper.dart';

/// Example Widget showing how to use AppConfig in your Flutter widgets
class ConfigExampleWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${AppConfig.appName} v${AppConfig.version}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display app logo
            Center(
              child: Image.asset(
                AppConfig.logoAsset,
                width: 200,
                height: 100,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 20),
            
            // Configuration information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Configuration',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 10),
                    _buildConfigRow('App Name:', AppConfig.appName),
                    _buildConfigRow('Version:', AppConfig.version),
                    _buildConfigRow('App Type:', AppConfig.appType.toString()),
                    _buildConfigRow('Environment:', AppConfig.currentEnvironment.name),
                    _buildConfigRow('API URL:', AppConfig.apiUrl),
                    _buildConfigRow('Socket URL:', AppConfig.socketUrl),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            // Configuration validation
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Configuration Status',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 10),
                    _buildValidationStatus(),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            // Available whitelabels
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available WhiteLabels',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 10),
                    ...AppConfig.allWhiteLabels.map((config) => 
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: config.appType == AppConfig.currentAppType 
                                    ? Colors.green 
                                    : Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text('${config.name} (v${config.version})'),
                          ],
                        ),
                      )
                    ).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationStatus() {
    final validation = ConfigHelper.validateConfiguration();
    
    if (validation.isValid) {
      return Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green),
          SizedBox(width: 8),
          Text('Configuration is valid'),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 8),
              Text('Configuration has issues:'),
            ],
          ),
          ...validation.issues.map((issue) => 
            Padding(
              padding: const EdgeInsets.only(left: 32.0, top: 4.0),
              child: Text('• $issue', style: TextStyle(color: Colors.red)),
            )
          ).toList(),
        ],
      );
    }
  }
}

/// Example of how to use configuration in API services
class ExampleApiService {
  static String get baseUrl => AppConfig.apiUrl;
  static String get socketUrl => AppConfig.socketUrl;
  static String get installerUrl => AppConfig.installerApiUrl;
  
  // Example API call
  static Future<Map<String, dynamic>> makeApiCall(String endpoint) async {
    final url = '$baseUrl$endpoint';
    print('Making API call to: $url');
    
    // Add your HTTP client code here
    // Example:
    // final response = await http.get(Uri.parse(url));
    // return json.decode(response.body);
    
    return {'status': 'success', 'url': url};
  }
  
  // Example WebSocket connection
  static Future<void> connectWebSocket() async {
    print('Connecting to WebSocket: $socketUrl');
    
    // Add your WebSocket connection code here
    // Example:
    // final channel = WebSocketChannel.connect(Uri.parse(socketUrl));
  }
}

/// Example of how to use Google Maps API
class ExampleMapsService {
  static String get apiKey => AppConfig.googleApiKey;
  
  static Future<void> initializeMaps() async {
    print('Initializing Google Maps with API key: ${apiKey.substring(0, 10)}...');
    
    // Add your Google Maps initialization code here
  }
}