import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class StreamPlayerPage extends StatefulWidget {
  const StreamPlayerPage({Key? key}) : super(key: key);

  @override
  State<StreamPlayerPage> createState() => _StreamPlayerPageState();
}

class _StreamPlayerPageState extends State<StreamPlayerPage> {
  final TextEditingController _urlController = TextEditingController();
  bool _isPlaying = false;
  String _playerStatus = 'Ready to play';
  Process? _playerProcess;

  @override
  void initState() {
    super.initState();
    // Pre-fill with your server's output URL (matching your ffmpeg command)
    _urlController.text = 'http://47.130.109.65:8080/hls/mystream.flv';
  }

  @override
  void dispose() {
    _stopStream();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _testServerConnectivity() async {
    setState(() {
      _playerStatus = 'Testing server connectivity...';
    });

    final serverIP = '47.130.109.65';
    final ports = [8080, 1935, 80];
    final results = <String>[];

    for (final port in ports) {
      try {
        final socket = await Socket.connect(serverIP, port, timeout: const Duration(seconds: 3));
        socket.destroy();
        results.add('✅ Port $port: Open');
      } catch (e) {
        results.add('❌ Port $port: Closed or filtered');
      }
    }

    setState(() {
      _playerStatus = 'Server connectivity test completed';
    });

    final message = '''
Server Connectivity Test Results:

${results.join('\n')}

💡 Recommendations:
• If port 8080 is open, your stream URL should work
• If port 1935 is open, try the alternative port preset
• If all ports are closed, check if your server is running

🔧 Next steps:
1. If ports are open, make sure FFmpeg is streaming
2. Wait 10-15 seconds after starting FFmpeg
3. Try the stream URL test again
''';

    _showDetailedMessage('Server Connectivity Results', message);
  }

  Future<void> _testStreamUrl() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      _showMessage('Please enter a stream URL');
      return;
    }

    setState(() {
      _playerStatus = 'Testing URL...';
    });

    try {
      final uri = Uri.parse(url);
      
      // Try HEAD request first (faster) with shorter timeout
      var response = await http.head(uri).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        setState(() {
          _playerStatus = 'Stream URL is accessible ✅';
        });
        _showMessage('Stream URL is valid and accessible!');
        return;
      }
      
      // If HEAD fails, try GET request (some servers don't support HEAD)
      if (response.statusCode == 405 || response.statusCode == 404) {
        response = await http.get(uri).timeout(const Duration(seconds: 5));
        
        if (response.statusCode == 200) {
          setState(() {
            _playerStatus = 'Stream URL is accessible ✅ (via GET)';
          });
          _showMessage('Stream URL is valid and accessible!');
          return;
        }
      }
      
      setState(() {
        _playerStatus = 'URL test failed - but stream might still work ⚠️';
      });
      
      // For streaming URLs, HTTP test might fail but FFplay could still work
      String message = '''
HTTP Test Result: ${response.statusCode}

⚠️ IMPORTANT: Your stream might still work!

🎬 You mentioned that this command works in terminal:
ffplay http://47.130.109.65:8080/hls/mystream.flv

💡 HTTP tests often fail for streaming URLs because:
• Streaming servers don't always respond to HTTP HEAD/GET requests the same way
• Some servers only respond to media player requests (like FFplay)
• The stream might be active but not accessible via browser HTTP requests

🔧 What to do:
1. Use "Try Play" button (orange) - this will launch FFplay directly
2. FFplay should work since you confirmed it works in terminal
3. Ignore the HTTP test failure - it's not reliable for streaming URLs

🎯 The "Try Play" button bypasses HTTP testing and uses FFplay directly, which should work!
''';
      
