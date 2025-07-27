import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HLSVideoPlayerApp());
}

class HLSVideoPlayerApp extends StatelessWidget {
  const HLSVideoPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HLS Video Player',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const VideoPlayerScreen(),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  final TextEditingController _urlController = TextEditingController();
  VideoPlayerController? _videoPlayerController;
  VlcPlayerController? _vlcPlayerController;
  bool _isLoading = false;
  bool _isPlaying = false;
  String? _errorMessage;
  String _currentPlayer = 'None';

  @override
  void initState() {
    super.initState();
    _urlController.text = 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8';
  }

  @override
  void dispose() {
    _cleanup();
    _urlController.dispose();
    super.dispose();
  }

  void _cleanup() {
    _videoPlayerController?.dispose();
    _vlcPlayerController?.dispose();
    _videoPlayerController = null;
    _vlcPlayerController = null;
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
      _currentPlayer = 'Loading...';
    });

    try {
      _cleanup();

      if (kIsWeb) {
        // On web, video_player_web_hls will automatically handle HLS streams
        await _playWithVideoPlayer(url);
      } else {
        // Try VLC first for better HLS support on mobile/desktop
        try {
          await _playWithVlc(url);
        } catch (e) {
          debugPrint('VLC failed, falling back to video_player: $e');
          await _playWithVideoPlayer(url);
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isPlaying = false;
        _currentPlayer = 'Error';
      });
      _showError('Error loading video: ${e.toString()}');
    }
  }

  Future<void> _playWithVlc(String url) async {
    _vlcPlayerController = VlcPlayerController.network(
      url,
      hwAcc: HwAcc.full,
      autoPlay: true,
      options: VlcPlayerOptions(
        advanced: VlcAdvancedOptions([
          VlcAdvancedOptions.networkCaching(3000),
        ]),
        video: VlcVideoOptions([
          VlcVideoOptions.dropLateFrames(true),
          VlcVideoOptions.skipFrames(true),
        ]),
      ),
    );

    _vlcPlayerController!.addOnInitListener(() {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isPlaying = true;
          _currentPlayer = 'VLC Player';
        });
      }
    });

    // Add general state listener
    _vlcPlayerController!.addListener(() {
      if (mounted && _vlcPlayerController != null) {
        final isPlaying = _vlcPlayerController!.value.isPlaying;
        setState(() {
          _isPlaying = isPlaying;
        });
      }
    });

    await _vlcPlayerController!.initialize();
  }

  Future<void> _playWithVideoPlayer(String url) async {
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(url),
      httpHeaders: {
        'User-Agent': 'HLS Video Player Flutter App',
      },
    );

    _videoPlayerController!.addListener(() {
      if (mounted) {
        setState(() {
          _isPlaying = _videoPlayerController!.value.isPlaying;
        });
        
        // Check for errors
        if (_videoPlayerController!.value.hasError) {
          _showError('Video player error: ${_videoPlayerController!.value.errorDescription}');
        }
      }
    });

    await _videoPlayerController!.initialize();
    await _videoPlayerController!.play();

    setState(() {
      _isLoading = false;
      _isPlaying = true;
      _currentPlayer = kIsWeb ? 'HLS Web Player' : 'Standard Player';
    });
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _stopVideo() {
    _videoPlayerController?.pause();
    _vlcPlayerController?.pause();
    
    setState(() {
      _isPlaying = false;
      _currentPlayer = 'Stopped';
    });
  }

  void _togglePlayPause() {
    if (_vlcPlayerController != null) {
      if (_isPlaying) {
        _vlcPlayerController!.pause();
      } else {
        _vlcPlayerController!.play();
      }
    } else if (_videoPlayerController != null) {
      if (_videoPlayerController!.value.isPlaying) {
        _videoPlayerController!.pause();
      } else {
        _videoPlayerController!.play();
      }
    }
  }

  Widget _buildTestUrlButton(String title, String url) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: SizedBox(
        width: double.infinity,
        child: TextButton(
          onPressed: () {
            _urlController.text = url;
          },
          style: TextButton.styleFrom(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
          child: Text(
            '$title\n$url',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).primaryColor,
            ),
            textAlign: TextAlign.left,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('HLS Video Player'),
        centerTitle: true,
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
                    Text(
                      'HLS Stream URL (.m3u8)',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _urlController,
                      decoration: const InputDecoration(
                        hintText: 'Enter HLS stream URL (e.g., .m3u8)',
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
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.play_arrow),
                            label: Text(_isLoading ? 'Loading...' : 'Play Stream'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _isPlaying ? _stopVideo : null,
                          icon: const Icon(Icons.stop),
                          label: const Text('Stop'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Status: ',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          _isPlaying ? 'Playing ($_currentPlayer)' : _currentPlayer,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _isPlaying ? Colors.green : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Working Test URLs Section
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Working Test URLs:',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTestUrlButton('Mux HLS Test', 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8'),
                    _buildTestUrlButton('Apple Sample HLS', 'https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8'),
                    _buildTestUrlButton('Big Buck Bunny MP4', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Video Player Section
            Expanded(
              child: Card(
                elevation: 4,
                child: _buildVideoPlayer(),
              ),
            ),
            
            // Control buttons when playing
            if (_isPlaying) 
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _togglePlayPause,
                      icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                      label: Text(_isPlaying ? 'Pause' : 'Play'),
                    ),
                  ],
                ),
              ),
            
            // Status Section
            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading video...'),
          ],
        ),
      );
    }

    // VLC Player for mobile/desktop
    if (!kIsWeb && _vlcPlayerController != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: VlcPlayer(
          controller: _vlcPlayerController!,
          aspectRatio: 16 / 9,
          placeholder: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    // Standard Video Player (with HLS support on web via video_player_web_hls)
    if (_videoPlayerController != null && _videoPlayerController!.value.isInitialized) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: AspectRatio(
          aspectRatio: _videoPlayerController!.value.aspectRatio,
          child: Stack(
            children: [
              VideoPlayer(_videoPlayerController!),
              // Progress indicator overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: VideoProgressIndicator(
                  _videoPlayerController!,
                  allowScrubbing: true,
                  colors: const VideoProgressColors(
                    playedColor: Colors.red,
                    bufferedColor: Colors.grey,
                    backgroundColor: Colors.black26,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Enter an HLS stream URL and tap Play to start',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Supports HLS (.m3u8) streams and MP4 videos',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
            if (kIsWeb) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  border: Border.all(color: Colors.blue.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Web Platform: Using video_player_web_hls for optimal HLS support',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
