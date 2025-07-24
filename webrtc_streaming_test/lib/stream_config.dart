class StreamConfig {
  // Your specific server configuration for RTMP streaming
  static const String inputServerIP = "47.130.109.65";
  static const int inputServerPort = 1935; // RTMP standard port
  static const String outputServerIP = "47.130.109.65";
  static const int outputServerPort = 8080;
  
  final String inputHost;
  final int inputPort;
  final String outputHost;
  final int outputPort;
  final String protocol;
  final String streamKey;
  
  StreamConfig({
    this.inputHost = inputServerIP,
    this.inputPort = inputServerPort,
    this.outputHost = outputServerIP,
    this.outputPort = outputServerPort,
    this.protocol = 'rtmp',
    this.streamKey = '923244219594', // Default stream key (using SIM number)
  });
  
  // RTMP input streaming URL (where app sends video)
  String get inputUrl => '$protocol://$inputHost/hls/$streamKey';
  
  // Output streaming URL (where you watch the stream)  
  String get outputUrl => 'http://$outputHost:$outputPort/hls/$streamKey.flv';
  
  // RTMP streaming URL for publishing
  String get rtmpStreamUrl => 'rtmp://$inputHost/hls/$streamKey';
  
  // Display-friendly URLs
  String get inputDisplayUrl => '$inputHost/hls/$streamKey';
  String get outputDisplayUrl => '$outputHost:$outputPort/hls/$streamKey.flv';
  
  // Predefined configurations for your server
  static StreamConfig yourServer({String streamKey = '923244219594'}) => StreamConfig(
    inputHost: inputServerIP,
    inputPort: inputServerPort,
    outputHost: outputServerIP,
    outputPort: outputServerPort,
    protocol: 'rtmp',
    streamKey: streamKey,
  );
  
  // Test if this is your specific server
  bool get isYourServer => 
    inputHost == inputServerIP && 
    inputPort == inputServerPort &&
    outputHost == outputServerIP && 
    outputPort == outputServerPort;
  
  Map<String, dynamic> toJson() => {
    'inputHost': inputHost,
    'inputPort': inputPort,
    'outputHost': outputHost,
    'outputPort': outputPort,
    'protocol': protocol,
    'streamKey': streamKey,
  };
  
      factory StreamConfig.fromJson(Map<String, dynamic> json) => StreamConfig(
    inputHost: json['inputHost'] ?? inputServerIP,
    inputPort: json['inputPort'] ?? inputServerPort,
    outputHost: json['outputHost'] ?? outputServerIP,
    outputPort: json['outputPort'] ?? outputServerPort,
    protocol: json['protocol'] ?? 'rtmp',
    streamKey: json['streamKey'] ?? '923244219594',
  );
  
  @override
  String toString() => 'Input: $inputUrl, Output: $outputUrl';
}