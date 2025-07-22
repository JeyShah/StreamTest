class ServerConfig {
  static const String defaultHost = 'localhost';
  static const int defaultPort = 8080;
  static const String defaultProtocol = 'ws';
  
  late String host;
  late int port;
  late String protocol;
  late String path;
  
  ServerConfig({
    String? host,
    int? port,
    String? protocol,
    String? path,
  }) {
    this.host = host ?? defaultHost;
    this.port = port ?? defaultPort;
    this.protocol = protocol ?? defaultProtocol;
    this.path = path ?? '/';
  }
  
  ServerConfig.fromUrl(String url) {
    final uri = Uri.parse(url);
    host = uri.host.isEmpty ? defaultHost : uri.host;
    port = uri.port == 0 ? defaultPort : uri.port;
    protocol = uri.scheme.isEmpty ? defaultProtocol : uri.scheme;
    path = uri.path.isEmpty ? '/' : uri.path;
  }
  
  String get fullUrl => '$protocol://$host:$port$path';
  
  String get displayUrl => '$host:$port';
  
  bool get isSecure => protocol == 'wss' || protocol == 'https';
  
  Map<String, dynamic> toJson() => {
    'host': host,
    'port': port,
    'protocol': protocol,
    'path': path,
  };
  
  factory ServerConfig.fromJson(Map<String, dynamic> json) => ServerConfig(
    host: json['host'],
    port: json['port'],
    protocol: json['protocol'],
    path: json['path'],
  );
  
  @override
  String toString() => fullUrl;
  
  // Common server configurations
  static ServerConfig localhost({int port = 8080}) => ServerConfig(
    host: 'localhost',
    port: port,
    protocol: 'ws',
  );
  
  static ServerConfig custom(String host, int port, {bool secure = false}) => ServerConfig(
    host: host,
    port: port,
    protocol: secure ? 'wss' : 'ws',
  );
  
  static ServerConfig rtmp(String host, int port) => ServerConfig(
    host: host,
    port: port,
    protocol: 'rtmp',
  );
}