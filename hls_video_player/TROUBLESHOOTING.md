# Troubleshooting Guide - HLS Video Player

## 🚨 Common Issues & Solutions

### Issue 1: "Cannot read properties of undefined (reading 'registerWebViewFactory')"

**Cause:** This error comes from the `webrtc_streaming_test` project in the workspace, not our HLS video player.

**Solution:** 
- ✅ **Fixed**: I've updated the webrtc project to use safer JS interop
- The error should no longer occur

### Issue 2: "Error: 'if' can't be used as an identifier" (hls_player_page.dart)

**Cause:** Syntax error in `webrtc_streaming_test/lib/hls_player_page.dart` with malformed conditional imports.

**Solution:** 
- ✅ **Fixed**: Corrected the conditional import syntax
- Added proper semicolon to import statement

### Issue 3: Multiple Projects in Workspace Causing Conflicts

**Cause:** IDE analyzing multiple Flutter projects simultaneously can show errors from other projects.

**Solutions:**

#### Option A: Open Only Our Project (Recommended)
```bash
# Close your current IDE window
# Open only the HLS video player project:
code /workspace/hls_video_player
```

#### Option B: Use Terminal
```bash
cd /workspace/hls_video_player
export PATH="$PATH:/workspace/flutter/bin"
flutter run -d web
```

#### Option C: Use .vscode/settings.json
Create this file in the workspace root to exclude the problematic project:
```json
{
  "dart.analysisExcludedFolders": [
    "/workspace/webrtc_streaming_test"
  ]
}
```

## ✅ Verification Commands

To verify everything is working:

```bash
cd /workspace/hls_video_player

# Check for code issues
flutter analyze

# Run tests
flutter test

# Build for web
flutter build web

# Build for other platforms
flutter build apk      # Android
flutter build ios      # iOS (requires macOS)
flutter build macos    # macOS (requires macOS)
```

## 🎯 Using Your HLS Video Player

### Web Browser (Instant)
```bash
# Open the built web app
open /workspace/hls_video_player/build/web/index.html
```

### Chrome Extension
1. Open `chrome://extensions/`
2. Enable "Developer mode"
3. Click "Load unpacked"
4. Select `/workspace/hls_video_player/build/web/`

### Development Mode
```bash
cd /workspace/hls_video_player
export PATH="$PATH:/workspace/flutter/bin"
flutter run -d chrome  # If Chrome device is available
```

## 📱 Expected Features

Your HLS video player includes:
- ✅ URL input field (pre-filled with example stream)
- ✅ Play/Stop buttons
- ✅ Custom video player controls
- ✅ Progress bar with seeking
- ✅ Volume control and mute
- ✅ Time display (current/duration)
- ✅ Error handling and loading states
- ✅ Support for HLS, FLV, MP4, and other formats

## 🔍 If You Still See Errors

1. **Check you're in the right directory:**
   ```bash
   pwd  # Should show /workspace/hls_video_player
   ```

2. **Clean and rebuild:**
   ```bash
   flutter clean
   flutter pub get
   flutter build web
   ```

3. **Check Flutter configuration:**
   ```bash
   flutter doctor
   flutter config --list
   ```

4. **Open only our project in your IDE:**
   - Close all IDE windows
   - Open only `/workspace/hls_video_player`

## 📞 Success Indicators

You know everything is working when:
- ✅ `flutter analyze` shows "No issues found!"
- ✅ `flutter test` shows "All tests passed!"
- ✅ `flutter build web` completes without errors
- ✅ Opening `build/web/index.html` shows the video player interface
- ✅ No errors mentioning `hls_player_page.dart` or `registerWebViewFactory`

## 🎉 Your HLS Video Player is Production-Ready!

The app supports multiple platforms and formats, with a clean interface for entering stream URLs and playing videos with full controls.