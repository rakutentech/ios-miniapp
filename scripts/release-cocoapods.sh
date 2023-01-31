#!/usr/bin/env bash
set -ex

# Publishes the SDKs podspec to public CocoPods repo

bundle install
echo "Runing pod spec lint."
bundle exec pod spec lint --allow-warnings

echo "Pushing podspec to CocoaPods public repo."
bundle exec pod trunk push --allow-warnings
