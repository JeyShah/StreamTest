#!/bin/bash

# WebRTC Streaming Test App Setup Script
echo "🚀 Setting up WebRTC Streaming Test App..."

# Check if Flutter is available
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter not found in PATH"
    echo "💡 Using bundled Flutter from /tmp/flutter/bin"
    export PATH="/tmp/flutter/bin:$PATH"
fi

# Check Flutter version
echo "📱 Flutter version:"
flutter --version

# Install dependencies
echo "📦 Installing dependencies..."
flutter pub get

# Run code analysis
echo "🔍 Running code analysis..."
flutter analyze

# Run tests
echo "🧪 Running tests..."
flutter test

echo "✅ Setup complete!"
echo ""
echo "🎯 Next steps:"
echo "1. Open this project in Cursor: File -> Open Folder -> webrtc_streaming_test"
echo "2. Configure your media server URL in the app settings"
echo "3. Run the app:"
echo "   • Android: flutter run"
echo "   • iOS: flutter run -d ios (requires macOS + Xcode)"
echo "   • Web: flutter run -d web"
echo ""
echo "📚 See README.md for detailed usage instructions"