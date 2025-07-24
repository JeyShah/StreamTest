import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

void main() {
  runApp(const HLSVideoPlayerApp());
}

class HLSVideoPlayerApp extends StatelessWidget {
  const HLSVideoPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HLS Video Player',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HLSVideoPlayerScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HLSVideoPlayerScreen extends StatefulWidget {
  const HLSVideoPlayerScreen({super.key});

  @override
  State<HLSVideoPlayerScreen> createState() => _HLSVideoPlayerScreenState();
}

class _HLSVideoPlayerScreenState extends State<HLSVideoPlayerScreen> {
  final TextEditingController _urlController = TextEditingController();
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Default URL for testing
  static const String defaultURL = 'http://47.130.109.65:8080/hls/mystream.flv';

  @override
  void initState() {
    super.initState();
    _urlController.text = defaultURL;
  }

  @override
  void dispose() {
    _disposePlayer();
    _urlController.dispose();
    super.dispose();
  }

  void _disposePlayer() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    _chewieController = null;
    _videoPlayerController = null;
  }

  Future<void> _playVideo() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      _showError('Please enter a valid URL');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Dispose of any existing player
      _disposePlayer();

      // Create new video player controller
      if (kIsWeb) {
        // For web, use NetworkDataSource
        _videoPlayerController = VideoPlayerController.networkUrl(
          Uri.parse(url),
          httpHeaders: {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
            'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept',
          },
        );
      } else {
        // For mobile platforms
        _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url));
      }

      await _videoPlayerController!.initialize();

      // Create Chewie controller for better video controls
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        showControls: true,
        showControlsOnInitialize: true,
        allowFullScreen: true,
        allowMuting: true,
        showOptions: true,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                Text(
                  'Error: $errorMessage',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _playVideo,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        },
      );

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      _showError('Failed to load video: ${error.toString()}');
    }
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _stopVideo() {
    setState(() {
      _disposePlayer();
    });
  }

  String _getPlatformInfo() {
    if (kIsWeb) {
      return 'Web';
    } else if (Platform.isAndroid) {
      return 'Android';
    } else if (Platform.isIOS) {
      return 'iOS';
    } else if (Platform.isMacOS) {
      return 'macOS';
    } else if (Platform.isWindows) {
      return 'Windows';
    } else if (Platform.isLinux) {
      return 'Linux';
    } else {
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HLS Video Player'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Chip(
              label: Text(_getPlatformInfo()),
              backgroundColor: Colors.blue.shade100,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // URL Input Section
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enter HLS Stream URL:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _urlController,
                      decoration: const InputDecoration(
                        hintText: 'http://example.com/stream.m3u8',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.link),
                      ),
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _playVideo,
                            icon: _isLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.play_arrow),
                            label: Text(_isLoading ? 'Loading...' : 'Play Stream'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _chewieController != null ? _stopVideo : null,
                          icon: const Icon(Icons.stop),
                          label: const Text('Stop'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade100,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Video Player Section
            Expanded(
              child: Card(
                elevation: 4,
                child: Container(
                  width: double.infinity,
                  child: _chewieController != null
                      ? Chewie(controller: _chewieController!)
                      : _errorMessage != null
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.error, color: Colors.red, size: 64),
                                  const SizedBox(height: 16),
                                  Text(
                                    _errorMessage!,
                                    style: const TextStyle(color: Colors.red),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.videocam_off, size: 64, color: Colors.grey),
                                  SizedBox(height: 16),
                                  Text(
                                    'Enter a stream URL and press Play to start',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                ),
              ),
            ),
            
            // Info Section
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Supported Formats:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text('• HLS (.m3u8)'),
                    const Text('• MP4 (.mp4)'),
                    const Text('• WebM (.webm)'),
                    const Text('• FLV (.flv) - Limited support'),
                    const SizedBox(height: 8),
                    Text(
                      'Platform: ${_getPlatformInfo()}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
