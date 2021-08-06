#!/usr/bin/env bash

# Usage info
show_help()
{
echo "
        Usage: [-v Version] [-b Branch] [-d]

        -v Version      Version to deploy.
        -b Branch       Branch to release. By default 'candidate'
        -d              displays useful data to debug this script
        -a              automatic mode. Requires -v parameter to be 100% without prompt
        -s              same as -a but in silent mode

        For Example: ./release-candidate.sh -v 3.5.0 -b candidate -a

        -h              Help
"
}
NO_PROMPT=0

while getopts ":v:b:dhas" opt; do
  case $opt in
    v) VERSION="$OPTARG"
    ;;
    b) UPSTREAM_BRANCH="$OPTARG"
    ;;
    d) set -ex
    ;;
    h) show_help; exit 0
    ;;
    a) NO_PROMPT=1
    ;;
    s) NO_PROMPT=1; exec &>/dev/null
    ;;
    \?) echo "Invalid option -$OPTARG" >&2; exit 1
    ;;
  esac
done

if [ -z "$UPSTREAM_BRANCH" ]
  then
    UPSTREAM_BRANCH=candidate
fi

if [ -z "$VERSION" ]
  then
    read -r -p "Please input the version number to release (ex: for v3.5.0 please input 3.5.0): " VERSION
fi

UPSTREAM=git@github.com:rakutentech/ios-miniapp.git
CANDIDATE_BRANCH=$VERSION/$UPSTREAM_BRANCH
WORK_BRANCH=$(git branch --show-current)

if [ $NO_PROMPT == 0 ]
then
  while true; do
      echo -e "\nBefore validating check every features and bug fixes are present on upstream master branch"
      read -r -p "Is the next release v$VERSION version number correct? [Y/n]: " yn
      case $yn in
          [Yy]* ) break;;
          [Nn]* ) read -r -p "Please input the version number again (ex: for v3.5.0 please input 3.5.0): " VERSION;;
          * ) break;;
      esac
  done
fi

echo "Stashing your WIP and creating local $UPSTREAM_BRANCH branch from upstream master branch"
git stash
git fetch "$UPSTREAM" master:"$CANDIDATE_BRANCH"
git checkout "$CANDIDATE_BRANCH"

echo "Retrieving current version number..."
CURRENT_VERSION=$(grep -o -m 1 -E "([0-9]{1,}\.)+([0-9]{1,}\.)+[0-9]{1,}" MiniApp.podspec)
SEARCH_STRING=$(grep "miniapp.version   " MiniApp.podspec)
echo -e "\nMiniApp.podspec mentions this at version line: $SEARCH_STRING"

if [ $NO_PROMPT == 0 ]
then
  while true; do
      read -r -p "Is v$CURRENT_VERSION the current version to upgrade. Input n to change it. [Y/n]: " answer
      case $answer in
          [Yy]* ) break;;
          [Nn]* ) read -r -p "Please input the miniapp.version value currently in MiniApp.podspec (ex: for v3.5.0 please input 3.5.0): " CURRENT_VERSION;;
          * ) break;;
      esac
  done
fi

REPLACE_STRING="  miniapp.version      = '$VERSION'"

echo "Updating MiniApp.podspec file miniapp.version variable with v$VERSION version number"
sed -i "" -e "s/$SEARCH_STRING/$REPLACE_STRING/" MiniApp.podspec

echo -e "\nChangelog:"
awk -v version="$VERSION" '/### / {printit = $2 == version}; printit;' CHANGELOG.md

if [ $NO_PROMPT == 0 ]
then
  read -r -p "Is CHANGELOG.md up to date? Input Y after you think it is, or N to abort release[Y/n]: " answer
  case $answer in
    [nN])
      echo "Can't continue execution. Proceed manually"
      exit 1
  esac
fi

echo "build: Update podspec to v$VERSION"
git add MiniApp.podspec
git commit -m "v$VERSION candidate"
git push "$UPSTREAM" "$CANDIDATE_BRANCH":"$UPSTREAM_BRANCH" --force

echo "pop stashing your WIP"
git checkout "$WORK_BRANCH"
git stash pop
echo "Candidate branch pushed to https://github.com/rakutentech/ios-miniapp/tree/$UPSTREAM_BRANCH. Check CI jobs have been started"
