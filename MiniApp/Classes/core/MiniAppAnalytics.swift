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
        return "mini_app_\(rawValue)"
    }
}

// Swift doesn't have load-time initialization so we need
// this proxy class that is called by LoaderObjC's `load`
// method.
public class MiniAppAnalyticsLoader: NSObject {
    @objc public static func loadMiniAppAnalytics() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            MiniAppAnalytics.sendAnalytics(event: .hostLaunch)
        }
    }
}

public class MiniAppAnalytics {
    public static let notificationName = Notification.Name("com.rakuten.esd.sdk.events.custom")
    internal static let defaultRATAcc = MAAnalyticsConfig(acc: "1553", aid: "1")

    internal class func getAnalyticsInfo(miniAppId: String? = nil, miniAppVersion: String? = nil, projectId: String? = nil) -> [(String, String)] {
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

    internal class func getAnalyticsConfigList(analyticsConfig: [MAAnalyticsConfig]? = []) -> [MAAnalyticsConfig] {
        var analyticsConfigList: [MAAnalyticsConfig] = []
        analyticsConfigList.append(defaultRATAcc)
        guard let configList = analyticsConfig else {
            return analyticsConfigList
        }
        analyticsConfigList.append(contentsOf: configList)
        return analyticsConfigList
    }

    internal class func sendAnalytics(event: MiniAppRATEvent, miniAppId: String? = nil, miniAppVersion: String? = nil, projectId: String? = nil, customParameters: (String, String)..., analyticsConfig: [MAAnalyticsConfig]? = []) {
        let params = getAnalyticsInfo(miniAppId: miniAppId, miniAppVersion: miniAppVersion, projectId: projectId) + customParameters
        MiniAppLogger.d("posting \(event.name()) analytic \(event.eType()) event with params:\n\(params)", "📡")
        NotificationCenter.default.sendAnalytics(event: event, parameters: params, analyticsConfig: getAnalyticsConfigList(analyticsConfig: analyticsConfig))
    }
}
