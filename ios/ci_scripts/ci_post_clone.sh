#!/bin/bash

set -e
set -x

echo "--- Starting ci_post_clone.sh (running from ios/ci_scripts) ---"
echo "Current directory: $(pwd)" 

# --- Find Flutter ---
FLUTTER_PATH=""

# Check common Xcode Cloud locations first
COMMON_LOCATIONS=(
  "$FLUTTER_ROOT/bin"                  # From environment variable
  "/Users/local/flutter/bin"            # Common Xcode Cloud location
  "$HOME/flutter/bin"                  # User's home directory
  "/Applications/flutter/bin"           # Applications directory
  "/usr/local/flutter/bin"              # System-wide installation
  "$CI_WORKSPACE/flutter/bin"          # CI workspace directory
  "/Volumes/workspace/flutter/bin"      # Xcode Cloud specific path
)


check_flutter() {
  local path="$1/flutter"
  if [ -f "$path" ] && [ -x "$path" ]; then
    echo "Found Flutter at: $1"
    FLUTTER_PATH="$1"
    return 0
  fi
  return 1
}

for location in "${COMMON_LOCATIONS[@]}"; do
  if [ -n "$location" ] && check_flutter "$location"; then
    break
  fi
done

if [ -z "$FLUTTER_PATH" ]; then
  echo "Flutter not found in common locations. Attempting to find in PATH..."
  FLUTTER_CMD_PATH=$(which flutter 2>/dev/null || echo "")
  
  if [ -n "$FLUTTER_CMD_PATH" ]; then
    FLUTTER_PATH=$(dirname "$FLUTTER_CMD_PATH")
    echo "Found Flutter in PATH: $FLUTTER_PATH"
  else
    echo "WARNING: Flutter not found. Will attempt to continue with system Flutter."
    FLUTTER_PATH="flutter" 
  fi
fi

# Add Flutter to the script's PATH
export PATH="$FLUTTER_PATH:$PATH"
echo "Updated PATH: $PATH"

# Verify Flutter is available
if command -v flutter >/dev/null 2>&1; then
  echo "Verifying Flutter command: $(which flutter)"
  echo "Flutter version: $(flutter --version)"
else
  echo "ERROR: Flutter command still not available after PATH update."
  echo "Attempting to download and install Flutter..."
  
  # Create a temporary directory for Flutter
  TEMP_DIR="$(pwd)/flutter_temp"
  mkdir -p "$TEMP_DIR"
  cd "$TEMP_DIR"
  
  # Download Flutter SDK
  echo "Downloading Flutter SDK..."
  curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.13.9-stable.zip
  
  # Extract Flutter SDK
  echo "Extracting Flutter SDK..."
  unzip -q flutter_macos_3.13.9-stable.zip
  
  # Add Flutter to PATH
  export PATH="$TEMP_DIR/flutter/bin:$PATH"
  
  # Verify Flutter installation
  if command -v flutter >/dev/null 2>&1; then
    echo "Flutter successfully installed: $(which flutter)"
    echo "Flutter version: $(flutter --version)"
  else
    echo "ERROR: Failed to install Flutter. Exiting."
    exit 1
  fi
  
  # Return to original directory
  cd -
fi

# --- Flutter Project Setup ---
# Go UP one level to the 'ios' directory first
cd .. 
echo "Current directory: $(pwd)"

# Go UP another level to the project root directory
cd .. 
echo "Current directory: $(pwd)"

echo "Running flutter pub get in project root..."
if ! flutter pub get; then
  echo "WARNING: flutter pub get failed, retrying with --verbose"
  flutter pub get --verbose
fi

echo "Running flutter build ios in project root..."
if ! flutter build ios --release --no-codesign; then
  echo "WARNING: flutter build ios failed, retrying with --verbose"
  flutter build ios --release --no-codesign --verbose
fi

echo "Checking for Generated.xcconfig..."
ls -l ios/Flutter/ || echo "Warning: Could not list Flutter directory contents"

# --- CocoaPods Setup ---
echo "Navigating back to ios directory..."
cd ios 
echo "Current directory: $(pwd)"

# Ensure CocoaPods is installed
if ! command -v pod >/dev/null 2>&1; then
  echo "CocoaPods not found, installing..."
  gem install cocoapods
fi

echo "Pod version: $(pod --version)"
echo "Running pod install..."
if ! pod install; then
  echo "WARNING: pod install failed, retrying with --verbose"
  pod install --verbose
fi

echo "Checking for Pods directory and xcfilelists..."
ls -l Pods/Target\ Support\ Files/Pods-Runner/ || echo "Warning: Could not list Pods directory contents"

# Make sure the script is executable for future runs
chmod +x "$0"

echo "--- ci_post_clone.sh finished successfully ---"
set +x 
exit 0