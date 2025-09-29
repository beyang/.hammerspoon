#!/bin/bash

# Script to create Spotlight-searchable .app bundles for Hammerspoon actions
# Run this script to generate apps in ~/Applications/Hammerspoon Actions/

APPS_DIR="$HOME/Applications/Hammerspoon Actions"
mkdir -p "$APPS_DIR"

create_action_app() {
    local action_id="$1"
    local app_name="$2"
    local app_dir="$APPS_DIR/$app_name.app"
    
    echo "Creating $app_name.app..."
    
    mkdir -p "$app_dir/Contents/MacOS"
    
    # Create executable script
    cat > "$app_dir/Contents/MacOS/$app_name" << EOF
#!/bin/bash
osascript -e "tell application \"Hammerspoon\" to execute lua code \"executeAction('$action_id')\""
EOF
    
    chmod +x "$app_dir/Contents/MacOS/$app_name"
    
    # Create Info.plist for proper app recognition
    cat > "$app_dir/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$app_name</string>
    <key>CFBundleIdentifier</key>
    <string>com.hammerspoon.$action_id</string>
    <key>CFBundleName</key>
    <string>$app_name</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
EOF
}

# Create apps for each action
create_action_app "new-chrome" "New Google Chrome Window"
create_action_app "new-ghostty" "New Ghostty Window"

echo "Apps created in: $APPS_DIR"
echo ""
echo "Now you can:"
echo "1. Press Cmd+Space and search for 'New Google Chrome Window'"
echo "2. Or search for 'New Ghostty Window'"
echo "3. Press Enter to execute the action"
echo ""
echo "To update the apps after changing Hammerspoon actions, just run this script again."
