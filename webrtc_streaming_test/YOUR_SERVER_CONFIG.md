# Your Server Configuration

## ✅ Pre-configured for Your Server!

Your WebRTC Streaming Test App is now **pre-configured** with your specific server details:

### 🎯 Your Server Details
- **Input Server IP**: `47.130.109.65`
- **Input Port**: `1078` (for sending video TO your server)
- **Output Server**: `http://47.130.109.65:8080/[sim number]/1.m3u8` (for viewing the stream)

## 🚀 Quick Start

### 1. Launch the App
```bash
cd /workspace/webrtc_streaming_test
flutter run
```

### 2. Your Server is Already Configured!
The app automatically loads with your server settings:
- **Input**: `rtmp://47.130.109.65:1078`
- **Output**: `http://47.130.109.65:8080/12345/1.m3u8` (using default SIM: 12345)

### 3. Customize SIM Number (Optional)
1. Tap the **⚙️ Settings** icon
2. Click **"Your Server"** preset button (highlighted in blue)
3. Change the **SIM Number** field to your desired value
4. Tap **"Save"**

### 4. Start Streaming
1. Grant camera/microphone permissions
2. Tap **"Start Stream"**
3. The app will show both URLs:
   - **Sending to**: `rtmp://47.130.109.65:1078`
   - **Watch at**: `http://47.130.109.65:8080/[your-sim]/1.m3u8`

## 📱 Using Your Configuration

### When Streaming is Active:
✅ **Camera Preview**: See your video feed  
✅ **Media Controls**: Mute, video toggle, camera switch  
✅ **Stream Output Info**: Green box showing your viewing URL  
✅ **Copy URL Button**: Easy access to the output URL  

### Your Stream URLs:
- **Input (App → Server)**: `rtmp://47.130.109.65:1078/live/[sim-number]`
- **Output (View Stream)**: `http://47.130.109.65:8080/[sim-number]/1.m3u8`

## 🎥 Viewing Your Stream

### Option 1: VLC Media Player
1. Open VLC
2. Go to **Media** → **Open Network Stream**
3. Enter: `http://47.130.109.65:8080/[your-sim]/1.m3u8`
4. Click **Play**

### Option 2: Web Browser
1. Use an HLS-compatible player
2. Open the URL: `http://47.130.109.65:8080/[your-sim]/1.m3u8`

### Option 3: Mobile Players
- **iOS**: Safari browser (native HLS support)
- **Android**: VLC app or other HLS players

## 🔧 Configuration Examples

### Default Configuration (Already Set):
```
Input Host: 47.130.109.65
Input Port: 1078
Protocol: rtmp
SIM Number: 12345
Output URL: http://47.130.109.65:8080/12345/1.m3u8
```

### Custom SIM Number Example:
```
SIM Number: mysim001
Output URL: http://47.130.109.65:8080/mysim001/1.m3u8
```

## 🛠 Technical Flow

### What Happens When You Stream:
1. **App captures** camera/microphone
2. **Creates WebRTC** peer connection
3. **Generates SDP offer** for your server
4. **Streams to**: `rtmp://47.130.109.65:1078/live/[sim]`
5. **Server makes available at**: `http://47.130.109.65:8080/[sim]/1.m3u8`

### Integration Points:
- **RTMP Input**: App sends video to port 1078
- **HLS Output**: Server provides stream at port 8080
- **SIM-based Routing**: Each SIM number gets its own stream path

## 🔍 Testing Your Setup

### 1. Test Connection
- Open app settings
- Tap **"Test"** button
- Verify both input and output URLs are accessible

### 2. Test Streaming
- Start streaming in the app
- Copy the output URL from the green info box
- Open in VLC or browser to verify stream

### 3. Debug Information
Check the console logs for:
- Connection attempts to your server
- WebRTC SDP generation
- Stream URL construction

## 📋 Next Steps

### For Full Integration:
1. **Server-Side**: Ensure your RTMP server accepts streams on port 1078
2. **Output**: Verify HLS streams are available on port 8080
3. **Authentication**: Add any required authentication to your server
4. **Monitoring**: Set up stream monitoring and health checks

### Common SIM Numbers to Test:
- `12345` (default)
- `test001`
- `device001`
- Your actual device/SIM identifiers

---

## 🎉 You're All Set!

Your app is pre-configured with your exact server details. Just:
1. **Launch the app** → **Start Stream** → **View the output URL**
2. Your stream will be available at: `http://47.130.109.65:8080/[sim]/1.m3u8`

**Ready to stream to your server!** 🚀