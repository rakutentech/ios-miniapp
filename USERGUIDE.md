# MiniApp

This open-source library allows you to integrate Mini App ecosystem into your iOS applications.
Mini App SDK also facilitates communication between a mini app and the host app via a message bridge.

## Features

- Load MiniApp list
- Load MiniApp metadata
- Create a MiniApp view
- Facilitate comm between host app and mini app

All the MiniApp files downloaded by the MiniApp iOS library are cached locally

## Getting started

* [Requirements](#requirements)
* [Documentation](https://rakutentech.github.io/ios-miniapp/)
* [Installation](#installation)
* [Configuration](#configuration)
* [Usage](#usage)

## Requirements

This module supports **iOS 11.0 and above**. It has been tested on iOS 11.0 and above.

It is written in Swift 5.0 and can be used in compatible Xcode versions.

In order to run your MiniApp you will have to provide the following,

* MiniApp host application identifier (```RASApplicationIdentifier```)
* Subscription key (```RASProjectSubscriptionKey```)
* Base URL for API requests to the library (```RMAAPIEndpoint```)
* Preference, if you want to make use of Test API Endpoints in your application or not


## Installation

Mini App SDK is available through [CocoaPods](https://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'MiniApp'
```

## Configuration

In your project configuration .plist you should add below Key/Value :

| Key                          | Type    | Description                                                     | Optional| Default |
| :----                        | :----:  | :----                                                           |:----:   |:----:   |
| RASApplicationIdentifier     | String  | `Set your MiniApp host application identifier`                  |NO       |`none`   |
| RASProjectSubscriptionKey    | String  | `Set your MiniApp subscription key`                             |NO       |`none`   |
| RMAAPIEndpoint               | String  | `Provide your own Base URL for API requests`                    |NO       |`none`   |
| RMAHostAppUserAgentInfo      | String  | `Host app name and version info that is appended in User agent. The value specified in the plist is retrieved only at the build time.` |YES      |`none`   |

If you don't want to use project settings, you have to pass this information one by one to the `Config.userDefaults` using a `Config.Key` as key:

```swift
Config.userDefaults?.set("MY_CUSTOM_ID", forKey: Config.Key.subscriptionKey.rawValue)
```

<div id="usage"></div>

## Usage

* [Overriding configuration on runtime](#runtime-conf)
* [Load the Mini App list](#load-miniapp-list)
* [Get a MiniAppInfo](#get-mini-appinfo)
* [Create a MiniApp](#create-mini-app)
* [Communicate with MiniApp](#MiniAppMessageDelegate)
* [Customize history navigation](#navigation)
* [Custom Permissions](#custom-permissions)
* [List Downloaded Mini apps](#list-downloaded-mini-apps)
* [Retrieve User Profile details](#user-profile-details)
* [Orientation Lock](#orientation-lock)

<div id="runtime-conf"></div>

### Overriding configuration on runtime
---
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


<div id="load-miniapp-list"></div>

### Load the `MiniApp` list:
---
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
<div id="get-mini-appinfo"></div>

### Getting a `MiniAppInfo` :
---
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

<div id="create-mini-app"></div>

### Create a MiniApp for the given `MiniAppId` :
---
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
<div id="MiniAppMessageDelegate"></div>

### Implement the MiniAppMessageDelegate in your View Controller
---
The `MiniAppMessageDelegate` is used for passing messages between the Mini App (JavaScript) and the Host App (your native iOS App) and vice versa. Your App must provide the implementation for these functions.

```NOTE: Following code snippets is an example for implementing MiniAppMessageDelegate methods, you can add your own custom implementation or you can make use of the code which is provided in the Sample app.```

##### Retrieving Unique ID

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

##### Requesting Location Permissions

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

<div id="request-custom-permission"></div>

##### Requesting Custom Permissions

```swift
extension ViewController: MiniAppMessageDelegate {
        func requestCustomPermissions(
            permissions: [MASDKCustomPermissionModel],
            completionHandler: @escaping (
            Result<[MASDKCustomPermissionModel], Error>) -> Void) {
            completionHandler(.success(permissions))    
            }
    
```
<div id="share-mini-app-content"></div>

##### Share Mini app content

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

<div id="navigation"></div>

### Add a web navigation interface to the MiniApp view
---
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

<div id="custom-permissions"></div>

### Custom Permissions
---
MiniApp iOS SDK supports list of Custom Permissions ( ```MiniAppCustomPermissionType```) and these can be stored and retrieved using the following public interfaces.

#### Retrieving the Mini App Custom Permissions using MiniAppID

Custom permissions and its status can be retrieved using the following interface. ```getCustomPermissions``` will return list  of ```MASDKCustomPermissionModel``` that contains the meta-info such as title and its granted status.

```swift
let miniAppPermissionsList = MiniApp.shared().getCustomPermissions(forMiniApp: miniAppId)
```

#### Store the Mini App Custom Permissions
Custom permissions for a mini app is cached by the SDK and you can use the following interface to store and retrieve it when you need.

```swift
 MiniApp.shared().setCustomPermissions(forMiniApp: String, permissionList: [MASDKCustomPermissionModel])
```

<div id="list-downloaded-mini-apps"></div>

### List Downloaded Mini apps
Gets the list of downloaded Mini apps info and associated custom permissions status

```swift
 MiniApp.shared().listDownloadedWithCustomPermissions()
```

<div id="user-profile-details"></div>

### Retrieve User Profile details
---
Get the User profile related details using 'MiniAppMessageDelegate'.
The following delegates/interfaces will be called only if the user has allowed respective [Custom permissions](#custom-permissions)

<div id="user-profile-details-username"></div>

#### User Name

Retrieve user name of the User

```swift
extension ViewController: MiniAppMessageDelegate {
    MiniApp.shared().getUserName() -> String? {
        // Implementation to return the User name
        return ""
    }
}
```

<div id="user-profile-details-profilephoto"></div>

#### Profile Photo

Retrieve Profile Photo of the User

```swift
extension ViewController: MiniAppMessageDelegate {
    MiniApp.shared().getProfilePhoto() -> String? {
        // Implementation to return the Profile photo URI
        return ""
    }
}
```

<div id="orientation-lock"></div>

### Orientation Lock
---
Mini-app can request the SDK to lock the orientation using the JS SDK interfaces and the locked orientation can be retrieved using the following interface,

1. Overriding `supportedInterfaceOrientations` in your ViewController

    ```swift
    static var miniAppSupportedOrientation: UIInterfaceOrientationMask = []

    extension DisplayController {
        override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
            DisplayController.miniAppSupportedOrientation = self.miniAppDisplayDelegate?.getSupportedOrientation() ?? .all
            return DisplayController.miniAppSupportedOrientation
        }
    }
    ```
    NOTE: `self.miniAppDisplayDelegate` is an instance of `MiniAppDisplayProtocol` which can be retrieved while [creating mini-app](#create-mini-app).

    The above code will help you to override the orientation for a given Viewcontroller (in which the Mini app view is displayed)

2. Overriding `navigationControllerSupportedInterfaceOrientations`

    If you have used UINavigationController, then you need to add the following code to enable the orientation lock,

    ```swift
    extension DisplayController: UINavigationControllerDelegate {
        public func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
            return navigationController.topViewController?.supportedInterfaceOrientations ?? .all
        }
    }
    ```
    NOTE: You should also set the Navigation Controller delegate to self. ```self.navigationController?.delegate = self```

3. Overriding `supportedInterfaceOrientations` for AVPlayerViewController

    Orientation lock will not work for videos that is played inside Mini-app. To enable Orientation lock for the videos, please add the following code,

    `import AVKit`

    ```swift
    extension AVPlayerViewController {
        override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
                return DisplayController.miniAppSupportedOrientation
            }
        }
    ```

<div id="change-log"></div>

## Changelog

See the full [CHANGELOG](https://github.com/rakutentech/ios-miniapp/blob/master/CHANGELOG.md).
