import 'dart:convert';
import 'package:http/http.dart' as http;
import 'video_api.dart';

class VideoApiHttp implements VideoApi {
  final String baseUrl;

  VideoApiHttp({required this.baseUrl});

  @override
  Future<Map<String, dynamic>?> requestVideoStream({
    required String sessionToken,
    required String deviceId,
    required int channel,
    String? requestId,
  }) {
    return _postRequest(
      endpoint: '/video/request',
      sessionToken: sessionToken,
      body: {
        "deviceId": deviceId,
        "channel": channel,
        if (requestId != null) "requestId": requestId,
      },
    );
  }

  @override
  Future<Map<String, dynamic>?> getVideoResult({
    required String sessionToken,
    required String requestId,
  }) {
    return _getRequest(
      endpoint: '/video/result?requestId=$requestId',
      sessionToken: sessionToken,
    );
  }

  @override
  Future<Map<String, dynamic>> closeVideoStream({
    required String sessionToken,
    required String deviceId,
    required int channel,
  }) {
    return _postRequest(
      endpoint: '/video/close',
      sessionToken: sessionToken,
      body: {
        'deviceId': deviceId,
        'channel': channel,
      },
    );
  }

  @override
  Future<Map<String, dynamic>> switchVideoStream({
    required String deviceId,
    required int channel,
    required String sessionToken,
  }) {
    return _postRequest(
      endpoint: '/video/switch',
      body: {
        'deviceId': deviceId,
        'channel': channel,
      },
      sessionToken: sessionToken,
    );
  }

  @override
  Future<Map<String, dynamic>> pauseVideoStream({
    required String deviceId,
    required int channel,
    required String sessionToken,
  }) {
    return _postRequest(
      endpoint: '/video/pause',
      body: {
        'deviceId': deviceId,
        'channel': channel,
        'action': 'pause',
      },
      sessionToken: sessionToken,
    );
  }

  @override
  Future<Map<String, dynamic>> resumeVideoStream({
    required String sessionToken,
    required String deviceId,
    required int channel,
  }) {
    return _postRequest(
      endpoint: '/video/resume',
      body: {
        'deviceId': deviceId,
        'channel': channel,
        'action': 'resume',
      },
      sessionToken: sessionToken,
    );
  }

  @override
  Future<Map<String, dynamic>> stopIntercom({
    required String sessionToken,
    required String deviceId,
    required int channel,
  }) {
    return _postRequest(
      endpoint: '/video/stop-intercom',
      sessionToken: sessionToken,
      body: {
        'deviceId': deviceId,
        'channel': channel,
      },
    );
  }

  @override
  Future<Map<String, dynamic>> requestVideoPlayback({
    required String sessionToken,
    required String deviceId,
    required int channel,
    required String startTime,
    required String endTime,
    required int streamType,
    String? requestId,
  }) {
    return _postRequest(
      endpoint: '/video/playback',
      sessionToken: sessionToken,
      body: {
        'deviceId': deviceId,
        'channel': channel,
        'startTime': startTime,
        'endTime': endTime,
        'streamType': streamType,
        if (requestId != null) 'requestId': requestId,
      },
    );
  }

  @override
  Future<Map<String, dynamic>> getPlaybackResult({
    required String sessionToken,
    required String requestId,
  }) {
    return _getRequest(
      endpoint: '/video/playback/result?requestId=$requestId',
      sessionToken: sessionToken,
    );
  }

  @override
  Future<Map<String, dynamic>> pausePlayback({
    required String sessionToken,
    required String deviceId,
    required int channel,
  }) {
    return _postRequest(
      endpoint: '/video/playback/pause',
      sessionToken: sessionToken,
      body: {
        'deviceId': deviceId,
        'channel': channel,
      },
    );
  }

  @override
  Future<Map<String, dynamic>> resumePlayback({
    required String sessionToken,
    required String deviceId,
    required int channel,
    int? playSpeed,
  }) {
    return _postRequest(
      endpoint: '/video/playback/resume',
      sessionToken: sessionToken,
      body: {
        'deviceId': deviceId,
        'channel': channel,
        if (playSpeed != null) 'playSpeed': playSpeed,
      },
    );
  }

  @override
  Future<Map<String, dynamic>> fastForwardPlayback({
    required String sessionToken,
    required String deviceId,
    required int channel,
    required int playSpeed,
  }) {
    return _postRequest(
      endpoint: '/video/playback/fast-forward',
      sessionToken: sessionToken,
      body: {
        'deviceId': deviceId,
        'channel': channel,
        'playSpeed': playSpeed,
      },
    );
  }

  @override
  Future<Map<String, dynamic>> rewindPlayback({
    required String sessionToken,
    required String deviceId,
    required int channel,
    required int playSpeed,
  }) {
    return _postRequest(
      endpoint: '/video/playback/rewind',
      sessionToken: sessionToken,
      body: {
        'deviceId': deviceId,
        'channel': channel,
        'playSpeed': playSpeed,
      },
    );
  }

  @override
  Future<Map<String, dynamic>> seekPlayback({
    required String sessionToken,
    required String deviceId,
    required int channel,
    required String playAt,
  }) {
    return _postRequest(
      endpoint: '/video/playback/seek',
      sessionToken: sessionToken,
      body: {
        'deviceId': deviceId,
        'channel': channel,
        'playAt': playAt,
      },
    );
  }

