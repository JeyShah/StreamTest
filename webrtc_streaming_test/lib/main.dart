import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'rtmp_streaming_page.dart';
import 'stream_player_page.dart';

void main() {
  runApp(const RTMPStreamingApp());
}

class RTMPStreamingApp extends StatelessWidget {
  const RTMPStreamingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RTMP Streaming Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(title: 'RTMP Streaming Test'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _permissionsGranted = false;
  
  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    // Skip permission check for desktop platforms that don't support permission_handler
    if (defaultTargetPlatform == TargetPlatform.macOS || 
        defaultTargetPlatform == TargetPlatform.windows || 
        defaultTargetPlatform == TargetPlatform.linux) {
      setState(() {
        _permissionsGranted = true; // Desktop platforms handle permissions at system level
      });
      return;
    }

    try {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.camera,
        Permission.microphone,
      ].request();

      bool allGranted = statuses.values.every((status) => status.isGranted);
      
      setState(() {
        _permissionsGranted = allGranted;
      });

      if (!allGranted) {
        _showPermissionDialog();
      }
    } catch (e) {
      // Handle unexpected platform issues
      debugPrint('Permission check failed: $e');
      setState(() {
        _permissionsGranted = true; // Fallback to allow app to continue
      });
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('🎥 Camera & Microphone Access'),
          content: const Text(
            'This app needs camera and microphone permissions for RTMP streaming.\n\n'
            'Please grant these permissions to continue.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _checkPermissions();
              },
              child: const Text('Try Again'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Continue anyway for desktop platforms
                setState(() {
                  _permissionsGranted = true;
                });
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.stream,
              size: 64,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            const Text(
              'RTMP Streaming Test App',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Ready to stream to your RTMP server',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            
            // Status indicator
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _permissionsGranted ? Colors.green.shade50 : Colors.orange.shade50,
                border: Border.all(
                  color: _permissionsGranted ? Colors.green : Colors.orange,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _permissionsGranted ? Icons.check_circle : Icons.warning,
                    color: _permissionsGranted ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _permissionsGranted ? 'Permissions Granted' : 'Checking Permissions...',
                    style: TextStyle(
                      color: _permissionsGranted ? Colors.green.shade700 : Colors.orange.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _permissionsGranted ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RTMPStreamingPage(),
                  ),
                );
              } : null,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Start RTMP Streaming'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StreamPlayerPage(),
                  ),
                );
              },
              icon: const Icon(Icons.play_circle),
              label: const Text('Play Stream'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            
            if (!_permissionsGranted) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: _checkPermissions,
                child: const Text('Check Permissions Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
