import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'stream_config.dart';

// Import the global createPeerConnection function
import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc;

class WebRTCSignaling {
  late StreamConfig _config;
  WebSocketChannel? _channel;
  RTCPeerConnection? _peerConnection;
  
  // Callbacks
  Function(String)? onConnectionStateChanged;
  Function(String)? onSignalingStateChanged;
  Function(MediaStream)? onAddRemoteStream;
  Function(String)? onError;
  Function(String)? onMessage;

  WebRTCSignaling(StreamConfig config) {
    _config = config;
  }

  void updateConfig(StreamConfig config) {
    _config = config;
  }

  String get signalingUrl => _config.webrtcSignalingUrl;
  String get simNumber => _config.simNumber;

  Future<void> connect() async {
    try {
      debugPrint('🔗 Connecting to WebRTC signaling server: $signalingUrl');
      debugPrint('🔍 Parsed URI: ${Uri.parse(signalingUrl)}');
      debugPrint('🔍 URI scheme: ${Uri.parse(signalingUrl).scheme}');
      
      _channel = WebSocketChannel.connect(Uri.parse(signalingUrl));
      
      onMessage?.call('Connected to signaling server');
      onSignalingStateChanged?.call('connected');
      
      // Listen to WebSocket messages
      _channel!.stream.listen(
        (data) {
          _handleSignalingMessage(data);
        },
        onError: (error) {
          debugPrint('❌ WebSocket error: $error');
          onError?.call('WebSocket error: $error');
          onSignalingStateChanged?.call('error');
        },
        onDone: () {
          debugPrint('🔌 WebSocket connection closed');
          onSignalingStateChanged?.call('disconnected');
        },
      );

      // Send initial connection message with SIM number
      _sendSignalingMessage({
        'type': 'join',
        'simNumber': simNumber,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

    } catch (e) {
      debugPrint('❌ Failed to connect to signaling server: $e');
      onError?.call('Failed to connect: $e');
      onSignalingStateChanged?.call('error');
    }
  }

  Future<void> createPeerConnection(MediaStream localStream) async {
    try {
      
      final configuration = <String, dynamic>{
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'},
          {'urls': 'stun:stun1.l.google.com:19302'},
          {'urls': 'stun:stun2.l.google.com:19302'},
        ],
        'sdpSemantics': 'unified-plan',
      };

      _peerConnection = await webrtc.createPeerConnection(configuration);

      // Add local stream tracks
      localStream.getTracks().forEach((track) {
        _peerConnection!.addTrack(track, localStream);
      });

      // Set up event handlers
      _peerConnection!.onIceConnectionState = (RTCIceConnectionState state) {
        debugPrint('🧊 ICE Connection State: $state');
        onConnectionStateChanged?.call(state.toString().split('.').last);
      };

      _peerConnection!.onConnectionState = (RTCPeerConnectionState state) {
        debugPrint('🔗 Peer Connection State: $state');
        onConnectionStateChanged?.call(state.toString().split('.').last);
      };

      _peerConnection!.onTrack = (RTCTrackEvent event) {
        debugPrint('📺 Remote track added: ${event.track.kind}');
        if (event.streams.isNotEmpty) {
          onAddRemoteStream?.call(event.streams[0]);
        }
      };

      _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
        debugPrint('🧊 ICE Candidate: ${candidate.candidate}');
        _sendSignalingMessage({
          'type': 'ice-candidate',
          'candidate': candidate.toMap(),
          'simNumber': simNumber,
        });
      };

      onMessage?.call('Peer connection created');

    } catch (e) {
      debugPrint('❌ Failed to create peer connection: $e');
      onError?.call('Failed to create peer connection: $e');
    }
  }

