#!/bin/sh

# Fail if any command fails
set -e

echo "📦 iOS CI Post-Clone Script"

# Navigate to project root
cd "${CI_WORKSPACE}/myagenda_app"

# Install Flutter
echo "🔄 Installing Flutter dependencies"
flutter pub get

# Navigate to iOS folder
cd ios

# Install CocoaPods if needed
if ! command -v pod &> /dev/null; then
  echo "🔄 Installing CocoaPods"
  sudo gem install cocoapods
fi

# Make sure Flutter generates necessary files
echo "🔄 Running Flutter build for iOS"
flutter build ios --no-codesign

# Install CocoaPods dependencies
echo "🔄 Installing CocoaPods dependencies"
pod install

# Ensure Generated.xcconfig exists
if [ ! -f "${CI_WORKSPACE}/myagenda_app/ios/Flutter/Generated.xcconfig" ]; then
  echo "⚠️ Generated.xcconfig not found, running flutter pub get again"
  cd "${CI_WORKSPACE}/myagenda_app"
  flutter pub get
fi

echo "✅ iOS CI Post-Clone Script completed"