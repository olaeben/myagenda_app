#!/bin/bash

set -e
set -x

echo "--- Starting ci_post_clone.sh (running from ios/ci_scripts) ---"
echo "Current directory: $(pwd)" 

# --- Find Flutter ---
FLUTTER_PATH=""

# Check common Xcode Cloud locations first
COMMON_LOCATIONS=(
  "$CI_WORKSPACE/flutter/bin"          # CI workspace directory (primary)
  "/Users/local/flutter/bin"            # Common Xcode Cloud location
  "$FLUTTER_ROOT/bin"                  # From environment variable
  "/Volumes/workspace/flutter/bin"      # Xcode Cloud specific path
  "$HOME/flutter/bin"                  # User's home directory
  "/Applications/flutter/bin"           # Applications directory
  "/usr/local/flutter/bin"              # System-wide installation
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
    echo "Flutter not found. Installing Flutter SDK..."
    
    # Create a temporary directory for Flutter
    # In the Flutter installation section:
    # Change from:
    TEMP_DIR="$CI_WORKSPACE/flutter_sdk"
    
    # Change to (add fallback to home directory):
    TEMP_DIR="${CI_WORKSPACE:-$HOME}/flutter_sdk"
    
    # Then modify the directory creation to handle permissions:
    mkdir -p "$TEMP_DIR" || {
      echo "Falling back to user home directory"
      TEMP_DIR="$HOME/flutter_sdk"
      mkdir -p "$TEMP_DIR"
    }
    cd "$TEMP_DIR"
    
    # Download Flutter SDK
    echo "Downloading Flutter SDK..."
    curl -L -o flutter.zip https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.13.9-stable.zip
    
    # Extract Flutter SDK
    echo "Extracting Flutter SDK..."
    unzip -q flutter.zip
    
    # Set Flutter path
    FLUTTER_PATH="$TEMP_DIR/flutter/bin"
    
    # Clean up zip file
    rm flutter.zip
    
    echo "Flutter SDK installed at: $FLUTTER_PATH"
  fi
fi

# Add Flutter to the script's PATH
export PATH="$FLUTTER_PATH:$PATH"
echo "Updated PATH: $PATH"

# Verify Flutter is available
if command -v flutter >/dev/null 2>&1; then
  echo "Verifying Flutter command: $(which flutter)"
  flutter --version
  flutter precache
else
  echo "ERROR: Flutter command still not available after PATH update."
  echo "Attempting to download and install Flutter..."
  
  # Create a temporary directory for Flutter if it doesn't exist
  TEMP_DIR="$CI_WORKSPACE/flutter_sdk"
  if [ ! -d "$TEMP_DIR/flutter" ]; then
    mkdir -p "$TEMP_DIR"
    cd "$TEMP_DIR"
    
    # Download Flutter SDK
    echo "Downloading Flutter SDK..."
    curl -L -o flutter.zip https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.13.9-stable.zip
    
    # Extract Flutter SDK
    echo "Extracting Flutter SDK..."
    unzip -q flutter.zip
    rm flutter.zip
  fi
  
  # Add Flutter to PATH
  export PATH="$TEMP_DIR/flutter/bin:$PATH"
  
  # Verify Flutter installation and precache
  if command -v flutter >/dev/null 2>&1; then
    echo "Flutter successfully installed: $(which flutter)"
    flutter --version
    flutter precache
  else
    echo "ERROR: Failed to install Flutter. Exiting."
    exit 1
  fi
  
  # Return to original directory if we changed it
  if [ "$(pwd)" = "$TEMP_DIR" ]; then
    cd -
  fi
fi

# --- Flutter Project Setup ---
# Change directory handling to use absolute paths
echo "Navigating to project root..."
PROJECT_ROOT="/Users/oibitoye/Downloads/myagenda_app/myagenda_app"
cd "$PROJECT_ROOT" || { echo "Failed to enter project root"; exit 1; }
echo "Current directory: $(pwd)"

# Verify we're in the correct location
if [ ! -f "pubspec.yaml" ]; then
  echo "Error: pubspec.yaml not found - wrong directory?"
  echo "Current directory contents:"
  ls -la
  exit 1
fi

# Existing setup commands
echo "Setting up Flutter environment..."
flutter doctor -v

# Clean Flutter project
echo "Cleaning Flutter project..."
flutter clean

# Get dependencies with retry mechanism
echo "Running flutter pub get in project root..."
MAX_RETRIES=3
RETRY_COUNT=0
while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
  if flutter pub get --verbose; then
    echo "Dependencies successfully fetched"
    break
  else
    RETRY_COUNT=$((RETRY_COUNT + 1))
    if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
      echo "ERROR: flutter pub get failed after $MAX_RETRIES attempts"
      exit 1
    fi
    echo "Attempt $RETRY_COUNT of $MAX_RETRIES failed, retrying..."
    sleep 5
  fi
done

# Build iOS with retry mechanism
# Modify the Flutter build section
# Fix 1: Add proper environment variables for RubyGems before CocoaPods
echo "--- Configuring RubyGems Environment ---"
export GEM_HOME="$HOME/.gem"
export PATH="$GEM_HOME/bin:$PATH"

# Fix 2: Update the Flutter build command syntax
echo "Running flutter build ios in project root..."
RETRY_COUNT=0
while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
  if flutter build ios --release --no-codesign --verbose --no-pub; then  # Fixed syntax error here
    echo "iOS build completed successfully"
    break
  else
    RETRY_COUNT=$((RETRY_COUNT + 1))
    if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
      echo "ERROR: flutter build ios failed after $MAX_RETRIES attempts"
      # Add diagnostic commands
      echo "=== BUILD FAILURE DIAGNOSTICS ==="
      flutter doctor -v
      ls -la ios/
      pod repo list
      exit 1
    fi
    echo "Attempt $RETRY_COUNT of $MAX_RETRIES failed, retrying..."
    sleep $((RETRY_COUNT * 5))
  fi
done

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

# Fix 3: Enhance CocoaPods setup
echo "Ensuring CocoaPods is properly installed..."
gem install cocoapods --user-install
pod setup
pod repo update

# Fix 4: Add explicit path to Pods directory
echo "Running pod install with explicit path..."
cd "$CI_WORKSPACE/ios"
pod install