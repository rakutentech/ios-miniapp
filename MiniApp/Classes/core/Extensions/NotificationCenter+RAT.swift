internal extension NotificationCenter {

    func sendAnalytics(event: MiniAppRATEvent, type: MiniAppRATEventType? = nil, parameters customData: [(String, String)]? = nil, analyticsConfig: [MAAnalyticsConfig] = [MiniAppAnalytics.defaultRATAcc]) {
        var parameters = [String: Codable]()
        var topLevel = [String: String]()

        var configs = analyticsConfig
        if !configs.contains(MiniAppAnalytics.defaultRATAcc) {
            configs.append(MiniAppAnalytics.defaultRATAcc)
        }

        for configItem in configs {
            topLevel["acc"] = configItem.acc
            topLevel["aid"] = configItem.aid
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
}
