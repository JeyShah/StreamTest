import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'web_hls_player.dart';
import 'locator.dart';
import 'services/video_api.dart';
import 'dart:developer' as developer;
import 'constants/global_functions.dart';
import 'constants/app_alert.dart';
import 'popup/video_configuration_dialog.dart';

class HLSPlayerPage extends StatefulWidget {
  const HLSPlayerPage({super.key});

  @override
  State<HLSPlayerPage> createState() => _HLSPlayerPageState();
}

class _HLSPlayerPageState extends State<HLSPlayerPage> {
  final videoApi = locator<VideoApi>();
  final TextEditingController _urlController = TextEditingController();
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isLoading = false;
  bool _isPlaying = false;
  String _status = 'Enter HLS URL to start';
  final deviceID = "66666353076524353";

  @override
  void initState() {
    super.initState();
    _initiateVideoStreaming();
    // _urlController.text = 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8';
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

  Future<void> _initiateVideoStreaming() async {
    final requestRes = await videoApi.requestVideoStream(
      sessionToken: "your-token",
      deviceId: deviceID,
      channel: 1,
    );

    print("Request video res: $requestRes");
    if (requestRes?['code'] == 9001) {
      final requestId = requestRes!['data']['requestId'];
      print("Success: Request ID: $requestId");

      // Second: get result
      final resultRes = await videoApi.getVideoResult(
        sessionToken: "your-token",
        requestId: requestId,
      );

      if (resultRes?['code'] == 9048) {
        final type = resultRes!['data']['responseType'];
        print("Response Type: $type");

        _urlController.text = convertFlvToM3u8(resultRes!['data']['videoUrl']);
        print("Response Type: ${_urlController.text}");
        print(_urlController.text);

        _playVideo();

        // switch (type) {
        //   case "stream_with_list":
        //     print("Video URL: ${resultRes['data']['videoUrl']}");
        //     print("Videos: ${resultRes['data']['videoList']['videos']}");
        //     break;
        //   case "stream":
        //     print("Video URL: ${resultRes['data']['videoUrl']}");
        //     break;
        //   case "list":
        //     print("Videos: ${resultRes['data']['videos']}");
        //     break;
        //   default:
        //     print("Unknown response type");
        // }
      }
    }
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
            'Playing: \${_videoController!.value.size.width.toInt()}x\${_videoController!.value.size.height.toInt()}';
      });

      _showMessage('Stream started successfully!');
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isPlaying = false;
        _status = 'Error: \${e.toString()}';
      });
      _showMessage('Failed to load stream: \$e');
    }
  }

  Future<void> _stopVideo() async {
    if (!kIsWeb) {
      await _chewieController?.pause();
      _chewieController?.dispose();
      await _videoController?.dispose();

      _chewieController = null;
      _videoController = null;
    }

    _closeStreamApi();

    setState(() {
      _isPlaying = false;
      _status = 'Stopped';
    });
  }

  /* SWITCH VIDEO STREAM API */
  Future<void> _switchVideoStreamApi() async {
    try {
      final result = await videoApi.switchVideoStream(
        sessionToken: "your-token",
        deviceId: deviceID,
        channel: 1,
      );

      if (result?['code'] == 9045) {
        showAppAlert(
          context: context,
          title: "Stream/Cammera Switch",
          message: "Your video stream/camera has been switched successfully.",
        );
      } else {
        showAppAlert(
          context: context,
          title: "Issue: Stream Switch",
          message: "Issue in switching stream/camera.",
        );
      }
      print('Stream video switch: $result');
    } catch (e) {
      print('Error: $e');
    }
  }

  /* PAUSE VIDEO STREAM API */
  Future<void> _pauseVideoStreamApi() async {
    try {
      final result = await videoApi.pauseVideoStream(
        sessionToken: "your-token",
        deviceId: deviceID,
        channel: 1,
      );

      if (result?['code'] == 9045) {
        showAppAlert(
          context: context,
          title: "Stream Paused",
          message: "Your video stream has been paused successfully.",
        );
      } else {
        showAppAlert(
          context: context,
          title: "Issue: Stream Pause",
          message: "Issue in pausing stream.",
        );
      }
      print('Stream paused: $result');
    } catch (e) {
      print('Error: $e');
    }
  }

  /* PAUSE VIDEO STREAM API */
  Future<void> _resumeVideoStreamApi() async {
    try {
      final result = await videoApi.resumeVideoStream(
        sessionToken: "your-token",
        deviceId: deviceID,
        channel: 1,
      );

      if (result?['code'] == 9045) {
        showAppAlert(
          context: context,
          title: "Stream Resumed",
          message: "Your video stream has been resumed successfully.",
        );
      } else {
        showAppAlert(
          context: context,
          title: "Issue: Stream Resume",
          message: "Issue in resuming stream.",
        );
      }
      print('Stream resumed: $result');
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _closeStreamApi() async {
    try {
      final result = await videoApi.closeVideoStream(
        sessionToken: "your-token",
        deviceId: deviceID,
        channel: 1,
      );
      if (result?['code'] == 9045) {
        showAppAlert(
          context: context,
          title: "Stream Closed",
          message: "Your video stream has been closed successfully.",
        );
      } else {
        showAppAlert(
          context: context,
          title: "Issue: Stream Closed",
          message: "Issue in closing stream.",
        );
      }
      print('Stream closed: $result');
    } catch (e) {
      print('Error: $e');
    }
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
            // Row with TextField + Configure button
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      labelText: 'HLS Stream URL (.m3u8)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.url,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: "Configure Video",
                  icon: const Icon(Icons.settings), // gear icon
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => VideoConfigDialog(
                        initialDeviceId: deviceID,
                        onSubmit: (data) async {
                          final requestRes = await videoApi.configureVideoParameters(
                            sessionToken: "your-token",
                            deviceId: data["deviceId"],
                            channel: data["channel"],
                            liveStreamEncodingMode: data["liveStreamEncodingMode"],
                            liveStreamResolution: data["liveStreamResolution"],
                            liveStreamKeyframeInterval: data["liveStreamKeyframeInterval"],
                            liveStreamTargetFrameRate: data["liveStreamTargetFrameRate"],
                            liveStreamTargetBitRate: data["liveStreamTargetBitRate"],
                            saveStreamEncodingMode: data["saveStreamEncodingMode"],
                            saveStreamResolution: data["saveStreamResolution"],
                            saveStreamKeyframeInterval: data["saveStreamKeyframeInterval"],
                            saveStreamTargetFrameRate: data["saveStreamTargetFrameRate"],
                            saveStreamTargetBitRate: data["saveStreamTargetBitRate"],
                            osdSubtitleOverlay: data["osdSubtitleOverlay"],
                            enableAudioOutput: data["enableAudioOutput"],
                          );

                          print("Video configuration res: $requestRes");
                          if (requestRes?['code'] == 9036) {
                            showAppAlert(
                              context: context,
                              title: "Video Settings",
                              message: "Your video configuration set successfully.",
                            );
                          }
                          else {
                            showAppAlert(
                              context: context,
                              title: "Issue: Video Settings",
                              message: "Issue in video configuration set.",
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
              ],
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

            ElevatedButton.icon(
              onPressed: _closeStreamApi,
              icon: const Icon(Icons.stop),
              label: const Text('Close Stream'),
            ),

            const SizedBox(height: 16),
            Text(_status),

            const SizedBox(height: 16),

            IconButton(
              tooltip: "Switch Camera",
              icon: const Icon(Icons.switch_camera), // <-- this is the switch camera icon
              onPressed: _switchVideoStreamApi
            ),

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