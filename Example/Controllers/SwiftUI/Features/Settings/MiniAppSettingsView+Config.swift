import Foundation
import SwiftUI
import MiniApp

enum PreviewMode: CaseIterable {
	case previewable
	case published

	var name: String {
		switch self {
		case .previewable:
			return "Previewable"
		case .published:
			return "Published"
		}
	}
}

enum ListType: CaseIterable {
	case listI
	case listII

	var name: String {
		switch self {
		case .listI:
			return "List I"
		case .listII:
			return "List II"
		}
	}

	var suiteName: String {
		switch self {
		case .listI:
			return "com.rakuten.tech.mobile.miniapp.MiniAppDemo.settings.list.i"
		case .listII:
			return "com.rakuten.tech.mobile.miniapp.MiniAppDemo.settings.list.ii"
		}
	}
}

protocol ListConfigurable: Hashable {
	var listType: ListType { get set }
	var previewMode: PreviewMode { get set }
	var environmentMode: NewConfig.Environment { get set }
	var projectId: String? { get set }
	var subscriptionKey: String? { get set }
	var placeholderProjectId: String { get set }
	var placeholderSubscriptionKey: String { get set }
}

struct ListConfiguration {

	var listType: ListType
	var previewMode: PreviewMode
	var environmentMode: NewConfig.Environment

	var projectIdProd: String
	var subscriptionKeyProd: String
	var projectIdStaging: String
	var subscriptionKeyStaging: String

	var error: Error?

	init(listType: ListType) {
		self.listType 					= listType
		self.previewMode 				= (NewConfig.bool(listType, key: .isPreviewMode, fallbackKey: .isPreviewMode) ?? true) ? .previewable : .published
		self.environmentMode 			= (NewConfig.bool(listType, key: .environment, fallbackKey: .environment) ?? true) ? .production : .staging
		self.projectIdProd 				= NewConfig.string(listType, key: .projectId, fallbackKey: .projectId) ?? ""
		self.subscriptionKeyProd 		= NewConfig.string(listType, key: .subscriptionKey, fallbackKey: .subscriptionKey) ?? ""
		self.projectIdStaging 			= NewConfig.string(listType, key: .stagingProjectId, fallbackKey: .stagingProjectId) ?? ""
		self.subscriptionKeyStaging 	= NewConfig.string(listType, key: .stagingSubscriptionKey, fallbackKey: .stagingSubscriptionKey) ?? ""
	}

	var baseUrl: String? {
		environmentMode == .production ? NewConfig.getInfoString(key: .endpoint) : NewConfig.getInfoString(key: .stagingEndpoint)
	}

	var projectId: String? {
		get {
			return environmentMode == .production ? projectIdProd : projectIdStaging
		}
		set {
			switch environmentMode {
			case .production:
				projectIdProd = newValue ?? ""
			case .staging:
				projectIdStaging = newValue ?? ""
			}
		}
	}

	var wrappedProjectId: String {
		switch environmentMode {
		case .production:
			return projectIdProd.isEmpty ? placeholderProjectId : projectIdProd
		case .staging:
			return projectIdStaging.isEmpty ? placeholderProjectId : projectIdStaging
		}
	}

	var subscriptionKey: String? {
		get {
			return environmentMode == .production ? subscriptionKeyProd : subscriptionKeyStaging
		}
		set {
			switch environmentMode {
			case .production:
				subscriptionKeyProd = newValue ?? ""
			case .staging:
				subscriptionKeyStaging = newValue ?? ""
			}
		}
	}

	var wrappedSubscriptionKey: String {
		switch environmentMode {
		case .production:
			return subscriptionKeyProd.isEmpty ? placeholderSubscriptionKey : subscriptionKeyProd
		case .staging:
			return subscriptionKeyProd.isEmpty ? placeholderSubscriptionKey : subscriptionKeyStaging
		}
	}

