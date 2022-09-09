import Foundation
import SwiftUI

extension MiniAppSettingsView {

    struct SettingsConfig: Hashable {
        var previewMode: PreviewMode =
        (Config.getUserDefaultsBool(key: .isPreviewMode) ?? true) ? .previewable : .published
        // var previewMode: PreviewMode = (Bundle.main.infoDictionary?[Config.Key.isPreviewMode.rawValue] as? Bool) ?? true ? .previewable : .published
        var environmentMode: EnvironmentMode = Config.isProd ? .production : .staging

        var listIProjectIdPlaceholder: String = Config.getInfoPlistString(key: .projectId) ?? ""
        var listISubscriptionKeyPlaceholder: String = Config.getInfoPlistString(key: .subscriptionKey) ?? ""

        // list 1
        var listIProjectId: String = Config.string(.production, key: .projectId, withFallback: true) ?? ""
        var listISubscriptionKey: String = Config.string(.production, key: .subscriptionKey, withFallback: true) ?? ""

        var listIStagingProjectId: String = Config.string(.staging, key: .projectId, withFallback: true) ?? ""
        var listIStagingSubscriptionKey: String = Config.string(.staging, key: .subscriptionKey, withFallback: true) ?? ""

        // list 2
        var listIIProjectId: String = Config.string(.production, key: .projectIdList2, withFallback: true) ?? ""
        var listIISubscriptionKey: String = Config.string(.production, key: .subscriptionKeyList2, withFallback: true) ?? ""

        var listIIStagingProjectId: String = Config.string(.staging, key: .projectIdList2, withFallback: true) ?? ""
        var listIIStagingSubscriptionKey: String = Config.string(.staging, key: .subscriptionKeyList2, withFallback: true) ?? ""

        var queryParameters: String = ""

        var secureStorageLimit: String = ""

        init() {
            // secureStorageLimit = viewModel.store.getSecureStorageLimitString()
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

    enum EnvironmentMode: CaseIterable {
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
        case qa
        case profile
        case contacts
        case accessToken
        case points
        case signature

        var name: String {
            switch self {
            case .general:
                return "General"
            case .qa:
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
            case .qa:
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
