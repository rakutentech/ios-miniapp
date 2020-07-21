[![Build Status](https://travis-ci.org/rakutentech/ios-miniapp.svg?branch=master)](https://travis-ci.org/rakutentech/ios-miniapp)
[![codecov](https://codecov.io/gh/rakutentech/ios-miniapp/branch/master/graph/badge.svg)](https://codecov.io/gh/rakutentech/ios-miniapp)
[![ios](https://cocoapod-badges.herokuapp.com/p/MiniApp/badge.png)](https://cocoapods.org/pods/MiniApp)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

# MiniApp

This open-source library allows you to integrate Mini App ecosystem into your iOS applications. 
Mini App SDK also facilitates communication between a mini app and the host app via a message bridge.

## Features

- Load MiniApp list
- Load MiniApp metadata
- Create a MiniApp view
- Facilitate comm between host app and mini app

All the MiniApp files downloaded by the MiniApp iOS library are cached locally

# Getting started

* [Requirements](#requirements)
* [Documentation](#documentation)
* [Installation](#installation)
* [Configuration](#configuration)
* [Usage](#usage)
* [Sample App](#sample-app)
* [Changelog](#change-log)

<div id="requirements"></div>

## Requirements

This module supports **iOS 11.0 and above**. It has been tested on iOS 11.0 and above.

It is written in Swift 5.0 and can be used in compatible Xcode versions.

In order to run your MiniApp you will have to provide the following,

* MiniApp host application identifier (RASApplicationIdentifier)
* Subscription key (RASProjectSubscriptionKey)
* Base URL for API requests to the library (RMAAPIEndpoint)
* Preference, if you want to make use of Test API Endpoints in your application or not

<div id="documentation"></div>

# Documentation

Generated documentation for this SDK can be found at https://rakutentech.github.io/ios-miniapp/

<div id="installation"></div>

# Installation

Mini App SDK is available through [CocoaPods](https://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'MiniApp'
```
<div id="configuration"></div>

# Configuration

In your project configuration .plist you should add below Key/Value :

| Key                          | Type    | Description                                                     | Optional| Default |
| :----                        | :----:  | :----                                                           |:----:   |:----:   |
| RASApplicationIdentifier     | String  | `Set your MiniApp host application identifier`                  |NO       |`none`   |
| RASProjectSubscriptionKey    | String  | `Set your MiniApp subscription key`                             |NO       |`none`   |
| RMAAPIEndpoint               | String  | `Provide your own Base URL for API requests`                    |NO       |`none`   |
| RMAIsTestMode                | String  | `Loading mode of the API (`true`: testing, `false`: published)` |NO       |false    |
| RMAHostAppUserAgentInfo      | String  | `Host app name and version info that is appended in User agent` |YES      |`none`   |

If you don't want to use project settings, you have to pass this information one by one to the `Config.userDefaults` using a `Config.Key` as key:

```swift
Config.userDefaults?.set("MY_CUSTOM_ID", forKey: Config.Key.subscriptionKey.rawValue)
```

<div id="usage"></div>

# Usage

* [Overriding configuration on runtime](#runtime-conf)
* [Load the Mini App list](#load-miniapp-list)
* [Get a MiniAppInfo](#get-mini-appinfo)
* [Create a MiniApp](#create-mini-app)
* [Communicate with MiniApp](#MiniAppMessageProtocol)
* [Customize history navigation](#navigation)

<div id="runtime-conf"></div>

### Overriding configuration on runtime

Every call to the API can be done with default parameters retrieved from the project .plist configuration file, or by providing a `MiniAppSdkConfig` object during the call. Here is a simple example class we use to create the configuration in samples below:

```swift
class Config: NSObject {
    class func getCurrent() -> MiniAppSdkConfig {
        return MiniAppSdkConfig(baseUrl: "https://your.custom.url"
                                rasAppId: "your_RAS_App_id",
                                subscriptionKey: "your_subscription_key",
                                hostAppVersion: "your_custom_version",
                                isTestMode: true,
                                hostAppUserAgentInfo: "host_app_name_and_version")
    }
}
```

<div id="load-miniapp-list"></div>

### Load the `MiniApp` list:

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

### Create a MiniApp for the given `MiniAppInfo` object :

```swift
MiniApp.shared().create(appInfo: info, completionHandler: { (result) in
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

The `MiniAppMessageProtocol` is used for passing messages between the Mini App (JavaScript) and the Host App (your native iOS App) and vice versa. Your App must provide the implementation for these functions.

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
<div id="navigation"></div>

### Add a web navigation interface to the MiniApp view

MiniApp iOS SDK provides a fully customizable way to implement a navigation interface inside your html pages with a `MiniAppNavigationConfig` object. The class takes 3 arguments:

- `navigationBarVisibility` : 
    - never = the UI will never be shown
    - auto = navigation UI is only shown when a back or forward action is availabe
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

<div id="sample-app"></div>

# Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

### Custom parameters

In order to load your MiniApp, you will have to use your own Host App ID and your Subscription key. These can either be set in project configuration plist (`RASApplicationIdentifier`, `RASProjectSubscriptionKey`) or by taping the top right configuration icon in the example application. Also we don't currently host a public API, so you will need to provide your own Base URL for API requests by setting it in project configuration plist (`RMAAPIEndpoint`)

### Testing mode

The SDK can be configured to load MiniApps in 2 modes : Published mode and Testing mode. Published mode only allows access to the last published version of your MiniApps, whereas Testing mode allows you to load all your MiniApps versions, as long as they are in `Testing` state on RAS console. To configure the loading mode, you can either do it in the .plist file with the configuration variable `RMAIsTestMode`, or by taping the top right configuration icon in the example application.


## License

See the *LICENSE* file for more info.

<div id="change-log"></div>

# Changelog

See the full [CHANGELOG](https://github.com/rakutentech/ios-miniapp/blob/master/CHANGELOG.md).
