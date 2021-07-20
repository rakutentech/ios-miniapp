#!/usr/bin/env bash

# Get SDK version as X.X (remove fix version)
PACKAGE_VERSION=$(node -p "require('./package.json').version" | sed -e 's/\.[0-9]*$//')
DATE=$(date +%Y-%m-%d)

DIR_DOCS="publishableDocs/docs/$PACKAGE_VERSION"
DIR_VERSIONS="publishableDocs/_versions/$PACKAGE_VERSION"
echo "doc_base: $DIR_DOCS"
echo "version_base: $DIR_VERSIONS"

FILE_VERSION_MD="$DIR_VERSIONS/${PACKAGE_VERSION}.md"
mkdir -p "${FILE_VERSION_MD%/*}" && touch "$FILE_VERSION_MD"
contents="---
version: \"$PACKAGE_VERSION\"
date: $DATE
---"
cat <<< "$contents" > "$FILE_VERSION_MD"

echo "Created version file: $FILE_VERSION_MD
$contents
"

# Generate docs
npx typedoc --out $DIR_DOCS/api src --options typedoc.json

# Move userguide to docs and create correct folder structure
mv $DIR_DOCS/api/README.md $DIR_DOCS/api/index.md
cp README.md $DIR_DOCS/index.md
# The typedoc plugin generates breadcrumbs which point to `README.md` as the parent page
# So we must create this page and add a redirect to `index`
cp ./scripts/readme-redirect.md $DIR_DOCS/api/README.md
