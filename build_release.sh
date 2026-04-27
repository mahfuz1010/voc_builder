#!/bin/bash

# Build Flutter release APK
echo "🚀 Building Flutter release APK..."
flutter build apk --release

if [ $? -eq 0 ]; then
    echo "✓ Build completed successfully!"
    echo "📦 APK location: build/app/outputs/flutter-apk/app-release.apk"
else
    echo "✗ Build failed!"
    exit 1
fi
