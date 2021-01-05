## CHANGELOG

### 1.6.1 (2021-01-06)
- **Fix:** Location permission support for iOS/Android Mini App SDK 2.6 and below.
- **Fix:** Reject promise from `MiniApp.requestLocationPermission` when the user denies location custom permission.

### 1.6.0 (2020-12-18)
- **Feature:** Added `CustomPermissionName.LOCATION`.
- **Change:** Updated `requestLocationPermission()` to `requestLocationPermission(permissionDescription?: string)`. From now `requestLocationPermission` will request both custom and device permission respectively. [See here](README.md#Request-Permissions).
- **Feature:** Added support for requesting Contact list from Host app. [See here](README.md#Requesting-User-details).

### 1.5.0 (2020-11-13)

- **Feature:** Added `MiniApp.getAccessToken` for retrieving an access token. [See here](README.md#Get-access-token).

### 1.4.0 (2020-11-02)

- **Feature:** Set and lock device screen orientation. [See here](README.md#Set-screen-orientation).

### 1.3.0 (2020-10-22)

- **Feature:** Added support for requesting the load and display of Interstitial & Rewarded Ads in Host app. [See here](README.md#4-Show-Ads).
- **Feature:** Added support for requesting User Name and Profile Photo from Host app. [See here](README.md#Requesting-User-details).
- **Feature:** Added `MiniApp.getPlatform` for retrieving the platform name of the device. [See here](README.md#check-androidios-device).

### v1.2.0 (2020-10-02)

- **Feature:** Added `MiniApp.requestCustomPermissions` for requesting `USER_NAME`, `PROFILE_PHOTO`, and `CONTACT_LIST` permissions. [See here](README.md#Request-Permissions)
- **Feature:** Added `MiniApp.shareInfo` for sharing content with other Apps. [See here](README.md#Share-Info).

### v1.1.0 (2020-7-21)

- Added support for requesting geolocation permission from the host application to allow fetching of the coordinates data thereafter. [See here](README.md#Request-Permissions).

### v1.0.0 (2020-5-13)

- Initial release.
