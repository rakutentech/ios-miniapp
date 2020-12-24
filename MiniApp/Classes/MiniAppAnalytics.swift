import Foundation

internal enum MiniAppRATEventType: String, CaseIterable {
    case appear
    case click
    case custom
}

internal enum MiniAppRATEvent: String, CaseIterable {
    case hostLaunch = "host_launch"
    case open
    case close

    func name() -> String {
        return "mini_app_\(rawValue)"
    }

    func eType() -> MiniAppRATEventType {
        switch self {
        case .hostLaunch:
            return .appear
        case .open, .close:
            return .click
        }
    }
}

internal enum MiniAppAnalyticsParameter: String, CaseIterable {
    case projectId = "project_id"
    case miniAppId = "id"
    case versionId = "version_id"
    case sdkVersion = "sdk_version"

    func name() -> String {
        return "cp.mini_app_\(rawValue)"
    }
}

internal class MiniAppAnalytics {
    class func notification(type: MiniAppRATEventType) -> Notification.Name {
        return Notification.Name("com.rakuten.esd.sdk.events.\(type.rawValue)")
    }

    class func getAnalyticsInfo(miniAppId: String? = nil, miniAppVersion: String? = nil, projectId: String? = nil) -> [(String, String)] {
        var result = [(String, String)]()
        if let miniAppId = miniAppId {
            result.append((MiniAppAnalyticsParameter.miniAppId.name(), miniAppId))
        }
        if let version = miniAppVersion {
            result.append((MiniAppAnalyticsParameter.versionId.name(), version))
        }
        if let projectId = projectId ?? Bundle.main.value(for: Environment.Key.projectId.rawValue) {
            result.append((MiniAppAnalyticsParameter.projectId.name(), projectId))
        }
        if let version = Bundle(identifier: "org.cocoapods.MiniApp")?.infoDictionary?["CFBundleShortVersionString"] as? String {
            result.append((MiniAppAnalyticsParameter.sdkVersion.name(), version))
        }
        return result
    }

    class func sendAnalytics(event: MiniAppRATEvent, miniAppId: String? = nil, miniAppVersion: String? = nil, projectId: String? = nil, customParameters: (String, String)...) {
        let params = getAnalyticsInfo(miniAppId: miniAppId, miniAppVersion: miniAppVersion, projectId: projectId) + customParameters
        MiniAppLogger.d("posting \(event.name()) analytic \(event.eType()) event with params:\n\(params)", "📡")
        NotificationCenter.default.sendAnalytics(event: event, parameters: params)
    }
}
