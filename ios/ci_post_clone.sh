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

# Ensure Flutter generates all necessary files first
echo "🏗️ Generating Flutter files (no build)"
if ! flutter build ios --no-codesign --config-only; then
  echo "❌ Flutter config generation failed"
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
if ! pod install --repo-update; then
  echo "❌ Pod installation failed"
  exit 1
fi

# Create missing xcfilelist files if they don't exist
PODS_RUNNER_DIR="Pods/Target Support Files/Pods-Runner"
mkdir -p "$PODS_RUNNER_DIR"

for CONFIG in debug release; do
  for TYPE in resources frameworks; do
    for IO in input output; do
      FILE="${PODS_RUNNER_DIR}/Pods-Runner-${TYPE}-${CONFIG}-${IO}-files.xcfilelist"
      if [ ! -f "$FILE" ]; then
        echo "❗ ${FILE} missing — creating empty fallback"
        touch "$FILE"
      fi
    done
  done
done

cd "${PROJECT_ROOT}"

echo "🏗️ Building iOS release (no codesign)"
if ! flutter build ios --release --no-codesign; then
  echo "❌ Flutter build failed"
  exit 1
fi

# Double check Generated.xcconfig exists
if [ ! -f "ios/Flutter/Generated.xcconfig" ]; then
  echo "❗ Generated.xcconfig still missing — create minimal fallback"
  mkdir -p ios/Flutter
  cat <<EOF > ios/Flutter/Generated.xcconfig
// fallback file
FLUTTER_TARGET=lib/main.dart
FLUTTER_BUILD_MODE=release
ASSET_MANIFEST_PATH=Flutter/App.framework/flutter_assets/AssetManifest.json
SYMROOT=\${SOURCE_ROOT}/../build/ios
FLUTTER_BUILD_DIR=build
FLUTTER_FRAMEWORK_DIR=Flutter
EOF
fi

echo "✅ iOS CI Post-Clone Script complete"