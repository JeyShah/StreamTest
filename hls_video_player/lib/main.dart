import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

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
  bool _showControls = true;
  bool _useVlcPlayer = true;

  @override
  void initState() {
    super.initState();
    // Pre-fill with a working test URL
    _urlController.text = 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8';
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _vlcPlayerController?.dispose();
    _urlController.dispose();
    super.dispose();
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
      if (_useVlcPlayer && !kIsWeb) {
        // Use VLC player for better HLS support on mobile/desktop
        await _playWithVlc(url);
      } else {
        // Use video_player for web or as fallback
        await _playWithVideoPlayer(url);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isPlaying = false;
      });
      
      String errorMessage = 'Error loading video: ';
      
      if (e.toString().contains('NetworkException') || 
          e.toString().contains('SocketException') ||
          e.toString().contains('HttpException')) {
        errorMessage += 'Network error. Check if the URL is accessible and supports CORS.';
      } else if (e.toString().contains('FormatException')) {
        errorMessage += 'Invalid video format. Try HLS (.m3u8), MP4, or FLV streams.';
      } else if (e.toString().contains('PlatformException')) {
        errorMessage += 'Platform error. This format may not be supported on web.';
      } else {
        errorMessage += e.toString();
      }
      
      _showError(errorMessage);
    }
  }

  Future<void> _playWithVlc(String url) async {
    // Dispose of previous controllers
    await _videoPlayerController?.dispose();
    _vlcPlayerController?.dispose();
    
    setState(() {
      _videoPlayerController = null;
    });

    // Create VLC player controller
    _vlcPlayerController = VlcPlayerController.network(
      url,
      hwAcc: HwAcc.full,
      autoPlay: true,
      options: VlcPlayerOptions(
        advanced: VlcAdvancedOptions([
          VlcAdvancedOptions.networkCaching(2000),
          VlcAdvancedOptions.clockJitter(0),
        ]),
        video: VlcVideoOptions([
          VlcVideoOptions.dropLateFrames(true),
          VlcVideoOptions.skipFrames(true),
        ]),
        sout: VlcStreamOutputOptions([
          VlcStreamOutputOptions.soutMuxCaching(2000),
        ]),
        rtp: VlcRtpOptions([
          VlcRtpOptions.rtpOverRtsp(true),
        ]),
      ),
    );

    // Add listeners
    _vlcPlayerController!.addOnInitListener(() async {
      setState(() {
        _isLoading = false;
        _isPlaying = true;
      });
    });

    _vlcPlayerController!.addOnRendererEventListener((type, id, name) {
      // Renderer event listener for debugging
    });

    await _vlcPlayerController!.initialize();
  }

  Future<void> _playWithVideoPlayer(String url) async {
    // Dispose of previous controllers
    await _videoPlayerController?.dispose();
    _vlcPlayerController?.dispose();
    
    setState(() {
      _vlcPlayerController = null;
    });

    // Create video player controller
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(url),
      httpHeaders: {
        'User-Agent': 'HLS Video Player Flutter App',
      },
    );

    // Add listener for player state changes
    _videoPlayerController!.addListener(_videoPlayerListener);

    // Initialize the video player
    await _videoPlayerController!.initialize();

    // Start playing
    await _videoPlayerController!.play();

    setState(() {
      _isLoading = false;
      _isPlaying = true;
    });
  }

  void _videoPlayerListener() {
    if (_videoPlayerController != null) {
      setState(() {
        _isPlaying = _videoPlayerController!.value.isPlaying;
      });
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
    _videoPlayerController?.pause();
    _videoPlayerController?.dispose();
    _vlcPlayerController?.stop();
    _vlcPlayerController?.dispose();
    setState(() {
      _videoPlayerController = null;
      _vlcPlayerController = null;
      _isPlaying = false;
      _errorMessage = null;
    });
  }

  void _togglePlayPause() {
    if (_vlcPlayerController != null) {
      if (_isPlaying) {
        _vlcPlayerController!.pause();
      } else {
        _vlcPlayerController!.play();
      }
      setState(() {
        _isPlaying = !_isPlaying;
      });
    } else if (_videoPlayerController != null) {
      if (_videoPlayerController!.value.isPlaying) {
        _videoPlayerController!.pause();
      } else {
        _videoPlayerController!.play();
      }
    }
  }

  void _toggleMute() {
    if (_vlcPlayerController != null) {
      _vlcPlayerController!.getVolume().then((volume) {
        final currentVolume = volume ?? 0;
        _vlcPlayerController!.setVolume(currentVolume > 0 ? 0 : 100);
      });
    } else if (_videoPlayerController != null) {
      final currentVolume = _videoPlayerController!.value.volume;
      _videoPlayerController!.setVolume(currentVolume > 0 ? 0.0 : 1.0);
      setState(() {});
    }
  }



  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    } else {
      return '$minutes:${twoDigits(seconds)}';
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
                      'Stream URL',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _urlController,
                      decoration: const InputDecoration(
                        hintText: 'Enter HLS stream URL (e.g., .m3u8, .flv)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.link),
                        helperText: 'Try: https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
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
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.play_arrow),
                            label: Text(_isLoading ? 'Loading...' : 'Play Stream'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _videoPlayerController != null ? _stopVideo : null,
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
                      // Player selection
                      if (!kIsWeb) ...[
                        Row(
                          children: [
                            Text(
                              'Player: ',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Switch(
                              value: _useVlcPlayer,
                              onChanged: (value) {
                                setState(() {
                                  _useVlcPlayer = value;
                                });
                              },
                            ),
                            Text(
                              _useVlcPlayer ? 'VLC (Better HLS)' : 'Standard',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
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
                    _buildTestUrlButton('HLS Test Stream', 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8'),
                    _buildTestUrlButton('Big Buck Bunny MP4', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4'),
                    _buildTestUrlButton('Sintel MP4', 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4'),
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

    

    // VLC Player
    if (_vlcPlayerController != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          alignment: Alignment.center,
          children: [
            VlcPlayer(
              controller: _vlcPlayerController!,
              aspectRatio: 16 / 9,
              placeholder: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            // Custom controls overlay for VLC
            if (_showControls)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Control buttons for VLC
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: _togglePlayPause,
                              icon: Icon(
                                _isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            IconButton(
                              onPressed: _toggleMute,
                              icon: const Icon(
                                Icons.volume_up,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'VLC Player',
                              style: TextStyle(color: Colors.white70),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _showControls = !_showControls;
                                });
                              },
                              icon: const Icon(
                                Icons.settings,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // Tap to toggle controls
            GestureDetector(
              onTap: () {
                setState(() {
                  _showControls = !_showControls;
                });
              },
              child: Container(
                color: Colors.transparent,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ],
        ),
      );
    }

    // Standard Video Player
    if (_videoPlayerController != null && _videoPlayerController!.value.isInitialized) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: _videoPlayerController!.value.aspectRatio,
              child: VideoPlayer(_videoPlayerController!),
            ),
            // Custom controls overlay
            if (_showControls)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Progress bar
                      VideoProgressIndicator(
                        _videoPlayerController!,
                        allowScrubbing: true,
                        colors: const VideoProgressColors(
                          playedColor: Colors.red,
                          bufferedColor: Colors.grey,
                          backgroundColor: Colors.black26,
                        ),
                      ),
                      // Control buttons
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: _togglePlayPause,
                              icon: Icon(
                                _isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            IconButton(
                              onPressed: _toggleMute,
                              icon: Icon(
                                _videoPlayerController!.value.volume > 0
                                    ? Icons.volume_up
                                    : Icons.volume_off,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatDuration(_videoPlayerController!.value.position),
                              style: const TextStyle(color: Colors.white),
                            ),
                            const Text(
                              ' / ',
                              style: TextStyle(color: Colors.white),
                            ),
                            Text(
                              _formatDuration(_videoPlayerController!.value.duration),
                              style: const TextStyle(color: Colors.white),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _showControls = !_showControls;
                                });
                              },
                              icon: const Icon(
                                Icons.settings,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // Tap to toggle controls
            GestureDetector(
              onTap: () {
                setState(() {
                  _showControls = !_showControls;
                });
              },
              child: Container(
                color: Colors.transparent,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ],
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
              'Enter a stream URL and tap Play to start',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Supports HLS (.m3u8), FLV, MP4, and other stream formats',
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
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue.shade700, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Web Platform Notes:',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Some HLS streams may not work due to CORS restrictions\n'
                      '• MP4 videos generally work better on web\n'
                      '• Try the working test URLs provided above',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
