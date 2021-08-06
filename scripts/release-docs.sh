#!/usr/bin/env bash
set -ex

# Publishes SDK documentation to Github Pages for a Git tag ($RELEASE_TAG)

# You must set the environent variable $RELEASE_GIT_REMOTE
# It should be inclue a github token in the format:
# https://{GITHUB_TOKEN}@github.com/{ORG}/{REPO}.git

### Removing admobs subspec before generating doc is necessary. The following script has to be run (from CI) before
#echo "" >> MiniApp.podspec # add a new line to the podspec file to remove it after awk treatment
#awk '!/Admob'\''/' RS=miniapp.subspec ORS=miniapp.subspec MiniApp.podspec > MiniApp.jazzy.podspec # create the jazzy podspec
#sed -i '' -e '$ d' MiniApp.jazzy.podspec # clean the last line which contains an awk artifact
#sed -i '' -e '$ d' MiniApp.podspec # remove the last line we added before
#bundle exec jazzy

git fetch $RELEASE_GIT_REMOTE gh-pages:gh-pages --force
git checkout -f gh-pages

echo "Copying new docs to gh-pages branch."
git rm -r '*'
git add docs
git mv docs/* ./ -k

echo "Pushing docs for $RELEASE_TAG to gh-pages branch."
git commit -m "Publish documentation for $RELEASE_TAG [ci skip]"
git push $RELEASE_GIT_REMOTE gh-pages
