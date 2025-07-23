import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'stream_config.dart';
import 'connection_tester.dart';
import 'webrtc_signaling.dart';

class WebRTCStreamingPage extends StatefulWidget {
  const WebRTCStreamingPage({super.key});

  @override
  State<WebRTCStreamingPage> createState() => _WebRTCStreamingPageState();
}

class _WebRTCStreamingPageState extends State<WebRTCStreamingPage> {
  WebRTCSignaling? _signaling;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  
  bool _isStreaming = false;
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  String _connectionStatus = 'Disconnected';
  String _signalingStatus = 'Disconnected';
  
  // Server configuration
  late StreamConfig _streamConfig;
  final TextEditingController _hostController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  final TextEditingController _simNumberController = TextEditingController();
  String _selectedProtocol = 'ws';

  @override
  void initState() {
    super.initState();
    _initializeRenderers();
    _initializeServerConfig();
  }
  
  void _initializeServerConfig() {
    // Initialize with your specific server configuration
    _streamConfig = StreamConfig.yourServer(simNumber: '923244219594');
    
    // Initialize WebRTC signaling
    _signaling = WebRTCSignaling(_streamConfig);
    _setupSignalingCallbacks();
    
    _hostController.text = _streamConfig.inputHost;
    _portController.text = _streamConfig.inputPort.toString();
    _simNumberController.text = _streamConfig.simNumber;
    _selectedProtocol = _streamConfig.protocol;
  }

  void _setupSignalingCallbacks() {
    _signaling?.onConnectionStateChanged = (state) {
      setState(() {
        _connectionStatus = state;
      });
    };

    _signaling?.onSignalingStateChanged = (state) {
      setState(() {
        _signalingStatus = state;
      });
    };

    _signaling?.onAddRemoteStream = (stream) {
      setState(() {
        _remoteStream = stream;
        _remoteRenderer.srcObject = stream;
      });
    };

    _signaling?.onError = (error) {
      _showError(error);
    };

    _signaling?.onMessage = (message) {
      _showInfo(message);
    };
  }

  Future<void> _testConnection() async {
    try {
      _showInfo('🔍 Testing server connectivity...');
      
      final results = await ConnectionTester.testServerConnectivity(_streamConfig);
      
      _showConnectionTestResults(results);
      
    } catch (e) {
      _showError('❌ Connection test failed: $e');
    }
  }

