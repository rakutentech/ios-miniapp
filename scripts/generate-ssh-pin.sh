#!/bin/sh -e
GREY='\033[0;90m'
YELLOW='\033[0;93m'
BOLD='\033[1m'
RED='\033[0;31m'
NOCOLOR='\033[0m'

if [ -z "$RMA_API_HOST" ]
  then
    echo "${NOCOLOR}➜ ${RED}Can't generate SSL pin! please define ${YELLOW}RMA_API_HOST${RED} environment variable${NOCOLOR}"
else
  echo "➜ ${BOLD}Generating SSL pin for ${YELLOW}$RMA_API_HOST${GREY}"
  HASHKEY=$(openssl s_client -servername $RMA_API_HOST -connect $RMA_API_HOST:443 < /dev/null | openssl x509 -pubkey -noout | openssl rsa -pubin -outform der | openssl dgst -sha256 -binary | openssl enc -base64 | tail -1)
  echo "➜ ${BOLD}SSL pin generated: ${YELLOW}$HASHKEY${NOCOLOR}"
  echo "RMA_SSL_KEY_HASH = $HASHKEY" > SSL-pinning.xcconfig
fi