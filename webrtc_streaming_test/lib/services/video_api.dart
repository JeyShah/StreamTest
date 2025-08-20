abstract class VideoApi {
  Future<Map<String, dynamic>?> requestVideoStream({
    required String sessionToken,
    required String deviceId,
    required int channel,
    String? requestId,
  });

  Future<Map<String, dynamic>?> getVideoResult({
    required String sessionToken,
    required String requestId,
  });

  Future<Map<String, dynamic>> closeVideoStream({
    required String sessionToken,
    required String deviceId,
    required int channel,
  });

  Future<Map<String, dynamic>> switchVideoStream({
    required String sessionToken,
    required String deviceId,
    required int channel,
  });

  Future<Map<String, dynamic>> pauseVideoStream({
    required String sessionToken,
    required String deviceId,
    required int channel,
  });

  Future<Map<String, dynamic>> resumeVideoStream({
    required String sessionToken,
    required String deviceId,
    required int channel,
  });

  Future<Map<String, dynamic>> stopIntercom({
    required String sessionToken,
    required String deviceId,
    required int channel,
  });

  Future<Map<String, dynamic>> requestVideoPlayback({
    required String sessionToken,
    required String deviceId,
    required int channel,
    required String startTime,
    required String endTime,
    required int streamType,
    String? requestId,
  });

  Future<Map<String, dynamic>> getPlaybackResult({
    required String sessionToken,
    required String requestId,
  });

  Future<Map<String, dynamic>> pausePlayback({
    required String sessionToken,
    required String deviceId,
    required int channel,
  });

  Future<Map<String, dynamic>> resumePlayback({
    required String sessionToken,
    required String deviceId,
    required int channel,
    int? playSpeed,
  });

  Future<Map<String, dynamic>> fastForwardPlayback({
    required String sessionToken,
    required String deviceId,
    required int channel,
    required int playSpeed,
  });

  Future<Map<String, dynamic>> rewindPlayback({
    required String sessionToken,
    required String deviceId,
    required int channel,
    required int playSpeed,
  });

  Future<Map<String, dynamic>> seekPlayback({
    required String sessionToken,
    required String deviceId,
    required int channel,
    required String playAt,
  });

  Future<Map<String, dynamic>> stopPlayback({
    required String sessionToken,
    required String deviceId,
    required int channel,
  });

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
  });

  Future<Map<String, dynamic>> getUploadCompleteStatus({
    required String sessionToken,
    required String requestId,
  });

  Future<Map<String, dynamic>> controlVideoUpload({
    required String sessionToken,
    required String deviceId,
    required int serialNumber,
    required int uploadControl,
  });

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
  });

  Future<Map<String, dynamic>> getVideoListResult({
    required String sessionToken,
    required String requestId,
  });

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
  });

}