  Future<void> createOffer() async {
    try {
      if (_peerConnection == null) {
        throw 'Peer connection not created';
      }

      debugPrint('📝 Creating WebRTC offer...');
      
      RTCSessionDescription offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);

      // Send offer to signaling server
      _sendSignalingMessage({
        'type': 'offer',
        'sdp': offer.toMap(),
        'simNumber': simNumber,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      onMessage?.call('Offer created and sent');
      debugPrint('✅ Offer sent for SIM: $simNumber');

    } catch (e) {
      debugPrint('❌ Failed to create offer: $e');
      onError?.call('Failed to create offer: $e');
    }
  }

  Future<void> _handleSignalingMessage(dynamic data) async {
    try {
      final message = jsonDecode(data);
      debugPrint('📨 Received signaling message: ${message['type']}');

      switch (message['type']) {
        case 'answer':
          await _handleAnswer(message['sdp']);
          break;
        case 'ice-candidate':
          await _handleIceCandidate(message['candidate']);
          break;
        case 'joined':
          onMessage?.call('Successfully joined room for SIM: ${message['simNumber']}');
          break;
        case 'error':
          onError?.call('Server error: ${message['message']}');
          break;
        case 'peer-connected':
          onMessage?.call('Remote peer connected');
          break;
        case 'peer-disconnected':
          onMessage?.call('Remote peer disconnected');
          break;
        default:
          debugPrint('🤷 Unknown message type: ${message['type']}');
      }
    } catch (e) {
      debugPrint('❌ Error handling signaling message: $e');
      onError?.call('Error handling message: $e');
    }
  }

  Future<void> _handleAnswer(Map<String, dynamic> sdpMap) async {
    try {
      RTCSessionDescription answer = RTCSessionDescription(
        sdpMap['sdp'],
        sdpMap['type'],
      );
      await _peerConnection!.setRemoteDescription(answer);
      onMessage?.call('Answer received and processed');
    } catch (e) {
      debugPrint('❌ Error handling answer: $e');
      onError?.call('Error handling answer: $e');
    }
  }

  Future<void> _handleIceCandidate(Map<String, dynamic> candidateMap) async {
    try {
      RTCIceCandidate candidate = RTCIceCandidate(
        candidateMap['candidate'],
        candidateMap['sdpMid'],
        candidateMap['sdpMLineIndex'],
      );
      await _peerConnection!.addCandidate(candidate);
    } catch (e) {
      debugPrint('❌ Error handling ICE candidate: $e');
    }
  }

  void _sendSignalingMessage(Map<String, dynamic> message) {
    if (_channel != null) {
      final jsonMessage = jsonEncode(message);
      _channel!.sink.add(jsonMessage);
      debugPrint('📤 Sent: ${message['type']} for SIM: ${message['simNumber']}');
    } else {
      debugPrint('❌ Cannot send message: WebSocket not connected');
      onError?.call('Cannot send message: Not connected to signaling server');
    }
  }

  Future<void> disconnect() async {
    try {
      // Send leave message
      if (_channel != null) {
        _sendSignalingMessage({
          'type': 'leave',
          'simNumber': simNumber,
        });
      }

      // Close WebSocket
      await _channel?.sink.close(status.goingAway);
      _channel = null;

      // Close peer connection
      await _peerConnection?.close();
      _peerConnection = null;

      onSignalingStateChanged?.call('disconnected');
      debugPrint('🔌 Disconnected from signaling server');

    } catch (e) {
      debugPrint('❌ Error during disconnect: $e');
    }
  }

  bool get isConnected => _channel != null;
  bool get hasPeerConnection => _peerConnection != null;
  
  // Get connection statistics
  Future<Map<String, dynamic>> getStats() async {
    if (_peerConnection == null) {
      return {'error': 'No peer connection'};
    }

    try {
      final stats = await _peerConnection!.getStats();
      return {
        'connectionState': _peerConnection!.connectionState?.toString() ?? 'unknown',
        'iceConnectionState': _peerConnection!.iceConnectionState?.toString() ?? 'unknown',
        'signalingState': _peerConnection!.signalingState?.toString() ?? 'unknown',
        'statsCount': stats.length,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}