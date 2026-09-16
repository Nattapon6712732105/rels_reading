#!/bin/bash
set -e

# Download Flutter if not present
if [ ! -d "flutter" ]; then
  echo "Downloading Flutter SDK..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1
fi

export PATH="$PATH:`pwd`/flutter/bin"

echo "Flutter version:"
flutter --version

flutter config --no-analytics
flutter config --enable-web

echo "Resolving dependencies..."
flutter pub get

echo "Building Flutter Web release..."
flutter build web --release

echo "Build complete! Output in build/web"
