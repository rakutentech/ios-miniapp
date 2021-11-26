import Foundation
import MiniApp
import RAnalytics

internal class RATNotificationCenter {
    static func sendAnalytics(eventType: DemoAppRATEventType,
                              actionType: DemoAppRATActionType,
                              pageName: String,
                              siteSection: String,
                              targetElement: String,
                              parameters customData: [(String, String)]? = nil) {
        RAnalyticsRATTracker.shared().event(withEventType: eventType.rawValue,
                                            parameters: ["etype": eventType.rawValue,
                                                         "actype": actionType.rawValue,
                                                         "pgn": pageName,
                                                         "target_ele": targetElement,
                                                         "ssc": siteSection]).track()
    }
}