  @override
  Future<Map<String, dynamic>> stopPlayback({
    required String sessionToken,
    required String deviceId,
    required int channel,
  }) {
    return _postRequest(
      endpoint: '/video/playback/stop',
      sessionToken: sessionToken,
      body: {
        'deviceId': deviceId,
        'channel': channel,
      },
    );
  }

  @override
  Future<Map<String, dynamic>> uploadVideoToFTP({
    required String sessionToken,
    required String deviceId,
    required int channel,
    required String username,
    required String password,
    required String uploadPath,
    required String startTime,
    required String endTime,
    required int alarmSign,
    required int avResourceType,
    required int streamType,
    required int storageType,
    required int uploadCondition,
    String? requestId,
  }) {
    return _postRequest(
      endpoint: '/video/upload',
      sessionToken: sessionToken,
      body: {
        'deviceId': deviceId,
        'channel': channel,
        'username': username,
        'password': password,
        'uploadPath': uploadPath,
        'startTime': startTime,
        'endTime': endTime,
        'alarmSign': alarmSign,
        'avResourceType': avResourceType,
        'streamType': streamType,
        'storageType': storageType,
        'uploadCondition': uploadCondition,
        if (requestId != null) 'requestId': requestId,
      },
    );
  }

  @override
  Future<Map<String, dynamic>> getUploadCompleteStatus({
    required String sessionToken,
    required String requestId,
  }) {
    return _getRequest(
      endpoint: '/video/upload/complete?requestId=$requestId',
      sessionToken: sessionToken,
    );
  }

  @override
  Future<Map<String, dynamic>> controlVideoUpload({
    required String sessionToken,
    required String deviceId,
    required int serialNumber,
    required int uploadControl,
  }) {
    return _postRequest(
      endpoint: '/video/upload/control',
      sessionToken: sessionToken,
      body: {
        'deviceId': deviceId,
        'serialNumber': serialNumber,
        'uploadControl': uploadControl,
      },
    );
  }

  @override
  Future<Map<String, dynamic>> requestVideoList({
    required String sessionToken,
    required String deviceId,
    required int channel,
    required String startTime,
    required String endTime,
    required int alarmSign,
    required int avResourceType,
    required int streamType,
    required int memoryType,
    String? requestId,
  }) {
    return _postRequest(
      endpoint: '/video/list',
      sessionToken: sessionToken,
      body: {
        'deviceId': deviceId,
        'channel': channel,
        'startTime': startTime,
        'endTime': endTime,
        'alarmSign': alarmSign,
        'avResourceType': avResourceType,
        'streamType': streamType,
        'memoryType': memoryType,
        if (requestId != null) 'requestId': requestId,
      },
    );
  }

  @override
  Future<Map<String, dynamic>> getVideoListResult({
    required String sessionToken,
    required String requestId,
  }) {
    return _getRequest(
      endpoint: '/video/list/result?requestId=$requestId',
      sessionToken: sessionToken,
    );
  }

  @override
  Future<Map<String, dynamic>> configureVideoParameters({
    required String sessionToken,
    required String deviceId,
    required int channel,
    required int liveStreamEncodingMode,
    required int liveStreamResolution,
    required int liveStreamKeyframeInterval,
    required int liveStreamTargetFrameRate,
    required int liveStreamTargetBitRate,
    required int saveStreamEncodingMode,
    required int saveStreamResolution,
    required int saveStreamKeyframeInterval,
    required int saveStreamTargetFrameRate,
    required int saveStreamTargetBitRate,
    required int osdSubtitleOverlay,
    required int enableAudioOutput,
  }) {
    return _postRequest(
      endpoint: '/video/configure',
      sessionToken: sessionToken,
      body: {
        'deviceId': deviceId,
        'channel': channel,
        'liveStreamEncodingMode': liveStreamEncodingMode,
        'liveStreamResolution': liveStreamResolution,
        'liveStreamKeyframeInterval': liveStreamKeyframeInterval,
        'liveStreamTargetFrameRate': liveStreamTargetFrameRate,
        'liveStreamTargetBitRate': liveStreamTargetBitRate,
        'saveStreamEncodingMode': saveStreamEncodingMode,
        'saveStreamResolution': saveStreamResolution,
        'saveStreamKeyframeInterval': saveStreamKeyframeInterval,
        'saveStreamTargetFrameRate': saveStreamTargetFrameRate,
        'saveStreamTargetBitRate': saveStreamTargetBitRate,
        'osdSubtitleOverlay': osdSubtitleOverlay,
        'enableAudioOutput': enableAudioOutput,
      },
    );
  }

  // Private POST helper
  Future<Map<String, dynamic>> _postRequest({
    required String endpoint,
    required Map<String, dynamic> body,
    required String sessionToken,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'etSession': sessionToken,
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'POST $endpoint failed: ${response.statusCode} ${response.body}',
      );
    }
  }

  // Private GET helper
  Future<Map<String, dynamic>> _getRequest({
    required String endpoint,
    required String sessionToken,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'etSession': sessionToken,
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'GET $endpoint failed: ${response.statusCode} ${response.body}',
      );
    }
  }
}