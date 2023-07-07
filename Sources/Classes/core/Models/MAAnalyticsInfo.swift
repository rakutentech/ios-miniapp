import Foundation

public enum MAAnalyticsEventType: String, Codable {
    case appear
    case click
    case error
    case custom
}

public enum MAAnalyticsActionType: String, Codable {
    case open
    case close
    case add
    case delete
    case change
}

public class MAAnalyticsInfo: Codable {
    let eventType: MAAnalyticsEventType
    let actionType: MAAnalyticsActionType
    let pageName: String
    let componentName: String
    let elementType: String
    let data: String

    public init(eventType: MAAnalyticsEventType,
                actionType: MAAnalyticsActionType,
                pageName: String,
                componentName: String,
                elementType: String,
                data: String) {
        self.eventType = eventType
        self.actionType = actionType
        self.pageName = pageName
        self.componentName = componentName
        self.elementType = elementType
        self.data = data
    }
}
