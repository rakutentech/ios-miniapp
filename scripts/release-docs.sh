#!/bin/sh
set -ex

# Publishes SDK documentation to Github Pages for a Git tag ($RELEASE_TAG)

# You must set the environent variable $RELEASE_GIT_REMOTE
# It should be inclue a github token in the format:
# https://{GITHUB_TOKEN}@github.com/{ORG}/{REPO}.git

git fetch $RELEASE_GIT_REMOTE gh-pages:gh-pages --force
git checkout -f gh-pages

echo "Copying new docs to gh-pages branch."
git rm -r '*'
git add docs
git mv docs/* ./ -k

echo "Pushing docs for $RELEASE_TAG to gh-pages branch."
git commit -m "Publish documentation for $RELEASE_TAG [ci skip]"
git push $RELEASE_GIT_REMOTE gh-pages
