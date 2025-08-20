class VideoConfig {
  String deviceId;
  int channel;
  int liveStreamEncodingMode;
  int liveStreamResolution;
  int liveStreamKeyframeInterval;
  int liveStreamTargetFrameRate;
  int liveStreamTargetBitRate;
  int saveStreamEncodingMode;
  int saveStreamResolution;
  int saveStreamKeyframeInterval;
  int saveStreamTargetFrameRate;
  int saveStreamTargetBitRate;
  int osdSubtitleOverlay;
  int enableAudioOutput;

  VideoConfig({
    required this.deviceId,
    this.channel = 1,
    this.liveStreamEncodingMode = 0,
    this.liveStreamResolution = 5,
    this.liveStreamKeyframeInterval = 30,
    this.liveStreamTargetFrameRate = 25,
    this.liveStreamTargetBitRate = 2048,
    this.saveStreamEncodingMode = 0,
    this.saveStreamResolution = 5,
    this.saveStreamKeyframeInterval = 30,
    this.saveStreamTargetFrameRate = 25,
    this.saveStreamTargetBitRate = 2048,
    this.osdSubtitleOverlay = 1,
    this.enableAudioOutput = 1,
  });

  Map<String, dynamic> toJson() => {
        "deviceId": deviceId,
        "channel": channel,
        "liveStreamEncodingMode": liveStreamEncodingMode,
        "liveStreamResolution": liveStreamResolution,
        "liveStreamKeyframeInterval": liveStreamKeyframeInterval,
        "liveStreamTargetFrameRate": liveStreamTargetFrameRate,
        "liveStreamTargetBitRate": liveStreamTargetBitRate,
        "saveStreamEncodingMode": saveStreamEncodingMode,
        "saveStreamResolution": saveStreamResolution,
        "saveStreamKeyframeInterval": saveStreamKeyframeInterval,
        "saveStreamTargetFrameRate": saveStreamTargetFrameRate,
        "saveStreamTargetBitRate": saveStreamTargetBitRate,
        "osdSubtitleOverlay": osdSubtitleOverlay,
        "enableAudioOutput": enableAudioOutput,
      };
}