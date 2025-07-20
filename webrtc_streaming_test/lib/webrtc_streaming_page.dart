import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class WebRTCStreamingPage extends StatefulWidget {
  const WebRTCStreamingPage({super.key});

  @override
  State<WebRTCStreamingPage> createState() => _WebRTCStreamingPageState();
}

class _WebRTCStreamingPageState extends State<WebRTCStreamingPage> {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  
  bool _isStreaming = false;
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  String _connectionStatus = 'Disconnected';
  String _serverUrl = 'ws://your-media-server.com:8080';
  
  final TextEditingController _serverController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeRenderers();
    _serverController.text = _serverUrl;
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _localStream?.dispose();
    _remoteStream?.dispose();
    _peerConnection?.dispose();
    _serverController.dispose();
    super.dispose();
  }

  Future<void> _initializeRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  Future<void> _createPeerConnection() async {
    final configuration = <String, dynamic>{
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
        {'urls': 'stun:stun1.l.google.com:19302'},
        {'urls': 'stun:stun2.l.google.com:19302'},
      ],
    };

    _peerConnection = await createPeerConnection(configuration);

    _peerConnection!.onIceConnectionState = (RTCIceConnectionState state) {
      setState(() {
        _connectionStatus = state.toString().split('.').last;
      });
    };

    _peerConnection!.onAddStream = (MediaStream stream) {
      setState(() {
        _remoteStream = stream;
        _remoteRenderer.srcObject = stream;
      });
    };

    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      // In a real implementation, you would send this to your signaling server
      debugPrint('ICE Candidate: ${candidate.toMap()}');
    };
  }

  Future<void> _getUserMedia() async {
    final Map<String, dynamic> constraints = {
      'audio': true,
      'video': {
        'facingMode': 'user',
        'width': 1280,
        'height': 720,
      },
    };

    try {
      _localStream = await navigator.mediaDevices.getUserMedia(constraints);
      setState(() {
        _localRenderer.srcObject = _localStream;
      });

      if (_peerConnection != null) {
        await _peerConnection!.addStream(_localStream!);
      }
    } catch (e) {
      debugPrint('Error getting user media: $e');
      _showError('Failed to access camera/microphone: $e');
    }
  }

  Future<void> _startStreaming() async {
    try {
      setState(() {
        _connectionStatus = 'Connecting...';
      });

      await _createPeerConnection();
      await _getUserMedia();

      // Create offer
      RTCSessionDescription offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);

      setState(() {
        _isStreaming = true;
        _connectionStatus = 'Streaming';
      });

      // In a real implementation, you would send the offer to your signaling server
      debugPrint('Offer SDP: ${offer.sdp}');
      
      _showInfo('Streaming started! In a real implementation, this would connect to your media server.');

    } catch (e) {
      debugPrint('Error starting stream: $e');
      _showError('Failed to start streaming: $e');
      setState(() {
        _connectionStatus = 'Error';
      });
    }
  }

  Future<void> _stopStreaming() async {
    await _localStream?.dispose();
    await _remoteStream?.dispose();
    await _peerConnection?.dispose();

    setState(() {
      _localStream = null;
      _remoteStream = null;
      _peerConnection = null;
      _isStreaming = false;
      _connectionStatus = 'Disconnected';
      _localRenderer.srcObject = null;
      _remoteRenderer.srcObject = null;
    });
  }

  void _toggleMute() {
    if (_localStream != null) {
      bool enabled = _localStream!.getAudioTracks()[0].enabled;
      _localStream!.getAudioTracks()[0].enabled = !enabled;
      setState(() {
        _isMuted = enabled;
      });
    }
  }

  void _toggleVideo() {
    if (_localStream != null) {
      bool enabled = _localStream!.getVideoTracks()[0].enabled;
      _localStream!.getVideoTracks()[0].enabled = !enabled;
      setState(() {
        _isVideoEnabled = enabled;
      });
    }
  }

  void _switchCamera() async {
    if (_localStream != null) {
      await Helper.switchCamera(_localStream!.getVideoTracks()[0]);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showServerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Media Server Configuration'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _serverController,
                decoration: const InputDecoration(
                  labelText: 'Server URL',
                  hintText: 'ws://your-server.com:8080',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Configure your media server URL for WebRTC streaming. '
                'This is where your streaming data will be sent.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _serverUrl = _serverController.text;
                });
                Navigator.of(context).pop();
                _showInfo('Server URL updated');
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusIndicator() {
    Color statusColor;
    IconData statusIcon;

    switch (_connectionStatus) {
      case 'connected':
        statusColor = Colors.green;
        statusIcon = Icons.wifi;
        break;
      case 'Streaming':
        statusColor = Colors.blue;
        statusIcon = Icons.stream;
        break;
      case 'Connecting...':
        statusColor = Colors.orange;
        statusIcon = Icons.sync;
        break;
      case 'Error':
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.wifi_off;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        border: Border.all(color: statusColor),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 16, color: statusColor),
          const SizedBox(width: 6),
          Text(
            _connectionStatus,
            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebRTC Streaming'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _showServerDialog,
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Column(
        children: [
          // Status bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusIndicator(),
                Text(
                  'Server: ${_serverUrl.split('://').last}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),

          // Video views
          Expanded(
            child: _isStreaming
                ? Column(
                    children: [
                      // Remote stream (if available)
                      if (_remoteStream != null) ...[
                        Expanded(
                          flex: 3,
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: RTCVideoView(_remoteRenderer),
                            ),
                          ),
                        ),
                      ],

                      // Local stream
                      Expanded(
                        flex: _remoteStream != null ? 2 : 3,
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blue),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: RTCVideoView(_localRenderer, mirror: true),
                          ),
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.videocam_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Ready to start streaming',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the start button to begin',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),

          // Control buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Main streaming control
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isStreaming ? _stopStreaming : _startStreaming,
                      icon: Icon(_isStreaming ? Icons.stop : Icons.play_arrow),
                      label: Text(_isStreaming ? 'Stop Stream' : 'Start Stream'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isStreaming ? Colors.red : Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),

                if (_isStreaming) ...[
                  const SizedBox(height: 16),
                  // Media controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: _toggleMute,
                        icon: Icon(_isMuted ? Icons.mic_off : Icons.mic),
                        iconSize: 32,
                        color: _isMuted ? Colors.red : Colors.blue,
                      ),
                      IconButton(
                        onPressed: _toggleVideo,
                        icon: Icon(_isVideoEnabled ? Icons.videocam : Icons.videocam_off),
                        iconSize: 32,
                        color: _isVideoEnabled ? Colors.blue : Colors.red,
                      ),
                      IconButton(
                        onPressed: _switchCamera,
                        icon: const Icon(Icons.flip_camera_ios),
                        iconSize: 32,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}