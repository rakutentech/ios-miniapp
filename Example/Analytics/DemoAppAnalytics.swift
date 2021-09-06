import Foundation
import MiniApp

internal enum DemoAppRATEventType: String, CaseIterable {
    case appear = "appear"
    case click = "click"
    case pageLoad = "pv"
}

internal enum DemoAppRATActionType: String, CaseIterable {
    case open
    case close
    case changeStatus
    case initial
}

internal enum DemoAppAnalyticsParameter: String, CaseIterable {
    case projectId = "project_id"
    case miniAppId = "id"
    case versionId = "version_id"
    case sdkVersion = "sdk_version"

    func name() -> String {
        return "mini_app_\(rawValue)"
    }
}

public class DemoAppAnalytics {
    public static let notificationName = Notification.Name("com.rakuten.esd.sdk.events.custom")
    open class var sdkVersion: String? {
        Bundle.miniAppBundle?.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    internal static let defaultRATAcc = MAAnalyticsConfig(acc: String(Bundle.main.infoDictionary?["RATAccountIdentifier"] as? Int ?? 0) ,
                                                          aid: String(Bundle.main.infoDictionary?["RATAppIdentifier"] as? Int ?? 0) )

    internal class func getAnalyticsInfo() -> [(String, String)] {
        var result = [(String, String)]()
        if let projectId = Config.userDefaults?.string(forKey: Config.Key.projectId.rawValue) {
            result.append((DemoAppAnalyticsParameter.projectId.name(), projectId))
        }
        if let version = sdkVersion {
            result.append((DemoAppAnalyticsParameter.sdkVersion.name(), version))
        }
        return result
    }

    internal class func sendAnalytics(eventType: DemoAppRATEventType? = .click,
                                      actionType: DemoAppRATActionType? = .open,
                                      pageName: String? = "",
                                      siteSection: String? = "",
                                      componentName: String? = "",
                                      elementType: String? = "",
                                      customParameters: (String, String)...) {
        let params = getAnalyticsInfo() + customParameters
        NotificationCenter.default.sendAnalytics(eventType: eventType ?? .click,
                                                 actionType: actionType ?? .open,
                                                 pageName: pageName ?? "",
                                                 siteSection: siteSection ?? "",
                                                 targetElement: getTargetElementString(component: componentName ?? "", element: elementType ?? "", action: actionType ?? .initial),
                                                 parameters: params)
    }

    internal class func getTargetElementString(component: String, element: String, action: DemoAppRATActionType) -> String {
        return component + "-" + element + "." + action.rawValue
    }
}
