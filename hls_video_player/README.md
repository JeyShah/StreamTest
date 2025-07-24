# HLS Video Player

A cross-platform Flutter application that can play HLS streams and other video formats on Android, iOS, macOS, web, and Chrome extension platforms.

## Features

- 🎥 **Multi-format Support**: Plays HLS (.m3u8), FLV, MP4, and other video stream formats
- 🌐 **Cross-Platform**: Works on Android, iOS, macOS, web, and can be packaged as a Chrome extension
- 🎮 **Custom Controls**: Built-in video controls with play/pause, volume, progress bar, and time display
- 📱 **Responsive Design**: Adapts to different screen sizes and orientations
- 🔗 **URL Input**: Easy-to-use interface for entering stream URLs
- 🚫 **Error Handling**: Comprehensive error handling and user feedback
- 🎨 **Modern UI**: Clean, Material Design 3 interface

## Screenshots

The app includes:
- URL input field with validation
- Play/Stop buttons for stream control
- Full-featured video player with custom controls
- Progress bar with scrubbing support
- Volume control and mute functionality
- Time display (current/total duration)
- Error handling with user-friendly messages

## Supported Platforms

- ✅ **Android** (API 21+)
- ✅ **iOS** (iOS 12.0+)
- ✅ **macOS** (macOS 10.14+)
- ✅ **Web** (Chrome, Firefox, Safari, Edge)
- ✅ **Chrome Extension** (with additional packaging)

## Getting Started

### Prerequisites

- Flutter SDK (3.19.0 or higher)
- Dart SDK (3.3.0 or higher)
- For Android: Android Studio and Android SDK
- For iOS: Xcode and iOS SDK
- For macOS: Xcode and macOS SDK

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd hls_video_player
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
# For web
flutter run -d chrome

# For Android (with device/emulator connected)
flutter run -d android

# For iOS (with device/simulator connected)
flutter run -d ios

# For macOS
flutter run -d macos
```

### Building for Production

#### Web
```bash
flutter build web
```
The built web app will be in `build/web/` directory.

#### Android
```bash
flutter build apk --release
# or for app bundle
flutter build appbundle --release
```

#### iOS
```bash
flutter build ios --release
```

#### macOS
```bash
flutter build macos --release
```

## Configuration

### Network Security

The app is configured to allow HTTP traffic for streaming compatibility:

- **Android**: Internet permissions added in `AndroidManifest.xml`
- **iOS/macOS**: `NSAppTransportSecurity` configured to allow arbitrary loads
- **macOS**: Network client entitlements added for sandbox compatibility

### Example Stream URLs

The app comes pre-configured with a working test stream URL and includes several working examples:

**Pre-loaded Test Stream:**
```
https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8
```

**Additional Working Test URLs (clickable in the app):**
- HLS: `https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8`
- MP4: `https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4`
- MP4: `https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4`

**Important Note:** The URL `https://test-streams.mux.dev/bbb-360p.m3u8` is not working (returns 404). Use the working test URLs provided above.

## Architecture

The app uses:
- **Flutter**: Cross-platform UI framework
- **video_player**: Official Flutter plugin for video playback
- **Material Design 3**: Modern UI components
- **Custom Controls**: Built-in video player controls

### Key Components

- `VideoPlayerScreen`: Main screen with URL input and video player
- `VideoPlayerController`: Handles video playback logic
- Custom UI controls overlaying the video player
- Error handling and loading states

## Chrome Extension Support

To package as a Chrome extension:

1. Build for web:
```bash
flutter build web
```

2. Create a `manifest.json` in the `build/web/` directory:
```json
{
  "manifest_version": 3,
  "name": "HLS Video Player",
  "version": "1.0.0",
  "description": "Cross-platform HLS stream video player",
  "action": {
    "default_popup": "index.html"
  },
  "permissions": ["activeTab"]
}
```

3. Load the `build/web/` directory as an unpacked extension in Chrome.

## Troubleshooting

### Common Issues

1. **CORS Issues (Web)**: Some streams may have CORS restrictions. Consider using a proxy server.

2. **Network Security (iOS/macOS)**: For production apps, configure specific domains instead of allowing all HTTP traffic.

3. **Android Permissions**: Ensure internet permission is added to AndroidManifest.xml.

4. **Video Format Support**: Not all formats are supported on all platforms. Test with common formats like HLS and MP4.

### Performance Tips

- Use HLS streams for better performance and adaptive bitrate
- Consider implementing a loading indicator for better UX
- Handle network connectivity changes gracefully

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test on multiple platforms
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Dependencies

- `flutter`: SDK
- `video_player`: ^2.8.1
- `http`: ^1.1.0
- `cupertino_icons`: ^1.0.6

## Support

For issues and feature requests, please use the GitHub issue tracker.