	var placeholderProjectId: String {
		switch environmentMode {
		case .production:
			return NewConfig.getInfoString(projectKey: .projectId) ?? ""
		case .staging:
			return NewConfig.getInfoString(projectKey: .stagingProjectId) ?? ""
		}
	}

	var placeholderSubscriptionKey: String {
		switch environmentMode {
		case .production:
			return NewConfig.getInfoString(projectKey: .subscriptionKey) ?? ""
		case .staging:
			return NewConfig.getInfoString(projectKey: .stagingSubscriptionKey) ?? ""
		}
	}

	var hostAppVersion: String? {
		NewConfig.string(.version)
	}

	var requiresSignatureVerification: Bool? {
		NewConfig.bool(.signatureVerification)
	}

	func sslKey(enabled: Bool) -> MiniAppConfigSSLKeyHash? {
		var pinConf: MiniAppConfigSSLKeyHash?
		let sslKeyHash = NewConfig.getInfoAny(.sslKeyHash)
		if enabled, let keyHash = (sslKeyHash as? [String: Any?])?["main"] as? String {
			pinConf = MiniAppConfigSSLKeyHash(pin: keyHash, backup: (sslKeyHash as? [String: Any?])?["backup"] as? String)
		}
		return pinConf
	}

	var analyticsConfig: [MAAnalyticsConfig]? {
		[MAAnalyticsConfig(acc: "477", aid: "998")]
	}

	var storageMaxSizeInBytes: Int {
		NewConfig.int(.maxSecureStorageFileLimit) ?? 5_000_000
	}

	var sdkConfig: MiniAppSdkConfig {
		return MiniAppSdkConfig(
			baseUrl: baseUrl,
			rasProjectId: projectId,
			subscriptionKey: subscriptionKey,
			hostAppVersion: hostAppVersion,
			isPreviewMode: previewMode == .previewable,
			analyticsConfigList: analyticsConfig,
			requireMiniAppSignatureVerification: requiresSignatureVerification,
			sslKeyHash: sslKey(enabled: false),
			storageMaxSizeInBytes: storageMaxSizeInBytes > 0 ? UInt64(storageMaxSizeInBytes) : nil
		)
	}

	func persist() {
		NewConfig.setBool(listType, key: .isPreviewMode, value: previewMode == .previewable)
		NewConfig.setBool(listType, key: .environment, value: environmentMode == .production)
		NewConfig.setString(listType, key: .projectId, value: projectIdProd)
		NewConfig.setString(listType, key: .subscriptionKey, value: subscriptionKeyProd)
		NewConfig.setString(listType, key: .stagingProjectId, value: projectIdStaging)
		NewConfig.setString(listType, key: .stagingSubscriptionKey, value: subscriptionKeyStaging)
	}

	static func current(type: ListType) -> MiniAppSdkConfig {
		let config = ListConfiguration(listType: type)
		return config.sdkConfig
	}
}

extension MiniAppSettingsView {
    enum MenuItem: CaseIterable {
        case general
        case qaSecureStorage
        case profile
        case contacts
        case accessToken
        case points
        case signature

        var name: String {
            switch self {
            case .general:
                return "General"
            case .qaSecureStorage:
                return "QA"
            case .profile:
                return "Profile"
            case .contacts:
                return "Contacts"
            case .accessToken:
                return "Access Token"
            case .points:
                return "Points"
            case .signature:
                return "Signature"
            }
        }

        var icon: Image {
            switch self {
            case .general:
                return Image(systemName: "gear")
            case .qaSecureStorage:
                return Image(systemName: "person.2")
            case .profile:
                return Image(systemName: "person.crop.circle.fill")
            case .contacts:
                return Image(systemName: "person.3.fill")
            case .accessToken:
                return Image(systemName: "checkerboard.shield")
            case .points:
                return Image(systemName: "p.circle")
            case .signature:
                return Image(systemName: "lock.fill")
            }
        }
    }
}
