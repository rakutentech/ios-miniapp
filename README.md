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
* [Documentation](https://rakutentech.github.io/ios-miniapp/)
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

<div id="installation"></div>

# Installation

Mini App SDK is available through [CocoaPods](https://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'MiniApp'
```
<div id="configuration"></div>



## License

See the *[LICENSE](https://github.com/rakutentech/ios-miniapp/blob/master/LICENSE)* file for more info.

<div id="change-log"></div>

# Changelog

See the full [CHANGELOG](https://github.com/rakutentech/ios-miniapp/blob/master/CHANGELOG.md).
