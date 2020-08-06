#!/bin/sh -e

#In order to have the // in https://, we need to split it with an empty variable substitution via $()
secureDoubleSlashForXCConfig() {
	ENDPOINT=$1
	URL_DOUBLE_SLASH_TO_BE_REPLACED="\/\/"
	BY_2_SLASHES_SPLITTED_BY_EMPTY_VARIABLE="/\$()/"

	SECURE_DOUBLE_SLASH_FOR_XCCONFIG_RESULT="${ENDPOINT/$URL_DOUBLE_SLASH_TO_BE_REPLACED/$BY_2_SLASHES_SPLITTED_BY_EMPTY_VARIABLE}" 
}

NOCOLOR='\033[0m'
RED='\033[0;31m'
SECRETS_FILE=../MiniApp-Secrets.xcconfig

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

secureDoubleSlashForXCConfig ${RMA_API_ENDPOINT:=https://www.example.com}
RMA_API_ENDPOINT_SECRET=$SECURE_DOUBLE_SLASH_FOR_XCCONFIG_RESULT
RAS_PROJECT_SUBSCRIPTION_KEY_SECRET=${RAS_PROJECT_SUBSCRIPTION_KEY:=RAS_PROJECT_SUBSCRIPTION_KEY}
RAS_APPLICATION_IDENTIFIER_SECRET=${RAS_APPLICATION_IDENTIFIER:=RAS_APPLICATION_IDENTIFIER}

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
echo "// variable substitution via \$() e.g. ROOT_URL = https:/\$()/www.example.com" >> $SECRETS_FILE

# Set secrets from environment variables
echo "RMA_API_ENDPOINT = $RMA_API_ENDPOINT_SECRET" >> $SECRETS_FILE
echo "RAS_PROJECT_SUBSCRIPTION_KEY = $RAS_PROJECT_SUBSCRIPTION_KEY_SECRET" >> $SECRETS_FILE
echo "RAS_APPLICATION_IDENTIFIER = $RAS_APPLICATION_IDENTIFIER_SECRET" >> $SECRETS_FILE
