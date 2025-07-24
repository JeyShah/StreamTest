import 'dart:html' as html;
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'web/web_view_factory.dart'
  if (dart.library.io) 'web_view_factory_stub.dart';
  if (dart.library.html) 'web/web_view_factory.dart'
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

import 'web_hls_player.dart';

class HLSPlayerPage extends StatefulWidget {
  const HLSPlayerPage({super.key});

  @override
  State<HLSPlayerPage> createState() => _HLSPlayerPageState();
}

class _HLSPlayerPageState extends State<HLSPlayerPage> {
  final TextEditingController _urlController = TextEditingController();
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isLoading = false;
  bool _isPlaying = false;
  String _status = 'Enter HLS URL to start';
  final String _elementId = 'hls-video-element';

  @override
  void initState() {
    super.initState();
    _urlController.text = 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8';
  }

  @override
  void dispose() {
    if (!kIsWeb) {
      _chewieController?.dispose();
      _videoController?.dispose();
    }
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

    if (kIsWeb) {
      setState(() {
        _isLoading = false;
        _isPlaying = true;
        _status = 'Playing (Web)';
      });
      return;
    }

    try {
      await _chewieController?.pause();
      _chewieController?.dispose();
      await _videoController?.dispose();

      _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
      await _videoController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      );

      setState(() {
        _isLoading = false;
        _isPlaying = true;
        _status =
            'Playing: ${_videoController!.value.size.width.toInt()}x${_videoController!.value.size.height.toInt()}';
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
    if (kIsWeb) {
      html.document.getElementById(_elementId)?.remove();
    } else {
      await _chewieController?.pause();
      _chewieController?.dispose();
      await _videoController?.dispose();

      _chewieController = null;
      _videoController = null;
    }

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

  Widget _buildPlayer() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (kIsWeb) {
      return WebHLSPlayer(url: _urlController.text.trim());
    } else if (_chewieController != null &&
        _chewieController!.videoPlayerController.value.isInitialized) {
      return Chewie(controller: _chewieController!);
    } else {
      return const Center(
        child: Text(
          'Enter a URL and press Play',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HLS Video Player'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'HLS Stream URL (.m3u8)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _playVideo,
              icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
              label: Text(_isPlaying ? 'Stop' : 'Play'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isPlaying ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            Text(_status),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.black,
                child: _buildPlayer(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}