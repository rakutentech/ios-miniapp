# MiniApp

This open-source library allows you to integrate Mini App ecosystem into your iOS applications.
Mini App SDK also facilitates communication between a mini app and the host app via a message bridge.

## Features

- Load MiniApp list
- Load MiniApp metadata
- Create a MiniApp view
- Facilitate communication between host app and mini app

And much more features which you can find them in [Usage](#usage).

All the MiniApp files downloaded by the MiniApp iOS library are cached locally

## Requirements

This module supports **iOS 11.0 and above**. It has been tested on iOS 11.0 and above.

It is written in Swift 5.0 and can be used in compatible Xcode versions.

## Getting started

* [Installation](#installation)
* [Configuration](#configuration)
* [Usage](#usage)
* [Documentation](https://rakutentech.github.io/ios-miniapp/)

### Installation

Mini App SDK is available through [CocoaPods](https://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'MiniApp'
```

### Configuration

In your project configuration .plist you should add below Key/Value :

| Key                          | Type    | Description                                                     | Optional| Default |
| :----                        | :----:  | :----                                                           |:----:   |:----:   |
| RASProjectId     | String  | `Set your MiniApp host application project identifier`                  |NO       |`none`   |
| RASProjectSubscriptionKey    | String  | `Set your MiniApp subscription key`                             |NO       |`none`   |
| RMAAPIEndpoint               | String  | `Provide your own Base URL for API requests`                    |NO       |`none`   |
| RMAHostAppUserAgentInfo      | String  | `Host app name and version info that is appended in User agent. The value specified in the plist is retrieved only at the build time.` |YES      |`none`   |

If you don't want to use project settings, you have to pass this information one by one to the `Config.userDefaults` using a `Config.Key` as key:

```swift
Config.userDefaults?.set("MY_CUSTOM_ID", forKey: Config.Key.subscriptionKey.rawValue)
```

<a id="usage"></a>

### Usage

* [Create a MiniApp](#create-mini-app)
* [Mini App Features](#mini-app-features)
    * [Retrieving Unique ID](#retrieve-unique-id)
    * [Requesting Location Permissions](#request-location-permission)
    * [Custom Permissions](#custom-permissions)
    * [Share Mini app content](#share-mini-app-content)
    * [Retrieve User Profile details](#retrieve-user-profile-details)
* [Load the Mini App list](#load-miniapp-list)
* [Get a MiniAppInfo](#get-mini-appinfo)
* [List Downloaded Mini apps](#list-downloaded-mini-apps)
* [Advanced Features](#advanced-features)
    * [Overriding configuration on runtime](#runtime-conf)
    * [Customize history navigation](#custom-navigation)
    * [Opening external links](#Opening-external-links)
    * [Orientation Lock](#orientation-lock)

<a id="create-mini-app"></a>

### Create a MiniApp for the given `MiniAppId` :
---
**API Docs:** `MiniApp.create(appId:completionHandler:messageInterface:)`, `MiniAppDisplayDelegate`

`MiniApp.create` is used to create a `View` for displaying a specific mini app. You must provide the mini app ID which you wish to create (you can get the mini-app ID by [Loading the Mini App List](#load-miniapp-list) first). Calling `MiniApp.create` will do the following:

- Checks with the platform what is the latest and published version of the mini app.
- Check if the latest version of the mini app has been already downloaded 
    - If yes, return the already downloaded mini app view.
    - If not, download the latest version and then return the view
- If the device is disconnected from the internet and if the device already has a version of the mini app downloaded, then the already downloaded version will be returned immediately.

After calling `MiniApp.create`, you will obtain an instance of `MiniAppDisplayDelegate` which is the delegate of the Display module. You can call `MiniAppDisplayDelegate.getMiniAppView` to obtain a `View` for displaying the mini app.

The following is a simplified example:

```swift
MiniApp.shared().create(appId: String, completionHandler: { (result) in
	switch result {
            case .success(let miniAppDisplay):
                let view = miniAppDisplay.getMiniAppView()
                view.frame = self.view.bounds
                self.view.addSubview(view)
            case .failure(let error):
                print("Error: ", error.localizedDescription)
            }
}, messageInterface: self)

```

<a id="mini-app-features"></a>

### Mini App Features
---
**API Docs:** [MiniAppMessageDelegate](https://rakutentech.github.io/ios-miniapp/Protocols/MiniAppMessageDelegate.html)

The `MiniAppMessageDelegate` is used for passing messages between the Mini App (JavaScript) and the Host App (your native iOS App) and vice versa. Your App must provide the implementation for these functions.

Mini App SDK provides default implementation for few interfaces in `MiniAppMessageDelegate`, however the Host app can still override them by implementing the interface in their side.

| Method                       | Default  |
| :----                        | :----:   |
| getUniqueId                  | 🚫       |
| requestPermission            | 🚫       |
| requestCustomPermissions     | ✅       |
| shareContent                 | ✅       |
| getUserName                  | 🚫       |
| getProfilePhoto              | 🚫       |
| getAccessToken               | 🚫       |

```NOTE: Following code snippets is an example for implementing MiniAppMessageDelegate methods, you can add your own custom implementation or you can make use of the code which is provided in the Sample app.```

<a id="retrieve-unique-id"></a>

##### Retrieving Unique ID
---
**API Docs:** [MiniAppUserInfoDelegate](https://rakutentech.github.io/ios-miniapp/Protocols/MiniAppUserInfoDelegate.html)

```swift
extension ViewController: MiniAppMessageDelegate {
    func getUniqueId() -> String {
        guard let deviceId = UIDevice.current.identifierForVendor?.uuidString else {
            return ""
        }
        return deviceId
    }
}
```

<a id="request-location-permission"></a>

##### Requesting Location Permissions
---
**API Docs:** [MiniAppMessageDelegate](https://rakutentech.github.io/ios-miniapp/Protocols/MiniAppMessageDelegate.html)

```swift
extension ViewController: MiniAppMessageDelegate {
    func requestPermission(permissionType: MiniAppPermissionType, completionHandler: @escaping (Result<String, Error>) -> Void) {
        switch permissionType {
        case .location:
            let locStatus = CLLocationManager.authorizationStatus()
            switch locStatus {
            case .authorizedAlways, .authorizedWhenInUse:
                completionHandler(.success("allowed"))
            }
        }
    }
```

<a id="custom-permissions"></a>

##### Custom Permissions
---
**API Docs:** [MiniAppMessageDelegate](https://rakutentech.github.io/ios-miniapp/Protocols/MiniAppMessageDelegate.html)

SDK has its own implementation to show the list of requested custom permissions. If you want to display your own UI for requesting custom permissions, you can do it by overriding the method like below,

```swift
extension ViewController: MiniAppMessageDelegate {
        func requestCustomPermissions(
            permissions: [MASDKCustomPermissionModel],
            miniAppTitle: String,
            completionHandler: @escaping (
            Result<[MASDKCustomPermissionModel], Error>) -> Void) {
                completionHandler(.success(permissions))    
            }
    
```

##### Retrieving and storing Custom Permissions

MiniApp iOS SDK supports list of Custom Permissions ( ```MiniAppCustomPermissionType```) and these can be stored and retrieved using the following public interfaces.

##### Retrieving the Mini App Custom Permissions using MiniAppID

Custom permissions and its status can be retrieved using the following interface. ```getCustomPermissions``` will return list  of ```MASDKCustomPermissionModel``` that contains the meta-info such as title and its granted status.

```swift
let miniAppPermissionsList = MiniApp.shared().getCustomPermissions(forMiniApp: miniAppId)
```

##### Store the Mini App Custom Permissions
Custom permissions for a mini app is cached by the SDK and you can use the following interface to store and retrieve it when you need.

```swift
 MiniApp.shared().setCustomPermissions(forMiniApp: String, permissionList: [MASDKCustomPermissionModel])
```

<a id="share-mini-app-content"></a>

##### Share Mini app content
---
**API Docs:** [MiniAppShareContentDelegate](https://rakutentech.github.io/ios-miniapp/Protocols/MiniAppShareContentDelegate.html)

By default, Mini App iOS SDK can open its own controller for content sharing. If you want to override this, you just have to implement the `shareContent(info: MiniAppShareContent, completionHandler: @escaping (Result<MASDKProtocolResponse, Error>) -> Void)` from `MiniAppShareContentDelegate`, which is part of `MiniAppMessageDelegate`.

```swift
extension ViewController: MiniAppMessageDelegate {
    func shareContent(info: MiniAppShareContent,
            completionHandler: @escaping (
                Result<String, Error>) -> Void) {
        let activityController = UIActivityViewController(activityItems: [info.messageContent], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
        completionHandler(.success("SUCCESS"))
    }
}
```

<a id="user-profile-details"></a>

##### Retrieve User Profile details
---
**API Docs:** [MiniAppUserInfoDelegate](https://rakutentech.github.io/ios-miniapp/Protocols/MiniAppUserInfoDelegate.html)

Get the User profile related details using 'MiniAppMessageDelegate'.
The following delegates/interfaces will be called only if the user has allowed respective [Custom permissions](#custom-permissions)

<a id="user-profile-details-username"></a>

###### User Name

Retrieve user name of the User

```swift
extension ViewController: MiniAppMessageDelegate {
    func getUserName() -> String? {
        // Implementation to return the User name
        return ""
    }
}
```

<a id="user-profile-details-profilephoto"></a>

###### Profile Photo

Retrieve Profile Photo of the User

```swift
extension ViewController: MiniAppMessageDelegate {
    func getProfilePhoto() -> String? {
        // Implementation to return the Profile photo URI
        return ""
    }
}
```

<a id="user-profile-details-contactlist"></a>

###### Contact List

Retrieve the Contact list of the User

```swift
extension ViewController: MiniAppMessageDelegate {
    func getContacts() -> [MAContact]? {
        // Implementation to return the contact list
        return []
    }
}
```

<a id="access-token-info"></a>

###### Access Token Info

Retrieve access token and expiry date

```swift
extension ViewController: MiniAppMessageDelegate {
    func getAccessToken(miniAppId: String, completionHandler: @escaping (Result<MATokenInfo, MASDKCustomPermissionError>) -> Void) {

        completionHandler(.success(.init(accessToken: "ACCESS_TOKEN", expirationDate: Date())))
    }
}
```

<a id="load-miniapp-list"></a>

### Load the `MiniApp` list:
---
**API Docs:** [MiniApp.list](https://rakutentech.github.io/ios-miniapp/Classes/MiniApp.html)

MiniApp library calls are done via the `MiniApp.shared()` singleton with or without a `MiniAppSdkConfig` instance (you can get the current one with `Config.getCurrent()`). If you don't provide a config instance, values in custom iOS target properties will be used by default. 

```swift
MiniApp.shared().list { (result) in
	...
}
```

or

```swift
MiniApp.shared(with: Config.getCurrent()).list { (result) in
	...
}
```
<a id="get-mini-appinfo"></a>

### Getting a `MiniAppInfo` :
---
**API Docs:** [MiniApp.info](https://rakutentech.github.io/ios-miniapp/Classes/MiniApp.html)

```swift
MiniApp.shared().info(miniAppId: miniAppID) { (result) in
	...
}
```

or

```swift
MiniApp.shared(with: Config.getCurrent()).info(miniAppId: miniAppID) { (result) in
	...
}
```

<a id="list-downloaded-mini-apps"></a>

### List Downloaded Mini apps
---
**API Docs:** [MiniApp.listDownloadedWithCustomPermissions](https://rakutentech.github.io/ios-miniapp/Classes/MiniApp.html)

Gets the list of downloaded Mini apps info and associated custom permissions status

```swift
 MiniApp.shared().listDownloadedWithCustomPermissions()
```

<a id="navigation"></a>

### Advanced Features
---
**API Docs:** [MiniAppSdkConfig](https://rakutentech.github.io/ios-miniapp/Classes/MiniAppSdkConfig.html)

Along with Mini app features, Mini app SDK does provides more customization for the user. Some of the more customizable features are below,


<a id="runtime-conf"></a>

#### Overriding configuration on runtime

Every call to the API can be done with default parameters retrieved from the project .plist configuration file, or by providing a `MiniAppSdkConfig` object during the call. Here is a simple example class we use to create the configuration in samples below:

```swift
class Config: NSObject {
    class func getCurrent() -> MiniAppSdkConfig {
        return MiniAppSdkConfig(baseUrl: "https://your.custom.url"
                                rasAppId: "your_RAS_App_id",
                                subscriptionKey: "your_subscription_key",
                                hostAppVersion: "your_custom_version",
                                isTestMode: true")
    }
}
```
*NOTE:* `RMAHostAppUserAgentInfo` cannot be configured at run time.

<a id="custom-navigation"></a>

#### Add a web navigation interface to the MiniApp view
---
**API Docs:** [MiniAppNavigationConfig](https://rakutentech.github.io/ios-miniapp/Classes/MiniAppNavigationConfig.html)

MiniApp iOS SDK provides a fully customizable way to implement a navigation interface inside your html pages with a `MiniAppNavigationConfig` object. The class takes 3 arguments:

- `navigationBarVisibility` : 
    - never = the UI will never be shown
    - auto = navigation UI is only shown when a back or forward action is available
    - always = navigation UI is always present
- `navigationDelegate` : A delegate that will receive MiniApp view instructions about available navigation options. It will also receive taps on external links.
- `customNavigationView` : A view implementing `MiniAppNavigationDelegate` that will be overlayed to the bottom of the MiniApp view

```swift
let navConfig = MiniAppNavigationConfig(
                    navigationBarVisibility: .always,
                    navigationDelegate: myNavigationDelegate,
                    customNavigationView: mCustomView)

MiniApp.shared(with: Config.getCurrent(), navigationSettings: navConfig).info(miniAppId: miniAppID) { (result) in
...
}
```

#### Opening external links
---
**API Docs:** [MiniAppNavigationConfig](https://rakutentech.github.io/ios-miniapp/Classes/MiniAppExternalUrlLoader.html)

By default MiniApp iOS SDK will open external links into a separate modal controller when tapped. `MiniAppNavigationDelegate` implements a method that allows to override this behaviour and provide your own external links management. Here is an example of implementation:

```swift
extension ViewController: MiniAppNavigationDelegate {
    func miniAppNavigation(shouldOpen url: URL, with externalLinkResponseHandler: @escaping (URL) -> Void) {
        // Getting your custom viewcontroller
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ExternalWebviewController") as? ExternalWebViewController {
            viewController.currentURL = url
            viewController.miniAppExternalUrlLoader = MiniAppExternalUrlLoader(webViewController: viewController, responseHandler: externalLinkResponseHandler)
            self.presentedViewController?.present(viewController, animated: true)
        }
    }

    ...
}
```

The `externalLinkResponseHandler` closure allows you to give a feedback as an URL to the SDK, for example when the controller is closed or when a custom scheme link is tapped. This closure can be passed to a `MiniAppExternalUrlLoader` object that will provide a method to test an URL and return the appropriate decision for a `WKNavigationDelegate` method, and if you provided a controller it will be dismissed automatically. Here is an example following previous example:

```swift
extension ExternalWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.currentURL = self.webView.url
    }

    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(miniAppExternalUrlLoader?.shouldOverrideURLLoading(navigationAction.request.url) ?? .allow)
    }
}
```

<a id="orientation-lock"></a>

#### Orientation Lock


You can choose to give orientation lock control to mini apps. However, this requires you to add some code to your `AppDelegate` which could have an affect on your entire App. If you do not wish to do this, please see the section *"Allow only full screen videos to change orientation".*

##### Allow mini apps to lock the view to any orientation
    
```swift
func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if #available(iOS 12, *) {
            if window?.isKeyWindow != true {
                return .all
            }
        }
        if MiniApp.MAOrientationLock.isEmpty {
            return .all
        } else {
            return MiniApp.MAOrientationLock
        }
    }
```

##### Allow full screen videos to change orientation

You can add the following if you want to enable videos to change orientation. Note that if you do not wish to add code to `AppDelegate` as in the above example, you can still allow videos inside the mini app to use landscape mode even when your App is locked to portrait mode and vice versa.

```swift
import AVKit

extension AVPlayerViewController {
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if MiniApp.MAOrientationLock.isEmpty {
            return .all
        } else {
            return MiniApp.MAOrientationLock
        }
    }
}
```

<a id="change-log"></a>

## Changelog

See the full [CHANGELOG](https://github.com/rakutentech/ios-miniapp/blob/master/CHANGELOG.md).
