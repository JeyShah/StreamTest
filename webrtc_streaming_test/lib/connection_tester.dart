import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ConnectionTester {
  static Future<Map<String, dynamic>> testServerConnectivity({
    required String inputHost,
    required int inputPort,
    required String outputHost,
    required int outputPort,
    required String simNumber,
  }) async {
    Map<String, dynamic> results = {
      'inputServer': {'status': 'testing', 'message': ''},
      'outputServer': {'status': 'testing', 'message': ''},
      'outputStream': {'status': 'testing', 'message': ''},
      'overall': {'status': 'testing', 'message': ''},
    };

    try {
      // Test 1: Input Server Connectivity (Port Check)
      debugPrint('🔍 Testing input server connectivity...');
      results['inputServer'] = await _testInputServer(inputHost, inputPort);

      // Test 2: Output Server Connectivity (HTTP Check)
      debugPrint('🔍 Testing output server connectivity...');
      results['outputServer'] = await _testOutputServer(outputHost, outputPort);

      // Test 3: Specific Stream URL Check
      debugPrint('🔍 Testing stream output URL...');
      results['outputStream'] = await _testStreamUrl(outputHost, outputPort, simNumber);

      // Overall assessment
      results['overall'] = _assessOverallStatus(results);

    } catch (e) {
      debugPrint('❌ Error during connectivity test: $e');
      results['overall'] = {
        'status': 'error',
        'message': 'Test failed with error: $e'
      };
    }

    return results;
  }

  static Future<Map<String, dynamic>> _testInputServer(String host, int port) async {
    try {
      debugPrint('📡 Testing TCP connection to $host:$port...');
      
      // Try to establish a TCP connection to the input port
      Socket? socket;
      try {
        socket = await Socket.connect(host, port, timeout: const Duration(seconds: 5));
        await socket.close();
        
        return {
          'status': 'success',
          'message': '✅ Input server ($host:$port) is reachable and accepting connections'
        };
      } on SocketException catch (e) {
        String errorMsg = '';
        if (e.osError?.errorCode == 111 || e.osError?.errorCode == 10061) {
          errorMsg = '❌ Connection refused - Server may not be running on port $port';
        } else if (e.osError?.errorCode == 113 || e.osError?.errorCode == 10060) {
          errorMsg = '❌ Connection timeout - Server may be unreachable or firewalled';
        } else {
          errorMsg = '❌ Connection failed: ${e.message}';
        }
        
        return {
          'status': 'failed',
          'message': errorMsg
        };
      } finally {
        socket?.close();
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': '❌ Error testing input server: $e'
      };
    }
  }

  static Future<Map<String, dynamic>> _testOutputServer(String host, int port) async {
    try {
      debugPrint('🌐 Testing HTTP connection to $host:$port...');
      
      final response = await http.get(
        Uri.parse('http://$host:$port/'),
        headers: {'User-Agent': 'Flutter-WebRTC-Tester'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'status': 'success',
          'message': '✅ Output server ($host:$port) is accessible (HTTP ${response.statusCode})'
        };
      } else {
        return {
          'status': 'warning',
          'message': '⚠️ Output server responded with HTTP ${response.statusCode} - may still work for streaming'
        };
      }
    } on TimeoutException {
      return {
        'status': 'failed',
        'message': '❌ Output server timeout - Server may not be running on port $port'
      };
    } on SocketException catch (e) {
      return {
        'status': 'failed',
        'message': '❌ Cannot reach output server: ${e.message}'
      };
    } catch (e) {
      return {
        'status': 'warning',
        'message': '⚠️ Output server test inconclusive: $e'
      };
    }
  }

  static Future<Map<String, dynamic>> _testStreamUrl(String host, int port, String simNumber) async {
    try {
      debugPrint('📺 Testing stream URL for SIM: $simNumber...');
      
      final streamUrl = 'http://$host:$port/$simNumber/1.m3u8';
      final response = await http.head(
        Uri.parse(streamUrl),
        headers: {'User-Agent': 'Flutter-WebRTC-Tester'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'] ?? '';
        if (contentType.contains('application/vnd.apple.mpegurl') || 
            contentType.contains('application/x-mpegurl') ||
            contentType.contains('text/plain')) {
          return {
            'status': 'success',
            'message': '✅ Stream URL exists and returns HLS playlist'
          };
        } else {
          return {
            'status': 'warning',
            'message': '⚠️ Stream URL accessible but content type may be incorrect: $contentType'
          };
        }
      } else if (response.statusCode == 404) {
        return {
          'status': 'info',
          'message': '📡 Stream URL not found (404) - This is normal if no stream is currently active'
        };
      } else {
        return {
          'status': 'warning',
          'message': '⚠️ Stream URL returned HTTP ${response.statusCode}'
        };
      }
    } on TimeoutException {
      return {
        'status': 'failed',
        'message': '❌ Stream URL timeout'
      };
    } catch (e) {
      return {
        'status': 'info',
        'message': '📡 Stream URL test inconclusive (this is normal if no active stream): $e'
      };
    }
  }

  static Map<String, dynamic> _assessOverallStatus(Map<String, dynamic> results) {
    final inputStatus = results['inputServer']['status'];
    final outputStatus = results['outputServer']['status'];

    if (inputStatus == 'success' && (outputStatus == 'success' || outputStatus == 'warning')) {
      return {
        'status': 'ready',
        'message': '🎯 Server connectivity looks good! Ready for streaming.'
      };
    } else if (inputStatus == 'failed') {
      return {
        'status': 'input_failed',
        'message': '❌ Cannot connect to input server. Check if streaming server is running on port 1078.'
      };
    } else if (outputStatus == 'failed') {
      return {
        'status': 'output_failed',
        'message': '❌ Cannot connect to output server. Check if web server is running on port 8080.'
      };
    } else {
      return {
        'status': 'partial',
        'message': '⚠️ Some connectivity issues detected. Streaming may work but with limitations.'
      };
    }
  }

  static String getStatusIcon(String status) {
    switch (status) {
      case 'success':
      case 'ready':
        return '✅';
      case 'warning':
      case 'partial':
        return '⚠️';
      case 'failed':
      case 'input_failed':
      case 'output_failed':
        return '❌';
      case 'info':
        return '📡';
      case 'testing':
        return '🔍';
      default:
        return '❓';
    }
  }

  static Color getStatusColor(String status) {
    switch (status) {
      case 'success':
      case 'ready':
        return Colors.green;
      case 'warning':
      case 'partial':
        return Colors.orange;
      case 'failed':
      case 'input_failed':
      case 'output_failed':
        return Colors.red;
      case 'info':
        return Colors.blue;
      case 'testing':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}