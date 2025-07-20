# WebRTC Streaming Test App

A Flutter application for testing WebRTC streaming capabilities with your media server.

## Features

- **Camera Preview**: Real-time camera feed display
- **WebRTC Streaming**: Stream video/audio using WebRTC protocol
- **Media Controls**: 
  - Mute/unmute microphone
  - Enable/disable camera
  - Switch between front/back camera
- **Server Configuration**: Configurable media server URL
- **Permission Management**: Automatic camera and microphone permission handling
- **Connection Status**: Real-time streaming status indicator

## Prerequisites

- Flutter SDK 3.24.5 or higher
- Android SDK (for Android development)
- Xcode (for iOS development)
- Camera and microphone permissions

## Setup and Installation

1. **Navigate to the project directory:**
   ```bash
   cd /tmp/webrtc_streaming_test
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   # For Android
   flutter run

   # For iOS (requires macOS and Xcode)
   flutter run -d ios

   # For web (limited WebRTC support)
   flutter run -d web
   ```

## Usage

1. **Launch the app** and grant camera/microphone permissions when prompted
2. **Configure your media server** by tapping the settings icon in the top-right
3. **Start streaming** by tapping the "Start Stream" button
4. **Use media controls** to mute audio, disable video, or switch cameras
5. **Stop streaming** when finished

## Configuration

### Media Server Setup

The app is configured to work with WebRTC media servers. To connect to your server:

1. Tap the settings icon in the streaming page
2. Enter your server URL (e.g., `ws://your-server.com:8080`)
3. Save the configuration

### Default Configuration

- **Server URL**: `ws://your-media-server.com:8080`
- **Video Resolution**: 1280x720
- **STUN Servers**: Google STUN servers for ICE negotiation

## WebRTC Implementation Details

The app implements:

- **Peer Connection**: Creates RTCPeerConnection for media streaming
- **Media Stream**: Captures local camera/microphone
- **ICE Candidates**: Handles connectivity establishment
- **Session Description Protocol (SDP)**: Manages offer/answer negotiation

## Permissions Required

### Android
- `android.permission.CAMERA`
- `android.permission.RECORD_AUDIO`
- `android.permission.INTERNET`
- `android.permission.ACCESS_NETWORK_STATE`
- `android.permission.CHANGE_NETWORK_STATE`
- `android.permission.MODIFY_AUDIO_SETTINGS`

### iOS
- `NSCameraUsageDescription`
- `NSMicrophoneUsageDescription`

## Testing with Your Media Server

To test with a real media server:

1. Set up a WebRTC signaling server (WebSocket-based)
2. Implement SDP offer/answer exchange
3. Handle ICE candidates transmission
4. Configure the app with your server URL

## Troubleshooting

### Common Issues

1. **Camera/Microphone not working**
   - Ensure permissions are granted
   - Check device compatibility
   - Restart the app

2. **Connection failures**
   - Verify server URL is correct
   - Check network connectivity
   - Ensure server is running and accessible

3. **Build errors**
   - Run `flutter clean && flutter pub get`
   - Check Flutter and Dart versions
   - Verify platform-specific requirements

### Debug Information

The app logs WebRTC events to the console:
- ICE candidates
- Connection state changes
- Media stream events
- SDP offer/answer details

## Dependencies

- `flutter_webrtc: ^0.11.7` - WebRTC implementation for Flutter
- `permission_handler: ^11.3.1` - Runtime permission management
- `http: ^1.2.2` - HTTP client for server communication

## Architecture

```
lib/
├── main.dart                 # App entry point and permission handling
└── webrtc_streaming_page.dart # Main streaming interface and WebRTC logic
```

## Next Steps

For production use, consider:

1. **Signaling Server Integration**: Implement WebSocket connection to your signaling server
2. **Error Handling**: Add comprehensive error handling and recovery
3. **Quality Settings**: Allow users to configure video quality
4. **Recording**: Add local recording capabilities
5. **Multiple Peers**: Support for multiple concurrent connections
6. **TURN Server**: Add TURN server for NAT traversal

## License

This is a test application for development and testing purposes.