  void _showConnectionTestResults(Map<String, dynamic> results) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.network_check, color: Colors.blue),
              SizedBox(width: 8),
              Text('Connection Diagnostics'),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Show formatted report
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SelectableText(
                      ConnectionTester.formatResults(results),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                
                ],
              ),
            ),
          ),
          actions: [
          ],
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _testConnection(); // Re-run test
              },
              child: const Text('Test Again'),
            ),
          ],
        );
      },
    );
  }



  void _showDebugInfo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.bug_report, color: Colors.blue),
              SizedBox(width: 8),
              Text('Debug Information'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current Configuration
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('📡 Current Configuration:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('WebRTC Signaling: ${_streamConfig.webrtcSignalingUrl}'),
                      Text('Output Stream: ${_streamConfig.outputUrl}'),
                      Text('SIM Number: ${_streamConfig.simNumber}'),
                      Text('Protocol: ${_streamConfig.protocol}'),
                      Text('Input Format: ws://host:port/sim_number'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Stream Status
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _isStreaming ? Colors.green.shade50 : Colors.orange.shade50,
                    border: Border.all(color: _isStreaming ? Colors.green : Colors.orange),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🎥 Stream Status: ${_isStreaming ? "ACTIVE" : "INACTIVE"}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _isStreaming ? Colors.green.shade700 : Colors.orange.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Signaling: $_signalingStatus'),
                      Text('WebRTC: $_connectionStatus'),
                      Text('Audio: ${_isMuted ? "MUTED" : "ACTIVE"}'),
                      Text('Video: ${_isVideoEnabled ? "ACTIVE" : "DISABLED"}'),
                      Text('Local Stream: ${_localStream != null ? "READY" : "NOT READY"}'),
                      Text('Remote Stream: ${_remoteStream != null ? "CONNECTED" : "NOT CONNECTED"}'),
                      Text('Signaling Connected: ${_signaling?.isConnected ?? false}'),
                      Text('Peer Connection: ${_signaling?.hasPeerConnection ?? false}'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Troubleshooting
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🔧 If Output URL Shows Loading Only:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text('1. ❌ WebRTC signaling not connecting'),
                      const Text('2. ❌ Server not accepting WebSocket connections'),
                      const Text('3. ❌ Wrong SIM number or path format'),
                      const Text('4. ❌ Server not processing WebRTC streams'),
                      const Text('5. ❌ Firewall blocking WebSocket connections'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Testing Instructions
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    border: Border.all(color: Colors.blue.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '✅ Next Steps to Debug:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text('1. Tap "Test Connection" in settings'),
                      const Text('2. Check if WebSocket server accepts connections'),
                      const Text('3. Verify WebRTC signaling server on port 1078'),
                      const Text('4. Test WebSocket connection manually'),
                      const Text('5. Check server logs for WebRTC signaling'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _testConnection();
              },
              child: const Text('Test Connection'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _localStream?.dispose();
    _remoteStream?.dispose();
    _signaling?.disconnect();
    _hostController.dispose();
    _portController.dispose();
    _simNumberController.dispose();
    super.dispose();
  }

  Future<void> _initializeRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  // This method is now handled by the WebRTCSignaling class

  Future<void> _checkAvailableDevices() async {
    try {
      final devices = await navigator.mediaDevices.enumerateDevices();
      debugPrint('Available devices:');
      for (var device in devices) {
        debugPrint('  ${device.kind}: ${device.label}');
      }
    } catch (e) {
      debugPrint('Failed to enumerate devices: $e');
    }
  }

  Future<void> _getUserMedia() async {
    try {
      // First, try with basic constraints for better macOS compatibility
      Map<String, dynamic> constraints = {
        'audio': true,
        'video': true,
      };

             debugPrint('Attempting getUserMedia with basic constraints...');
       await _checkAvailableDevices();
       _localStream = await navigator.mediaDevices.getUserMedia(constraints);
      
      setState(() {
        _localRenderer.srcObject = _localStream;
      });
      debugPrint('Successfully got user media');
    } catch (e) {
      debugPrint('Basic constraints failed, trying without audio: $e');
      
      // If basic constraints fail, try video only
      try {
        Map<String, dynamic> videoOnlyConstraints = {
          'audio': false,
          'video': true,
        };
        
        _localStream = await navigator.mediaDevices.getUserMedia(videoOnlyConstraints);
        setState(() {
          _localRenderer.srcObject = _localStream;
        });
        debugPrint('Successfully got video-only media');
        _showError('Camera access granted, but microphone unavailable: $e');
      } catch (e2) {
        debugPrint('Video-only constraints also failed: $e2');
        _showError('Failed to access camera/microphone. Unable to getUserMedia: $e2. Failed to start streaming:Failed to get local media stream');
      }
    }
  }

  Future<void> _startStreaming() async {
    try {
      setState(() {
        _connectionStatus = 'Connecting...';
        _signalingStatus = 'Connecting...';
      });

      // Get user media first
      await _getUserMedia();

      if (_localStream == null) {
        throw 'Failed to get local media stream';
      }

      // Connect to signaling server
      await _signaling!.connect();

      // Create peer connection with local stream
      await _signaling!.createPeerConnection(_localStream!);

      // Create and send offer
      await _signaling!.createOffer();

      setState(() {
        _isStreaming = true;
      });

      debugPrint('🎯 WebRTC streaming started');
      debugPrint('📡 Signaling URL: ${_streamConfig.webrtcSignalingUrl}');
      debugPrint('📺 SIM Number: ${_streamConfig.simNumber}');
      debugPrint('🎬 Output URL: ${_streamConfig.outputUrl}');
      
      _showInfo('WebRTC streaming started!\n'
          'Signaling: ${_streamConfig.inputUrl}\n'
          'SIM: ${_streamConfig.simNumber}\n'
          'Watch at: ${_streamConfig.outputUrl}');

    } catch (e) {
      debugPrint('❌ Error starting stream: $e');
      _showError('Failed to start streaming: $e');
      setState(() {
        _connectionStatus = 'Error';
        _signalingStatus = 'Error';
      });
    }
  }

  Future<void> _stopStreaming() async {
    // Disconnect signaling
    await _signaling?.disconnect();

    // Dispose media streams
    await _localStream?.dispose();
    await _remoteStream?.dispose();

    setState(() {
      _localStream = null;
      _remoteStream = null;
      _isStreaming = false;
      _connectionStatus = 'Disconnected';
      _signalingStatus = 'Disconnected';
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
    // Reset controllers with current values
    _hostController.text = _streamConfig.inputHost;
    _portController.text = _streamConfig.inputPort.toString();
    _simNumberController.text = _streamConfig.simNumber;
    _selectedProtocol = _streamConfig.protocol;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Custom Server Configuration'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Protocol selection
                    const Text('Protocol:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedProtocol,
                      items: const [
                        DropdownMenuItem(value: 'ws', child: Text('WebSocket (ws)')),
                        DropdownMenuItem(value: 'wss', child: Text('WebSocket Secure (wss)')),
                        DropdownMenuItem(value: 'rtmp', child: Text('RTMP')),
                        DropdownMenuItem(value: 'http', child: Text('HTTP')),
                        DropdownMenuItem(value: 'https', child: Text('HTTPS')),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          _selectedProtocol = value!;
                        });
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Host/IP input
                    const Text('Host/IP Address:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _hostController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'e.g., 192.168.1.100 or yourserver.com',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Port input
                    const Text('Port:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _portController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'e.g., 8080, 1935, 8000',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // SIM Number input (for output URL)
                    const Text('SIM Number:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _simNumberController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'e.g., 12345, sim001',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Preview URL
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                                              child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Preview URLs:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(
                              'Input: $_selectedProtocol://${_hostController.text.isNotEmpty ? _hostController.text : 'host'}:${_portController.text.isNotEmpty ? _portController.text : 'port'}',
                              style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Output: http://${_hostController.text.isNotEmpty ? _hostController.text : 'host'}:8080/${_simNumberController.text.isNotEmpty ? _simNumberController.text : 'sim'}/1.m3u8',
                              style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                            ),
                          ],
                        ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Quick presets
                    const Text('Quick Presets:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                                          Wrap(
                        spacing: 8,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              setDialogState(() {
                                _hostController.text = StreamConfig.inputServerIP;
                                _portController.text = StreamConfig.inputServerPort.toString();
                                _selectedProtocol = 'ws';
                                _simNumberController.text = '923244219594';
                              });
                            },
                            icon: const Icon(Icons.cloud, size: 16),
                            label: const Text('Your Server'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              setDialogState(() {
                                _hostController.text = 'localhost';
                                _portController.text = '8080';
                                _selectedProtocol = 'ws';
                              });
                            },
                            icon: const Icon(Icons.computer, size: 16),
                            label: const Text('Local:8080'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              setDialogState(() {
                                _hostController.text = 'localhost';
                                _portController.text = '1935';
                                _selectedProtocol = 'rtmp';
                              });
                            },
                            icon: const Icon(Icons.stream, size: 16),
                            label: const Text('RTMP:1935'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 16),
                    
                    const Text(
                      'Enter your custom streaming server details. This will be used to establish the WebRTC connection.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                                  TextButton.icon(
                    onPressed: () async {
                      final host = _hostController.text.trim();
                      final portText = _portController.text.trim();
                      final simNumber = _simNumberController.text.trim();
                      
                      if (host.isEmpty || portText.isEmpty) {
                        _showError('Please enter both host and port to test');
                        return;
                      }
                      
                      final port = int.tryParse(portText);
                      if (port == null || port < 1 || port > 65535) {
                        _showError('Please enter a valid port number (1-65535)');
                        return;
                      }
                      
                      // Temporarily update config for testing
                      final tempStreamConfig = StreamConfig(
                        inputHost: host,
                        inputPort: port,
                        protocol: _selectedProtocol,
                        simNumber: simNumber.isNotEmpty ? simNumber : '923244219594',
                      );
                      
                      final oldStreamConfig = _streamConfig;
                      _streamConfig = tempStreamConfig;
                      await _testConnection();
                      _streamConfig = oldStreamConfig; // Restore original
                    },
                    icon: const Icon(Icons.network_check),
                    label: const Text('Test'),
                  ),
                                  ElevatedButton(
                    onPressed: () {
                      final host = _hostController.text.trim();
                      final portText = _portController.text.trim();
                      final simNumber = _simNumberController.text.trim();
                      
                      if (host.isEmpty || portText.isEmpty) {
                        _showError('Please enter both host and port');
                        return;
                      }
                      
                      if (simNumber.isEmpty) {
                        _showError('Please enter a SIM number');
                        return;
                      }
                      
                      final port = int.tryParse(portText);
                      if (port == null || port < 1 || port > 65535) {
                        _showError('Please enter a valid port number (1-65535)');
                        return;
                      }
                      
                      setState(() {
                        _streamConfig = StreamConfig(
                          inputHost: host,
                          inputPort: port,
                          protocol: _selectedProtocol,
                          simNumber: simNumber,
                        );
                        
                        // Update signaling configuration
                        _signaling?.updateConfig(_streamConfig);
                      });
                      Navigator.of(context).pop();
                      _showInfo('Server configuration updated!\nInput: ${_streamConfig.inputUrl}\nOutput: ${_streamConfig.outputUrl}');
                    },
                    child: const Text('Save'),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatusIndicator() {
    Color statusColor;
    IconData statusIcon;
    String displayStatus;

    if (_isStreaming) {
      statusColor = Colors.green;
      statusIcon = Icons.stream;
      displayStatus = 'Streaming';
    } else {
      switch (_signalingStatus) {
        case 'connected':
          statusColor = Colors.blue;
          statusIcon = Icons.wifi;
          displayStatus = 'Connected';
          break;
        case 'Connecting...':
          statusColor = Colors.orange;
          statusIcon = Icons.sync;
          displayStatus = 'Connecting...';
          break;
        case 'error':
        case 'Error':
          statusColor = Colors.red;
          statusIcon = Icons.error;
          displayStatus = 'Error';
          break;
        default:
          statusColor = Colors.grey;
          statusIcon = Icons.wifi_off;
          displayStatus = 'Disconnected';
      }
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
            displayStatus,
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
            onPressed: _showDebugInfo,
            icon: const Icon(Icons.bug_report),
            tooltip: 'Debug Info',
          ),
          IconButton(
            onPressed: _showServerDialog,
            icon: const Icon(Icons.settings),
            tooltip: 'Server Settings',
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Input: ${_streamConfig.inputDisplayUrl}',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    Text(
                      'Output: ${_streamConfig.outputDisplayUrl}',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
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
                  const SizedBox(height: 16),
                  // Stream output info
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      border: Border.all(color: Colors.green.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.play_circle, color: Colors.green.shade700),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Stream Output Available',
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _streamConfig.outputUrl,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            _showInfo('Open this URL in a browser or media player:\n${_streamConfig.outputUrl}');
                          },
                          icon: const Icon(Icons.open_in_browser),
                          label: const Text('Copy Output URL'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
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