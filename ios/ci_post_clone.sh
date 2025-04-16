#!/bin/sh
set -e

echo "🚀 Running iOS CI Post-Clone Script"

# Fix potential directory issues
if [ -d "${CI_WORKSPACE}/myagenda_app/myagenda_app" ]; then
  echo "📂 Detected nested project structure"
  PROJECT_ROOT="${CI_WORKSPACE}/myagenda_app/myagenda_app"
else
  echo "📂 Using standard project structure"
  PROJECT_ROOT="${CI_WORKSPACE}/myagenda_app"
fi

echo "📂 Using project root: ${PROJECT_ROOT}"
cd "${PROJECT_ROOT}"

# Clean everything first
echo "🧹 Cleaning all build artifacts"
flutter clean
rm -rf "${PROJECT_ROOT}/ios/Pods"
rm -rf "${PROJECT_ROOT}/ios/.symlinks"
rm -rf "${PROJECT_ROOT}/ios/Flutter/Flutter.framework"
rm -rf "${PROJECT_ROOT}/ios/Flutter/Flutter.podspec"
rm -f "${PROJECT_ROOT}/ios/Podfile.lock"

# Get dependencies
echo "📦 Running flutter pub get"
flutter pub get

# Generate all necessary Flutter files first
echo "🛠️ Generating Flutter files"
flutter pub run flutter_launcher_icons:main
flutter precache --ios
flutter build ios --no-codesign --config-only

cd ios

# Install CocoaPods if needed
if ! command -v pod &> /dev/null; then
  echo "💎 Installing CocoaPods"
  sudo gem install cocoapods
fi

# Pod setup
echo "🔧 Setting up CocoaPods"
pod setup

# Install pods
echo "📦 Installing Pods"
pod install --repo-update --clean-install

# Create all missing xcfilelist files
echo "📝 Creating missing xcfilelist files"
PODS_RUNNER_DIR="Pods/Target Support Files/Pods-Runner"
mkdir -p "$PODS_RUNNER_DIR"

for CONFIG in debug release; do
  for TYPE in resources frameworks; do
    for IO in input output; do
      FILE="${PODS_RUNNER_DIR}/Pods-Runner-${TYPE}-${CONFIG}-${IO}-files.xcfilelist"
      if [ ! -f "$FILE" ]; then
        echo "Creating ${FILE}"
        touch "$FILE"
      fi
    done
  done
done

# Ensure Generated.xcconfig exists with proper content
echo "⚙️ Ensuring Generated.xcconfig exists"
FLUTTER_CONFIG_DIR="Flutter"
mkdir -p "$FLUTTER_CONFIG_DIR"

cat <<EOF > "${FLUTTER_CONFIG_DIR}/Generated.xcconfig"
// Generated file
FLUTTER_ROOT=${HOME}/flutter
FLUTTER_APPLICATION_PATH=${PROJECT_ROOT}
FLUTTER_TARGET=lib/main.dart
FLUTTER_BUILD_DIR=build
FLUTTER_BUILD_MODE=release
SYMROOT=\${SOURCE_ROOT}/../build/ios
FLUTTER_FRAMEWORK_DIR=${FLUTTER_CONFIG_DIR}
EOF

cd "${PROJECT_ROOT}"

# Final build
echo "🏗️ Building iOS release"
flutter build ios --release --no-codesign

echo "✅ iOS CI Post-Clone Script complete"