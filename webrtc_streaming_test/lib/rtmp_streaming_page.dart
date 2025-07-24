import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'stream_config.dart';
import 'rtmp_streaming_service.dart';
import 'connection_tester.dart';
import 'stream_player_page.dart';

class RTMPStreamingPage extends StatefulWidget {
  const RTMPStreamingPage({Key? key}) : super(key: key);

  @override
  State<RTMPStreamingPage> createState() => _RTMPStreamingPageState();
}

class _RTMPStreamingPageState extends State<RTMPStreamingPage> {
  StreamConfig _streamConfig = StreamConfig.yourServer(streamKey: '923244219594');
  RTMPStreamingService? _rtmpService;
  
  bool _isStreaming = false;
  String _connectionStatus = 'Not connected';
  String _streamingStatus = 'Camera off - Ready to preview';
  
  // Controllers for configuration
  final TextEditingController _hostController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  final TextEditingController _streamKeyController = TextEditingController();
  String _selectedProtocol = 'rtmp';

  @override
  void initState() {
    super.initState();
    _initializeServerConfig();
    _initializeRTMPService();
  }

  void _initializeServerConfig() {
    // Initialize with your specific server configuration
    _streamConfig = StreamConfig.yourServer(streamKey: '923244219594');
    
    // Initialize RTMP service
    _rtmpService = RTMPStreamingService(_streamConfig);
    _setupRTMPCallbacks();
    
    _hostController.text = _streamConfig.inputHost;
    _portController.text = _streamConfig.inputPort.toString();
    _streamKeyController.text = _streamConfig.streamKey;
  }

  void _initializeRTMPService() async {
    if (_rtmpService != null) {
      await _rtmpService!.initializeCamera();
    }
  }

  void _setupRTMPCallbacks() {
    _rtmpService?.onStatusChanged = (String status) {
      setState(() {
        _streamingStatus = status;
      });
    };

    _rtmpService?.onError = (String error) {
      _showError(error);
    };

    _rtmpService?.onMessage = (String message) {
      _showInfo(message);
    };
  }

