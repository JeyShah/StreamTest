import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class HLSPlayerPage extends StatefulWidget {
  const HLSPlayerPage({super.key});

  @override
  State<HLSPlayerPage> createState() => _HLSPlayerPageState();
}

class _HLSPlayerPageState extends State<HLSPlayerPage> {
  final TextEditingController _urlController = TextEditingController();
  VideoPlayerController? _videoController;
  bool _isLoading = false;
  bool _isPlaying = false;
  String _status = 'Enter HLS URL to start';

  @override
  void initState() {
    super.initState();
    // Pre-fill with your HLS stream URL
    _urlController.text = 'http://47.130.109.65:8080/hls/mystream.m3u8';
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _playVideo() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      _showMessage('Please enter a stream URL');
      return;
    }

    if (_isPlaying) {
      await _stopVideo();
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'Loading stream...';
    });

    try {
      // Dispose existing controller
      await _videoController?.dispose();

      // Create new controller
      final uri = Uri.parse(url);
      _videoController = VideoPlayerController.networkUrl(uri);

      // Initialize and play
      await _videoController!.initialize();
      await _videoController!.play();

      setState(() {
        _isLoading = false;
        _isPlaying = true;
        _status = 'Playing: ${_videoController!.value.size.width.toInt()}x${_videoController!.value.size.height.toInt()}';
      });

      _showMessage('Stream started successfully!');

    } catch (e) {
      setState(() {
        _isLoading = false;
        _isPlaying = false;
        _status = 'Error: ${e.toString()}';
      });
      _showMessage('Failed to load stream: $e');
    }
  }

  Future<void> _stopVideo() async {
    await _videoController?.pause();
    await _videoController?.dispose();
    _videoController = null;

    setState(() {
      _isPlaying = false;
      _status = 'Stopped';
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HLS Video Player'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    _isPlaying ? Icons.play_circle : Icons.stop_circle,
                    color: _isPlaying ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _status,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // URL Input
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'HLS Stream URL',
                hintText: 'Enter .m3u8 URL here',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
              keyboardType: TextInputType.url,
            ),

            const SizedBox(height: 16),

            // Play Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _playVideo,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
              label: Text(_isLoading
                  ? 'Loading...'
                  : (_isPlaying ? 'Stop' : 'Play Stream')),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isPlaying ? Colors.red : Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),

            const SizedBox(height: 16),

            // Video Player
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildVideoPlayer(),
                ),
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
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Loading stream...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (_videoController != null && _videoController!.value.isInitialized) {
      return AspectRatio(
        aspectRatio: _videoController!.value.aspectRatio,
        child: VideoPlayer(_videoController!),
      );
    }

    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.play_circle_outline,
            size: 80,
            color: Colors.white54,
          ),
          SizedBox(height: 16),
          Text(
            'Enter HLS URL and tap Play',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Supports: .m3u8, .mp4, .flv and more',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}