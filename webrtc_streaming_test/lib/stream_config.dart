class StreamConfig {
  // Your specific server configuration
  static const String inputServerIP = "47.130.109.65";
  static const int inputServerPort = 1078;
  static const String outputServerIP = "47.130.109.65";
  static const int outputServerPort = 8080;
  
  final String inputHost;
  final int inputPort;
  final String outputHost;
  final int outputPort;
  final String protocol;
  final String simNumber;
  
  StreamConfig({
    this.inputHost = inputServerIP,
    this.inputPort = inputServerPort,
    this.outputHost = outputServerIP,
    this.outputPort = outputServerPort,
    this.protocol = 'ws',
    this.simNumber = '923244219594', // Default SIM number
  });
  
  // WebRTC input streaming URL (where app sends video with SIM number)
  String get inputUrl => '$protocol://$inputHost:$inputPort/$simNumber';
  
  // Output streaming URL (where you watch the stream)
  String get outputUrl => 'http://$outputHost:$outputPort/$simNumber/1.m3u8';
  
  // WebRTC signaling URL for streaming
  String get webrtcSignalingUrl => 'ws://$inputHost:$inputPort';
  
  // Display-friendly URLs
  String get inputDisplayUrl => '$inputHost:$inputPort';
  String get outputDisplayUrl => '$outputHost:$outputPort/$simNumber/1.m3u8';
  
  // Predefined configurations for your server
  static StreamConfig yourServer({String simNumber = '923244219594'}) => StreamConfig(
    inputHost: inputServerIP,
    inputPort: inputServerPort,
    outputHost: outputServerIP,
    outputPort: outputServerPort,
    protocol: 'ws',
    simNumber: simNumber,
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
    'simNumber': simNumber,
  };
  
      factory StreamConfig.fromJson(Map<String, dynamic> json) => StreamConfig(
    inputHost: json['inputHost'] ?? inputServerIP,
    inputPort: json['inputPort'] ?? inputServerPort,
    outputHost: json['outputHost'] ?? outputServerIP,
    outputPort: json['outputPort'] ?? outputServerPort,
    protocol: json['protocol'] ?? 'ws',
    simNumber: json['simNumber'] ?? '923244219594',
  );
  
  @override
  String toString() => 'Input: $inputUrl, Output: $outputUrl';
}