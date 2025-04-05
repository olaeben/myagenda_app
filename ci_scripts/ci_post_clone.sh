    #!/bin/sh

    # Exit immediately if a command exits with a non-zero status.
    set -e

    # --- Flutter Environment Setup ---
    # This assumes Flutter is available in the Xcode Cloud environment.
    # Adjust path if necessary, though default environments usually have it.
    echo "Setting up Flutter..."
    # Install Flutter dependencies
    flutter pub get

    # --- Generate Xcode Config Files ---
    echo "Generating Xcode config files..."
    # Run flutter build ios to generate Generated.xcconfig and other necessary files
    # Using --no-codesign as Xcode Cloud will handle signing later
    flutter build ios --release --no-codesign

    # --- CocoaPods Setup ---
    echo "Setting up CocoaPods..."
    # Navigate to the ios directory
    cd ios

    # Install CocoaPods dependencies
    # Using repo-update might be needed if Pods are outdated, but can be slower.
    # Try without it first.
    # pod install --repo-update
    pod install

    echo "Post-clone script finished successfully."

    exit 0