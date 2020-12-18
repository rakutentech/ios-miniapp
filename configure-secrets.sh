#!/bin/sh -e

NOCOLOR='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
BOLD='\033[1m'
NOBOLD='\033[21m'

usage () {
cat <<HELP_USAGE
usage: $0 param1 param[n]...
   Parameters:
   - param1: The SDK name which needs to have a -Secrets.xcconfig file
   - param[n]: a list of secrets environment variables to put in secret config file
  Example usage:
    $0 MiniApp RMA_API_ENDPOINT RAS_PROJECT_SUBSCRIPTION_KEY RAS_PROJECT_IDENTIFIER
HELP_USAGE
}

if [ $# == 0 ]; then
    usage
    exit 1
fi

#In order to have the // in https://, we need to split it with an empty variable substitution via $()
secureDoubleSlashForXCConfig() {
    ENDPOINT=$1
    URL_DOUBLE_SLASH_TO_BE_REPLACED="\/\/"
    BY_2_SLASHES_SPLITTED_BY_EMPTY_VARIABLE="/\$()/"

    SECURE_DOUBLE_SLASH_FOR_XCCONFIG_RESULT="${ENDPOINT/$URL_DOUBLE_SLASH_TO_BE_REPLACED/$BY_2_SLASHES_SPLITTED_BY_EMPTY_VARIABLE}"
}

vars=("${@:2}")
SECRETS_FILE=../${1}-Secrets.xcconfig

echo "${GREEN}Configuring project's build secrets in ${BOLD}$SECRETS_FILE${GREEN}...${NOCOLOR}"

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

longest_name=-1
for var_name in ${vars[@]}
do
    current=${#var_name}
   if [ $current -gt $longest_name ]
   then
      longest_name=$current
   fi
done

success=true
for var_name in ${vars[@]}
do
  nbstars=$(($longest_name - ${#var_name} + 5))
  stars=$(printf '%*s' $nbstars '')
  value=$(eval "echo \$$var_name")
  if [ -z "$value" ]; then
    >&2 echo "➜ ${BOLD}$var_name${NOCOLOR} ${stars// /*} ${RED}ERROR!${NOCOLOR} Missing environment variable ${BOLD}$var_name${NOCOLOR}."
    success=false
  else
      echo "➜ ${BOLD}$var_name${NOCOLOR} ${stars// /*} ${GREEN}OK${NOCOLOR}"
  fi
  secureDoubleSlashForXCConfig $value
  # Set secrets from environment variables
  cmd='echo "${var_name} = $SECURE_DOUBLE_SLASH_FOR_XCCONFIG_RESULT"'
  eval ${cmd} >> $SECRETS_FILE
done

if [ $success = false ] ; then
    echo "Before building the project you must set missing environment variables. See project README for instructions."
fi
