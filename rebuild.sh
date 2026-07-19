#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
PROJECT="$ROOT/Flatland.xcodeproj"
SCHEME="Flatland"
CONFIG="Release"
DERIVED_DATA="$ROOT/build"
APP_OUT="$DERIVED_DATA/Build/Products/$CONFIG/Flatland.app"
DEST="$ROOT/Flatland.app"

if [[ -x "/Volumes/Samsung9100Pro/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild" ]]; then
  export DEVELOPER_DIR="/Volumes/Samsung9100Pro/Applications/Xcode.app/Contents/Developer"
  XCODEBUILD="$DEVELOPER_DIR/usr/bin/xcodebuild"
elif command -v xcodebuild >/dev/null 2>&1; then
  XCODEBUILD="$(command -v xcodebuild)"
else
  echo "error: xcodebuild not found. Install Xcode or set DEVELOPER_DIR." >&2
  exit 1
fi

echo "Building $SCHEME ($CONFIG)…"
"$XCODEBUILD" \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration "$CONFIG" \
  -derivedDataPath "$DERIVED_DATA" \
  clean build

if [[ ! -d "$APP_OUT" ]]; then
  echo "error: build succeeded but app not found at $APP_OUT" >&2
  exit 1
fi

rm -rf "$DEST"
cp -R "$APP_OUT" "$DEST"

echo ""
echo "Done: $DEST"
du -sh "$DEST" | awk '{print "Size: " $1}'

if [[ "${1:-}" == "--open" ]]; then
  open "$DEST"
fi
