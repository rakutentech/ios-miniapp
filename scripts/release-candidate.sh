#!/usr/bin/env bash
#set -ex

echo "Setting upstream to rakutentech/ios-miniapp"
git remote add upstream_release git@github.com:rakutentech/ios-miniapp.git
git fetch upstream_release

while true; do
    read -r -p "When you have checked every features and bug fixes are present on upstream master branch, please input the version number to release (ex: for v3.5.0 please input 3.5.0): " VERSION
    read -r -p "Is the next release v$VERSION correct? [Y/n] " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) echo "Please input the version number again.";;
        * ) break;;
    esac
done

CANDIDATE_BRANCH=$VERSION/candidate

echo "Stashing your WIP and creating local candidate branch from upstream master branch"
git stash
git checkout -b "$CANDIDATE_BRANCH" upstream_release/master

echo "Retrieving current version number..."
CURRENT_VERSION=$(grep -o -m 1 -E "([0-9]{1,}\.)+([0-9]{1,}\.)+[0-9]{1,}" MiniApp.podspec)
read -r -p "Is v$CURRENT_VERSION the current version to upgrade? [Y/n] " answer

if [ "$answer" != "" ] && [ "$answer" == "${answer#[Nn]}" ] ;then
    echo "Can't continue execution. Proceed manually"
    exit 1
fi



SEARCH_STRING="s.version      = '$CURRENT_VERSION'"
REPLACE_STRING="s.version      = '$VERSION'"

echo "Updating MiniApp.podspec file s.version variable with v$VERSION version number"
sed -i "" -e "s/$SEARCH_STRING/$REPLACE_STRING/" MiniApp.podspec

echo "Changelog:"
awk -v version="$VERSION" '/### / {printit = $2 == version}; printit;' "$1" CHANGELOG.md

read -r -p "Is CHANGELOG.md up to date? Input Y after you think it is, or N to abort release[Y/n]: " answer

if [ "$answer" != "" ] && [ "$answer" == "${answer#[Nn]}" ] ;then
    echo "Can't continue execution. Proceed manually"
    exit 1
fi

echo "Committing candidate version number changes"
git commit -a -m "v$VERSION candidate"
git push upstream_release "$CANDIDATE_BRANCH":candidate --force
git checkout master
git branch -D "$CANDIDATE_BRANCH"
git remote remove upstream_release

echo "Candidate branch created. Check CI jobs have been started"
