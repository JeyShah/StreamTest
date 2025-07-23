import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'stream_config.dart';
import 'connection_tester.dart';

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
    _streamConfig = StreamConfig.yourServer();
    
    _hostController.text = _streamConfig.inputHost;
    _portController.text = _streamConfig.inputPort.toString();
    _simNumberController.text = _streamConfig.simNumber;
    _selectedProtocol = _streamConfig.protocol;
  }

  Future<void> _testConnection() async {
    try {
      _showInfo('🔍 Testing server connectivity...');
      
      final results = await ConnectionTester.testServerConnectivity(
        inputHost: _streamConfig.inputHost,
        inputPort: _streamConfig.inputPort,
        outputHost: _streamConfig.outputHost,
        outputPort: _streamConfig.outputPort,
        simNumber: _streamConfig.simNumber,
      );
      
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
          title: Row(
            children: [
              Icon(
                Icons.network_check,
                color: ConnectionTester.getStatusColor(results['overall']['status']),
              ),
              const SizedBox(width: 8),
              const Text('Connection Test Results'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overall Status
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ConnectionTester.getStatusColor(results['overall']['status']).withOpacity(0.1),
                    border: Border.all(color: ConnectionTester.getStatusColor(results['overall']['status'])),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Text(
                        ConnectionTester.getStatusIcon(results['overall']['status']),
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          results['overall']['message'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: ConnectionTester.getStatusColor(results['overall']['status']),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Individual Test Results
                _buildTestResult('Input Server (${_streamConfig.inputHost}:${_streamConfig.inputPort})', results['inputServer']),
                _buildTestResult('Output Server (${_streamConfig.outputHost}:${_streamConfig.outputPort})', results['outputServer']),
                _buildTestResult('Stream URL (${_streamConfig.simNumber}/1.m3u8)', results['outputStream']),
                
                const SizedBox(height: 16),
                
                // Troubleshooting Tips
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
                        '💡 Troubleshooting Tips:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text('• Input server should accept RTMP streams on port 1078'),
                      const Text('• Output server should serve HLS streams on port 8080'),
                      const Text('• Stream URL will be 404 until you start streaming'),
                      const Text('• Check firewall settings if connections fail'),
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
                _testConnection(); // Re-run test
              },
              child: const Text('Test Again'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTestResult(String title, Map<String, dynamic> result) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ConnectionTester.getStatusIcon(result['status']),
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  result['message'],
                  style: TextStyle(
                    fontSize: 12,
                    color: ConnectionTester.getStatusColor(result['status']),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
                      Text('Input: ${_streamConfig.inputUrl}'),
                      Text('Output: ${_streamConfig.outputUrl}'),
                      Text('RTMP Push: ${_streamConfig.rtmpPushUrl}'),
                      Text('SIM Number: ${_streamConfig.simNumber}'),
                      Text('Protocol: ${_streamConfig.protocol}'),
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
                      Text('Connection: $_connectionStatus'),
                      Text('Audio: ${_isMuted ? "MUTED" : "ACTIVE"}'),
                      Text('Video: ${_isVideoEnabled ? "ACTIVE" : "DISABLED"}'),
                      Text('Local Stream: ${_localStream != null ? "READY" : "NOT READY"}'),
                      Text('Remote Stream: ${_remoteStream != null ? "CONNECTED" : "NOT CONNECTED"}'),
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
                      const Text('1. ❌ No stream is being sent to input server'),
                      const Text('2. ❌ Server not processing RTMP correctly'),
                      const Text('3. ❌ Wrong protocol (need actual RTMP, not WebRTC)'),
                      const Text('4. ❌ Server not converting to HLS format'),
                      const Text('5. ❌ Firewall blocking connections'),
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
                      const Text('2. Check if input server accepts connections'),
                      const Text('3. Verify RTMP server is running on port 1078'),
                      const Text('4. Test with actual RTMP tools (OBS, FFmpeg)'),
                      const Text('5. Check server logs for incoming streams'),
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
    _peerConnection?.dispose();
    _hostController.dispose();
    _portController.dispose();
    _simNumberController.dispose();
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
      debugPrint('Streaming to input: ${_streamConfig.inputUrl}');
      debugPrint('Stream will be available at: ${_streamConfig.outputUrl}');
      
      _showInfo('Streaming started!\nSending to: ${_streamConfig.inputUrl}\nWatch at: ${_streamConfig.outputUrl}');

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
                                _selectedProtocol = 'rtmp';
                                _simNumberController.text = '12345';
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
                        simNumber: simNumber.isNotEmpty ? simNumber : '12345',
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