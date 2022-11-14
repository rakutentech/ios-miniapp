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
