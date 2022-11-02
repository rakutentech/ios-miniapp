import UIKit
import MiniApp

class Config {

	enum Environment: String, CaseIterable {
		case production
		case staging

		var name: String {
			switch self {
			case .production:
				return "Production"
			case .staging:
				return "Staging"
			}
		}

		var suiteName: String {
			switch self {
			case .production:
				return "com.rakuten.tech.mobile.miniapp.MiniAppDemo.settings.prod"
			case .staging:
				return "com.rakuten.tech.mobile.miniapp.MiniAppDemo.settings.stg"
			}
		}
	}

	enum GlobalKey: String {
		case appId = "RASApplicationIdentifier"
		case version = "CFBundleShortVersionString"
		case signatureVerification = "RMARequireMiniAppSignatureVerification"
		case sslKeyHash = "RMASSLKeyHash"
		case endpoint = "RMAAPIEndpoint"
		case stagingEndpoint = "RMAAPIStagingEndpoint"
		case maxSecureStorageFileLimit = "MAMaxSecureStorageFileLimit"
	}

	enum ProjectKey: String {
		case isPreviewMode = "RMAIsPreviewMode"
		case environment = "RMAEnvironment"

		case projectId = "RASProjectId"
		case subscriptionKey = "RASProjectSubscriptionKey"
		case stagingProjectId = "RASStagingProjectId"
		case stagingSubscriptionKey = "RASStagingProjectSubscriptionKey"
	}

	enum FallbackKey: String {
		case isPreviewMode = "RMAIsPreviewMode"
		case environment = "RMAEnvironment"

		case projectId = "RASProjectId"
		case subscriptionKey = "RASProjectSubscriptionKey"
		case stagingProjectId = "RASStagingProjectId"
		case stagingSubscriptionKey = "RASStagingProjectSubscriptionKey"
	}

	// main bundle
	class func string(_ key: GlobalKey) -> String? {
		let userDefaults = UserDefaults.standard
		return userDefaults.string(forKey: key.rawValue)
	}

	class func bool(_ key: GlobalKey) -> Bool? {
		let userDefaults = UserDefaults.standard
		return userDefaults.value(forKey: key.rawValue) as? Bool
	}

	class func int(_ key: GlobalKey) -> Int? {
		let userDefaults = UserDefaults.standard
		return userDefaults.value(forKey: key.rawValue) as? Int
	}

	class func any(_ key: GlobalKey) -> Any? {
		let userDefaults = UserDefaults.standard
		return userDefaults.value(forKey: key.rawValue)
	}

	class func setInt(key: GlobalKey, value: Int) {
		let userDefaults = UserDefaults.standard
		userDefaults.set(value, forKey: key.rawValue)
		userDefaults.synchronize()
	}

	// lists

	class func string(_ list: ListType, key: ProjectKey, fallbackKey: FallbackKey? = nil) -> String? {
		let userDefaults = UserDefaults(suiteName: list.suiteName)
		if let withFallback = fallbackKey {
			return userDefaults?.string(forKey: key.rawValue) ?? getInfoString(string: withFallback.rawValue)
		} else {
			return userDefaults?.string(forKey: key.rawValue)
		}
	}

	class func setString(_ list: ListType, key: ProjectKey, value: String) {
		let userDefaults = UserDefaults(suiteName: list.suiteName)
		userDefaults?.set(value, forKey: key.rawValue)
		userDefaults?.synchronize()
	}

	class func bool(_ list: ListType, key: ProjectKey, fallbackKey: FallbackKey? = nil) -> Bool? {
		let userDefaults = UserDefaults(suiteName: list.suiteName)
		if let withFallback = fallbackKey {
			return userDefaults?.value(forKey: key.rawValue) as? Bool ?? getInfoBool(key: withFallback.rawValue)
		} else {
			return userDefaults?.value(forKey: key.rawValue) as? Bool
		}
	}

	class func setBool(_ list: ListType, key: ProjectKey, value: Bool) {
		let userDefaults = UserDefaults(suiteName: list.suiteName)
		userDefaults?.set(value, forKey: key.rawValue)
		userDefaults?.synchronize()
	}

	class func value(_ env: Environment, key: ProjectKey) -> Any? {
		let userDefaults = UserDefaults(suiteName: env.suiteName)
		return userDefaults?.value(forKey: key.rawValue)
	}

	class func exists(_ env: Environment, key: ProjectKey) -> Bool {
		let userDefaults = UserDefaults(suiteName: env.suiteName)
		return userDefaults?.value(forKey: key.rawValue) != nil
	}

	class func getInfoAny(_ key: GlobalKey) -> Any? {
		return Bundle.main.infoDictionary?[key.rawValue]
	}

	class func getInfoString(projectKey: ProjectKey) -> String? {
		return Bundle.main.infoDictionary?[projectKey.rawValue] as? String
	}

	class func getInfoString(key: GlobalKey) -> String? {
		return Bundle.main.infoDictionary?[key.rawValue] as? String
	}

	class func getInfoString(string: String) -> String? {
		return Bundle.main.infoDictionary?[string] as? String
	}

	class func getInfoBool(key: GlobalKey) -> Bool? {
		return Bundle.main.infoDictionary?[key.rawValue] as? Bool
	}

	class func getInfoBool(key: String) -> Bool? {
		return Bundle.main.infoDictionary?[key] as? Bool
	}

	class func sampleSdkConfig() -> MiniAppSdkConfig {
		return MiniAppSdkConfig(baseUrl: "https://rakuten.co.jp", rasProjectId: "test-project-id", subscriptionKey: "test-sub-key")
	}
}
