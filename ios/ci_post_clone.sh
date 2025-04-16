#!/bin/sh
set -e

echo "🚀 Running iOS CI Post-Clone Script"
if [ -d "${CI_WORKSPACE}/myagenda_app/myagenda_app" ]; then
  echo "📂 Detected nested project structure"
  PROJECT_ROOT="${CI_WORKSPACE}/myagenda_app/myagenda_app"
else
  echo "📂 Using standard project structure"
  PROJECT_ROOT="${CI_WORKSPACE}/myagenda_app"
fi

echo "📂 Using project root: ${PROJECT_ROOT}"
cd "${PROJECT_ROOT}"

echo "📦 Running flutter pub get"
if ! flutter pub get; then
  echo "❌ Flutter pub get failed"
  exit 1
fi

echo "📦 Pre-caching Flutter"
if ! flutter precache; then
  echo "❌ Flutter precache failed"
  exit 1
fi

cd ios

if ! command -v pod &> /dev/null; then
  echo "💎 Installing CocoaPods"
  sudo gem install cocoapods
fi

pod deintegrate || true
rm -rf Pods
rm -f Podfile.lock

echo "📦 Installing Pods"
if ! pod install; then
  echo "❌ Pod installation failed"
  exit 1
fi

cd "${PROJECT_ROOT}"

echo "🏗️ Building iOS release (no codesign)"
if ! flutter build ios --release --no-codesign; then
  echo "❌ Flutter build failed"
  exit 1
fi

echo "✅ Flutter build completed successfully"

if [ ! -f "ios/Flutter/Generated.xcconfig" ]; then
  echo "❗ Generated.xcconfig still missing — create minimal fallback"
  mkdir -p ios/Flutter
  echo "// fallback file" > ios/Flutter/Generated.xcconfig
  echo "FLUTTER_TARGET=lib/main.dart" >> ios/Flutter/Generated.xcconfig
  echo "FLUTTER_BUILD_MODE=release" >> ios/Flutter/Generated.xcconfig
fi

PODS_RUNNER_DIR="ios/Pods/Target Support Files/Pods-Runner"
if [ ! -f "$PODS_RUNNER_DIR/Pods-Runner.debug.xcfilelist" ]; then
  echo "❗ Pods-Runner.debug.xcfilelist missing — create minimal fallback"
  mkdir -p "$PODS_RUNNER_DIR"
  echo "" > "$PODS_RUNNER_DIR/Pods-Runner.debug.xcfilelist"
fi
if [ ! -f "$PODS_RUNNER_DIR/Pods-Runner.release.xcfilelist" ]; then
  echo "❗ Pods-Runner.release.xcfilelist missing — create minimal fallback"
  mkdir -p "$PODS_RUNNER_DIR"
  echo "" > "$PODS_RUNNER_DIR/Pods-Runner.release.xcfilelist"
fi

echo "✅ iOS CI Post-Clone Script complete"