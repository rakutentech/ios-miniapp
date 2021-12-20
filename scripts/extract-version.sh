#!/bin/bash -eu
cd $(dirname "$0")/..
mkdir -p tmp
VERSION=$(grep -o -m 1 -E "([0-9]{1,}\.)+([0-9]{1,}\.)+[0-9]{1,}" CHANGELOG.md)
echo "$VERSION" | tr -d '[:space:]' > tmp/version.env
echo "Retrieving changelog"
awk -v version="$VERSION" '/### / {printit = $2 == version}; printit;' CHANGELOG.md > tmp/CHANGELOG.md
sed -i.bak 1d tmp/CHANGELOG.md
