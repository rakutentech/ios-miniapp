#!/bin/bash -xeu
rm -rf bundle
depdl=0
if [ ! -d "gadsdk" ]
then
    depdl=1
    osascript -e 'display notification "Even if XCode does not show it your build is running, but it needs to wait for Google libs download finish first" with title "Dependencies download" subtitle "Google Mobile Ads libs missing"'
    curl -O https://dl.google.com/googleadmobadssdk/googlemobileadssdkios.zip
    bsdtar -xf googlemobileadssdkios.zip -s'|[^/]*/|gadsdk/|'
    rm googlemobileadssdkios.zip
fi
if [ ! -d "${PROJECT_DIR}/../../Carthage/build" ]
then
    depdl=1
    osascript -e 'display notification "Even if XCode does not show it your build is running, but it needs to wait for Carthage dependencies build first" with title "Dependencies download" subtitle "Carthage libs missing"'
    cd "${PROJECT_DIR}"/../..
    carthage update --platform ios --use-xcframeworks
    #carthage build --no-skip-current --platform ios --use-xcframeworks
fi
if [ $depdl -eq 1 ]; then
    osascript -e 'display notification "Prebuild finished. Logs available at '${PROJECT_DIR}/prebuild.log'" with title "Dependencies download" subtitle "Finished"'
fi
