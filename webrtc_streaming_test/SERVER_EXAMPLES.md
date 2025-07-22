# Server Configuration Examples

This document provides examples of how to configure the WebRTC Streaming Test App with different types of streaming servers.

## Quick Configuration

### 1. Open Server Settings
- Launch the app
- Tap the **Settings icon** (⚙️) in the top-right corner
- The "Custom Server Configuration" dialog will open

### 2. Enter Your Server Details
Fill in the following fields:
- **Protocol**: Choose from WebSocket (ws/wss), RTMP, HTTP/HTTPS
- **Host/IP Address**: Your server's IP address or domain name
- **Port**: Your server's port number

### 3. Test Connection (Optional)
- Tap **Test** button to verify connectivity
- Tap **Save** to apply the configuration

## Common Server Examples

### Local Development Server
```
Protocol: ws (WebSocket)
Host: localhost
Port: 8080
Full URL: ws://localhost:8080
```

### Remote WebRTC Server
```
Protocol: wss (WebSocket Secure)
Host: your-domain.com
Port: 443
Full URL: wss://your-domain.com:443
```

### RTMP Streaming Server
```
Protocol: rtmp
Host: 192.168.1.100
Port: 1935
Full URL: rtmp://192.168.1.100:1935
```

### Custom Port Configuration
```
Protocol: ws
Host: 10.0.0.50
Port: 9090
Full URL: ws://10.0.0.50:9090
```

## Server Type Specific Instructions

### 1. WebRTC Signaling Server
If you're using a WebRTC signaling server:
- **Protocol**: `ws` (unsecured) or `wss` (secured)
- **Common Ports**: 8080, 8443, 3000, 4000
- **Example**: `ws://192.168.1.100:8080`

### 2. RTMP Server (like OBS Server, FFmpeg)
If you're streaming to an RTMP server:
- **Protocol**: `rtmp`
- **Common Ports**: 1935, 8935
- **Example**: `rtmp://live.example.com:1935`

### 3. HTTP/HTTPS Server
For HTTP-based streaming:
- **Protocol**: `http` or `https`
- **Common Ports**: 80, 443, 8000, 8080
- **Example**: `https://api.example.com:8000`

### 4. Local Network Server
For testing on your local network:
- **Protocol**: `ws` or `http`
- **Host**: Your computer's local IP (find with `ipconfig` or `ifconfig`)
- **Example**: `ws://192.168.1.105:8080`

## Step-by-Step Configuration

### For Your Custom Server:

1. **Determine Your Server Type**
   - WebRTC signaling server → Use `ws` or `wss`
   - RTMP streaming server → Use `rtmp`
   - HTTP API server → Use `http` or `https`

2. **Find Your Server Details**
   - **IP Address/Domain**: Where your server is running
   - **Port**: Which port your server listens on
   - **Security**: Use secure protocols (`wss`, `https`) for production

3. **Configure in App**
   - Open the app settings
   - Select the correct protocol
   - Enter your host/IP address
   - Enter the port number
   - Tap **Test** to verify (optional)
   - Tap **Save** to confirm

4. **Test Streaming**
   - Return to main screen
   - Tap "Start Stream"
   - Check console logs for connection details

## Quick Presets

The app includes quick preset buttons:

### Local:8080 Preset
- Sets up: `ws://localhost:8080`
- Good for: Local development testing

### RTMP:1935 Preset  
- Sets up: `rtmp://localhost:1935`
- Good for: Local RTMP server testing

## Troubleshooting

### Connection Issues
1. **Verify server is running** on the specified host and port
2. **Check firewall settings** - ensure the port is open
3. **Test network connectivity** - ping the host IP
4. **Verify protocol** - ensure server supports the selected protocol

### Common Port Numbers
- **WebSocket**: 8080, 8443, 3000, 4000
- **RTMP**: 1935, 8935
- **HTTP**: 80, 8000, 8080
- **HTTPS**: 443, 8443

### Network Discovery
To find your local IP address:

**Windows:**
```cmd
ipconfig
```

**Mac/Linux:**
```bash
ifconfig
```

**Find devices on network:**
```bash
nmap -sn 192.168.1.0/24
```

## Example Server Implementations

### Simple WebSocket Server (Node.js)
```javascript
const WebSocket = require('ws');
const wss = new WebSocket.Server({ port: 8080 });

wss.on('connection', function connection(ws) {
  console.log('Client connected');
  ws.on('message', function incoming(message) {
    console.log('Received:', message);
    // Handle WebRTC signaling messages
  });
});
```

### RTMP Server (FFmpeg)
```bash
# Start FFmpeg RTMP server
ffmpeg -f flv -listen 1 -i rtmp://localhost:1935/live/stream -c copy output.mp4
```

### HTTP Server (Python)
```python
from http.server import HTTPServer, BaseHTTPRequestHandler

class StreamHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        # Handle streaming data
        pass

httpd = HTTPServer(('localhost', 8000), StreamHandler)
httpd.serve_forever()
```

## Security Notes

### For Production Use:
- Always use secure protocols (`wss`, `https`) in production
- Implement proper authentication
- Use valid SSL certificates
- Configure CORS properly for web clients

### For Development:
- Local testing can use unsecured protocols (`ws`, `http`)
- Ensure development servers are not exposed to the internet
- Use localhost or private IP ranges

---

## Need Help?

If you're having trouble configuring your specific server:

1. Check your server documentation for the correct protocol and port
2. Use the **Test** button in the app to verify connectivity
3. Check the app console logs for detailed error messages
4. Verify your server is running and accessible from your device

Remember: The exact configuration depends on your specific streaming server setup. Consult your server's documentation for the correct protocol, host, and port information.