import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'stream_config.dart';

class RTMPStreamingService {
  StreamConfig? _config;
  CameraController? _cameraController;
  bool _isStreaming = false;
  Process? _ffmpegProcess;
  
  // Callbacks
  Function(String)? onStatusChanged;
  Function(String)? onError;
  Function(String)? onMessage;

  RTMPStreamingService(StreamConfig config) {
    _config = config;
  }

  void updateConfig(StreamConfig config) {
    _config = config;
  }

  String get rtmpUrl => _config?.rtmpStreamUrl ?? '';
  String get streamKey => _config?.streamKey ?? '';
  String get outputUrl => _config?.outputUrl ?? '';
  bool get isStreaming => _isStreaming;

  Future<void> initializeCamera() async {
    try {
      // Get available cameras
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw 'No cameras available';
      }

      // Use the first available camera (usually front camera)
      final camera = cameras.first;
      
      _cameraController = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: true,
      );

      await _cameraController!.initialize();
      onMessage?.call('Camera initialized successfully');
      
    } catch (e) {
      debugPrint('❌ Error initializing camera: $e');
      onError?.call('Camera not available - FFmpeg streaming still works: $e');
      // Don't block the app - allow it to continue without camera preview
      onMessage?.call('Camera preview unavailable - Use FFmpeg commands for streaming');
    }
  }

  Future<void> startStreaming() async {
    if (_isStreaming) {
      onMessage?.call('Streaming already in progress');
      return;
    }

    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      onMessage?.call('Camera preview not available - FFmpeg streaming can still be used');
      // Continue anyway - camera preview is optional for FFmpeg streaming
    }

    try {
      onStatusChanged?.call('Starting RTMP stream...');
      
      // Note: This Flutter app provides camera preview and FFmpeg instructions
      // Actual RTMP streaming is done via external FFmpeg command
      onMessage?.call('Camera preview active - ready for streaming');

      // Generate FFmpeg command for the user
      await _startFFmpegStream();
      
      _isStreaming = true;
      onStatusChanged?.call('Ready for RTMP streaming');
      onMessage?.call('Use the FFmpeg command provided to start streaming');
      
    } catch (e) {
      debugPrint('❌ Error starting RTMP stream: $e');
      onError?.call('Failed to start RTMP stream: $e');
      onStatusChanged?.call('Stream failed');
    }
  }

  Future<void> _startFFmpegStream() async {
    try {
      // For now, we'll provide instructions for manual FFmpeg streaming
      // since direct camera-to-RTMP streaming requires platform-specific implementation
      
      final rtmpCommand = '''
FFmpeg command to stream to your server:

ffmpeg -f avfoundation -i "0:0" -c:v libx264 -c:a aac -f flv ${_config!.rtmpStreamUrl}

Where:
- Input: Camera and microphone (0:0 on macOS)
- Video codec: H.264
- Audio codec: AAC
- Output format: FLV
- RTMP URL: ${_config!.rtmpStreamUrl}

Your stream will be available at: ${_config!.outputUrl}
''';

      onMessage?.call(rtmpCommand);
      
      // Simulate streaming status
      _isStreaming = true;
      onStatusChanged?.call('Ready for RTMP streaming');
      
    } catch (e) {
      debugPrint('❌ Error setting up FFmpeg: $e');
      throw 'Failed to setup RTMP streaming: $e';
    }
  }

  Future<void> stopStreaming() async {
    if (!_isStreaming) {
      onMessage?.call('No active stream to stop');
      return;
    }

    try {
      onStatusChanged?.call('Stopping stream...');
      
      // Note: Camera preview continues, only streaming mode is disabled
      onMessage?.call('Streaming mode disabled - camera preview still active');

      // Stop FFmpeg process if running
      if (_ffmpegProcess != null) {
        _ffmpegProcess!.kill();
        _ffmpegProcess = null;
      }

      _isStreaming = false;
      onStatusChanged?.call('Stream stopped');
      onMessage?.call('RTMP stream stopped');
      
    } catch (e) {
      debugPrint('❌ Error stopping stream: $e');
      onError?.call('Failed to stop stream: $e');
    }
  }

  Future<void> dispose() async {
    await stopStreaming();
    
    if (_cameraController != null) {
      await _cameraController!.dispose();
      _cameraController = null;
    }
  }

  // Camera control methods
  Future<void> switchCamera() async {
    if (_cameraController == null) {
      onMessage?.call('Camera not available - cannot switch');
      return;
    }

    try {
      final cameras = await availableCameras();
      if (cameras.length < 2) {
        onMessage?.call('Only one camera available');
        return;
      }

      // Find the next camera
      final currentCamera = _cameraController!.description;
      final currentIndex = cameras.indexOf(currentCamera);
      final nextIndex = (currentIndex + 1) % cameras.length;
      final nextCamera = cameras[nextIndex];

      // Dispose current controller
      await _cameraController!.dispose();

      // Create new controller with next camera
      _cameraController = CameraController(
        nextCamera,
        ResolutionPreset.medium,
        enableAudio: true,
      );

      await _cameraController!.initialize();
      onMessage?.call('Switched to ${nextCamera.name}');
      
    } catch (e) {
      debugPrint('❌ Error switching camera: $e');
      onError?.call('Failed to switch camera: $e');
    }
  }

  Future<void> toggleFlash() async {
    if (_cameraController == null) {
      onMessage?.call('Camera not available - cannot toggle flash');
      return;
    }

    try {
      final currentFlashMode = _cameraController!.value.flashMode;
      final newFlashMode = currentFlashMode == FlashMode.off 
          ? FlashMode.torch 
          : FlashMode.off;
      
      await _cameraController!.setFlashMode(newFlashMode);
      onMessage?.call('Flash ${newFlashMode == FlashMode.torch ? 'on' : 'off'}');
      
    } catch (e) {
      debugPrint('❌ Error toggling flash: $e');
      onError?.call('Failed to toggle flash: $e');
    }
  }

  // Helper methods for RTMP streaming setup
  static String generateFFmpegCommand(StreamConfig config) {
    return '''
# Stream from video file:
ffmpeg -re -i ./your_video.mp4 -c copy -f flv ${config.rtmpStreamUrl}

# Stream from camera (macOS):
ffmpeg -f avfoundation -i "0:0" -c:v libx264 -c:a aac -f flv ${config.rtmpStreamUrl}

# Stream from camera (Linux):
ffmpeg -f v4l2 -i /dev/video0 -f alsa -i default -c:v libx264 -c:a aac -f flv ${config.rtmpStreamUrl}

# Stream from camera (Windows):
ffmpeg -f dshow -i video="Integrated Camera" -f dshow -i audio="Microphone" -c:v libx264 -c:a aac -f flv ${config.rtmpStreamUrl}
''';
  }

  static String getViewingInstructions(StreamConfig config) {
    return '''
View your stream with:

# Using FFplay:
ffplay ${config.outputUrl}

# Using VLC:
vlc ${config.outputUrl}

# In web browser:
${config.outputUrl}
''';
  }

  // Widget for camera preview
  Widget getCameraPreview() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return Container(
        color: Colors.grey.shade200,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.camera_alt_outlined,
                size: 64,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'Camera Preview Not Available',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Use FFmpeg commands to stream',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return CameraPreview(_cameraController!);
  }
}