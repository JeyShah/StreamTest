import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
        'simNumber': config.simNumber,
        'webrtcUrl': config.webrtcSignalingUrl,
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

    // Test 3: WebSocket connectivity test
    await _testWebSocketConnectivity(config, results['tests']);

    // Test 4: Check for alternative ports
    await _testAlternativePorts(config, results['tests']);

    // Test 5: Check if RTMP might be expected instead
    await _testRTMPConnectivity(config, results['tests']);

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
    final test = {
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
      test['httpStatus'] = response.statusCode;
      test['headers'] = <String, String>{};
      response.headers.forEach((name, values) {
        test['headers'][name] = values.join(', ');
      });
      
      client.close();
    } catch (e) {
      test['status'] = 'failed';
      test['error'] = e.toString();
    }
    
    test['endTime'] = DateTime.now().toIso8601String();
  }

  static Future<void> _testWebSocketConnectivity(
    StreamConfig config, 
    Map<String, dynamic> tests
  ) async {
    final test = {
      'status': 'testing',
      'startTime': DateTime.now().toIso8601String(),
      'url': config.webrtcSignalingUrl,
    };
    tests['WebSocket Connection'] = test;

    try {
      final uri = Uri.parse(config.webrtcSignalingUrl);
      test['parsedUri'] = uri.toString();
      test['scheme'] = uri.scheme;
      test['host'] = uri.host;
      test['port'] = uri.port;
      test['path'] = uri.path;

      // Attempt WebSocket connection with timeout
      final channel = WebSocketChannel.connect(uri);
      
      // Set up a timer for timeout
      bool completed = false;
      Timer(const Duration(seconds: 10), () {
        if (!completed) {
          test['status'] = 'timeout';
          test['error'] = 'WebSocket connection timed out after 10 seconds';
          channel.sink.close(status.normalClosure);
        }
      });

      // Try to establish connection
      await channel.ready.timeout(const Duration(seconds: 10));
      
      completed = true;
      test['status'] = 'success';
      test['message'] = 'WebSocket connection established successfully';
      
      // Send a test message
      channel.sink.add(jsonEncode({
        'type': 'test',
        'simNumber': config.simNumber,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      }));
      
      // Close the connection
      await channel.sink.close(status.normalClosure);
      
    } catch (e) {
      test['status'] = 'failed';
      test['error'] = e.toString();
      
      // Analyze the error type
      if (e.toString().contains('Connection refused')) {
        test['errorType'] = 'connection_refused';
        test['diagnosis'] = 'Server is not accepting connections on port ${config.inputPort}';
      } else if (e.toString().contains('Failed to connect WebSocket')) {
        test['errorType'] = 'websocket_handshake_failed';
        test['diagnosis'] = 'Server does not support WebSocket protocol';
      } else if (e.toString().contains('Empty reply from server')) {
        test['errorType'] = 'no_response';
        test['diagnosis'] = 'Server is not running WebSocket service on this port';
      } else {
        test['errorType'] = 'unknown';
        test['diagnosis'] = 'Unknown WebSocket connection error';
      }
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
    final test = {
      'status': 'testing',
      'startTime': DateTime.now().toIso8601String(),
    };
    tests['RTMP Server Check'] = test;

    try {
      // Test RTMP port (usually 1935)
      final socket = await Socket.connect(config.inputHost, 1935, timeout: const Duration(seconds: 5));
      socket.destroy();
      
      test['status'] = 'success';
      test['message'] = 'RTMP port (1935) is accessible';
      test['recommendation'] = 'Your server might expect RTMP instead of WebRTC';
    } catch (e) {
      test['status'] = 'failed';
      test['error'] = e.toString();
      test['message'] = 'RTMP port (1935) is not accessible';
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