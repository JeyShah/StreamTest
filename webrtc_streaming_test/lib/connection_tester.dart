import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'stream_config.dart';

class ConnectionTester {
  static Future<Map<String, dynamic>> testServerConnectivity(StreamConfig config) async {
    final results = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'config': {
        'inputHost': config.inputHost,
        'inputPort': config.inputPort,
        'outputHost': config.outputHost,
        'outputPort': config.outputPort,
        'streamKey': config.streamKey,
        'rtmpUrl': config.rtmpStreamUrl,
        'outputUrl': config.outputUrl,
      },
      'tests': <String, dynamic>{},
      'recommendations': <String>[],
    };

    // Test 1: Basic HTTP connectivity to input server
    await _testHttpConnectivity(
      config.inputHost, 
      config.inputPort, 
      'Input Server HTTP', 
      results['tests']
    );

    // Test 2: Basic HTTP connectivity to output server
    await _testHttpConnectivity(
      config.outputHost, 
      config.outputPort, 
      'Output Server HTTP', 
      results['tests']
    );

    // Test 3: RTMP connectivity test
    await _testRTMPConnectivity(config, results['tests']);

    // Test 4: Check for alternative ports
    await _testAlternativePorts(config, results['tests']);

    // Test 4: Test alternative HTTP paths for RTMP
    await _testRTMPHTTPPaths(config, results['tests']);

    // Generate recommendations
    _generateRecommendations(results);

