## CHANGELOG

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
