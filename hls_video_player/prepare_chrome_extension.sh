#!/bin/bash

# Script to prepare Chrome extension from Flutter web build

echo "Preparing HLS Video Player Chrome Extension..."

# Build for web first
echo "Building Flutter web app..."
flutter build web

# Check if build was successful
if [ ! -d "build/web" ]; then
    echo "Error: Web build failed or build/web directory not found"
    exit 1
fi

# Copy Chrome extension manifest
echo "Copying Chrome extension manifest..."
cp chrome_extension_manifest.json build/web/manifest.json

# Update the index.html to work better as a popup
echo "Updating index.html for Chrome extension..."
sed -i 's/<title>hls_video_player<\/title>/<title>HLS Video Player<\/title>/g' build/web/index.html

echo "Chrome extension ready in build/web/"
echo ""
echo "To install in Chrome:"
echo "1. Open Chrome and go to chrome://extensions/"
echo "2. Enable 'Developer mode'"
echo "3. Click 'Load unpacked'"
echo "4. Select the build/web/ directory"
echo ""
echo "The extension will appear in your Chrome toolbar!"