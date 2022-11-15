#!/usr/bin/env bash
set -ex

# Publish the Simulator and Device App builds to App Center.
# You must set the following environment variables:
# APP_CENTER_TOKEN
# APP_CENTER_APP_NAME
# APP_CENTER_GROUP
# APP_CENTER_BUILD_VERSION
# APPLE_ENTERPRISE_P12
# APPLE_ENTERPRISE_PROVISION

WORK_DIR=$(pwd)
TMP_DIR=$WORK_DIR/tmp

mkdir -p "$TMP_DIR"

echo "Retrieving changelog"
$(dirname "$0")/extract-version.sh

echo "Installing App Center CLI."
npm install -g appcenter-cli

##############################
# Simulator Build           #
############################

echo "Creating ZIP file for Simulator build."
zip -r ./artifacts/miniapp.app.zip ./artifacts/MiniApp_Example.app/*


echo "Deploying Simulator App build to $APP_CENTER_GROUP group on App Center."
appcenter distribute release \
--token "$APP_CENTER_TOKEN" \
--app "$APP_CENTER_APP_NAME" \
--release-notes-file "$TMP_DIR"/CHANGELOG.md \
--group "$APP_CENTER_GROUP" \
--build-version "$CIRCLE_BUILD_NUM" \
--file ./artifacts/miniapp.app.zip \
--quiet

echo "Uploading Symbols to $APP_CENTER_GROUP group on App Center."
appcenter crashes upload-symbols \
--symbol ./artifacts/MiniApp_Example.app.dSYM \
--token "$APP_CENTER_TOKEN" \
--app "$APP_CENTER_DSYM_NAME" \
--quiet

##############################
# Device Build              #
############################

KEYCHAIN=miniapp-signing.keychain-db
PROVISION=miniapp.mobileprovision
P12=miniapp.p12
PROFILES_DIR=~/Library/MobileDevice/Provisioning\ Profiles
DSYM_FILE=$TMP_DIR/dsym.zip
EXPORT_PLIST=$TMP_DIR/miniapp.plist

echo "Installing the Apple certificate and provisioning profile stored as base64 env vars"
### Here is an example on how to generate the base64 from a P12 or a provisionning profile:
### openssl base64 -in MiniAppDemo.mobileprovision -out MiniAppDemoBase64.txt
echo -n "$APPLE_ENTERPRISE_P12" | base64 --decode --output "$P12"
echo -n "$APPLE_ENTERPRISE_PROVISION" | base64 --decode --output "$PROVISION"

echo "Initializing the custom keychain used to sign the IPA"
security create-keychain -p "$P12_PASSWORD" $KEYCHAIN
security default-keychain -d user -s $KEYCHAIN
security set-keychain-settings -t 120 $KEYCHAIN
security unlock-keychain -p "$P12_PASSWORD" $KEYCHAIN
security import "$P12" -P "$P12_PASSWORD" -A -t cert -f pkcs12 -k $KEYCHAIN
security set-key-partition-list -S apple-tool:,apple: -k "$P12_PASSWORD" $KEYCHAIN
security list-keychain -d user -s $KEYCHAIN

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
OTHER_CODE_SIGN_FLAGS="--keychain $KEYCHAIN" \
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

echo "Cleaning $KEYCHAIN keychain"
security delete-keychain $KEYCHAIN
rm "$PROFILES_DIR"/"$PROVISION"

echo "Retrieving dsym files"
cd MiniApp-Example.xcarchive/dSYMs
zip -rX "$DSYM_FILE" -- *
cd "$WORK_DIR"

echo "Deploying Device App build to $APP_CENTER_GROUP group on App Center."
appcenter distribute release \
--token "$APP_CENTER_TOKEN_DEVICE" \
--app "$APP_CENTER_APP_NAME_DEVICE" \
--group "$APP_CENTER_GROUP" \
--build-version "$CIRCLE_BUILD_NUM" \
--release-notes-file "$TMP_DIR"/CHANGELOG.md \
--file "$TMP_DIR"/MiniApp_Example.ipa \
--quiet

echo "Uploading Crash Symbols to $APP_CENTER_GROUP group on App Center."
appcenter crashes upload-symbols \
--symbol "$DSYM_FILE" \
--token "$APP_CENTER_TOKEN_DEVICE" \
--app "$APP_CENTER_DSYM_NAME" \
--quiet
