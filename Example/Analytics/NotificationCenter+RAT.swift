import Foundation
import MiniApp
internal extension NotificationCenter {

    func sendAnalytics(eventType: DemoAppRATEventType,
                       actionType: DemoAppRATActionType,
                       pageName: String, siteSection: String,
                       targetElement: String,
                       parameters customData: [(String, String)]? = nil) {
        var parameters = [String: Codable]()
        var topLevel = [String: String]()

        topLevel["acc"] = DemoAppAnalytics.defaultRATAcc.acc
        topLevel["aid"] = DemoAppAnalytics.defaultRATAcc.aid
        topLevel["etype"] = eventType.rawValue
        topLevel["ssc"] = siteSection
        topLevel["pgn"] = "miniapp_" + pageName
        topLevel["target_ele"] = targetElement

        parameters["topLevelObject"] = topLevel
        parameters["eventData"] = customData?.reduce([String: String]()) { (eventData, param) in
            var mutableEventData = eventData
            mutableEventData.updateValue(param.1, forKey: param.0)
            return mutableEventData
        }
        self.post(name: MiniAppAnalytics.notificationName, object: parameters)
    }
}
