#!/usr/bin/env bash

# Publish the Simulator and Device App builds to App Center.
# You must set the following environment variables:
# APP_CENTER_TOKEN
# APP_CENTER_APP_NAME
# APP_CENTER_GROUP
# APP_CENTER_BUILD_VERSION
# APPLE_ENTERPRISE_P12
# APPLE_ENTERPRISE_PROVISION

# Usage info
show_help()
{
echo "
        Usage: [-v Type]

        -t Type           Simulator/Device
        -p Build Prefix   Build prefix
        -d                Displays useful data to debug this script
        -a                Automatic mode. Requires -v parameter to be 100% without prompt
        -s                Same as -a but in silent mode

        For Example: ./deploy-to-app-center.sh -t SIMULATOR

        -h                Help
"
}
NO_PROMPT=0
DEPLOY_TYPE_SIMULATOR="SIMULATOR"
DEPLOY_TYPE_DEVICE="DEVICE"

while getopts ":t:build-prefix:app-center-group:dhas" opt; do
  case $opt in
    t) TYPE="$OPTARG"
    ;;
    build-prefix) BUILD_PREFIX="$OPTARG"
    ;;
    app-center-group) APPCENTER_GROUP="$OPTARG"
    ;;
    d) set -ex
    ;;
    h) show_help; exit 0
    ;;
    a) NO_PROMPT=1
    ;;
    s) NO_PROMPT=1; exec &>/dev/null
    ;;
    \?) echo "Invalid option -$OPTARG" >&1; exit 1
    ;;
  esac
done


if [ -z "$TYPE" ]
  then
    read -r -p "Please input the Type of build you wanted to Deploy (ex: for Simulator please input SIMULATOR): " TYPE
fi

WORK_DIR=$(pwd)
TMP_DIR=$WORK_DIR/tmp

mkdir -p "$TMP_DIR"

echo "Retrieving changelog...."
$(dirname "$0")/extract-version.sh

echo "Installing App Center CLI."
npm install -g appcenter-cli

# ##############################
# # Simulator Build           #
# ############################

