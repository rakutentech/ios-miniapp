## CHANGELOG

### 2.2.0 (2020-10-02)

**SDK**

- **Feature:** Added public interface to set and get the Custom permissions that are cached by the iOS SDK. [See here](USERGUIDE.md#custom-permissions)
- **Feature:** Added support in Javascript bridge for requesting Custom permission.
`requestCustomPermissions(permissionType)`
- **Feature:** Added `requestCustomPermissions` function to MiniAppMessageProtocol. This function requests the host app to implement and return the list of Custom permissions that User responds with allow/deny option.[See here](USERGUIDE.md#request-custom-permission)
- **Feature:** Added support for Javascript bridge interface for sharing message string from Mini app.
`shareInfo(info)`
- **Feature:** Added `shareContent(info:completionHandler:)` function to MiniAppMessageProtocol. Host app can make use of this function to display the Sharing feature/Controller [See here](USERGUIDE.md#share-mini-app-content)
- **Feature:** Added ability to load external link outside of Mini App view with included SFSafariViewController or by providing delegate, with ability to provide a result URL to Mini App with a closure.  [See here](USERGUIDE.md#navigation)
- **Feature:** Added `listDownloadedWithCustomPermissions()` public interface that enables the host app to retrieve the list of downloaded mini-apps and their respective custom permissions. [See here](USERGUIDE.md#list-downloaded-mini-apps)

**Sample App**

- **Feature:** Added example for showing list of Custom permissions (on request from Mini app) and response back to Mini app.
- **Feature:** Added sample implementation for Sharing the message from Mini app
- **Feature:** Added sample app implementation to revoke/manage the custom permissions for the list of downloaded mini apps


### 2.1.0 (2020-09-03)

**SDK**
- **Feature:** Support telephone (`tel:`) hyperlinks from a mini app. See [here](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/a).

**Sample App:**
- **Feature:** User name, profile photo, and contact list can be configured in the settings screen.
- **Fix:** Location permission callback was not triggered after user accepted/denied the permission.

### 2.0.0 (2020-08-07)

**SDK**
- **Feature:** Added public interface to create a mini app using mini app id `MiniApp#create(appId:completionHandler:messageInterface)`
- **Feature:** Mini App is now downloaded as a ZIP archive and extracted. This should improve the initial launch time on a Mini App with many files.
- **Feature:** Add support for [`navigator.geolocation.getCurrentPosition`](https://developer.mozilla.org/en-US/docs/Web/API/Geolocation/getCurrentPosition) from JavaScript. Note that the other `geolocation` APIs (`gelocation.watchPosition` and `geolocation.clearWatch`) are currently not supported.
- **Feature:** Enable localizable strings to be overriden by the Host App. This currently applies only to dialog button text.
- **Fixed:** Prevent cache poisoning vulnerability by verifying cached Mini App files using a SHA512 hash.
- **Deprecated:** `MiniApp#create(appInfo:completionHandler:messageInterface)`. Your App should instead use `MiniApp#create(appId:completionHandler:messageInterface)`.
- **Removed:** `MiniApp#create(appInfo:completionHandler:)`. Your App should instead use `MiniApp#create(appId:completionHandler:messageInterface)`.
- **Removed:** Runtime config option for the User Agent string. This can now be set only by using the `RMAHostAppUserAgentInfo` setting in your '.plist' file.

**Sample App**
- No changes

### 1.2.0 (2020-07-21)

**SDK**
- *Feature:* Possibility to use back and forward navigation inside MiniApp with SDK default UI or custom client provided UI - [See here](USERGUIDE.md#navigation)
- *Feature:* Ability to add a host app information string (RMAHostAppUserAgentInfo) that will get appended in the User agent. - [See here](USERGUIDE.md#configuration)
- *Feature:* Added support for `window.alert`, `window.confirm` and `window.prompt` JS dialogs in the mini app display
- *Bugfix:* Fixed support for display of SVG file format in a mini app

**Sample App**
- *Feature:* Added example of custom view to navigate backward inside MiniApp - [See here](USERGUIDE.md#navigation)
- Added build information in App's setting screen
- *Bugfix:* First time settings success dialog dismissed before tapping OK
- *Bugfix:* "Display MiniApp" button was not visible when scrolling in the Mini Apps list

### 1.1.1 (2020-06-11)

**SDK**
- no changes

**Sample App**
- *Bugfix:* First time settings success dialog dismissed before tapping OK
- *Bugfix:* "Display MiniApp" button was not visible when scrolling in the list Mini Apps

### 1.1.0 (2020-06-01)

- Added JavaScript bridge for passing data between Mini App and Host App. Your App now must implement `MiniAppMessageProtocol` in your view controller and provide the implementation when calling `MiniApp#create`. - [See here](USERGUIDE.md#MiniAppMessageProtocol)
- Deprecated `MiniApp#create(appInfo:completionHandler:)`. Your App should instead use `MiniApp#create(appInfo:completionHandler:messageInterface)`.
- Added `getUniqueId` function to `MiniAppMessageProtocol`. This function should provide a unique identifier (unique to the user and device) to Mini Apps.

### 1.0.0 (2020-04-27)

- Initial release
