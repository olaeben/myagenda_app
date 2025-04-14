#!/bin/sh
set -e

echo "🚀 Running iOS CI Post-Clone Script"

# Detect project root
if [ -d "${CI_WORKSPACE}/myagenda_app/myagenda_app" ]; then
  PROJECT_ROOT="${CI_WORKSPACE}/myagenda_app/myagenda_app"
else
  PROJECT_ROOT="${CI_WORKSPACE}/myagenda_app"
fi

cd "${PROJECT_ROOT}"

echo "📦 Running flutter pub get"
flutter pub get

echo "📦 Pre-caching Flutter"
flutter precache

cd ios

# Ensure CocoaPods is installed
if ! command -v pod &> /dev/null; then
  echo "💎 Installing CocoaPods"
  sudo gem install cocoapods
fi

# Clean up any old pods
pod deintegrate || true
rm -rf Pods
rm -f Podfile.lock

echo "📦 Installing Pods"
pod install

cd "${PROJECT_ROOT}"

# Build AFTER pod install
echo "🏗️ Building iOS release (no codesign)"
flutter build ios --release --no-codesign

# Check Generated.xcconfig exists
if [ ! -f "ios/Flutter/Generated.xcconfig" ]; then
  echo "❗ Generated.xcconfig still missing — create minimal fallback"
  mkdir -p ios/Flutter
  echo "// fallback file" > ios/Flutter/Generated.xcconfig
  echo "FLUTTER_TARGET=lib/main.dart" >> ios/Flutter/Generated.xcconfig
  echo "FLUTTER_BUILD_MODE=release" >> ios/Flutter/Generated.xcconfig
fi

echo "✅ iOS CI Post-Clone Script complete"