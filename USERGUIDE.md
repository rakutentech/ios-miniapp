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
* [Communicate with MiniApp](#MiniAppMessageProtocol)
* [Customize history navigation](#navigation)
* [Custom Permissions](#custom-permissions)

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
<div id="MiniAppMessageProtocol"></div>

### Implement the MiniAppMessageProtocol in your View Controller
---
The `MiniAppMessageProtocol` is used for passing messages between the Mini App (JavaScript) and the Host App (your native iOS App) and vice versa. Your App must provide the implementation for these functions.

```NOTE: Following code snippets is an example for implementing MiniAppMessageProtocol methods, you can add your own custom implementation or you can make use of the code which is provided in the Sample app.```

##### Retrieving Unique ID

```swift
extension ViewController: MiniAppMessageProtocol {
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
extension ViewController: MiniAppMessageProtocol {
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
extension ViewController: MiniAppMessageProtocol {
        func requestCustomPermissions(
            permissions: [MASDKCustomPermissionModel],
            completionHandler: @escaping (
            Result<[MASDKCustomPermissionModel], Error>) -> Void) {
            completionHandler(.success(permissions))    
            }
    
```
<div id="share-mini-app-content"></div>

##### Share Mini app content

```swift
extension ViewController: MiniAppMessageProtocol {
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
- `navigationDelegate` : A delegate that will receive MiniApp view instructions about available navigation options
- `customNavigationView` : A view implementing `MiniAppNavigationDelegate` that will be overlayed to the bottom of the MiniApp view

```swift
let navConfig = MiniAppNavigationConfig(
                    navigationBarVisibility: .always,
                    navigationDelegate: myCustomView,
                    customNavigationView: mCustomView)

MiniApp.shared(with: Config.getCurrent(), navigationSettings: navConfig).info(miniAppId: miniAppID) { (result) in
...
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


<div id="change-log"></div>

## Changelog

See the full [CHANGELOG](https://github.com/rakutentech/ios-miniapp/blob/master/CHANGELOG.md).