import Foundation
import SwiftUI
import MiniApp

extension MiniAppSettingsView {

    struct SettingsConfig: Hashable {

        var previewMode: PreviewMode = (Config.bool(.isPreviewMode, fallback: .isPreviewMode) ?? true) ? .previewable : .published
        var environmentMode: Config.Env = (Config.bool(.environment) ?? true) ? .production : .staging

        // list 1 placeholders
        var listIProjectIdPlaceholder: String = Config.getInfoPlistString(key: .projectId) ?? ""
        var listISubscriptionKeyPlaceholder: String = Config.getInfoPlistString(key: .subscriptionKey) ?? ""

        // list 1 prod
        var listIProjectId: String = Config.string(.production, key: .projectId, withFallback: true) ?? ""
        var listISubscriptionKey: String = Config.string(.production, key: .subscriptionKey, withFallback: true) ?? ""
        // list 1 stg
        var listIStagingProjectId: String = Config.string(.staging, key: .projectId, fallbackKey: .stagingProjectId) ?? ""
        var listIStagingSubscriptionKey: String = Config.string(.staging, key: .subscriptionKey, fallbackKey: .stagingSubscriptionKey) ?? ""

        // list 2 prod
        var listIIProjectId: String = Config.string(.production, key: .projectIdList2, withFallback: true) ?? ""
        var listIISubscriptionKey: String = Config.string(.production, key: .subscriptionKeyList2, withFallback: true) ?? ""
        // list 2 stg
        var listIIStagingProjectId: String = Config.string(.staging, key: .projectIdList2, withFallback: false) ?? ""
        var listIIStagingSubscriptionKey: String = Config.string(.staging, key: .subscriptionKeyList2, withFallback: false) ?? ""

        init() {
            // init
        }

        func sdkConfig(list: ListConfig) -> MiniAppSdkConfig {
            return MiniAppSdkConfig(
                baseUrl: baseUrl,
                rasProjectId: projectId(list: list),
                subscriptionKey: subscriptionKey(list: list),
                hostAppVersion: hostAppVersion,
                isPreviewMode: previewMode == .previewable,
                analyticsConfigList: analyticsConfig,
                requireMiniAppSignatureVerification: requiresSignatureVerification,
                sslKeyHash: sslKey(enabled: false),
                storageMaxSizeInBytes: storageMaxSizeInBytes > 0 ? UInt64(storageMaxSizeInBytes) : nil
            )
        }

        var baseUrl: String? {
            environmentMode == .production ? Config.getInfoString(key: .endpoint) : Config.getInfoString(key: .stagingEndpoint)
        }

        func projectId(list: ListConfig) -> String? {
            switch list {
            case .listI:
                return environmentMode == .production ? listIProjectId : listIStagingProjectId
            case .listII:
                return environmentMode == .production ? listIIProjectId : listIIStagingProjectId
            }
        }

        func subscriptionKey(list: ListConfig) -> String? {
            switch list {
            case .listI:
                return environmentMode == .production ? listISubscriptionKey : listIStagingSubscriptionKey
            case .listII:
                return environmentMode == .production ? listIISubscriptionKey : listIIStagingSubscriptionKey
            }
        }

        var hostAppVersion: String? {
            Config.string(.version)
        }

        var requiresSignatureVerification: Bool? {
            Config.userDefaults?.value(forKey: Config.Key.requireMiniAppSignatureVerification.rawValue) as? Bool
        }

        func sslKey(enabled: Bool) -> MiniAppConfigSSLKeyHash? {
            var pinConf: MiniAppConfigSSLKeyHash?
            if enabled, let keyHash = (Bundle.main.object(forInfoDictionaryKey: "RMASSLKeyHash") as? [String: Any?])?["main"] as? String {
                pinConf = MiniAppConfigSSLKeyHash(pin: keyHash, backup: (Bundle.main.object(forInfoDictionaryKey: "RMASSLKeyHash") as? [String: Any?])?["backup"] as? String)
            }
            return pinConf
        }

        var analyticsConfig: [MAAnalyticsConfig]? {
            [MAAnalyticsConfig(acc: "477", aid: "998")]
        }

        var storageMaxSizeInBytes: Int {
            UserDefaults.standard.integer(forKey: Config.LocalKey.maxSecureStorageFileLimit.rawValue)
        }
    }

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

    enum ListConfig: CaseIterable {
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
    }

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
