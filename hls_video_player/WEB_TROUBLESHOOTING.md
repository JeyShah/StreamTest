# Web Platform Troubleshooting Guide

## 🚨 Common Web Initialization Errors

### Error: "Cannot read properties of undefined (reading 'debugTracePostFrameCallbacks')"

**Cause:** Flutter web binding initialization issue, often related to browser compatibility or Flutter version conflicts.

**Solutions:**

#### ✅ **Solution 1: Use Different Browser**
- Try **Chrome** (best Flutter web support)
- Try **Firefox** (good alternative)
- Avoid **Safari** (limited Flutter web support)
- Avoid **Internet Explorer** (not supported)

#### ✅ **Solution 2: Clear Browser Cache**
```bash
# Chrome
1. F12 → Application → Storage → Clear site data
2. Or Ctrl+Shift+Delete → Clear all

# Firefox  
1. F12 → Storage → Clear all
2. Or Ctrl+Shift+Delete → Clear all
```

#### ✅ **Solution 3: Use Backup Video Player**
If Flutter app fails to load:
1. Open `build/web/simple_player.html`
2. This uses native HTML5 video element
3. Supports MP4 and some HLS streams

#### ✅ **Solution 4: Try Different Renderer**
The app automatically tries:
1. **CanvasKit renderer** (preferred)
2. **HTML renderer** (fallback)
3. Shows error page if both fail

## 🔧 Platform-Specific Issues

### Chrome Browser
- ✅ **Best support** for Flutter web
- ✅ **Hardware acceleration** available
- ✅ **All video formats** supported
- 💡 **Tip**: Enable hardware acceleration in chrome://flags

### Firefox Browser  
- ✅ **Good support** for Flutter web
- ✅ **Most video formats** supported
- ⚠️ **Some HLS limitations**
- 💡 **Tip**: Update to latest version

### Safari Browser
- ⚠️ **Limited Flutter support**
- ✅ **Good native HLS support**
- 🎯 **Recommendation**: Use simple_player.html
- 💡 **Tip**: Enable Developer features

### Edge Browser
- ✅ **Good support** (Chromium-based)
- ✅ **Similar to Chrome**
- ✅ **Full compatibility**

## 🎯 Testing Options

### Option 1: Flutter Web App (Primary)
```
File: build/web/index.html
Features: Full Flutter UI, VLC integration (mobile), custom controls
Best for: Modern browsers, desktop usage
```

### Option 2: Simple HTML5 Player (Backup)
```
File: build/web/simple_player.html  
Features: Native HTML5, direct video element, basic controls
Best for: Compatibility issues, older browsers
```

### Option 3: Chrome Extension
```
Load: build/web/ directory as unpacked extension
Features: Same as Flutter web app, browser integration
Best for: Regular usage, toolbar access
```

## 🛠️ Error Resolution Steps

### Step 1: Check Browser Console
1. Open Developer Tools (F12)
2. Look at Console tab for errors
3. Common errors and solutions:

```javascript
// Error: Flutter binding failed
// Solution: Try different renderer or use backup player

// Error: Video format not supported  
// Solution: Use working test URLs provided

// Error: CORS blocked
// Solution: Use CORS-enabled test streams
```

### Step 2: Verify Network Access
1. Test with provided working URLs:
   - `https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8`
   - `https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4`
2. Check internet connection
3. Try different network (mobile hotspot, etc.)

### Step 3: Browser-Specific Fixes

#### Chrome Issues:
```bash
# Reset Chrome
1. chrome://settings/reset
2. Clear all browsing data
3. Disable extensions temporarily
4. Try incognito mode
```

#### Firefox Issues:
```bash
# Reset Firefox
1. about:support → Refresh Firefox
2. Clear all data
3. Disable add-ons temporarily
4. Try private window
```

### Step 4: Use Backup Options
If Flutter app completely fails:
1. Open `simple_player.html` directly
2. Use basic HTML5 video player
3. Still supports HLS and MP4 streams
4. No Flutter dependencies

## 📱 Mobile Browser Issues

### Mobile Chrome
- ✅ **Good support**
- ⚠️ **VLC not available** (uses standard player)
- 💡 **Tip**: Use landscape mode for better experience

### Mobile Safari  
- ⚠️ **Limited Flutter support**
- ✅ **Excellent native HLS**
- 🎯 **Recommendation**: Use simple_player.html
- 💡 **Tip**: Add to home screen for app-like experience

### Mobile Firefox
- ✅ **Decent support**
- ✅ **Most features work**
- ⚠️ **Some performance issues**

## 🎬 Video Format Compatibility

| Format | Chrome | Firefox | Safari | Edge | Notes |
|--------|--------|---------|--------|------|-------|
| **MP4** | ✅ | ✅ | ✅ | ✅ | Best compatibility |
| **HLS (.m3u8)** | ✅ | ⚠️ | ✅ | ✅ | Native in Safari |
| **WebM** | ✅ | ✅ | ❌ | ✅ | Chrome/Firefox only |
| **FLV** | ❌ | ❌ | ❌ | ❌ | Not supported in browsers |

## 🚀 Performance Tips

### For Better Performance:
1. **Use MP4** for maximum compatibility
2. **Use HLS** for adaptive streaming  
3. **Clear cache** regularly
4. **Close other tabs** playing video
5. **Enable hardware acceleration**

### For Troubleshooting:
1. **Start with simple_player.html**
2. **Test with working URLs first**
3. **Check browser console for errors**
4. **Try different browsers**
5. **Contact support with specific error messages**

## 📞 Quick Fix Summary

| Issue | Quick Fix |
|-------|-----------|
| App won't load | Try `simple_player.html` |
| Video won't play | Use test URLs provided |
| CORS errors | Switch to different stream |
| Performance issues | Clear cache, close tabs |
| Mobile issues | Try landscape mode |
| All else fails | Use Chrome browser |

Your HLS video player includes multiple fallback options to ensure it works across all platforms and browsers! 🎉