      _showDetailedMessage('HTTP Test Failed - But Try Playing Anyway!', message);
      
    } catch (e) {
      setState(() {
        _playerStatus = 'URL test failed - but stream might still work ⚠️';
      });
      
      String errorMessage = '''
HTTP Test Error: ${e.toString().split(':').first}

✅ GOOD NEWS: You confirmed FFplay works in terminal!

🎬 Since this command works for you:
ffplay http://47.130.109.65:8080/hls/mystream.flv

💡 The HTTP test failure is expected because:
• Streaming servers often don't respond to regular HTTP requests
• Flutter's HTTP client works differently than FFplay
• Your stream is likely working fine - just not testable via HTTP

🔧 Solution:
1. Click "Try Play" (orange button) - this launches FFplay directly
2. FFplay should work since you confirmed it works in terminal
3. The app will bypass the HTTP test and try to play directly

🎯 Use "Try Play" instead of "Test URL" for streaming URLs!
''';
      
      _showDetailedMessage('HTTP Test Failed - But Stream Should Work!', errorMessage);
    }
  }

  Future<void> _playStream({bool skipTest = false}) async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      _showMessage('Please enter a stream URL');
      return;
    }

    if (_isPlaying) {
      await _stopStream();
      return;
    }

    setState(() {
      _isPlaying = true;
      _playerStatus = skipTest ? 'Trying to play without test...' : 'Starting player...';
    });

    try {
      // Try to launch the stream with ffplay
      _playerProcess = await Process.start('ffplay', [
        '-i', url,
        '-window_title', 'RTMP Stream Player',
        '-autoexit',  // Exit when stream ends
        '-loglevel', 'quiet',  // Reduce log output
      ]);

      setState(() {
        _playerStatus = 'Playing stream 🎬';
      });

      // Monitor the process
      _playerProcess!.exitCode.then((exitCode) {
        if (mounted) {
          setState(() {
            _isPlaying = false;
            _playerStatus = exitCode == 0 
                ? 'Stream ended' 
                : 'Player stopped (code: $exitCode)';
          });
        }
      });

      _showMessage('Stream player launched! Check for new window.');
      
    } catch (e) {
      setState(() {
        _isPlaying = false;
        _playerStatus = 'Failed to start player ❌';
      });
      
      // Show detailed instructions if ffplay is not available
      _showFFplayInstructions(url);
    }
  }

  Future<void> _stopStream() async {
    if (_playerProcess != null) {
      _playerProcess!.kill();
      _playerProcess = null;
    }
    
    setState(() {
      _isPlaying = false;
      _playerStatus = 'Player stopped';
    });
  }

  void _showFFplayInstructions(String url) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.info, color: Colors.blue),
              SizedBox(width: 8),
              Text('Stream Player Instructions'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'FFplay is not available or failed to start. You can play the stream manually:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                const Text('🎯 Using FFplay (Recommended):'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: SelectableText(
                    'ffplay "$url"',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                const Text('🎬 Using VLC Media Player:'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: SelectableText(
                    'vlc "$url"',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                const Text('🌐 In Web Browser:'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: SelectableText(
                    url,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                      color: Colors.blue,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                const Text(
                  '💡 Install FFmpeg/FFplay for direct playback from this app.',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Got it'),
            ),
          ],
        );
      },
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showDetailedMessage(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                title.contains('Failed') ? Icons.error : Icons.info,
                color: title.contains('Failed') ? Colors.red : Colors.blue,
              ),
              const SizedBox(width: 8),
              Text(title),
            ],
          ),
          content: SingleChildScrollView(
            child: SelectableText(
              message,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showPresetUrls() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('🎯 Stream URL Presets'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Common stream formats:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                _buildPresetTile(
                  '🎬 Your Stream (HTTP-FLV)',
                  'http://47.130.109.65:8080/hls/mystream.flv',
                  'Your current stream: mystream',
                ),
                
                _buildPresetTile(
                  '📺 Your Stream (HLS)',
                  'http://47.130.109.65:8080/hls/mystream.m3u8',
                  'HLS format of your stream',
                ),
                
                _buildPresetTile(
                  '🔑 Default Stream Key',
                  'http://47.130.109.65:8080/hls/923244219594.flv',
                  'Default stream key from config',
                ),
                
                _buildPresetTile(
                  '🔄 Alternative Port (1935)',
                  'http://47.130.109.65:1935/hls/mystream.flv',
                  'Try different port if 8080 fails',
                ),
                
                _buildPresetTile(
                  '🌐 No Port Specified',
                  'http://47.130.109.65/hls/mystream.flv',
                  'Default HTTP port (80)',
                ),
                
                _buildPresetTile(
                  '🔴 Test Stream (Big Buck Bunny)',
                  'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
                  'Test video stream',
                ),
                
                _buildPresetTile(
                  '📡 Local RTMP',
                  'rtmp://localhost/live/stream',
                  'Local RTMP server stream',
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

  Widget _buildPresetTile(String title, String url, String description) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              url,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          _urlController.text = url;
          Navigator.of(context).pop();
          _showMessage('Stream URL updated');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stream Player'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.network_ping),
            onPressed: _testServerConnectivity,
            tooltip: 'Test Server',
          ),
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: _showPresetUrls,
            tooltip: 'Stream Presets',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              color: Colors.purple.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isPlaying ? Icons.play_circle : Icons.stop_circle,
                          color: _isPlaying ? Colors.green : Colors.grey,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Player Status',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _playerStatus,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // URL Input Section
            const Text(
              '🎯 Stream URL',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                hintText: 'Enter stream URL (HTTP, RTMP, HLS, etc.)',
                prefixIcon: const Icon(Icons.link),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _urlController.clear(),
                ),
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              keyboardType: TextInputType.url,
              maxLines: 2,
              minLines: 1,
            ),
            
            const SizedBox(height: 16),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _testStreamUrl,
                    icon: const Icon(Icons.network_check),
                    label: const Text('Test URL'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _playStream,
                    icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
                    label: Text(_isPlaying ? 'Stop' : 'Play'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isPlaying ? Colors.red : Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _playStream(skipTest: true),
                    icon: const Icon(Icons.play_circle_outline),
                    label: const Text('Try Play'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // FFmpeg Command Card
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.terminal, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          'Start Your Stream First',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Run this command in terminal to start streaming:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const SelectableText(
                        'ffmpeg -re -i /Users/mac/Downloads/IK.mp4 -c copy -f flv rtmp://47.130.109.65/hls/mystream',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '🎯 After starting FFmpeg, use "Try Play" button (orange) - it works even if URL test fails!',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Instructions Card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'How to Use',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('1. Start your FFmpeg stream (see command above)'),
                    const Text('2. Verify the stream URL is correct'),
                    const Text('3. Use "Try Play" (orange) - works even if test fails'),
                    const Text('4. Optional: Test server connectivity (network icon)'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Text(
                        '🎯 For streaming URLs, use "Try Play" instead of "Test URL" - it bypasses HTTP testing and launches FFplay directly!',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.orange.shade800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '💡 Supports: HTTP-FLV, HLS (.m3u8), RTMP, MP4, and more',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const Spacer(),
            
            // Quick Access Button
            OutlinedButton.icon(
              onPressed: _showPresetUrls,
              icon: const Icon(Icons.list),
              label: const Text('Stream Presets'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}