#!/bin/bash -eu
$(dirname "$0")/extract-version.sh
cd $(dirname "$0")/..
VERSION=`cat $(dirname "$0")/../tmp/version.env`
# set framework folder name
FRAMEWORK_FOLDER_NAME="XCFramework"
# set framework name or read it from project by this variable
FRAMEWORK_NAME="MiniApp"
FINAL_FOLDER="Binary/${FRAMEWORK_FOLDER_NAME}"
#xcframework path
FRAMEWORK_PATH="${FINAL_FOLDER}/${FRAMEWORK_NAME}.xcframework"
# set path for iOS simulator archive
SIMULATOR_ARCHIVE_PATH="${FRAMEWORK_FOLDER_NAME}/simulator.xcarchive"
# set path for iOS device archive
IOS_DEVICE_ARCHIVE_PATH="${FINAL_FOLDER}/iOS.xcarchive"
rm -rf "${FINAL_FOLDER}"
echo "Deleted ${FINAL_FOLDER}"
rm -rf "${FRAMEWORK_FOLDER_NAME}"
echo "Deleted ${FRAMEWORK_FOLDER_NAME}"
mkdir "${FRAMEWORK_FOLDER_NAME}"
echo "Created ${FRAMEWORK_FOLDER_NAME}"
echo "Archiving ${FRAMEWORK_NAME}"
xcodebuild archive -scheme ${FRAMEWORK_NAME} -workspace ${FRAMEWORK_NAME}.xcworkspace -destination="iOS Simulator" -archivePath "${SIMULATOR_ARCHIVE_PATH}" -sdk iphonesimulator SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES
xcodebuild archive -scheme ${FRAMEWORK_NAME} -workspace ${FRAMEWORK_NAME}.xcworkspace -destination="iOS" -archivePath "${IOS_DEVICE_ARCHIVE_PATH}" -sdk iphoneos SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES
#Creating XCFramework
xcodebuild -create-xcframework -framework ${SIMULATOR_ARCHIVE_PATH}/Products/Library/Frameworks/${FRAMEWORK_NAME}.framework -framework ${IOS_DEVICE_ARCHIVE_PATH}/Products/Library/Frameworks/${FRAMEWORK_NAME}.framework -output "${FRAMEWORK_PATH}"
zip -r "${FRAMEWORK_PATH}".zip "${FRAMEWORK_PATH}"
FRAMEWORK_CHECKSUM=$(swift package compute-checksum "${FRAMEWORK_PATH}".zip)
echo "${FRAMEWORK_CHECKSUM}"

sed -i -e "s/.*xcframework.*/            url: \"https:\/\/github.com\/rakutentech\/ios-miniapp\/releases\/download\/v$VERSION\/MiniApp.xcframework.zip\",/" Package.swift
sed -i -e "s/.*checksum.*/            checksum: \"$FRAMEWORK_CHECKSUM\"/" Package.swift

rm -rf "${FRAMEWORK_PATH}"
rm -rf "${SIMULATOR_ARCHIVE_PATH}"
rm -rf "${IOS_DEVICE_ARCHIVE_PATH}"
#git commit -m "SPM checksum" Package.swift
#open "${FINAL_FOLDER}"
