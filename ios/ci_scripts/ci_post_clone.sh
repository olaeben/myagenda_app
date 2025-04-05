#!/bin/sh

# Exit immediately if a command exits with a non-zero status.
set -e
# Print each command before executing it (for debugging)
set -x

echo "--- Starting ci_post_clone.sh (running from ios/ci_scripts) ---"
echo "Current directory: $(pwd)" # Should be /Volumes/workspace/repository/ios/ci_scripts

# --- Find Flutter ---
# Xcode Cloud environment variable $FLUTTER_ROOT is often set.
# Fallback to a common location if variable isn't set.
FLUTTER_PATH=""
if [ -n "$FLUTTER_ROOT" ]; then
  FLUTTER_PATH="$FLUTTER_ROOT/bin"
  echo "Found Flutter root via \$FLUTTER_ROOT: $FLUTTER_ROOT"
elif [ -d "/Users/local/flutter" ]; then
  FLUTTER_PATH="/Users/local/flutter/bin"
  echo "Found Flutter root at default location: /Users/local/flutter"
else
  echo "ERROR: Could not find Flutter installation."
  # Try searching common paths (might be slow)
  FLUTTER_CMD_PATH=$(which flutter)
  if [ -n "$FLUTTER_CMD_PATH" ]; then
      FLUTTER_PATH=$(dirname "$FLUTTER_CMD_PATH")
      echo "Found Flutter using 'which' command: $FLUTTER_PATH"
  else
      echo "Flutter command 'flutter' not found in PATH or common locations."
      exit 1 # Exit if Flutter cannot be found
  fi
fi

# Add Flutter to the script's PATH
export PATH="$FLUTTER_PATH:$PATH"
echo "Updated PATH: $PATH"
echo "Verifying Flutter command: $(which flutter)"
echo "Flutter version: $(flutter --version)"

# --- Flutter Project Setup ---
# Go UP one level to the 'ios' directory first
cd .. # Now in /Volumes/workspace/repository/ios
echo "Current directory: $(pwd)"

# Go UP another level to the project root directory
cd .. # Now in /Volumes/workspace/repository
echo "Current directory: $(pwd)"

echo "Running flutter pub get in project root..."
flutter pub get

echo "Running flutter build ios in project root..."
flutter build ios --release --no-codesign

echo "Checking for Generated.xcconfig..."
ls -l ios/Flutter/

# --- CocoaPods Setup ---
echo "Navigating back to ios directory..."
cd ios # Now in /Volumes/workspace/repository/ios
echo "Current directory: $(pwd)"

echo "Pod version: $(pod --version)"
echo "Running pod install..."
pod install

echo "Checking for Pods directory and xcfilelists..."
ls -l Pods/Target\ Support\ Files/Pods-Runner/

echo "--- ci_post_clone.sh finished successfully ---"
set +x # Turn off command printing
exit 0