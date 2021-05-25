# MiniApp

This open-source library allows you to integrate Mini App ecosystem into your iOS applications.
Mini App SDK also facilitates communication between a Mini App and the host app via a message bridge.

## Features

- Load MiniApp list
- Load MiniApp metadata
- Create a MiniApp view
- Facilitate communication between host app and Mini App

And much more features which you can find them in [Usage](#usage).

All the MiniApp files downloaded by the MiniApp iOS library are cached locally

## Requirements

This module supports **iOS 13.0 and above**. It has been tested on iOS 13.0 and above.

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

If you need to support display of Google ads triggered from your Mini App, you need to add the following subspec instead:

```ruby
pod 'MiniApp/Admob'
```

### Configuration

In your project configuration .plist you should add below Key/Value :

| Key                          | Type    | Description                                                     | Optional| Default |
| :----                        | :----:  | :----                                                           |:----:   |:----:   |
| RASProjectId     | String  | `Set your MiniApp host application project identifier`                  |NO       |`none`   |
| RASProjectSubscriptionKey    | String  | `Set your MiniApp subscription key`                             |NO       |`none`   |
| RMAAPIEndpoint               | String  | `Provide your own Base URL for API requests`                    |NO       |`none`   |
| RMAHostAppUserAgentInfo      | String  | `Host app name and version info that is appended in User agent. The value specified in the plist is retrieved only at the build time.` |YES      |`none`   |

<a id="setting-admob"></a>Additionally, if you support Google ads with `MiniApp/Admob` subspec, you need to configure Google ads framework as advised into this [documentation](https://developers.google.com/admob/ios/quick-start)

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
    * [Ads integration](#ads-integration)
    * [Retrieve User Profile details](#retrieve-user-profile-details)
    * [Send message to contacts](#send-message-to-contacts)
* [Load the Mini App list](#load-miniapp-list)
* [Get a MiniAppInfo](#get-mini-appinfo)
* [Mini App meta-data](#mini-meta-data)
    * [Getting a MiniApp meta-data](#get-mini-meta-data)
    * [How to use MiniApp meta-data](#how-to-use-meta-data)
    * [How to get downloaded MiniApp meta-data](#how-to-get-downloaded-meta-data)
* [List Downloaded Mini apps](#list-downloaded-mini-apps)
* [Advanced Features](#advanced-features)
    * [Overriding configuration on runtime](#runtime-conf)
    * [Overriding localizations](#localization)
    * [Customize history navigation](#custom-navigation)
    * [Opening external links](#Opening-external-links)
    * [Orientation Lock](#orientation-lock)
    * [Catching analytics events](#analytics-events)
    * [Passing Query parameters while creating Mini App](#query-param-mini-app)
    * [Permissions required from the Host app](#permissions-from-host-app)

<a id="create-mini-app"></a>

### Create a MiniApp for the given `MiniAppId` :
---
**API Docs:** `MiniApp.create(appId:completionHandler:messageInterface:)`, `MiniAppDisplayDelegate`

`MiniApp.create` is used to create a `View` for displaying a specific Mini App. You must provide the Mini App ID which you wish to create (you can get the Mini App ID by [Loading the Mini App List](#load-miniapp-list) first). Calling `MiniApp.create` will do the following:

- Checks with the platform what is the latest and published version of the Mini App.
- Check if the latest version of the Mini App has been already downloaded 
    - If yes, return the already downloaded Mini App view.
    - If not, download the latest version and then return the view
- If the device is disconnected from the internet and if the device already has a version of the Mini App downloaded, then the already downloaded version will be returned immediately.

After calling `MiniApp.create`, you will obtain an instance of `MiniAppDisplayDelegate` which is the delegate of the Display module. You can call `MiniAppDisplayDelegate.getMiniAppView` to obtain a `View` for displaying the Mini App.

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
| requestDevicePermission      | 🚫       |
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
    func getUniqueId(completionHandler: @escaping (Result<String, MASDKError>) -> Void) {
        // Implementation to return the Unique ID
        completionHandler(.success(""))
    }
}
```

<a id="request-location-permission"></a>

##### Requesting Location Permissions
---
**API Docs:** [MiniAppMessageDelegate](https://rakutentech.github.io/ios-miniapp/Protocols/MiniAppMessageDelegate.html)

```swift
extension ViewController: MiniAppMessageDelegate {
    func requestDevicePermission(permissionType: MiniAppDevicePermissionType, completionHandler: @escaping (Result<String, Error>) -> Void) {
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

<a id="store-custom-permission"></a>
##### Store the Mini App Custom Permissions
Custom permissions for a Mini App is cached by the SDK and you can use the following interface to store and retrieve it when you need.

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

<a id="ads-integration"></a>
##### Ads integration
---
**API Docs:** [MiniAppAdDisplayDelegate](https://rakutentech.github.io/ios-miniapp/Protocols/MiniAppAdDisplayDelegate.html)

Mini App SDK gives you the possibility to display ads triggered by your Mini App from your host app.
There are 2 ways to achieve this: 
- by implementing [MiniAppAdDisplayDelegate](https://rakutentech.github.io/ios-miniapp/Protocols/MiniAppAdDisplayDelegate.html) by yourself 
- if you rely on Google ads to display your ads you can simply implement `pod MiniApp/Admob` into your pod dependencies (see [settings section](#setting-admob)).
###### Google ads displayer

When you chose to implement Google Ads support for your Mini Apps (see [configuration section](#setting-admob)), you must provide an [`AdMobDisplayer`](https://rakutentech.github.io/ios-miniapp/Classes/AdMobDisplayer.html) as adsDelegate parameter when creating your Mini App display:

Be careful when declaring your variable, as Mini App SDK does not keep a strong reference to it, it is preferable to declare it as a global variable or in most cases it will become nil once your method called.

```swift
let adsDelegate = AdMobDisplayer() // This is just declared here as a convenience for the example.

MiniApp.shared(with: Config.current(), navigationSettings: Config.getNavConfig(delegate: self))
        .create(appId: appInfo.id, 
                version: appInfo.version.versionId,
                queryParams: getQueryParam(),
                completionHandler: { (result) in }, // retrieve your Mini App view in the result success 
                messageInterface: someMessageInterfaceDelegate, 
                adsDelegate: adsDelegate) // notice the new parameter for ads delegation
```

###### Custom ads displayer

If you chose to implement ads displaying by yourself, you first need do implement [`MiniAppAdDisplayDelegate`](https://rakutentech.github.io/ios-miniapp/Protocols/MiniAppAdDisplayDelegate.html) and provide it to a [`MiniAppAdDisplayer`](https://rakutentech.github.io/ios-miniapp/Classes/MiniAppAdDisplayer.html).

For the same reasons mentioned in `AdMobDisplayer` section above, prefer declaring your `MiniAppAdDisplayer` globally.

```swift
class ViewController: UIViewController {
    let adsDelegate: MiniAppAdDisplayer 
    
    override func viewDidLoad() {
      super.viewDidLoad()
      adsDelegate = MiniAppAdDisplayer(with: self) // you must provide your ads displayer a MiniAppAdDisplayDelegate
    }

}

extension ViewController: MiniAppAdDisplayDelegate {
    func loadInterstitial(for adId: String, onLoaded: @escaping (Result<Void, Error>) -> Void) {
        // Here your code to load and prepare an interstitial ad
        let isLoaded = onInterstitiaLoaded()
        if isLoaded {
          onLoaded(.success(()))
        } else {
          onLoaded(.failure(NSError("Custom interstitial failed loading")))
        }
    }

    func showInterstitial(for adId: String, onClosed: @escaping (Result<Void, Error>) -> Void) {
      // Here your code to display an interstitial ad
      var interstitialController = getCustomInsterstialController(for: adId, onClosed: onClosed)
    }

    func loadRewarded(for adId: String, onLoaded: @escaping (Result<Void, Error>) -> Void) {
      // Here your code to load and prepare an ad 
      let isLoaded = onRewardedAdLoaded()
      if isLoaded {
        onLoaded(.success(()))
      } else {
        onLoaded(.failure(NSError("Custom rewarded ad failed loading")))
      }
    }

    func showRewarded(forId: String, onClosed: @escaping (MiniAppReward?) -> Void, onFailed: @escaping (Error) -> Void) {
      // Here your code to display your rewarded ad.
      // When the onClosed closure is called the user receives a reward you defined
      var interstitialController = getCustomRewrdedController(for: adId, onClosed: onClosed, reward: MiniAppReward(type: "star", amount: 100))
    }
}
```

Once the delegate implemented, don't forget to provide it when you call a Mini App creation with the parameter `adsDelegate`:

```swift
MiniApp.shared(with: Config.current())
            .create(appId: appInfo.id,
                    version: appInfo.version.versionId,
                    queryParams: getQueryParam(),
                    completionHandler: { (result) in
            // Some code to manage Mini App view creation callbacks
        }, messageInterface: self, adsDelegate: self)
```
<a id="retrieve-user-profile-details"></a>

#### Retrieve User Profile details
---
**API Docs:** [MiniAppUserInfoDelegate](https://rakutentech.github.io/ios-miniapp/Protocols/MiniAppUserInfoDelegate.html)

Get the User profile related details using 'MiniAppMessageDelegate'.
The following delegates/interfaces will be called only if the user has allowed respective [Custom permissions](#custom-permissions)

<a id="user-profile-details-username"></a>

###### User Name

Retrieve user name of the User

```swift
extension ViewController: MiniAppMessageDelegate {
    func getUserName(completionHandler: @escaping (Result<String, MASDKError>) -> Void) {
        // Implementation to return the User name
        completionHandler(.success(""))
    }
}
```

<a id="user-profile-details-profilephoto"></a>

###### Profile Photo

Retrieve Profile Photo of the User

```swift
extension ViewController: MiniAppMessageDelegate {
    func getProfilePhoto(completionHandler: @escaping (Result<String?, MASDKError>) -> Void) {
        // Implementation to return the Profile photo URI
        completionHandler(.success(""))
    }
}
```

<a id="user-profile-details-contactlist"></a>

###### Contact List

Retrieve the Contact list of the User

```swift
extension ViewController: MiniAppMessageDelegate {
    func getContacts(completionHandler: @escaping (Result<[MAContact]?, MASDKError>) -> Void) {
        // Implementation to return the contact list
        completionHandler(.success([]))
    }
}
```

<a id="access-token-info"></a>

###### Access Token Info

Retrieve access token and expiry date

```swift
extension ViewController: MiniAppMessageDelegate {
    func getAccessToken(miniAppId: String,
                        scopes: MASDKAccessTokenPermission?,
                        completionHandler: @escaping (Result<MATokenInfo, MASDKCustomPermissionError>) -> Void) {

        completionHandler(.success(.init(accessToken: "ACCESS_TOKEN", expirationDate: Date())))
    }
}
```
<a id="send-message-to-contacts"></a>

#### Send message to contacts
---
**API Docs:** [ChatMessageBridgeDelegate](https://rakutentech.github.io/ios-miniapp/Protocols/ChatMessageBridgeDelegate.html)

Send a message to a contact from the [user profile contacts list](#user-profile-details-contactlist) using 'MiniAppMessageDelegate' methods.
Three methods can be triggered by the Mini App, and here are the recommended behaviors for each one:

| |`sendMessageToContact(_:completionHandler:)`|`sendMessageToContactId(_:message:completionHandler:)`|`sendMessageToMultipleContacts(_:completionHandler:)`|
|---|---|---|---|
|**Triggered when**|Mini App wants to send a message to a contact.|Triggered when Mini App wants to send a message to a specific contact.|Triggered when Mini App wants to send a message to multiple contacts. |
| **Contact chooser needed** | single contact | None | multiple contacts |
| **Action** | send the message to the chosen contact | send a message to the specified contactId without any prompt to the User | send the message to all chosen contacts |
| **On success** | invoke completionHandler success with the ID of the contact which was sent the message. | invoke completionHandler success with the ID of the contact which was sent the message. | invoke completionHandler success with a list of IDs of the contacts which were successfully sent the message. |
| **On cancellation** | invoke completionHandler success with nil value. | invoke completionHandler success with nil value. | invoke completionHandler success with nil value. |
| **On error** | invoke completionHandler error when there was an error. | invoke completionHandler error when there was an error. | invoke completionHandler error when there was an error. |

Here is an example of integration:

```swift
extension ViewController: MiniAppMessageDelegate {
  public func sendMessageToContact(_ message: MessageToContact, completionHandler: @escaping (Result<String?, MASDKError>) -> Void) {
    presentContactsPicker { controller in
      controller.message = message
      controller.title = NSLocalizedString("Pick a contact", comment: "")
    }
  }

  public func sendMessageToContactId(_ contactId: String, message: MessageToContact, completionHandler: @escaping (Result<String?, MASDKError>) -> Void) {
    getContacts { result in
      switch result {
      case success(let contacts):
        if let contact = contacts.first(where: { $0.id == contactId }) {
          // insert here code to send the message
          completionHandler(.success(contact.id))
        } else {
          fallthrough
        }
      default:
        completionHandler(.failure(.invalidContactId))
      }
    }
  }

  public func sendMessageToMultipleContacts(_ message: MessageToContact, completionHandler: @escaping (Result<[String]?, MASDKError>) -> Void) {
    presentContactsPicker { chatContactsSelectorViewController in
      chatContactsSelectorViewController.contactsHandlerJob = completionHandler
      chatContactsSelectorViewController.message = message
      chatContactsSelectorViewController.multipleSelection = true
      chatContactsSelectorViewController.title = NSLocalizedString("Select contacts", comment: "")
    }
  }

  func presentContactsPicker(controllerPresented: (() -> Void)? = nil, contactsPickerCreated: (ChatContactsSelectorViewController) -> Void) {
    if let viewController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "ChatContactsSelectorViewController") as? ChatContactsSelectorViewController {
      UINavigationController.topViewController()?.present(UINavigationController(rootViewController: viewController), animated: true, completion: controllerPresented)
    }
  }
}
```

<a id="load-miniapp-list"></a>

### Load the `MiniApp` list:
---
**API Docs:** [MiniApp.list](https://rakutentech.github.io/ios-miniapp/Classes/MiniApp.html)

MiniApp library calls are done via the `MiniApp.shared()` singleton with or without a `MiniAppSdkConfig` instance (you can get the current one with `Config.current()`). If you don't provide a config instance, values in custom iOS target properties will be used by default. 

```swift
MiniApp.shared().list { (result) in
	...
}
```

or

```swift
MiniApp.shared(with: Config.current()).list { (result) in
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
MiniApp.shared(with: Config.current()).info(miniAppId: miniAppID) { (result) in
	...
}
```

<a id="mini-meta-data"></a>

### Mini App meta-data

<a id="get-mini-meta-data"></a>

#### Getting a `MiniApp meta-data` :
---

MiniApp developers can define several metadata into the `manifest.json`:
- `required` & `optional` permissions
- access token audience/scope permissions
- custom variables/items inside `customMetaData`.


Host app will use the defined interfaces to retrieve these details from manifest.json

```json
{
   "reqPermissions":[
      {
         "name":"rakuten.miniapp.user.USER_NAME",
         "reason":"Describe your reason here."
      },
      {
         "name":"rakuten.miniapp.user.PROFILE_PHOTO",
         "reason":"Describe your reason here."
      }
   ],
   "optPermissions":[
      {
         "name":"rakuten.miniapp.user.CONTACT_LIST",
         "reason":"Describe your reason here."
      },
      {
         "name":"rakuten.miniapp.device.LOCATION",
         "reason":"Describe your reason here."
      }
   ],
   "accessTokenPermissions":[
      {
          "audience":"rae",
          "scopes":["idinfo_read_openid", "memberinfo_read_point"]
      },
      {
          "audience":"api-c",
          "scopes":["your_service_scope_here"]
      }
   ],
   "customMetaData":{
      "hostAppRandomTestKey":"metadata value"
   }
}
```

Retrieve the meta-data of a MiniApp using the following method,

```swift
MiniApp.shared().getMiniAppManifest(miniAppId: miniAppId, miniAppVersion: miniAppVersionId) { (result) in
    switch result {
        case .success(let manifestData):
            // Retrieve the custom key/value pair like the following.
            let randomTestKeyValue = manifestData.customMetaData?["hostAppRandomTestKey"]
        case .failure:
          break
    }
	...
}
```

<a id="how-to-use-meta-data"></a>

#### How to use `MiniApp meta-data` :
---

SDK internally checks if the User has responded to the list of required/optional permissions that are enforced by the Mini App. So host app SHOULD make sure that the user is prompted with necessary custom permissions and get the response back from the user.

Before calling the `MiniApp.create`, host app should make sure the following things are done:

* Retrieve the meta-data for the Mini App using [getMiniAppManifest](#get-mini-meta-data)
* Display/Prompt the list of required & optional permissions to the user and the user response should be stored using [MiniApp.setCustomPermissions](#store-custom-permission)
* Call [MiniApp.create](#create-mini-app) to start downloading the Mini App


<a id="how-to-get-downloaded-meta-data"></a>
How to get downloaded `Mini App meta-data`

---
In Host App, we can get the downloaded manifest information as following:

```kotlin
  let downloadedManifest = MiniApp.shared().getDownloadedManifest(miniAppId:)
```

HostApp can compare the old `downloadedManifest` and the latest manifest by calling [MiniApp.shared().getMiniAppManifest](#get-mini-meta-data) to detect any new changes.


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

<a id="localization"></a>

#### Overriding localizations

Mini App SDK localization is based on [iOS framework localizable strings system](https://help.apple.com/xcode/mac/current/#/dev3255e0273).
In the following table, you can find all the keys that the SDK is using to translate its texts to your UI language.
Mini App SDK will look in the host app `Localizable.strings` for these keys to find local texts. If these keys are not present, a default text is provided.

|                     Localization key                      | Usage | Default text | Parameters |
|-----------------------------------------------------------|-------|:------------:|------------|
| `miniapp.sdk.ios.alert.title.ok`                              | alert dialogs validation button | OK | - |
| `miniapp.sdk.ios.alert.title.cancel`                          | alert dialogs cancellation button | Cancel | - |
| `miniapp.sdk.ios.ui.allow`                                    | permission screen authorization validation | Allow | - |
| `miniapp.sdk.all.ui.save`                                     | permission screen denial validation | Save | - |
| `miniapp.sdk.ios.firstlaunch.footer`                          | used at the bottom of the permissions validation screen | %@<sup>[1]</sup> wants to access the above permissions. Choose your preference accordingly.\n\n  You can also manage these permissions later in the Miniapp settings | <sup>[1]</sup> Mini App name |
| `miniapp.sdk.ios.error.message.server`                        | error reporting (decription) | Server returned an error. %@<sup>[1]</sup>: %@<sup>[2]</sup> | <sup>[1]</sup> Error code<br/><sup>[2]</sup> Error message|
| `miniapp.sdk.ios.error.message.invalid_url`                   | error reporting (decription) | URL is invalid. | - |
| `miniapp.sdk.ios.error.message.invalid_app_id`                | error reporting (decription) | Provided Mini App ID is invalid. | - |
| `miniapp.sdk.ios.error.message.invalid_version_id`            | error reporting (decription) | Provided Mini App Version ID is invalid. | - |
| `miniapp.sdk.ios.error.message.invalid_contact_id`            | error reporting (decription) | Provided contact ID is invalid. | - |
| `miniapp.sdk.ios.error.message.invalid_response`              | error reporting (decription) | Invalid response received from server. | - |
| `miniapp.sdk.ios.error.message.download_failed`               | error reporting (decription) | Failed to download the mini app. | - |
| `miniapp.sdk.ios.error.message.miniapp_meta_data_required_permisions_failure` | error reporting (decription) | Mini App has not been granted all of the required permissions. | - |
| `miniapp.sdk.ios.error.message.unknown`                       | error reporting (decription) | Unknown error occurred in %@<sup>[1]</sup> domain with error code %@<sup>[2]</sup>: %@<sup>[3]</sup> | <sup>[1]</sup> Error domain<br/><sup>[2]</sup> Error code<br/><sup>[3]</sup> Error message |
| `miniapp.sdk.ios.error.message.host_app`                      | error reporting (domain) | Host app Error | - |
| `miniapp.sdk.ios.error.message.failed_to_conform_to_protocol` | error reporting (decription) | Host app failed to implement required interface | - |
| `miniapp.sdk.ios.error.message.no_published_version`          | error reporting (decription) | Server returned no published versions for the provided Mini App ID. | - |
| `miniapp.sdk.ios.error.message.miniapp_id_not_found`          | error reporting (decription) | Server could not find the provided Mini App ID. | - |
| `miniapp.sdk.ios.error.message.unknown_server_error`          | error reporting (decription) | Unknown server error occurred | - |
| `miniapp.sdk.ios.error.message.ad_not_loaded`                 | error reporting (decription) | Ad %@<sup>[1]</sup> is not loaded yet | <sup>[1]</sup>Ad id |
| `miniapp.sdk.ios.error.message.ad_loading`                    | error reporting (decription) | Previous %@<sup>[1]</sup> is still in progress | <sup>[1]</sup>Ad id |
| `miniapp.sdk.ios.error.message.ad_loaded`                     | error reporting (decription) | Ad %@<sup>[1]</sup> is already loaded | <sup>[1]</sup>Ad id |

If you need to use one of this strings in your host application, you can use the convenience method `MASDKLocale.localize(_:_:)`

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

MiniApp.shared(with: Config.current(), navigationSettings: navConfig).info(miniAppId: miniAppID) { (result) in
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


You can choose to give orientation lock control to Mini Apps. However, this requires you to add some code to your `AppDelegate` which could have an affect on your entire App. If you do not wish to do this, please see the section *"Allow only full screen videos to change orientation".*

##### Allow Mini Apps to lock the view to any orientation
    
```swift
func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if window?.isKeyWindow != true {
            return .all
        }
        if MiniApp.MAOrientationLock.isEmpty {
            return .all
        } else {
            return MiniApp.MAOrientationLock
        }
    }
```

##### Allow full screen videos to change orientation

You can add the following if you want to enable videos to change orientation. Note that if you do not wish to add code to `AppDelegate` as in the above example, you can still allow videos inside the Mini App to use landscape mode even when your App is locked to portrait mode and vice versa.

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

<a id="analytics-events"></a>

#### Analytics events

MiniApp iOS SDK sends some notification to your app when some events are triggered by a MiniApp:

- When it is launched
- When it is closed

To catch this events and retrieve insight data, you simply have to register to the notification center like this:

```swift
NotificationCenter.default.addObserver(self, selector: #selector(yourMethod(_:)), name: MiniAppAnalytics.notificationName, object: nil)
```

```swift
@objc func yourMethod(_ notification:Notification) {
  if let payload = notification.object as? [String:String] {
    // do something with the data   
  }
}
```

Here is an example of data contained in payload:

```json
{
  "etype": "click",
  "actype": "mini_app_open",
  "cp": {
    "mini_app_project_id": "1234",
    "mini_app_id": "4321",
    "mini_app_version_id": "123456"
  }
}
```

<a id="query-param-mini-app"></a>

### Passing Query parameters while creating Mini App

While creating a Mini App, you can pass the optional query parameter as well. This query parameter will be appended to the Mini App's URL.

For eg.,

```swift
MiniApp.shared().create(appId: String, queryParams: "param1=value1&param2=value2", completionHandler: { (result) in
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

And the Mini App will be loaded like the following scheme,

```
mscheme.rakuten//miniapp/index.html?param1=value1&param2=value2
```

<a id="permissions-from-host-app"></a>

### Permissions required from the Host app

Mini App SDK requires the host app to include the following set of device permissions into its Info.plist file:

| Plist key | Permission | Reason |
|-----------|:----------:|--------|
| [NSLocationAlwaysAndWhenInUseUsageDescription](https://developer.apple.com/documentation/bundleresources/information_property_list/nslocationalwaysandwheninuseusagedescription) |  Location  | Mini app to track/get the current location of the user |
| [NSCameraUsageDescription](https://developer.apple.com/documentation/bundleresources/information_property_list/nscamerausagedescription)                                         |   Camera   | Camera permission required by Mini app to take pictures                              |
| [NSMicrophoneUsageDescription](https://developer.apple.com/documentation/bundleresources/information_property_list/nsmicrophoneusagedescription)                                 | Microphone | Microphone permission required by Mini app to record a video.                             |

<a id="faqs-and-troubleshooting"></a>

## FAQs and Troubleshooting

### How do I deep link to mini apps?

If you want to have deep links directly to your mini apps, then you must implement deep link handling within your App. This can be done using either a custom deep link scheme (such as `myAppName://miniapp`) or a [Universal Link](https://developer.apple.com/ios/universal-links/) (such as `https://www.example.com/miniapp`). See the following resources for more information on how to implement deep linking capabilities:

- [Allowing Apps and Websites to Link to Your Content](https://developer.apple.com/documentation/xcode/allowing_apps_and_websites_to_link_to_your_content)
- [Supporting Associated Domains](https://developer.apple.com/documentation/safariservices/supporting_associated_domains)

After you have implemented deep linking capabilities in your App, then you can configure your deep link to open and launch a Mini App. Note that your deep link should contain information about which mini app ID to open. Also, you can pass query parameters and a URL fragment to the mini app. The recommended deep link format is similar to `https://www.example.com/miniapp/MINI_APP_ID?myParam=myValue#myFragment` where the `myParam=myValue#myFragment` portion is optional and will be passed directly to the mini app. 

The following is an example which will parse the mini app ID and query string from a deep link:

```swift
// In your AppDelegate
func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
        let incomingURL = userActivity.webpageURL,
        let components = URLComponents(url: incomingURL, resolvingAgainstBaseURL: true) else {
        return false
    }

    return handleDeepLink(components: components)
}

func handleDeepLink(components: URLComponents) -> Bool
{
    guard let host = components.host, host == "example.com" {
        return false
    }

    let pathComponents = components.path.split("/")
    guard
        let rootPath = pathComponents.first
    else { return false }

    if (rootPath == "miniapp") {
        guard
            let id = pathComponents[1]
        else { return false }
        
        let query = components.query ?? ""
        let fragment = components.fragment ?? ""
        let queryString = query + "#" + fragment
        
        // Note that `myMiniAppCoordinator` is just a placeholder example for your own class
        // Inside this class you should call `MiniApp.create` in order to create and display the mini app
        myMiniAppCoordinator.goToMiniApp(miniAppId: id, query: queryString)

        return true
    }

    return false
}
```

### How do I clear the session data for Mini Apps?

In the case that a user logs out of your App, you should clear the session data for all of your Mini Apps. This will ensure that the next user does not have access to the stored sensitive information about the previous user such as Local Storage, IndexedDB, and Web SQL.

The session data can be cleared by using the following:

```swift
WKWebsiteDataStore.default().removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), 
    modifiedSince: Date.distantPast, completionHandler: {
    // Data removal complete
})
```

**Note:** This will also clear the storage, cookies, and authentication data for ALL `WkWebViews` used by your App.

<a id="change-log"></a>

## Changelog

See the full [CHANGELOG](https://github.com/rakutentech/ios-miniapp/blob/master/CHANGELOG.md).
