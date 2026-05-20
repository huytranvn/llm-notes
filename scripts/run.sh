#!/usr/bin/env bash
# Build LLMNotes and launch it wrapped in a minimal .app bundle so macOS
# treats it as a regular foreground app (dock icon, activated window).
set -euo pipefail

cd "$(dirname "$0")/.."

export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"

CONFIG="${1:-debug}"

echo "→ swift build (-c $CONFIG)"
xcrun swift build -c "$CONFIG"

BIN_PATH="$(xcrun swift build -c "$CONFIG" --show-bin-path)"
BIN="$BIN_PATH/LLMNotes"
[ -x "$BIN" ] || { echo "missing binary at $BIN"; exit 1; }

APP_DIR=".build/LLMNotes.app"
rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS" "$APP_DIR/Contents/Resources"

cp "$BIN" "$APP_DIR/Contents/MacOS/LLMNotes"

cat > "$APP_DIR/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key>                 <string>LLM Notes</string>
  <key>CFBundleDisplayName</key>          <string>LLM Notes</string>
  <key>CFBundleIdentifier</key>           <string>com.huytran.llm-notes</string>
  <key>CFBundleExecutable</key>           <string>LLMNotes</string>
  <key>CFBundlePackageType</key>          <string>APPL</string>
  <key>CFBundleShortVersionString</key>   <string>0.1</string>
  <key>CFBundleVersion</key>              <string>1</string>
  <key>LSMinimumSystemVersion</key>       <string>14.0</string>
  <key>NSHighResolutionCapable</key>      <true/>
  <key>NSPrincipalClass</key>             <string>NSApplication</string>
</dict>
</plist>
PLIST

echo "→ launching $APP_DIR"
open -n -a "$(pwd)/$APP_DIR"
