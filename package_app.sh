#!/bin/bash

APP_NAME="ClipboardManager"
BUILD_PATH=".build/release"
APP_BUNDLE="$APP_NAME.app"
CONTENTS_DIR="$APP_BUNDLE/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

# Build the project
echo "🚀 Building project (Release Mode)..."
swift build -c release --disable-sandbox

if [ ! -f "$BUILD_PATH/$APP_NAME" ]; then
    echo "❌ Binary not found at $BUILD_PATH/$APP_NAME"
    exit 1
fi

echo "📦 Creating App Bundle structure..."
# Create directory structure
rm -rf "$APP_BUNDLE"
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# Copy binary
cp "$BUILD_PATH/$APP_NAME" "$MACOS_DIR/"

# Create Info.plist
cat > "$CONTENTS_DIR/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>com.clipboardmanager.app</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>$(date +%Y%m%d%H%M)</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

# Create PkgInfo
echo "APPL????" > "$CONTENTS_DIR/PkgInfo"

# Code Signing
echo "🔏 Signing App Bundle..."
codesign --force --deep --sign - "$APP_BUNDLE"

echo "✅ App Bundle created: $APP_BUNDLE"

# Create DMG for distribution
echo "📦 Creating DMG..."
DMG_NAME="$APP_NAME.dmg"
STAGING_DIR="dmg_staging"

# Prepare staging directory
rm -rf "$STAGING_DIR" "$DMG_NAME"
mkdir -p "$STAGING_DIR"
cp -r "$APP_BUNDLE" "$STAGING_DIR/"
ln -s /Applications "$STAGING_DIR/Applications"

# Create DMG
hdiutil create -volname "$APP_NAME" -srcfolder "$STAGING_DIR" -ov -format UDZO "$DMG_NAME"

# Cleanup
rm -rf "$STAGING_DIR"

echo "✅ DMG created: $DMG_NAME"

echo "👉 You can now open $DMG_NAME and drag the app to Applications!"
echo "⚠️ Note: You may need to grant Accessibility permissions again for the new .app bundle."
