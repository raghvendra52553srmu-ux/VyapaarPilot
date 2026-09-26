#!/usr/bin/env bash
set -euo pipefail

echo "=================================================="
echo "VyapaarPilot — Cloudflare Pages Build Script"
echo "=================================================="

# 1. Ensure Flutter SDK is installed and available
if command -v flutter &> /dev/null; then
  echo "✓ Flutter SDK detected in PATH: $(flutter --version | head -n 1)"
else
  echo "Flutter not found in PATH. Setting up Flutter SDK..."
  FLUTTER_ROOT="/tmp/flutter"
  if [ ! -d "$FLUTTER_ROOT" ]; then
    echo "Cloning Flutter stable branch..."
    git clone --depth 1 -b stable https://github.com/flutter/flutter.git "$FLUTTER_ROOT"
  fi
  export PATH="$FLUTTER_ROOT/bin:$PATH"
  echo "✓ Installed Flutter: $(flutter --version | head -n 1)"
fi

# 2. Determine directory paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
FRONTEND_DIR="$REPO_ROOT/frontend"

cd "$FRONTEND_DIR"

# 3. Resolve dependencies
echo "Resolving Flutter dependencies..."
flutter pub get

# 4. Determine API Base URL
TARGET_API_URL="${API_BASE_URL:-https://vyapaarpilot.onrender.com/api}"
# If TARGET_API_URL does not end in /api, append it
if [[ "$TARGET_API_URL" != */api ]]; then
  TARGET_API_URL="${TARGET_API_URL%/}/api"
fi
echo "Configuring API Base URL: $TARGET_API_URL"


# 5. Build Flutter Web release
echo "Building Flutter Web release in strict API mode (NO mock data fallback)..."
flutter build web --release \
  --dart-define=API_BASE_URL="$TARGET_API_URL" \
  --dart-define=DATA_MODE=api


# 6. Configure Cloudflare SPA routing and 404 fallback
echo "Generating Cloudflare SPA routing configuration..."
OUTPUT_DIR="$FRONTEND_DIR/build/web"
mkdir -p "$OUTPUT_DIR"

# Clean any legacy _redirects file to prevent Cloudflare rewrite loop error 100324
rm -f "$OUTPUT_DIR/_redirects"

# Static 404 fallback (reloads Flutter SPA)
cp "$OUTPUT_DIR/index.html" "$OUTPUT_DIR/404.html"

echo "✓ Build output successfully generated at: $OUTPUT_DIR"

echo "=================================================="
echo "VyapaarPilot Cloudflare Build Completed Successfully!"
echo "=================================================="
