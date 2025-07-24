# Quick Setup Guide - HLS Video Player

## 🚀 Quick Start

### Option 1: Web Browser (Instant)
The easiest way to try the HLS video player:
1. Open your browser
2. Navigate to the `build/web/index.html` file (already built)
3. Enter your stream URL (example: `http://47.130.109.65:8080/hls/mystream.flv`)
4. Click "Play Stream"

### Option 2: Chrome Extension
1. Open Chrome and go to `chrome://extensions/`
2. Enable "Developer mode" (top right toggle)
3. Click "Load unpacked"
4. Select the `build/web/` directory from this project
5. The HLS Video Player extension will appear in your toolbar

### Option 3: Development Mode
```bash
# Install Flutter dependencies
flutter pub get

# Run in Chrome browser
flutter run -d chrome

# Or run in other platforms
flutter run -d android  # Requires Android SDK
flutter run -d ios      # Requires Xcode (macOS only)
flutter run -d macos    # Requires Xcode (macOS only)
```

## 📱 Platform Support Status

| Platform | Status | Requirements |
|----------|--------|--------------|
| **Web** | ✅ Ready | Modern browser |
| **Chrome Extension** | ✅ Ready | Chrome browser |
| **Android** | ✅ Ready | Android SDK (to build) |
| **iOS** | ✅ Ready | Xcode + iOS SDK (to build) |
| **macOS** | ✅ Ready | Xcode (to build) |

## 🎯 Key Features Tested

- ✅ URL input field with validation
- ✅ Play/Stop stream controls
- ✅ Custom video player with overlay controls
- ✅ Progress bar with seeking
- ✅ Volume control and mute
- ✅ Time display (current/duration)
- ✅ Error handling and loading states
- ✅ Responsive design
- ✅ HTTP/HTTPS stream support
- ✅ HLS, FLV, MP4 format support

## 🔧 Supported Stream Formats

- **HLS** (.m3u8) - HTTP Live Streaming
- **FLV** - Flash Video
- **MP4** - MPEG-4 Video
- **WebM** - Web Media format
- **Other formats** supported by Flutter's video_player plugin

## 🌐 Example Stream URLs

```
# The pre-filled example
http://47.130.109.65:8080/hls/mystream.flv

# Other test streams (replace with your own)
https://example.com/stream.m3u8
https://example.com/video.mp4
```

## 🛠️ Build Commands

```bash
# Web (for browsers)
flutter build web

# Android APK
flutter build apk

# iOS (requires macOS)
flutter build ios

# macOS App
flutter build macos

# Chrome Extension (automated)
./prepare_chrome_extension.sh
```

## 🐛 Troubleshooting

### Common Issues:

1. **Stream won't play**: Check if the URL is accessible and the format is supported
2. **CORS errors**: Use streams that allow cross-origin requests or set up a proxy
3. **Network security**: The app is configured to allow HTTP streams for testing

### Platform-specific Notes:

- **Web**: Some streams may have CORS restrictions
- **Mobile**: Internet permissions are already configured
- **macOS**: Network access permissions are configured for sandbox mode

## 📞 Support

This is a complete, working HLS video player that supports multiple platforms. The web version and Chrome extension are ready to use immediately without any additional setup!