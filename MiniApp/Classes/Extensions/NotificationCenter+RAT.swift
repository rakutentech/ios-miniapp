internal extension NotificationCenter {
    func sendAnalytics(event: MiniAppRATEvent, type: MiniAppRATEventType? = nil, parameters customData: (String, String)...) {
        sendAnalytics(event: event, type: type, parameters: customData)
    }

    func sendAnalytics(event: MiniAppRATEvent, type: MiniAppRATEventType? = nil, parameters customData: [(String, String)]? = nil) {
        var parameters = [String: Codable]()
        parameters["eventName"] = event.name()
        parameters["eventData"] = customData?.reduce([String: String]()) { (eventData, param) in
            var mutableEventData = eventData
            mutableEventData.updateValue(param.1, forKey: param.0)
            return mutableEventData
        }
        self.post(name: MiniAppAnalytics.notification(type: type ?? event.eType()), object: parameters)
    }
}
