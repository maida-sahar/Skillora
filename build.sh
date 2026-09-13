#!/bin/bash
set -e  # stop the whole build if any step fails

echo "==> Cloning Flutter SDK (stable channel)..."
git clone https://github.com/flutter/flutter.git -b stable --depth 1
export PATH="$PATH:$(pwd)/flutter/bin"

echo "==> Verifying Flutter install..."
flutter doctor

echo "==> Fetching packages..."
flutter pub get

echo "==> Writing .env from Vercel environment variable..."
if [ -z "$GEMINI_API_KEY" ]; then
  echo "ERROR: GEMINI_API_KEY is not set in Vercel's Environment Variables."
  exit 1
fi
echo "GEMINI_API_KEY=$GEMINI_API_KEY" > .env

echo "==> Building Flutter web release..."
flutter build web --release

echo "==> Build complete. Output is in build/web"