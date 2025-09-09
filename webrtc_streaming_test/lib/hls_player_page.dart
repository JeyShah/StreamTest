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
  bool? _lastIsPlaying;
  bool _isVideoStream = true;
  Timer? _seekTimer;
  final GlobalKey<WebHLSPlayerState> _webPlayerKey = GlobalKey();
  DateTime? _playbackStartTime;
  Duration? _lastPosition;
  DateTime? _startDateTime;
  DateTime? _endDateTime;


  @override
  void initState() {
    super.initState();
    _initiateVideoStreaming();
    // _initiateVideoStreaming();
    // _initiatePlayback();
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

  void _startSeekTimer({required bool isForward}) {

    if (_isVideoStream) {
      // Live stream: just do local seek
    } else {
      if (isForward) {
        _fastForwardPlayback(); // API call
      } else {
        _rewindPlayback(); // API call
      }
    }

    _seekTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (kIsWeb) {
        // 🔹 Safari / Web handling
        // if (_webPlayerKey.currentState != null) {
        //   _webPlayerKey.currentState!.seekBy(
        //     isForward ? const Duration(seconds: 2) : const Duration(seconds: -2),
        //   );
        // }
        _webPlayerKey.currentState?.seekBy(
          isForward ? const Duration(seconds: 2) : const Duration(seconds: -2),
        );
        return;
      }

      // 🔹 Native platforms (Android/iOS with video_player)
      final controller = _videoController;
      if (controller == null || !controller.value.isInitialized) return;

      final pos = controller.value.position;
      final duration = controller.value.duration;

      final newPos = isForward
          ? pos + const Duration(seconds: 2)
          : pos - const Duration(seconds: 2);

      if (newPos < Duration.zero) {
        controller.seekTo(Duration.zero);
      } else if (newPos > duration) {
        controller.seekTo(duration);
      } else {
        controller.seekTo(newPos);
      }
    });
  }

  void _stopSeekTimer() {
    _seekTimer?.cancel();
    _seekTimer = null;

    if (!_isVideoStream) {
      // 🔹 Reset playback to normal speed
      _resumePlaybackApi();
    }
  }

  Future<DateTime?> _pickDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  String toIso8601WithZ(DateTime dt) =>
    dt.toUtc().toIso8601String().split('.').first + "Z";

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

  Future<void> _stopPlaybackApi() async {
    final requestRes = await videoApi.stopPlayback(
      sessionToken: "your-token",
      deviceId: deviceID,
      channel: 1
    );

    if (requestRes?['code'] == 9033) {
      showAppAlert(
        context: context,
        title: "Playback Closed",
        message: "Your playback has been closed successfully.",
      );
    } else {
      showAppAlert(
        context: context,
        title: "Issue: Playback Closed",
        message: "Issue in closing playback.",
      );
    }

    print("stop playback res: $requestRes");
  }

  Future<void> _initiatePlayback() async {
    final startTime = toIso8601WithZ(_startDateTime!);
    final endTime = toIso8601WithZ(_endDateTime!);

    final requestRes = await videoApi.requestVideoPlayback(
      sessionToken: "your-token",
      deviceId: deviceID,
      channel: 1,
      startTime: startTime,
      endTime: endTime,
      streamType: 0,
    );

    print("Request playback res: $requestRes");
    if (requestRes?['code'] == 9015) {
      final requestId = requestRes!['data']['requestId'];
      print("Success: Request ID: $requestId");

      // Second: get result
      final resultRes = await videoApi.getPlaybackResult(
        sessionToken: "your-token",
        requestId: requestId,
      );

      print("Success: Request ID playback: $resultRes");

      if (resultRes?['code'] == 9048) {
        final type = resultRes!['data']['responseType'];
        final startTime = DateTime.parse("2025-08-27T00:00:00Z");
        _playbackStartTime = startTime;
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
      await _isVideoStream ? _stopVideo() : _stopPlayback();
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

      await _initializeChewieController(url);

      setState(() {
        _isLoading = false;
        _isPlaying = true;
        _status =
            'Playing: ${_chewieController!.videoPlayerController.value.size.width.toInt()}x${_chewieController!.videoPlayerController.value.size.height.toInt()}';
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

  Future<void> _stopPlayback() async {
    if (!kIsWeb) {
      await _chewieController?.pause();
      _chewieController?.dispose();
      await _videoController?.dispose();

      _chewieController = null;
      _videoController = null;
    }

    _stopPlaybackApi();

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
          title: "Stream/Camera Switch",
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
        print("STREAM PAUSEDDDD");
        // showAppAlert(
        //   context: context,
        //   title: "Stream Paused",
        //   message: "Your video stream has been paused successfully.",
        // );
      } else {
        print("STREAM NOT PAUSEDDDD");
        // showAppAlert(
        //   context: context,
        //   title: "Issue: Stream Pause",
        //   message: "Issue in pausing stream.",
        // );
      }
      print('Stream paused: $result');
    } catch (e) {
      print('Error: $e');
    }
  }

  /* PAUSE PLAYBACK API */
  Future<void> _pausePlaybackApi() async {
    try {
      final result = await videoApi.pausePlayback(
        sessionToken: "your-token",
        deviceId: deviceID,
        channel: 1,
      );

      print("Playback pause: $result");

      // if (result?['code'] == 9045) {
      //   print("STREAM PAUSEDDDD");
      //   // showAppAlert(
      //   //   context: context,
      //   //   title: "Stream Paused",
      //   //   message: "Your video stream has been paused successfully.",
      //   // );
      // } else {
      //   print("STREAM NOT PAUSEDDDD");
      //   // showAppAlert(
      //   //   context: context,
      //   //   title: "Issue: Stream Pause",
      //   //   message: "Issue in pausing stream.",
      //   // );
      // }
      // print('Stream paused: $result');
    } catch (e) {
      print('Error: $e');
    }
  }

  /* RESUME PLAY BACK API */
  Future<void> _resumePlaybackApi() async {
    try {
      final result = await videoApi.resumePlayback(
        sessionToken: "your-token",
        deviceId: deviceID,
        channel: 1,
      );

      if (result?['code'] == 9045) {
        print("PLAYBACK RESUMMEDDDDD");
        // showAppAlert(
        //   context: context,
        //   title: "Stream Resumed",
        //   message: "Your video stream has been resumed successfully.",
        // );
      } else {
        print("PLAYBACK NOT RESUMMEDDDDD");
        // showAppAlert(
        //   context: context,
        //   title: "Issue: Stream Resume",
        //   message: "Issue in resuming stream.",
        // );
      }
      print('PLAYBACK resumed: $result');
    } catch (e) {
      print('Error: $e');
    }
  }

  /* RESUME VIDEO STREAM API */
  Future<void> _resumeVideoStreamApi() async {
    try {
      final result = await videoApi.resumeVideoStream(
        sessionToken: "your-token",
        deviceId: deviceID,
        channel: 1,
      );

      if (result?['code'] == 9045) {
        print("STREAM RESUMMEDDDDD");
        // showAppAlert(
        //   context: context,
        //   title: "Stream Resumed",
        //   message: "Your video stream has been resumed successfully.",
        // );
      } else {
        print("STREAM NOT RESUMMEDDDDD");
        // showAppAlert(
        //   context: context,
        //   title: "Issue: Stream Resume",
        //   message: "Issue in resuming stream.",
        // );
      }
      print('Stream resumed: $result');
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _fastForwardPlayback() async {
    try {
      final result = await videoApi.fastForwardPlayback(
        sessionToken: "your-token",
        deviceId: deviceID,
        channel: 1,
        playSpeed: 2,
      );

      if (result?['code'] == 9045) {
        
      } else {
        
      }
      print('fast forward playback res: $result');
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _rewindPlayback() async {
    try {
      final result = await videoApi.rewindPlayback(
        sessionToken: "your-token",
        deviceId: deviceID,
        channel: 1,
        playSpeed: 2,
      );

      if (result?['code'] == 9045) {
        
      } else {
        
      }
      print('Rewind playback res: $result');
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _seekPlaybackApi(String playAt) async {
    try {
      final result = await videoApi.seekPlayback(
        sessionToken: "your-token",
        deviceId: deviceID,
        channel: 1,
        playAt: playAt,
      );

      if (result?['code'] == 9045) {
        
      } else {
        
      }
      print('Seek playback res: $result');
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _stopIntercomApi() async {
    try {
      final result = await videoApi.stopIntercom(
        sessionToken: "your-token",
        deviceId: deviceID,
        channel: 1,
      );

      if (result?['code'] == 9045) {
        showAppAlert(
          context: context,
          title: "Stop Intercom",
          message: "Your intercom has been stopped successfully.",
        );
      } else {
        showAppAlert(
          context: context,
          title: "Issue: Stop Intercom",
          message: "Issue in stopping intercom.",
        );
      }
      print('Intercom stopped res: $result');
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

  void _handlePlayPause(bool isPlaying) {
    if (isPlaying) {
      _isVideoStream ? _resumeVideoStreamApi() : _resumePlaybackApi();
    } else {
      _isVideoStream ? _pauseVideoStreamApi() : _pausePlaybackApi();
    }
  }

  Future<void> _initializeChewieController(String url) async {
    _videoController = VideoPlayerController.network(url);
    await _videoController!.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoController!,
      autoPlay: true,
      looping: false,
    );

    // 🔹 Attach listener only once
    _chewieController!.videoPlayerController.addListener(_videoStateListener);

    setState(() {});
  }

  void _onWebSeek(Duration position) {
    if (!_isVideoStream && _playbackStartTime != null) {
      final playAt = _playbackStartTime!.add(position).toUtc().toIso8601String();
      _seekPlaybackApi(playAt); // <-- API call stays in parent
    }
  }

  Widget _buildPlayer() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (kIsWeb) {
      final url = _urlController.text.trim();
      if (url.isEmpty) {
        return const Center(child: Text("No URL provided"));
      }
      return WebHLSPlayer(
        key: _webPlayerKey,
        url: url, // ✅ always pass updated URL
        onPlayPauseChanged: _handlePlayPause,
        onSeek: _onWebSeek,
      );
    } else if (_chewieController != null &&
      _chewieController!.videoPlayerController.value.isInitialized) {
      // ✅ Native player (Chewie)
      final vpController = _chewieController!.videoPlayerController;

      // attach listener once
      vpController.removeListener(_videoStateListener);
      vpController.addListener(_videoStateListener);

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

  void _videoStateListener() {
    final vpController = _chewieController?.videoPlayerController;
    if (vpController == null || !vpController.value.isInitialized) return;

    final isPlaying = vpController.value.isPlaying;
    final position = vpController.value.position;

    // 🔹 Only trigger when actual state changes
    if (_lastIsPlaying != isPlaying) {
      _lastIsPlaying = isPlaying;

      if (isPlaying) {
        _resumeVideoStreamApi();
      } else {
        _pauseVideoStreamApi();
      }
    }

    // 🔹 Detect Seek (skip/rewind/drag)
    if (_lastPosition != null) {
      final diff = (position - _lastPosition!).inSeconds.abs();
      if (diff > 2) { // moved more than 2s → user dragged/seeked
        if (_playbackStartTime != null && !_isVideoStream) {
          final targetTime = _playbackStartTime!.add(position);
          final playAt = targetTime.toUtc().toIso8601String();
          _seekPlaybackApi(playAt); // ✅ call API
        }
      }
    }

    _lastPosition = position;
  }

  Widget _buildSwitchButton(String text, bool selected, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: selected ? Colors.blue : Colors.grey[300],
        foregroundColor: selected ? Colors.white : Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: onPressed,
      child: Text(text),
    );
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
            // --- Top row: Switch between Stream / Playback ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSwitchButton("Video Stream", _isVideoStream, () {
                  setState(() {
                    _isVideoStream = true;
                    _stopPlayback();
                    _startDateTime = null;
                    _endDateTime = null;
                    _initiateVideoStreaming();
                  });
                }),
                const SizedBox(width: 12),
                _buildSwitchButton("Playback", !_isVideoStream, () {
                  setState(() {
                    _isVideoStream = false;
                    _stopVideo();
                    // wait until user submits start/end times
                  });
                }),
              ],
            ),

            const SizedBox(height: 16),

            // --- Stream Mode: URL + Configure Video ---
            if (_isVideoStream) ...[
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
                    icon: const Icon(Icons.settings),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => VideoConfigDialog(
                          initialDeviceId: deviceID,
                          onSubmit: (data) async {
                            final requestRes =
                                await videoApi.configureVideoParameters(
                              sessionToken: "your-token",
                              deviceId: data["deviceId"],
                              channel: data["channel"],
                              liveStreamEncodingMode:
                                  data["liveStreamEncodingMode"],
                              liveStreamResolution:
                                  data["liveStreamResolution"],
                              liveStreamKeyframeInterval:
                                  data["liveStreamKeyframeInterval"],
                              liveStreamTargetFrameRate:
                                  data["liveStreamTargetFrameRate"],
                              liveStreamTargetBitRate:
                                  data["liveStreamTargetBitRate"],
                              saveStreamEncodingMode:
                                  data["saveStreamEncodingMode"],
                              saveStreamResolution:
                                  data["saveStreamResolution"],
                              saveStreamKeyframeInterval:
                                  data["saveStreamKeyframeInterval"],
                              saveStreamTargetFrameRate:
                                  data["saveStreamTargetFrameRate"],
                              saveStreamTargetBitRate:
                                  data["saveStreamTargetBitRate"],
                              osdSubtitleOverlay: data["osdSubtitleOverlay"],
                              enableAudioOutput: data["enableAudioOutput"],
                            );

                            print("Video configuration res: $requestRes");
                            if (requestRes?['code'] == 9036) {
                              showAppAlert(
                                context: context,
                                title: "Video Settings",
                                message:
                                    "Your video configuration set successfully.",
                              );
                            } else {
                              showAppAlert(
                                context: context,
                                title: "Issue: Video Settings",
                                message:
                                    "Issue in video configuration set.",
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ] else ...[
              // --- Playback Mode: Start/End Pickers + Submit ---
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final picked = await _pickDateTime(context);
                        if (picked != null) {
                          setState(() => _startDateTime = picked);
                        }
                      },
                      child: Text(_startDateTime == null
                          ? "Pick Start Time"
                          : "Start: ${_startDateTime.toString()}"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final picked = await _pickDateTime(context);
                        if (picked != null) {
                          setState(() => _endDateTime = picked);
                        }
                      },
                      child: Text(_endDateTime == null
                          ? "Pick End Time"
                          : "End: ${_endDateTime.toString()}"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.cloud_download),
                label: const Text("Submit Playback Request"),
                onPressed: () async {
                  if (_startDateTime == null || _endDateTime == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Please select both Start and End times")),
                    );
                    return;
                  }
                  await _initiatePlayback();
                },
              ),
            ],

            const SizedBox(height: 16),

            // --- Play / Stop main button ---
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _playVideo,
              icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
              label: Text(_isPlaying
                  ? _isVideoStream
                      ? 'Stop'
                      : 'Stop Playback'
                  : _isVideoStream
                      ? 'Play'
                      : 'Play Playback'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isPlaying ? Colors.red : Colors.green,
              ),
            ),

            const SizedBox(height: 16),

            // --- Close button ---
            ElevatedButton.icon(
              onPressed: _isVideoStream ? _stopVideo : _stopPlayback,
              icon: const Icon(Icons.stop),
              label: Text(_isVideoStream ? 'Close Stream' : 'Close Playback'),
            ),

            const SizedBox(height: 16),
            Text(_status),

            // --- Camera + Intercom controls ---
            Row(
              children: [
                const SizedBox(height: 16),
                IconButton(
                  tooltip: "Switch Camera",
                  icon: const Icon(Icons.switch_camera),
                  onPressed: _switchVideoStreamApi,
                ),
                const SizedBox(height: 16),
                IconButton(
                  tooltip: "Stop Intercom",
                  icon: const Icon(Icons.mic),
                  onPressed: _stopIntercomApi,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // --- Video Player ---
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.black,
                child: Stack(
                  children: [
                    Positioned.fill(child: _buildPlayer()),

                    // rewind zone
                    Positioned.fill(
                      right: MediaQuery.of(context).size.width / 2,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onLongPressStart: (_) {
                          _startSeekTimer(isForward: false);
                          setState(() => _status = "⏪ Rewinding...");
                        },
                        onLongPressEnd: (_) {
                          _stopSeekTimer();
                          setState(() => _status = "Playing");
                        },
                      ),
                    ),

                    // forward zone
                    Positioned.fill(
                      left: MediaQuery.of(context).size.width / 2,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onLongPressStart: (_) {
                          _startSeekTimer(isForward: true);
                          setState(() => _status = "⏩ Forwarding...");
                        },
                        onLongPressEnd: (_) {
                          _stopSeekTimer();
                          setState(() => _status = "Playing");
                        },
                      ),
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