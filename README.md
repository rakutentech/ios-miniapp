[![Build Status](https://travis-ci.org/rakutentech/ios-miniapp.svg?branch=master)](https://travis-ci.org/rakutentech/ios-miniapp)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com)
<a href="https://opensource.org/licenses/MIT">
  <img src="https://img.shields.io/badge/License-MIT-yellow.svg" />
</a>

# MiniApp

This open-source library allows you to integrate a Rakuten MiniApp into your iOS applications. It also provides more features to interact with the native application via bridge.

## Features

- Load MiniApp list
- Load MiniApp meta-informations
- Create a MiniApp view

All the MiniApp files downloaded by the MiniApp iOS library are cached localy for efficiency

## Getting started

### Requirements

This module supports iOS 11.0 and above. It has been tested on iOS 11.0 and above.

It is written in Swift 5.0 and can be used in compatible Xcode versions.

In order to run your MiniApp you will have to provide your MiniApp host application identifier, Subsbscription key and your own Base URL for API requests to the library.

# Documentation

Generated documentation for this SDK can be found at https://rakutentech.github.io/ios-miniapp/

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

### Custom parameters

In order to load your MiniApp, you will have to use your own Host App ID and your Subscription key. These can either be set in project configuration plist (RASApplicationIdentifier, RASProjectSubscriptionKey) or by taping the top right configuration icon in the example application. Also we don't currently host a public API, so you will need to provide your own Base URL for API requests by setting it in project configuration plist (RMAAPIEndpoint)

## Installation

MiniApp is available through [CocoaPods](https://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'MiniApp'
```

In your project configuration .plist you should add 2 custom string target properties :

- `RASApplicationIdentifier` - to set your MiniApp host application identifier
- `RASProjectSubscriptionKey` - to set your MiniApp subsbscription key
- `RMAAPIEndpoint` - to provide your own Base URL for API requests


If you don't want to use project settings, you have to pass this informations one by one to the `Config.userDefaults` using a `Config.Key` as key:

```swift
Config.userDefaults?.set("MY_CUSTOM_ID", forKey: Config.Key.subscriptionKey.rawValue)
```

## Usage

MiniApp library calls are done via the `MiniApp.shared()` singleton with or without a `MiniAppSdkConfig` instance (you can get the current one with `Config.getCurrent()`). If you don't provide a config instance, values in custom iOS target properties will be used by default. 

### Load the MiniApp list:

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

## License

See the *LICENSE* file for more info.
