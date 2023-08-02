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
    public let eventType: MAAnalyticsEventType
    public let actionType: MAAnalyticsActionType
    public let pageName: String
    public let componentName: String
    public let elementType: String
    public let data: String

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