    return results;
  }

  static Future<void> _testHttpConnectivity(
    String host, 
    int port, 
    String testName, 
    Map<String, dynamic> tests
  ) async {
    final test = <String, dynamic>{
      'status': 'testing',
      'startTime': DateTime.now().toIso8601String(),
    };
    tests[testName] = test;

    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 5);
      
      final request = await client.openUrl('GET', Uri.parse('http://$host:$port'));
      final response = await request.close();
      
             test['status'] = 'success';
       test['httpStatus'] = response.statusCode.toString();
       final headers = <String, String>{};
       response.headers.forEach((name, values) {
         headers[name] = values.join(', ');
       });
       test['headers'] = headers;
      
      client.close();
    } catch (e) {
      test['status'] = 'failed';
      test['error'] = e.toString();
    }
    
    test['endTime'] = DateTime.now().toIso8601String();
  }

  

  static Future<void> _testAlternativePorts(
    StreamConfig config, 
    Map<String, dynamic> tests
  ) async {
    final alternativePorts = [8080, 9000, 3000, 4000, 5000];
    
    for (final port in alternativePorts) {
      if (port == config.inputPort) continue; // Skip the port we already tested
      
      final testName = 'Alternative Port $port';
      await _testHttpConnectivity(config.inputHost, port, testName, tests);
    }
  }

  static Future<void> _testRTMPConnectivity(
    StreamConfig config, 
    Map<String, dynamic> tests
  ) async {
    final test = <String, dynamic>{
      'status': 'testing',
      'startTime': DateTime.now().toIso8601String(),
      'url': config.rtmpStreamUrl,
    };
    tests['RTMP Server Connection'] = test;

    try {
      // Test RTMP port connectivity
      final socket = await Socket.connect(config.inputHost, config.inputPort, timeout: const Duration(seconds: 5));
      socket.destroy();
      
      test['status'] = 'success';
      test['message'] = 'RTMP server is accessible on port ${config.inputPort}';
      test['rtmpUrl'] = config.rtmpStreamUrl;
      test['recommendation'] = 'Server ready for RTMP streaming';
    } catch (e) {
      test['status'] = 'failed';
      test['error'] = e.toString();
      test['message'] = 'RTMP server not accessible on port ${config.inputPort}';
      
      // Try standard RTMP port 1935 if different
      if (config.inputPort != 1935) {
        try {
          final socket1935 = await Socket.connect(config.inputHost, 1935, timeout: const Duration(seconds: 5));
          socket1935.destroy();
          test['alternativePort'] = 1935;
          test['recommendation'] = 'RTMP server might be on standard port 1935 instead of ${config.inputPort}';
        } catch (e1935) {
          test['port1935Error'] = e1935.toString();
        }
      }
    }
    
    test['endTime'] = DateTime.now().toIso8601String();
  }

  static Future<void> _testRTMPHTTPPaths(
    StreamConfig config, 
    Map<String, dynamic> tests
  ) async {
    final test = <String, dynamic>{
      'status': 'testing',
      'startTime': DateTime.now().toIso8601String(),
    };
    tests['RTMP HTTP Paths'] = test;

    try {
      // Test different RTMP path structures
      final testPaths = [
        '/hls/${config.streamKey}',
        '/live/${config.streamKey}',
        '/stream/${config.streamKey}',
        '/${config.streamKey}',
      ];

      final workingPaths = <String>[];
      
      for (final path in testPaths) {
        try {
          final testUrl = 'http://${config.inputHost}:${config.outputPort}$path';
          final client = HttpClient();
          client.connectionTimeout = const Duration(seconds: 3);
          
          final request = await client.openUrl('GET', Uri.parse(testUrl));
          final response = await request.close();
          
          if (response.statusCode < 500) {
            workingPaths.add(path);
          }
          
          client.close();
        } catch (e) {
          // Path not working, continue
        }
      }

      if (workingPaths.isNotEmpty) {
        test['status'] = 'success';
        test['workingPaths'] = workingPaths;
        test['message'] = 'Found working RTMP paths: ${workingPaths.join(', ')}';
      } else {
        test['status'] = 'info';
        test['message'] = 'No HTTP paths responded (normal for RTMP-only server)';
      }
      
    } catch (e) {
      test['status'] = 'failed';
      test['error'] = e.toString();
    }
    
    test['endTime'] = DateTime.now().toIso8601String();
  }

  static void _generateRecommendations(Map<String, dynamic> results) {
    final tests = results['tests'] as Map<String, dynamic>;
    final recommendations = results['recommendations'] as List<String>;
    
    final wsTest = tests['WebSocket Connection'];
    final inputHttpTest = tests['Input Server HTTP'];
    final outputHttpTest = tests['Output Server HTTP'];
    final rtmpTest = tests['RTMP Server Check'];

    // WebSocket specific recommendations
    if (wsTest['status'] == 'failed') {
      if (wsTest['errorType'] == 'connection_refused') {
        recommendations.add('❌ Server is not accepting connections on port ${results['config']['inputPort']}');
        recommendations.add('💡 Check if your WebSocket server is running');
        recommendations.add('💡 Verify firewall settings allow port ${results['config']['inputPort']}');
      } else if (wsTest['errorType'] == 'websocket_handshake_failed') {
        recommendations.add('❌ Server does not support WebSocket protocol');
        recommendations.add('💡 Your server might expect regular HTTP instead of WebSocket');
        recommendations.add('💡 Check if server supports WebSocket upgrade headers');
      } else if (wsTest['errorType'] == 'no_response') {
        recommendations.add('❌ No WebSocket service running on port ${results['config']['inputPort']}');
        recommendations.add('💡 Server might be running a different service (HTTP, RTMP, etc.)');
      }
    }

    // HTTP connectivity recommendations
    if (inputHttpTest['status'] == 'success') {
      recommendations.add('✅ Input server is reachable via HTTP');
      if (wsTest['status'] == 'failed') {
        recommendations.add('💡 Try using HTTP API instead of WebSocket for media streaming');
      }
    }

    if (outputHttpTest['status'] == 'success') {
      recommendations.add('✅ Output server is reachable and responding');
    }

    // RTMP recommendations
    if (rtmpTest['status'] == 'success') {
      recommendations.add('✅ RTMP port is accessible - server might expect RTMP protocol');
      recommendations.add('💡 Consider switching to RTMP streaming instead of WebRTC');
    }

    // Alternative port recommendations
    final alternativeWorkingPorts = <int>[];
    tests.forEach((testName, testResult) {
      if (testName.startsWith('Alternative Port') && testResult['status'] == 'success') {
        final port = int.tryParse(testName.replaceAll('Alternative Port ', ''));
        if (port != null) {
          alternativeWorkingPorts.add(port);
        }
      }
    });

    if (alternativeWorkingPorts.isNotEmpty) {
      recommendations.add('✅ Alternative ports available: ${alternativeWorkingPorts.join(', ')}');
      recommendations.add('💡 Try using one of these ports instead of ${results['config']['inputPort']}');
    }

    // Overall recommendations
    if (wsTest['status'] == 'failed' && inputHttpTest['status'] == 'success') {
      recommendations.add('');
      recommendations.add('🔧 SUGGESTED SOLUTIONS:');
      recommendations.add('1. Check if your server supports WebSocket connections');
      recommendations.add('2. Verify server expects WebSocket on port ${results['config']['inputPort']}');
      recommendations.add('3. Consider implementing HTTP-based streaming instead');
      recommendations.add('4. Check server documentation for correct protocol');
    }
  }

  static String formatResults(Map<String, dynamic> results) {
    final buffer = StringBuffer();
    
    buffer.writeln('🔍 CONNECTION DIAGNOSTICS REPORT');
    buffer.writeln('=' * 50);
    buffer.writeln('Timestamp: ${results['timestamp']}');
    buffer.writeln();
    
    // Configuration
    buffer.writeln('📋 CONFIGURATION:');
    final config = results['config'];
    buffer.writeln('• Input Server: ${config['inputHost']}:${config['inputPort']}');
    buffer.writeln('• Output Server: ${config['outputHost']}:${config['outputPort']}');
    buffer.writeln('• SIM Number: ${config['simNumber']}');
    buffer.writeln('• WebSocket URL: ${config['webrtcUrl']}');
    buffer.writeln('• Output URL: ${config['outputUrl']}');
    buffer.writeln();
    
    // Test Results
    buffer.writeln('🧪 TEST RESULTS:');
    final tests = results['tests'] as Map<String, dynamic>;
    tests.forEach((testName, testResult) {
      final status = testResult['status'];
      final emoji = status == 'success' ? '✅' : status == 'failed' ? '❌' : '⏳';
      buffer.writeln('$emoji $testName: ${status.toUpperCase()}');
      
      if (testResult['error'] != null) {
        buffer.writeln('   Error: ${testResult['error']}');
      }
      if (testResult['diagnosis'] != null) {
        buffer.writeln('   Diagnosis: ${testResult['diagnosis']}');
      }
      if (testResult['message'] != null) {
        buffer.writeln('   ${testResult['message']}');
      }
    });
    buffer.writeln();
    
    // Recommendations
    buffer.writeln('💡 RECOMMENDATIONS:');
    final recommendations = results['recommendations'] as List<String>;
    for (final recommendation in recommendations) {
      if (recommendation.isEmpty) {
        buffer.writeln();
      } else {
        buffer.writeln('   $recommendation');
      }
    }
    
    return buffer.toString();
  }
}