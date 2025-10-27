#!/bin/bash

# HLS Video Player Setup Script
echo "🎬 Setting up HLS Video Player..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if Flutter is available
if ! command -v flutter &> /dev/null; then
    echo -e "${YELLOW}⚠️  Flutter not found in PATH${NC}"
    echo -e "${BLUE}💡 Using bundled Flutter from /tmp/flutter/bin${NC}"
    export PATH="/tmp/flutter/bin:$PATH"
    
    # Check if Flutter exists in /tmp
    if [ ! -f "/tmp/flutter/bin/flutter" ]; then
        echo -e "${RED}❌ Flutter not found. Installing Flutter...${NC}"
        cd /tmp
        wget -q https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.5-stable.tar.xz
        tar xf flutter_linux_3.24.5-stable.tar.xz
        cd - > /dev/null
    fi
    
    export PATH="/tmp/flutter/bin:$PATH"
fi

# Check Flutter version
echo -e "${BLUE}📱 Flutter version:${NC}"
flutter --version

# Install dependencies
echo -e "${BLUE}📦 Installing dependencies...${NC}"
flutter pub get

# Check doctor status
echo -e "${BLUE}🔍 Running Flutter doctor...${NC}"
flutter doctor

echo -e "${GREEN}✅ Setup complete!${NC}"
echo ""
echo -e "${BLUE}🎯 Next steps:${NC}"
echo "1. Choose your target platform:"
echo ""
echo -e "${YELLOW}   📱 Android:${NC}"
echo "   flutter run -d android"
echo ""
echo -e "${YELLOW}   🍎 iOS (macOS only):${NC}"
echo "   flutter run -d ios"
echo ""
echo -e "${YELLOW}   💻 macOS:${NC}"
echo "   flutter run -d macos"
echo ""
echo -e "${YELLOW}   🌐 Web:${NC}"
echo "   flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080"
echo ""
echo -e "${YELLOW}   🔧 Chrome:${NC}"
echo "   flutter run -d chrome"
echo ""
echo "2. Enter your stream URL in the app"
echo "3. Press 'Play Stream' to start watching"
echo ""
echo -e "${BLUE}📚 Supported formats:${NC}"
echo "   • HLS (.m3u8) streams"
echo "   • MP4 videos"
echo "   • WebM videos"
echo "   • FLV streams (limited support)"
echo ""
echo -e "${BLUE}🔗 Default test URL:${NC}"
echo "   http://47.130.109.65:8080/hls/mystream.flv"
echo ""
echo -e "${GREEN}📖 See README.md for detailed instructions${NC}"