  @override
  void dispose() {
    _rtmpService?.dispose();
    _hostController.dispose();
    _portController.dispose();
    _streamKeyController.dispose();
    super.dispose();
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

  Future<void> _startStreaming() async {
    try {
      setState(() {
        _connectionStatus = 'Initializing...';
        _streamingStatus = 'Starting camera...';
      });

      await _rtmpService!.startStreaming();

      setState(() {
        _isStreaming = true;
        _connectionStatus = 'Ready';
        _streamingStatus = 'Camera active - Use FFmpeg to stream';
      });

      debugPrint('🎯 Camera preview started');
      debugPrint('📡 RTMP URL: ${_streamConfig.rtmpStreamUrl}');
      debugPrint('📺 Stream Key: ${_streamConfig.streamKey}');
      debugPrint('🎬 Output URL: ${_streamConfig.outputUrl}');
      
      _showInfo('RTMP streaming configured!\n'
          'RTMP URL: ${_streamConfig.rtmpStreamUrl}\n'
          'Stream Key: ${_streamConfig.streamKey}\n'
          'Output: ${_streamConfig.outputUrl}');
      
    } catch (e) {
      setState(() {
        _connectionStatus = 'Failed';
        _streamingStatus = 'Error';
        _isStreaming = false;
      });
      _showError('Failed to start streaming: $e');
    }
  }

  Future<void> _stopStreaming() async {
    try {
      await _rtmpService!.stopStreaming();

      setState(() {
        _isStreaming = false;
        _connectionStatus = 'Disconnected';
        _streamingStatus = 'Stopped';
      });

      _showInfo('RTMP streaming stopped');
    } catch (e) {
      _showError('Failed to stop streaming: $e');
    }
  }

  void _showServerSettings() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('🔧 Server Configuration'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Quick server presets
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setDialogState(() {
                                _hostController.text = StreamConfig.inputServerIP;
                                _portController.text = StreamConfig.inputServerPort.toString();
                                _selectedProtocol = 'rtmp';
                                _streamKeyController.text = '923244219594';
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
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setDialogState(() {
                                _hostController.text = 'localhost';
                                _portController.text = '1935';
                                _selectedProtocol = 'rtmp';
                              });
                            },
                            icon: const Icon(Icons.computer, size: 16),
                            label: const Text('Local:1935'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Server configuration fields
                    TextField(
                      controller: _hostController,
                      decoration: const InputDecoration(
                        labelText: 'Server Host',
                        hintText: 'e.g., 47.130.109.65',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _portController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Server Port',
                        hintText: 'e.g., 1935',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _streamKeyController,
                      decoration: const InputDecoration(
                        labelText: 'Stream Key',
                        hintText: 'e.g., 923244219594, mystream',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Apply new configuration
                    final host = _hostController.text.trim();
                    final port = int.tryParse(_portController.text.trim()) ?? StreamConfig.inputServerPort;
                    final streamKey = _streamKeyController.text.trim();

                    if (host.isNotEmpty && streamKey.isNotEmpty) {
                      final newConfig = StreamConfig(
                        inputHost: host,
                        inputPort: port,
                        protocol: _selectedProtocol,
                        streamKey: streamKey.isNotEmpty ? streamKey : '923244219594',
                      );
                      
                      final oldStreamConfig = _streamConfig;
                      setState(() {
                        _streamConfig = newConfig;
                      });
                      
                      _rtmpService?.updateConfig(_streamConfig);
                      
                      Navigator.of(context).pop();
                      _showInfo('Server configuration updated!\nRTMP: ${_streamConfig.rtmpStreamUrl}\nOutput: ${_streamConfig.outputUrl}');
                    } else {
                      _showError('Please fill in all required fields');
                    }
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

  void _showFFmpegInstructions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('📹 FFmpeg Streaming Commands'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    RTMPStreamingService.generateFFmpegCommand(_streamConfig),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    RTMPStreamingService.getViewingInstructions(_streamConfig),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
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
          ],
        );
      },
    );
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RTMP Streaming Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showServerSettings,
            tooltip: 'Server Settings',
          ),
          IconButton(
            icon: const Icon(Icons.network_check),
            onPressed: _testConnection,
            tooltip: 'Test Connection',
          ),
          IconButton(
            icon: const Icon(Icons.play_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StreamPlayerPage(),
                ),
              );
            },
            tooltip: 'Play Stream',
          ),
        ],
      ),
      body: Column(
        children: [
          // Status Bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Icon(
                          Icons.cloud,
                          color: _connectionStatus == 'Connected' ? Colors.green : 
                                 _connectionStatus == 'Failed' ? Colors.red : Colors.orange,
                        ),
                        Text(
                          'Connection',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        Text(
                          _connectionStatus,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Icon(
                          Icons.stream,
                          color: _isStreaming ? Colors.green : Colors.grey,
                        ),
                        Text(
                          'Streaming',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        Text(
                          _streamingStatus,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('RTMP URL: ${_streamConfig.rtmpStreamUrl}'),
                    Text('Output: ${_streamConfig.outputUrl}'),
                    Text('Stream Key: ${_streamConfig.streamKey}'),
                  ],
                ),
              ],
            ),
          ),

          // Camera Preview
          Expanded(
            child: Container(
              color: Colors.black,
              child: Center(
                child: _rtmpService?.getCameraPreview() ?? 
                  Container(
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Initializing Camera...',
                            style: TextStyle(color: Colors.grey, fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
              ),
            ),
          ),

          // Control Panel
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Main control buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isStreaming ? _stopStreaming : _startStreaming,
                      icon: Icon(_isStreaming ? Icons.stop : Icons.camera_alt),
                      label: Text(_isStreaming ? 'Stop Preview' : 'Start Preview'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isStreaming ? Colors.red : Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _showFFmpegInstructions,
                      icon: const Icon(Icons.terminal),
                      label: const Text('Commands'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const StreamPlayerPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.play_circle),
                      label: const Text('Play'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Camera controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () => _rtmpService?.switchCamera(),
                      icon: const Icon(Icons.flip_camera_ios),
                      tooltip: 'Switch Camera',
                    ),
                    IconButton(
                      onPressed: () => _rtmpService?.toggleFlash(),
                      icon: const Icon(Icons.flash_on),
                      tooltip: 'Toggle Flash',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}