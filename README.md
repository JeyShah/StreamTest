# StreamTest Workspace

This workspace contains two video streaming applications built with Flutter:

## 🎬 HLS Video Player

**Location**: `/workspace/hls_video_player/`

A cross-platform HLS video streaming player that supports:
- **Platforms**: Android, iOS, macOS, Web, Chrome
- **Formats**: HLS (.m3u8), MP4, WebM, FLV
- **Features**: URL input, play controls, fullscreen, volume control
- **Default URL**: `http://47.130.109.65:8080/hls/mystream.flv`

### Quick Start:
```bash
cd hls_video_player
chmod +x setup.sh
./setup.sh

# Run on different platforms:
flutter run -d web               # Web
flutter run -d chrome           # Chrome
flutter run -d android          # Android
flutter run -d ios              # iOS (macOS only)
flutter run -d macos            # macOS
```

## 📡 WebRTC Streaming Test

**Location**: `/workspace/webrtc_streaming_test/`

A WebRTC streaming application for testing real-time video communication:
- **Features**: Camera preview, WebRTC streaming, media controls
- **Platforms**: Android, iOS, Web
- **Use case**: Live streaming to WebRTC media servers

### Quick Start:
```bash
cd webrtc_streaming_test
chmod +x setup.sh
./setup.sh
flutter run
```

## 🚀 Quick Setup for HLS Player

The HLS Video Player is ready to use immediately:

1. **Navigate to the project**:
   ```bash
   cd /workspace/hls_video_player
   ```

2. **Run the setup**:
   ```bash
   ./setup.sh
   ```

3. **Start the app** (choose your platform):
   ```bash
   # Web (recommended for testing)
   export PATH="/tmp/flutter/bin:$PATH"
   flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080
   
   # Chrome
   flutter run -d chrome
   
   # Android (requires Android SDK)
   flutter run -d android
   ```

4. **Use the app**:
   - Enter your stream URL (default: `http://47.130.109.65:8080/hls/mystream.flv`)
   - Press "Play Stream"
   - Enjoy your video!

## 📱 Platform Support

| Feature | HLS Player | WebRTC Test |
|---------|------------|-------------|
| Android | ✅ | ✅ |
| iOS | ✅ | ✅ |
| macOS | ✅ | ❌ |
| Web | ✅ | ✅ |
| Chrome | ✅ | ✅ |

## 🎯 Recommended Usage

- **For HLS/MP4 streaming**: Use the **HLS Video Player**
- **For live WebRTC streaming**: Use the **WebRTC Streaming Test**

Both apps are fully functional and ready to use!