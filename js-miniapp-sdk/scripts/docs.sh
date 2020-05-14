#!/usr/bin/env bash

# Get SDK version as X.X (remove fix version)
PACKAGE_VERSION=$(node -p "require('./package.json').version" | sed -e 's/\.[0-9]*$//')
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

# Generate docs
npx typedoc --includeVersion --out $DIR_DOCS/api src --plugin typedoc-plugin-markdown --stripInternal --readme none --mode file

# Move userguide to docs and create correct folder structure
mv $DIR_DOCS/api/README.md $DIR_DOCS/api/index.md
cp README.md $DIR_DOCS/index.md
# The typedoc plugin generates breadcrumbs which point to `README.md` as the parent page
# So we must create this page and add a redirect to `index`
cp ./scripts/readme-redirect.md $DIR_DOCS/api/README.md
