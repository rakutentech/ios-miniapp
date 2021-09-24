#!/bin/sh -e
GREY='\033[0;90m'
YELLOW='\033[0;93m'
BOLD='\033[1m'
RED='\033[0;31m'
NOCOLOR='\033[0m'

RMA_API_HOST=$(echo $RMA_API_ENDPOINT | cut -d'/' -f3 | cut -d':' -f2)
RMA_API_PORT=$(echo $RMA_API_ENDPOINT | cut -d'/' -f3 | cut -d':' -f3)

if [ "$RMA_API_HOST" = "$RMA_API_PORT" ]
  then
    PROTOCOL=$(echo "$RMA_API_ENDPOINT" | cut -d':' -f1)
    if [ "$(echo "$PROTOCOL" | tr "[:lower:]" "[:upper:]")" = "HTTPS" ]
    then
      RMA_API_PORT=443
    else
      RMA_API_PORT=80
    fi
fi

if [ -z "$RMA_API_HOST" ]
  then
    echo "${NOCOLOR}➜ ${RED}Can't generate SSL pin! please define ${YELLOW}RMA_API_ENDPOINT${RED} environment variable${NOCOLOR}"
    echo "" > SSL-pinning.xcconfig
else
  echo "➜ ${BOLD}Generating SSL pin for ${YELLOW}$RMA_API_HOST${GREY}"
  HASHKEY=$(openssl s_client -servername $RMA_API_HOST -connect $RMA_API_HOST:$RMA_API_PORT < /dev/null | openssl x509 -pubkey -noout | openssl rsa -pubin -outform der | openssl dgst -sha256 -binary | openssl enc -base64 | tail -1)
  echo "➜ ${BOLD}SSL pin generated: ${YELLOW}$HASHKEY${NOCOLOR}"
  echo "RMA_SSL_KEY_HASH = $HASHKEY" > SSL-pinning.xcconfig
  echo "RMA_SSL_KEY_HASH_BACKUP = $RMA_SSL_KEY_HASH_BACKUP" >> SSL-pinning.xcconfig
fi