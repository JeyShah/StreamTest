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
    // Pre-fill with your server's output URL
    _urlController.text = 'http://47.130.109.65:8080/hls/923244219594.flv';
  }

  @override
  void dispose() {
    _stopStream();
    _urlController.dispose();
    super.dispose();
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
      final response = await http.head(uri).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        setState(() {
          _playerStatus = 'Stream URL is accessible ✅';
        });
        _showMessage('Stream URL is valid and accessible!');
      } else {
        setState(() {
          _playerStatus = 'Stream not accessible (${response.statusCode})';
        });
        _showMessage('Stream returned status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _playerStatus = 'Stream test failed ❌';
      });
      _showMessage('Error testing stream: $e');
    }
  }

  Future<void> _playStream() async {
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
      _playerStatus = 'Starting player...';
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
                  '🎬 Your Server (HTTP-FLV)',
                  'http://47.130.109.65:8080/hls/923244219594.flv',
                  'Direct stream from your RTMP server',
                ),
                
                _buildPresetTile(
                  '📺 Your Server (HLS)',
                  'http://47.130.109.65:8080/hls/923244219594.m3u8',
                  'HLS stream from your server',
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
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _playStream,
                    icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
                    label: Text(_isPlaying ? 'Stop Player' : 'Play Stream'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isPlaying ? Colors.red : Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
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
                    const Text('1. Enter your stream URL in the text field above'),
                    const Text('2. Tap "Test URL" to verify the stream is accessible'),
                    const Text('3. Tap "Play Stream" to launch the player'),
                    const Text('4. Use "Stream Presets" for common URLs'),
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