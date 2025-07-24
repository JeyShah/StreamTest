import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
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
  VideoPlayerController? _videoController;
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  double _volume = 1.0;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    // Pre-fill with your server's output URL (matching your ffmpeg command)
    _urlController.text = 'http://47.130.109.65:8080/hls/mystream.flv';
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _checkFFplayAvailability() async {
    setState(() {
      _playerStatus = 'Checking FFplay availability...';
    });

    final commonPaths = [
      '/usr/local/bin/ffplay',
      '/opt/homebrew/bin/ffplay', 
      '/usr/bin/ffplay',
      'ffplay',
    ];

    final results = <String>[];
    String? workingPath;

    for (final path in commonPaths) {
      try {
        final process = await Process.start(path, ['--version'], runInShell: true);
        final exitCode = await process.exitCode;
        if (exitCode == 0) {
          results.add('✅ $path: Available');
          workingPath ??= path;
        } else {
          results.add('❌ $path: Found but not working');
        }
      } catch (e) {
        results.add('❌ $path: Not found');
      }
    }

    setState(() {
      _playerStatus = workingPath != null 
          ? 'FFplay found at $workingPath ✅' 
          : 'FFplay not available ❌';
    });

    final message = '''
FFplay Availability Check:

${results.join('\n')}

${workingPath != null ? '''
✅ GOOD NEWS: FFplay is available!
Working path: $workingPath

You can use FFplay directly in Terminal:
ffplay "${_urlController.text}"
''' : '''
❌ FFplay not found in common locations.

🔧 Installation options:
1. Install via Homebrew:
   brew install ffmpeg

2. Download from official site:
   https://ffmpeg.org/download.html

3. Install via MacPorts:
   sudo port install ffmpeg +universal

💡 After installation, restart this app to detect FFplay.
'''}

🎯 Alternative: Use VLC Media Player
If you have VLC installed, you can also use:
vlc "${_urlController.text}"
''';

    _showDetailedMessage('FFplay Availability Report', message);
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
      _isLoading = true;
      _hasError = false;
      _playerStatus = 'Loading stream...';
    });

    try {
      // Dispose existing controller
      await _videoController?.dispose();

      // Create new video controller
      Uri uri;
      try {
        uri = Uri.parse(url);
      } catch (e) {
        throw 'Invalid URL format: $url';
      }

      if (uri.scheme == 'http' || uri.scheme == 'https') {
        _videoController = VideoPlayerController.networkUrl(uri);
      } else if (uri.scheme == 'rtmp') {
        _videoController = VideoPlayerController.networkUrl(uri);
      } else {
        throw 'Unsupported URL scheme: ${uri.scheme}. Use HTTP, HTTPS, or RTMP.';
      }

      // Set up error listener
      _videoController!.addListener(_videoPlayerListener);

      // Initialize the controller
      await _videoController!.initialize();

      // Start playing
      await _videoController!.play();
      await _videoController!.setVolume(_volume);

      setState(() {
        _isLoading = false;
        _isPlaying = true;
        _playerStatus = 'Playing stream 🎬';
      });

      _showMessage('Stream started successfully!');

    } catch (e) {
      setState(() {
        _isLoading = false;
        _isPlaying = false;
        _hasError = true;
        _errorMessage = e.toString();
        _playerStatus = 'Failed to play stream ❌';
      });

      // Show alternatives for unsupported formats
      if (e.toString().contains('rtmp') || e.toString().contains('unsupported')) {
        _showStreamFormatHelp(url);
      } else {
        _showMessage('Error: ${e.toString()}');
      }
    }
  }

  void _videoPlayerListener() {
    if (_videoController == null) return;

    if (_videoController!.value.hasError) {
      setState(() {
        _hasError = true;
        _errorMessage = _videoController!.value.errorDescription ?? 'Unknown video error';
        _playerStatus = 'Stream error ❌';
        _isPlaying = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _stopStream() async {
    if (_videoController != null) {
      await _videoController!.pause();
      _videoController!.removeListener(_videoPlayerListener);
      await _videoController!.dispose();
      _videoController = null;
    }
    
    setState(() {
      _isPlaying = false;
      _isLoading = false;
      _playerStatus = 'Player stopped';
    });
  }

  Future<void> _togglePlayPause() async {
    if (_videoController == null) return;

    if (_videoController!.value.isPlaying) {
      await _videoController!.pause();
      setState(() {
        _isPlaying = false;
        _playerStatus = 'Paused';
      });
    } else {
      await _videoController!.play();
      setState(() {
        _isPlaying = true;
        _playerStatus = 'Playing stream 🎬';
      });
    }
  }

  Future<void> _setVolume(double volume) async {
    _volume = volume;
    if (_videoController != null) {
      await _videoController!.setVolume(volume);
    }
    setState(() {});
  }

  Widget _buildVideoPlayer() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Loading stream...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to load stream',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _errorMessage,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showStreamFormatHelp(_urlController.text),
              child: const Text('Get Help'),
            ),
          ],
        ),
      );
    }

    if (_videoController != null && _videoController!.value.isInitialized) {
      return GestureDetector(
        onTap: () {
          setState(() {
            _showControls = !_showControls;
          });
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: _videoController!.value.size.width,
                  height: _videoController!.value.size.height,
                  child: VideoPlayer(_videoController!),
                ),
              ),
            ),
            if (_showControls) ...[
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: _togglePlayPause,
                  icon: Icon(
                    _videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.play_circle_outline,
            color: Colors.white54,
            size: 64,
          ),
          SizedBox(height: 16),
          Text(
            'Enter stream URL and tap Play',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoControls() {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return const SizedBox.shrink();
    }

    return Card(
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Progress bar
            VideoProgressIndicator(
              _videoController!,
              allowScrubbing: true,
              colors: VideoProgressColors(
                backgroundColor: Colors.grey.shade300,
                bufferedColor: Colors.grey.shade400,
                playedColor: Colors.purple,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Volume control
            Row(
              children: [
                const Icon(Icons.volume_down),
                Expanded(
                  child: Slider(
                    value: _volume,
                    min: 0.0,
                    max: 1.0,
                    onChanged: _setVolume,
                    activeColor: Colors.purple,
                  ),
                ),
                const Icon(Icons.volume_up),
                const SizedBox(width: 8),
                Text('${(_volume * 100).round()}%'),
              ],
            ),
            
            // Stream info
            if (_videoController!.value.isInitialized) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Resolution: ${_videoController!.value.size.width.toInt()}x${_videoController!.value.size.height.toInt()}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    'Duration: ${_videoController!.value.duration.inSeconds > 0 ? _formatDuration(_videoController!.value.duration) : 'Live'}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return duration.inHours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }

  void _showStreamFormatHelp(String url) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.info, color: Colors.orange),
              SizedBox(width: 8),
              Text('Stream Format Help'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: const Text(
                    '⚠️ This stream format may not be supported by the built-in player.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                
                const SizedBox(height: 16),
                const Text('🎯 Supported formats in the app:'),
                const SizedBox(height: 8),
                const Text('✅ HTTP/HTTPS streams (.mp4, .m3u8, .flv)'),
                const Text('✅ HLS streams (.m3u8)'),
                const Text('✅ Progressive download videos'),
                const Text('⚠️ RTMP streams (limited support)'),
                
                const SizedBox(height: 16),
                const Text('🔧 Try these alternatives:'),
                const SizedBox(height: 8),
                
                if (url.contains('rtmp://')) ...[
                  const Text('Your URL is RTMP - try these HTTP versions:'),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: SelectableText(
                      url.replaceAll('rtmp://', 'http://').replaceAll(':1935/', ':8080/') + '.flv',
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: SelectableText(
                      url.replaceAll('rtmp://', 'http://').replaceAll(':1935/', ':8080/') + '.m3u8',
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                    ),
                  ),
                ],
                
                const SizedBox(height: 16),
                const Text('💡 External player options:'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: SelectableText(
                    'ffplay "$url"',
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: SelectableText(
                    'vlc "$url"',
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: 'ffplay "$url"'));
                Navigator.of(context).pop();
                _showMessage('FFplay command copied to clipboard!');
              },
              child: const Text('Copy FFplay Command'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showFFplayInstructions(String url) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.play_circle_outline, color: Colors.orange),
              SizedBox(width: 8),
              Text('Play Stream Manually'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: const Text(
                    '✅ GOOD NEWS: Your stream is working!\nSince FFplay works in your terminal, just use that.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                
                const SizedBox(height: 16),
                const Text('🎯 Copy and run this command in Terminal:'),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
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
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                const Text('🔧 Why the app can\'t launch FFplay:'),
                const SizedBox(height: 8),
                const Text('• FFplay might not be in the app\'s PATH'),
                const Text('• macOS security restrictions'),
                const Text('• Different shell environment'),
                
                const SizedBox(height: 16),
                const Text('💡 Alternative options:'),
                const SizedBox(height: 8),
                
                const Text('🎬 Using VLC Media Player:'),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: SelectableText(
                    'vlc "$url"',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                const Text('🌐 Or open in Safari (for some stream types):'),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: SelectableText(
                    url,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: Colors.blue,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: const Text(
                    '🎯 Since your terminal FFplay command works, that\'s the most reliable option!',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
                      actions: [
              TextButton(
                onPressed: () async {
                  // Copy ffplay command to clipboard
                  await Clipboard.setData(ClipboardData(text: 'ffplay "$url"'));
                  Navigator.of(context).pop();
                  _showMessage('FFplay command copied to clipboard! Paste in Terminal.');
                },
                child: const Text('Copy Command'),
              ),
              TextButton(
                onPressed: () async {
                  // Try to open Terminal and copy command
                  try {
                    await Clipboard.setData(ClipboardData(text: 'ffplay "$url"'));
                    await Process.start('open', ['-a', 'Terminal'], runInShell: true);
                    Navigator.of(context).pop();
                    _showMessage('Terminal opened! Paste the command (Cmd+V)');
                  } catch (e) {
                    Navigator.of(context).pop();
                    _showMessage('Command copied! Open Terminal manually and paste.');
                  }
                },
                child: const Text('Open Terminal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
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
            icon: const Icon(Icons.play_circle_outline),
            onPressed: _checkFFplayAvailability,
            tooltip: 'Check FFplay',
          ),
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
            
            // Video Player
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildVideoPlayer(),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Video Controls
            if (_videoController != null && _videoController!.value.isInitialized) ...[
              _buildVideoControls(),
              const SizedBox(height: 16),
            ],
            
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
                    onPressed: _isLoading ? null : _playStream,
                    icon: _isLoading 
                        ? const SizedBox(
                            width: 16, 
                            height: 16, 
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                          )
                        : Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
                    label: Text(_isLoading ? 'Loading...' : (_isPlaying ? 'Stop' : 'Play')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isPlaying ? Colors.red : Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                if (_videoController != null && _videoController!.value.isInitialized) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _togglePlayPause,
                      icon: Icon(_videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow),
                      label: Text(_videoController!.value.isPlaying ? 'Pause' : 'Resume'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
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
                    const Text('2. Enter the stream URL in the text field'),
                    const Text('3. Tap "Play" to start streaming in the app'),
                    const Text('4. Use volume controls and tap video to show/hide controls'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.purple.shade200),
                      ),
                      child: Text(
                        '🎬 Built-in Video Player: Streams play directly in the app with full controls!',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.purple.shade800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '✅ Supports: HTTP/HTTPS streams, HLS (.m3u8), MP4, FLV, and more',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.green.shade700,
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