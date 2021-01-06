#!/usr/bin/env bash
set -ex

# Pushes a release tag ($RELEASE_TAG) to the "prod" branch in order to trigger a prod build on App Center

# You must set the environent variable $RELEASE_GIT_REMOTE
# It should be inclue a github token in the format:
# https://{GITHUB_TOKEN}@github.com/{ORG}/{REPO}.git

git fetch $RELEASE_GIT_REMOTE $RELEASE_TAG:prod --force
git push $RELEASE_GIT_REMOTE prod --force
