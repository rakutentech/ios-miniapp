## CHANGELOG

### 4.0.0  (release date TBD)

**SDK**
- **Feature:** Added support for Carthage
- **Feature:** Changed deployment target from 13.0 to 14.0


**Sample app**
- **Bugfix:** Added error message when name and email are invalid when adding contacts
- **Enhancement:** Add an alert when successful shared content (file downloads)

---
### 3.9.1 (2022-01-17)
- **Fix:** Added weak references fix for clearing the RealMiniAppView object from memory.

---
### 3.9.0 (2021-12-17)

**SDK**
- **Feature:** Added support for Manifest localization by updating `getMiniAppManifest(miniAppId:miniAppVersion:languageCode:)` interface
- **Feature:** Added support for taking picture from camera in Mini App.
- **Feature:** Added `promotionalImageUrl` and `promotionalText` in MiniAppInfo model.
- **Update:** Updated `getHostEnvironmentInfo(completionHandler:)` interface to return `MAHostEnvironmentInfo` details with default locale to miniapp

**Sample app**

- **Feature:** Added production and staging toggle to change environments.
- **Feature:** Added promotional preview by enabling `enableSharePreview` when launching the MiniApp with MiniAppUI.

---
### 3.8.1 (2022-01-17)

**SDK**

- **Fix:** Added weak references fix for clearing the RealMiniAppView object from memory.

---
### 3.8.0 (2021-11-09)

**SDK**

- **Feature:** MiniApp custom events (pause, resume, external webview closed)
- **Feature:** Added `rakuten.miniapp.device.FILE_DOWNLOAD` custom permission

**Sample app**

- **Feature:** Added Dynamic deeplink support in the sample app.
- **Feature:** Sample app changes to show support for download files via Mini app.

---
### 3.7.0 (2021-10-08)

**SDK**

- **Feature:** Store Manifest as a json file
- **Feature:** A secure check is performed on manifest permissions before launching the Mini App
- **Feature:** A new subspec `MiniApp/Signature` is now available. If the dependency is added to the host, the MiniApp zip file signature is now checked to prevent file corruption or man in the middle attack
- **Feature:** A `RMAForceSignatureCheck` boolean setting can be set in '.plist' file. It is considered false by default and is only used by `MiniApp/Signature`
- **Feature:** Added support for App Store URL schemes
- **Feature:** Added new public interface `getMiniAppPreviewInfo` to get Mini app info using preview token
- **Feature:** Added SSL pinning check for API calls
- **Feature:** Added `getHostEnvironmentInfo(completionHandler:)` interface to return `MAHostEnvironmentInfo` details to miniapp

**Sample app**

- **Feature:** First time permissions screen now displays requested scopes
- **Feature:** ATS deactivated to match production needs
- **Feature:** Added support for previewing mini app using QR Code

---
### 3.5.0 (2021-08-05)

**SDK**

- **Feature:** Mini App SDK now supports an optional banner text in message to send to contacts received from MiniApp
- **Feature:** Added Points Interface `getPoints` to retrieve Rakuten Points
- **Feature:** Added `rakuten.miniapp.user.POINTS` custom permission
- **Feature:** Added support for Admob v8.+ in submodule `MiniApp/Admob8`

**Sample app**

- **Feature:** Display of a banner on message contact picker when required
- **Feature:** Added Points to the settings screen to change `getPoints` response values 

---
### 3.4.0 (2021-06-25)

**SDK**

- **Feature:** Mini App SDK now supports code updates in preview mode
- **Feature:** Added possibility to send analytics to multiple accounts at the same time
- **Feature:** Updated `MiniAppSdkConfig` class to add additional parameter `MAAnalyticsConfig` which will be used by Host app to send analytics for multiple accounts.
- **Updated:** Updated `getAccessToken` result with new Error type i.e `MASDKAccessTokenError` to support more errors
- **Fixed:** Added support for form submission redirections

**Sample App**

- **Feature:** Added QA tests settings screen containing options to test all `getAccessToken` error types

---
### 3.3.0 (2021-05-27)

**SDK**

- **Feature:** Added `rakuten.miniapp.user.action.SEND_MESSAGE` custom permission
- **Feature:** Support Email addresses (`mailto:`) hyperlinks from a mini app. See [here](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/a).
- **Deprecated:** `getUniqueId()` in `MiniAppMessageDelegate` protocol is deprecated. You should use `getUniqueId(completionHandler:)` instead
- **Deprecated:** `getContacts()` in `MiniAppUserInfoDelegate` protocol is deprecated. You should use `getContacts(completionHandler:)` instead
- **Deprecated:** `localize(bundle:_:params:)` in `MASDKLocale` class is deprecated. You should use `localize(bundle:_:)` instead
- **Fixed:** Long messages were truncated in sample app

