#!/bin/bash -eu
if [ ! -d "gadsdk" ]
then
    curl -O https://dl.google.com/googleadmobadssdk/googlemobileadssdkios.zip
    bsdtar -xf googlemobileadssdkios.zip -s'|[^/]*/|gadsdk/|'
    rm googlemobileadssdkios.zip
fi
