#!/bin/sh -e

NOCOLOR='\033[0m'
RED='\033[0;31m'
SECRETS_FILE=Example/Example-Secrets.xcconfig

echo "Configuring project's build secrets in $SECRETS_FILE..."

#
# New secrets should be added below (following the same format)
#
declare -a vars=(RMA_API_ENDPOINT RAS_PROJECT_SUBSCRIPTION_KEY RAS_APPLICATION_IDENTIFIER)
for var_name in "${vars[@]}"
do
  if [ -z "$(eval "echo \$$var_name")" ]; then
    echo "${RED}ERROR:${NOCOLOR} Before building the project you must set environment variable $var_name. See project README for instructions."
  fi
done

CONFIG_URL=${RMA_API_ENDPOINT}
SUBSCRIPTION_KEY=${RAS_PROJECT_SUBSCRIPTION_KEY}
APP_ID=${RAS_APPLICATION_IDENTIFIER}

# Overwrite secrets xcconfig and add file header
echo "// Secrets configuration for the app." > $SECRETS_FILE
echo "//" >> $SECRETS_FILE
echo "// **DO NOT** add this file to git." >> $SECRETS_FILE
echo "//" >> $SECRETS_FILE
echo "// Auto-generated file. Any modifications will be lost on next 'pod install'" >> $SECRETS_FILE
echo "//" >> $SECRETS_FILE
echo "// Add new secrets configuration in ./configure-secrets.sh" >> $SECRETS_FILE
echo "//" >> $SECRETS_FILE
echo "// In order to have the // in https://, we need to split it with an empty" >> $SECRETS_FILE
echo "// variable substitution via $() e.g. ROOT_URL = https:/$()/www.endpoint.com" >> $SECRETS_FILE

# Set secrets from environment variables
echo "RMA_API_ENDPOINT = $CONFIG_URL" >> $SECRETS_FILE
echo "RAS_PROJECT_SUBSCRIPTION_KEY = $SUBSCRIPTION_KEY" >> $SECRETS_FILE
echo "RAS_APPLICATION_IDENTIFIER = $APP_ID" >> $SECRETS_FILE