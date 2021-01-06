internal extension NotificationCenter {
    func sendAnalytics(event: MiniAppRATEvent, type: MiniAppRATEventType = .custom, parameters customData: (String, String)...) {
        sendAnalytics(event: event, type: type, parameters: customData)
    }

    func sendAnalytics(event: MiniAppRATEvent, type: MiniAppRATEventType = .custom, parameters customData: [(String, String)]? = nil) {
        //@{@"eventName":@"blah",@"eventData":@{@"foo":@"bar"}};
        var parameters = [String: Codable]()
        parameters["acc"] = MiniAppAnalytics.acc
        parameters["aid"] = MiniAppAnalytics.aid
        parameters["actype"] = event.name()
        parameters["etype"] = type.rawValue
        parameters["eventData"] = customData?.reduce([String: String]()) { (eventData, param) in
            var mutableEventData = eventData
            mutableEventData.updateValue(param.1, forKey: param.0)
            return mutableEventData
        }
        self.post(name: MiniAppAnalytics.notificationName, object: parameters)
    }
}