**Sample App**
- **Feature:** Custom contact name and email can be added now from the settings

---
### 3.2.0 (2021-04-22)

**SDK**

- **Feature:** Added chat messages capabilities
- **Feature:** Standardized texts localization

**Sample App**

- **Feature:** Added chat messages screens with contact picker
- **Fixed:** First launch screen metadata text was hidden

---
### 3.1.0 (2021-04-02)

**SDK**

- **Feature:** Added `rakuten.miniapp.user.ACCESS_TOKEN` custom permission
- **Feature:** Added `rakuten.miniapp.user.ACCESS_TOKEN` audiences and scopes

---
### 3.0.0 (2021-03-19)

**SDK**

- **Core:** Incremented minimum support version for iOS from 11.0 to 13.0 
- **Removed:** Removed all deprecated and variables methods from v2:
  - `MiniApp` :
    - `list(completionHandler:)` now takes a `(Result<[MiniAppInfo], MASDKError>) -> Void` in place of a `(Result<[MiniAppInfo], Error>) -> Void`
    - `info(miniAppId:completionHandler:)` now takes a `(Result<MiniAppInfo, MASDKError>) -> Void` in place of a `(Result<MiniAppInfo, Error>) -> Void`
    - `create(appId:completionHandler:)` now takes a `(Result<MiniAppDisplayProtocol, MASDKError>) -> Void` in place of a `(Result<MiniAppDisplayProtocol, Error>) -> Void`
  - `MiniAppSdkConfig`:
    - `testMode` has been removed. Use `previewMode` instead
    - `appId` has been removed. Use `projectId`
  - `MiniAppPermissionType` has been renamed `MiniAppDevicePermissionType`
  - `MiniAppDisplayProtocol` has been renamed `MiniAppDisplayDelegate`
  - `MiniAppMessageDelegate`:
    - `MiniAppMessageProtocol` has ben renamed `MiniAppMessageDelegate`
    - `requestPermission(permissionType:completionHandler:)` has been removed. Use `requestDevicePermission(permissionType:completionHandler:)`
    - `requestCustomPermissions(permissions:completionHandler:)` has been removed. Use `requestCustomPermissions(permissions:miniAppTitle:completionHandler:)`
  - `MiniAppUserInfoDelegate`:
    - `getUserName()` has been removed. Use `getUserName(completionHandler:)`
    - `getProfilePhoto()` has been removed. Use `getProfilePhoto(completionHandler:)`
- **Feature:** Made MiniApp SDK a static framework
- **Feature:** Added ads for Mini Apps host
- **Feature:** Added Google mobile ads integration in a `MiniApps/Admob` pod subspec
- **Feature:** Added new interface `getMiniAppManifest(miniAppId:miniAppVersion:)` to retrieve the meta-data of a MiniApp
- **Feature:** Added new interface `getDownloadedManifest(miniAppId:)` to retrieve the cached meta-data of a MiniApp
- **Removed:** RSDKUtils dependency removed

**Sample App**

- **Feature:** Added implementation to retrieve meta-data and show first-time launch screen to user before downloading any mini-app

---
### 2.8.0 (2021-02-01)

**SDK**

- **Feature** Added analytics for Mini App usage tracking
- **Feature** Updated `getUserName` and `getProfilePhoto` interfaces to be asynchronous. Old methods are deprecated
- **Feature** Updated `MiniApp().shared.create` interface to accept another optional query string parameter.
- **Deprecated:** `requestPermission(permissionType:completionHandler:)` in `MiniAppMessageDelegate` protocol is deprecated. You should use `requestDevicePermission(permissionType:completionHandler:)` instead
- **Fixed** Geolocation was not updated after the first GPS fix

**Sample App**

- **Change** Updated sample app to use the latest asynchronous `getUserName` and `getProfilePhoto` interfaces
- **Feature:** Added a new section in Settings page to add the optional query parameter.

---

### 2.7.0 (2020-12-18)

**SDK**

- **Feature:** Added support for requesting a contact list from a MiniApp
- **Feature:** Added support to load a MiniApp from an URL
- **Feature:** Added location permission to custom permissions management
- **Fixed:** A specific exception is now raised when an app has no published version 
- **Fixed:** Location permissions glitch

**Sample App**

