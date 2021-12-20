VERSION=$(grep -o -m 1 -E "([0-9]{1,}\.)+([0-9]{1,}\.)+[0-9]{1,}" CHANGELOG.md)
echo "$VERSION" > version.env
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
echo "Deleted ${FRAMEWORK_FOLDER_NAME}"
mkdir "${FRAMEWORK_FOLDER_NAME}"
echo "Created ${FRAMEWORK_FOLDER_NAME}"
echo "Archiving ${FRAMEWORK_NAME}"
xcodebuild archive -scheme ${FRAMEWORK_NAME} -workspace ${FRAMEWORK_NAME}.xcworkspace -destination="iOS Simulator" -archivePath "${SIMULATOR_ARCHIVE_PATH}" -sdk iphonesimulator SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES
xcodebuild archive -scheme ${FRAMEWORK_NAME} -workspace ${FRAMEWORK_NAME}.xcworkspace -destination="iOS" -archivePath "${IOS_DEVICE_ARCHIVE_PATH}" -sdk iphoneos SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES
#Creating XCFramework
xcodebuild -create-xcframework -framework ${SIMULATOR_ARCHIVE_PATH}/Products/Library/Frameworks/${FRAMEWORK_NAME}.framework -framework ${IOS_DEVICE_ARCHIVE_PATH}/Products/Library/Frameworks/${FRAMEWORK_NAME}.framework -output "${FRAMEWORK_PATH}"
rm -rf "${SIMULATOR_ARCHIVE_PATH}"
rm -rf "${IOS_DEVICE_ARCHIVE_PATH}"
open "${FINAL_FOLDER}"
