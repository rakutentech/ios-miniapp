internal extension NotificationCenter {
    func sendAnalytics(event: MiniAppRATEvent, type: MiniAppRATEventType? = nil, parameters customData: (String, String)...) {
        sendAnalytics(event: event, type: type, parameters: customData)
    }

    func sendAnalytics(event: MiniAppRATEvent, type: MiniAppRATEventType? = nil, parameters customData: [(String, String)]? = nil, miniAppSDKConfig: MiniAppSdkConfig? = nil) {
        var parameters = [String: Codable]()
        var topLevel = [String: String]()

        topLevel["acc"] = MiniAppAnalytics.acc
        topLevel["aid"] = MiniAppAnalytics.aid
        topLevel["actype"] = event.name()

        parameters["topLevelObject"] = topLevel
        parameters["eventName"] = (type ?? event.eType()).rawValue
        parameters["eventData"] = customData?.reduce([String: String]()) { (eventData, param) in
            var mutableEventData = eventData
            mutableEventData.updateValue(param.1, forKey: param.0)
            return mutableEventData
        }
        self.post(name: MiniAppAnalytics.notificationName, object: parameters)
    }
}