- **Fixed:** Permissions toggles did not fit the screen
- **Fixed:** Location permissions glitch

---

### 2.6.0 (2020-11-27)

**SDK**

- **Feature:** Added support for `RASProjectId`. `RASApplicationIdentifier` is deprecated now
- **Feature:** Added support for Preview endpoint. Preview endpoint becomes the new default endpoint

**Sample App**

- **Feature:** Added implementation for Preview mode
- **Fixed:** iOS 11 search field visual glitches
- **Fixed:** Support for dark UI
- **Fixed:** Default settings were displayed instead of the saved one 

---

### 2.5.0 (2020-11-13)

**Note:** The 2.4.0 version was skipped to keep version alignment with the Android SDK.

**SDK**

- **Feature:** Added support for Orientation lock, that enables the mini app to lock `portrait` or `landscape` orientation for the mini-app. [Please check here](USERGUIDE.md#orientation-lock)
- **Feature:** Added support to retrieve Access token and expiry date
- **Feature:** Added default implementation in SDK for `requestCustomPermissions(permissions:miniAppTitle:completionHandler:)` [Please check here](USERGUIDE.md#request-custom-permission)
- **Deprecated:** `requestCustomPermissions(permissions:completionHandler:)` in `MiniAppCallbackProtocol` protocol is deprecated. You should use `requestCustomPermissions(permissions:miniAppTitle:completionHandler:)` instead

**Sample App**

- **Feature:** Added implementation for orientation lock
- **Feature:** Added implementation to retrieve Access token details

---

### 2.3.0 (2020-10-22)

**SDK**

- **Feature:** Added separate public `MiniAppUserInfoDelegate` to communicate with the host app to [getUserName](USERGUIDE.md#cuser-profile-details-username) and [getProfilePhoto](USERGUIDE.md#cuser-profile-details-profilephoto). Interfaces will be called only if user has agreed to the respective custom permission. i.e `rakuten.miniapp.user.USER_NAME` for [getUserName](USERGUIDE.md#cuser-profile-details-username) and `rakuten.miniapp.user.PROFILE_PHOTO` for [getProfilePhoto](USERGUIDE.md#cuser-profile-details-profilephoto).
- **Feature:** Added support for Javascript bridge interface for User Info detail retrieval from Mini app. `getUserName()` and `getProfilePhoto()`.
- **Feature:** Added a default sharing controller in the SDK for `MiniAppMessageDelegate.shareContent`. This means you are no longer required to implement this method and can instead choose to use the default functionality provided by the SDK if you wish.
- **Feature:** Added support of `playsinline` and `autoplay` instruction of `video` html tag.
- **Fixed:** Links in the external webview that targeted `_blank` were not functioning. This has been updated so that these links will open in the same webview.
- **Fixed:** `tel:` links were not working in the external webview.
- **Deprecated:** `MiniAppCallbackProtocol` has been deprecated and replaced with `MiniAppCallbackDelegate`. `MiniAppCallbackProtocol` will continue to function as a `typealias` for `MiniAppCallbackDelegate`, however it will be removed in the next major version.

**Sample App**

- **Feature:** Added sample implementation for Retrieving Username & Profile photo from Mini app
- **Feature:** Added search field for mini app list.

---

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

---

### 2.1.0 (2020-09-03)

**SDK**
- **Feature:** Support telephone (`tel:`) hyperlinks from a mini app. See [here](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/a).

**Sample App:**
- **Feature:** User name, profile photo, and contact list can be configured in the settings screen.
- **Fix:** Location permission callback was not triggered after user accepted/denied the permission.

---

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

---

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

---

### 1.1.1 (2020-06-11)

**SDK**
- no changes

**Sample App**
- *Bugfix:* First time settings success dialog dismissed before tapping OK
- *Bugfix:* "Display MiniApp" button was not visible when scrolling in the list Mini Apps

---

### 1.1.0 (2020-06-01)

- Added JavaScript bridge for passing data between Mini App and Host App. Your App now must implement `MiniAppMessageProtocol` in your view controller and provide the implementation when calling `MiniApp#create`. - [See here](USERGUIDE.md#MiniAppMessageProtocol)
- Deprecated `MiniApp#create(appInfo:completionHandler:)`. Your App should instead use `MiniApp#create(appInfo:completionHandler:messageInterface)`.
- Added `getUniqueId` function to `MiniAppMessageProtocol`. This function should provide a unique identifier (unique to the user and device) to Mini Apps.

---

### 1.0.0 (2020-04-27)

- Initial release
