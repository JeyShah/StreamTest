# HLS Video Player

A simple, cross-platform HLS video player built with Flutter.

## ✨ Features

- **🎬 HLS Streaming** - Play .m3u8 streams
- **📱 Cross-Platform** - Works on iOS, Android, Web, Desktop
- **🎮 Simple Interface** - URL input + video player
- **⚡ Fast & Lightweight** - Minimal dependencies

## 🎯 Supported Formats

- **HLS (.m3u8)** - HTTP Live Streaming
- **MP4** - Standard video files
- **FLV** - Flash Video format
- **HTTP/HTTPS streams** - Any supported video format

## 🚀 How to Use

1. **Enter stream URL** in the text field
2. **Tap "Play Stream"** to start playback
3. **Tap "Stop"** to stop playback

### Example URLs:
```
# Your HLS stream
http://47.130.109.65:8080/hls/mystream.m3u8

# Test video
https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4
```

## 🛠️ Setup

### Prerequisites
- Flutter SDK
- FFmpeg (for creating HLS streams)

### Installation
```bash
flutter pub get
flutter run
```

### Creating HLS Stream
```bash
# Convert video to HLS stream
ffmpeg -re -i your_video.mp4 -c copy -f flv rtmp://47.130.109.65/hls/mystream

# Your stream will be available at:
# http://47.130.109.65:8080/hls/mystream.m3u8
```

## 📱 Platform Support

| Platform | Status | Notes |
|----------|--------|--------|
| **iOS** | ✅ | Native HLS support |
| **Android** | ✅ | ExoPlayer backend |
| **Web** | ✅ | HTML5 video |
| **macOS** | ✅ | AVPlayer backend |
| **Windows** | ✅ | Media Foundation |
| **Linux** | ✅ | GStreamer backend |

## 🔧 Dependencies

- `video_player: ^2.8.2` - Cross-platform video playback

## 📝 License

This project is open source and available under the MIT License.