deploy_simulator_build()
{
    echo "Creating ZIP file for Simulator build."
    zip -r ./artifacts/miniapp.app.zip ./artifacts/MiniApp_Example.app/*

    echo "Deploying Simulator App build to $APPCENTER_GROUP group on App Center."
    appcenter distribute release \
    --token "$APP_CENTER_TOKEN" \
    --app "$APP_CENTER_APP_NAME" \
    --release-notes-file "$TMP_DIR"/CHANGELOG.md \
    --group "$APPCENTER_GROUP" \
    --build-version "$CIRCLE_BUILD_NUM-$BUILD_PREFIX" \
    --file ./artifacts/miniapp.app.zip \
    --quiet

    echo "Uploading Symbols to $APPCENTER_GROUP group on App Center."
    appcenter crashes upload-symbols \
    --symbol ./artifacts/MiniApp_Example.app.dSYM \
    --token "$APP_CENTER_TOKEN" \
    --app "$APP_CENTER_APP_NAME_DEVICE" \
    --quiet
}

# ##############################
# # Device Build              #
# ############################

deploy_device_build()
{
    KEYCHAIN_FILE=miniapp-signing.keychain-db
    PROVISION=miniapp.mobileprovision
    P12_FILE=miniapp.p12
    PROFILES_DIR=~/Library/MobileDevice/Provisioning\ Profiles
    DSYM_FILE=$TMP_DIR/dsym.zip
    EXPORT_PLIST=$TMP_DIR/miniapp.plist

    echo "Installing the Apple certificate and provisioning profile stored as base64 env vars"
    ### Here is an example on how to generate the base64 from a P12 or a provisionning profile:
    ### openssl base64 -in MiniAppDemo.mobileprovision -out MiniAppDemoBase64.txt
    echo -n "$APPLE_ENTERPRISE_P12" | base64 --decode --output "$P12_FILE"
    echo -n "$APPLE_ENTERPRISE_PROVISION" | base64 --decode --output "$PROVISION"

    echo "Initializing the custom keychain used to sign the IPA"
    security create-keychain -p "$P12_PASSWORD" $KEYCHAIN_FILE
    security default-keychain -d user -s $KEYCHAIN_FILE
    security set-keychain-settings -lut 21600 $KEYCHAIN_FILE
    security unlock-keychain -p "$P12_PASSWORD" $KEYCHAIN_FILE

    echo "Importing Certificate to Keychain"
    security import "$P12_FILE" -P "$P12_PASSWORD" -A -t cert -f pkcs12 -k $KEYCHAIN_FILE
    security set-key-partition-list -S apple-tool:,apple: -k "$P12_PASSWORD" $KEYCHAIN_FILE
    security list-keychain -d user -s $KEYCHAIN_FILE

    mkdir -p "$PROFILES_DIR"
    cp "$PROVISION" "$PROFILES_DIR"

    echo "Extracting provisioning profile UUID and code signing identity"
    UUID=$(/usr/libexec/PlistBuddy -c "Print UUID" /dev/stdin <<< "$(/usr/bin/security cms -D -i "$PROVISION")")
    CODE_SIGN_IDENTITY=$(security find-identity -v -p codesigning | grep  -o '"[^"]\+"' | head -1 | tr -d '"')

    echo "Creating the options plist used to sign IPA"
    PLIST="{\"compileBitcode\":false,\"method\":\"enterprise\",\"provisioningProfiles\":{\"com.rakuten.tech.mobile.miniapp.MiniAppDemo\":\"$UUID\"}}"
    echo "$PLIST" | plutil -convert xml1 -o $EXPORT_PLIST -

    echo "Building archive"
    xcodebuild DEVELOPMENT_TEAM="$APPLE_DEVELOPMENT_TEAM" \
    OTHER_CODE_SIGN_FLAGS="--keychain $KEYCHAIN_FILE" \
    CODE_SIGN_IDENTITY="$CODE_SIGN_IDENTITY" \
    PROVISIONING_PROFILE="$UUID" \
    archive \
    -archivePath MiniApp-Example.xcarchive \
    -workspace MiniApp.xcworkspace -scheme MiniApp-Example \
    -sdk iphoneos

    echo "Building IPA"
    xcodebuild -exportArchive \
    -archivePath MiniApp-Example.xcarchive \
    -exportPath "$TMP_DIR" \
    -exportOptionsPlist "$EXPORT_PLIST"

    echo "Cleaning $KEYCHAIN_FILE keychain"
    security delete-keychain $KEYCHAIN_FILE
    rm "$PROFILES_DIR"/"$PROVISION"

    echo "Retrieving dsym files"
    cd MiniApp-Example.xcarchive/dSYMs
    zip -rX "$DSYM_FILE" -- *
    cd "$WORK_DIR"

    echo "Deploying Device App build to $APPCENTER_GROUP group on App Center."
    appcenter distribute release \
    --token "$APP_CENTER_TOKEN_DEVICE" \
    --app "$APP_CENTER_APP_NAME_DEVICE" \
    --group "$APPCENTER_GROUP" \
    --build-version "$CIRCLE_BUILD_NUM" \
    --release-notes-file "$TMP_DIR"/CHANGELOG.md \
    --file "$TMP_DIR"/MiniApp_Example.ipa \
    --quiet

    echo "Uploading symbols for Tracking Crash"
    appcenter crashes upload-symbols \
    --symbol "$DSYM_FILE" \
    --token "$APP_CENTER_TOKEN_DEVICE" \
    --app "$APP_CENTER_APP_NAME_DEVICE" \
    --quiet
}

shopt -s nocasematch
if [[ "$TYPE" == "$DEPLOY_TYPE_SIMULATOR" ]]; then
  deploy_simulator_build
else
  deploy_device_build
fi
