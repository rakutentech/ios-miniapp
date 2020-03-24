#!/usr/bin/env bash
PACKAGE_VERSION=$(node -p "require('./package.json').version")
echo "version: $PACKAGE_VERSION"

DIR_DOCS="publishableDocs/docs/$PACKAGE_VERSION"
DIR_VERSIONS="publishableDocs/_versions/$PACKAGE_VERSION"
echo "doc_base: $DIR_DOCS"
echo "version_base: $DIR_VERSIONS"

FILE_VERSION_MD="$DIR_VERSIONS/${PACKAGE_VERSION}.md"
mkdir -p "${FILE_VERSION_MD%/*}" && touch "$FILE_VERSION_MD"
contents="---
version: "$PACKAGE_VERSION"
---"
cat <<< "$contents" > "$FILE_VERSION_MD"

npx typedoc --includeVersion --out $DIR_DOCS src --plugin typedoc-plugin-markdown
