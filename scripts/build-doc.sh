#!/usr/bin/env bash
set -ex

bundle install
### Removing admobs subspec before generating doc is necessary. The following script has to be run (from CI) before
echo "" >> MiniApp.podspec # add a new line to the podspec file to remove it after awk treatment
awk '!/Admob[0-9]'\''/' RS=miniapp.subspec ORS=miniapp.subspec MiniApp.podspec > MiniApp.jazzy.podspec # create the jazzy podspec
sed -i '' -e '$ d' MiniApp.jazzy.podspec # clean the last line which contains an awk artifact
echo "end" >> MiniApp.jazzy.podspec
sed -i '' -e '$ d' MiniApp.podspec # remove the last line we added before
bundle exec jazzy