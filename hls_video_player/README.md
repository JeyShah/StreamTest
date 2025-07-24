# HLS Video Player

A cross-platform Flutter application for streaming HLS, FLV, MP4, and other video formats. Works seamlessly on Android, iOS, macOS, and Web platforms.

## Features

🎥 **Multi-Platform Support**: Android, iOS, macOS, Web, and Chrome
📺 **Multiple Video Formats**: HLS (.m3u8), MP4, WebM, FLV
🎮 **Advanced Controls**: Play, pause, seek, fullscreen, volume control
📱 **Responsive Design**: Adapts to different screen sizes
🔗 **URL Input**: Easy stream URL configuration
⚡ **Real-time Streaming**: Low-latency video streaming
🔄 **Auto-retry**: Automatic error recovery

## Screenshots

The app provides a clean, intuitive interface with:
- URL input field for stream sources
- Play/Stop controls
- Full-featured video player with native controls
- Platform indicator
- Error handling and retry functionality

## Supported Formats

- **HLS (HTTP Live Streaming)**: `.m3u8` files
- **MP4**: Standard MP4 video files
- **WebM**: Web-optimized video format
- **FLV**: Flash Video format (limited support)

## Prerequisites

- Flutter SDK 3.5.4 or higher
- Platform-specific requirements:
  - **Android**: Android SDK, Android Studio
  - **iOS**: Xcode, iOS Simulator
  - **macOS**: Xcode, macOS development tools
  - **Web**: Chrome, Firefox, Safari

## Installation

### 1. Clone or Download the Project

```bash
cd /workspace/hls_video_player
```

### 2. Install Dependencies

```bash
# Make sure Flutter is in your PATH
export PATH="/tmp/flutter/bin:$PATH"

# Install Flutter dependencies
flutter pub get
```

### 3. Platform Setup

#### For Android:
```bash
# Check Android setup
flutter doctor --android-licenses
```

#### For iOS (macOS only):
```bash
# Open iOS simulator
open -a Simulator
```

#### For Web:
```bash
# Enable web support (if not already enabled)
flutter config --enable-web
```

## Running the App

### Android
```bash
flutter run -d android
```

### iOS (macOS only)
```bash
flutter run -d ios
```

### macOS
```bash
flutter run -d macos
```

### Web
```bash
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080
```

### Chrome (specific)
```bash
flutter run -d chrome
```

## Usage

1. **Launch the app** on your preferred platform
2. **Enter a stream URL** in the input field (defaults to: `http://47.130.109.65:8080/hls/mystream.flv`)
3. **Press "Play Stream"** to start playback
4. **Use video controls** to pause, seek, adjust volume, or go fullscreen
5. **Press "Stop"** to stop playback

### Sample URLs for Testing

```
# HLS Stream
http://example.com/stream.m3u8

# MP4 Video
https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4

# Your custom stream
http://47.130.109.65:8080/hls/mystream.flv
```

## Configuration

### Network Settings

For web deployment, you may need to configure CORS headers on your server:

```
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: GET, POST, OPTIONS
Access-Control-Allow-Headers: Origin, Content-Type, Accept
```

### Video Player Settings

The app uses Chewie video player with these default settings:
- **Auto-play**: Enabled
- **Controls**: Visible
- **Fullscreen**: Supported
- **Volume control**: Enabled
- **Seeking**: Enabled

## Building for Production

### Android APK
```bash
flutter build apk --release
```

### iOS App
```bash
flutter build ios --release
```

### macOS App
```bash
flutter build macos --release
```

### Web Build
```bash
flutter build web --release
```

## Troubleshooting

### Common Issues

1. **Video not playing**
   - Check if the URL is accessible
   - Verify internet connection
   - Try a different video format

2. **CORS errors on web**
   - Configure server CORS headers
   - Use a CORS proxy for testing
   - Check browser console for specific errors

3. **Platform-specific issues**
   - Run `flutter doctor` to check setup
   - Ensure platform-specific dependencies are installed
   - Check device/simulator compatibility

### Debug Commands

```bash
# Check Flutter setup
flutter doctor -v

# Clean and rebuild
flutter clean && flutter pub get

# Run with verbose logging
flutter run --verbose
```

## Architecture

```
lib/
└── main.dart                 # Main app and video player implementation
```

### Key Components

- **HLSVideoPlayerApp**: Main application widget
- **HLSVideoPlayerScreen**: Main screen with video player
- **VideoPlayerController**: Handles video playback
- **ChewieController**: Provides advanced video controls

## Dependencies

- `video_player: ^2.8.2` - Core video playback functionality
- `video_player_web: ^2.3.1` - Web platform support
- `chewie: ^1.7.5` - Enhanced video player UI and controls
- `http: ^1.2.2` - Network requests
- `url_launcher: ^6.2.4` - URL handling utilities

## Platform Support Matrix

| Feature | Android | iOS | macOS | Web | Chrome |
|---------|---------|-----|-------|-----|--------|
| HLS (.m3u8) | ✅ | ✅ | ✅ | ✅ | ✅ |
| MP4 | ✅ | ✅ | ✅ | ✅ | ✅ |
| WebM | ✅ | ❌ | ✅ | ✅ | ✅ |
| FLV | ⚠️ | ⚠️ | ⚠️ | ⚠️ | ⚠️ |
| Fullscreen | ✅ | ✅ | ✅ | ✅ | ✅ |
| Controls | ✅ | ✅ | ✅ | ✅ | ✅ |

✅ = Fully Supported, ⚠️ = Limited Support, ❌ = Not Supported

## Contributing

1. Fork the repository
2. Create your feature branch
3. Test on multiple platforms
4. Submit a pull request

## License

This project is open source and available under the MIT License.

## Support

For issues and questions:
1. Check the troubleshooting section
2. Run `flutter doctor` to verify setup
3. Test with known working video URLs
4. Check platform-specific requirements

---

**Happy Streaming! 🎬**
