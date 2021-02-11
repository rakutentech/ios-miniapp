#!/usr/bin/env bash
set -ex

# Publish the Simulator App build to App Center.
# You must set the following environment variables:
# APP_CENTER_TOKEN
# APP_CENTER_APP_NAME
# APP_CENTER_GROUP
# APP_CENTER_BUILD_VERSION

echo "Creating ZIP file for Simulator build."
zip -r ./artifacts/miniapp.app.zip ./artifacts/MiniApp_Example.app/*

echo "Instaling App Center CLI."
npm install -g appcenter-cli

echo "Deploying Simulator App build to $APP_CENTER_GROUP group on App Center."
appcenter distribute release \
--token $APP_CENTER_TOKEN \
--app $APP_CENTER_APP_NAME \
--group $APP_CENTER_GROUP \
--build-version $APP_CENTER_BUILD_VERSION \
--file ./artifacts/miniapp.app.zip \
--quiet

appcenter crashes upload-symbols \
--symbol ./artifacts/MiniApp_Example.app.dSYM \
--token $APP_CENTER_TOKEN \
--app $APP_CENTER_DSYM_NAME \
--quiet
