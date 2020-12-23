internal enum RATEventType: String {
    case appear
    case click
    case custom
}

internal enum RATEvent: String {
    case mini_app_host_launch
    case mini_app_open
    case mini_app_close
}

internal extension NotificationCenter {
    func sendAnalytics(event name: RATEvent, type: RATEventType? = nil, parameters customData: (String,String)...) {
        sendAnalytics(event: name, type: type, parameters: customData)
    }
    
    func sendAnalytics(event name: RATEvent, type: RATEventType? = nil, parameters customData: [(String,String)]? = nil) {
        var parameters = [String: Codable]()
        parameters["eventName"] = name.rawValue
        parameters["eventData"] = customData?.reduce([String:String]()) { (eventData, param) in
                var mutableEventData = eventData
                mutableEventData.updateValue(param.1, forKey: param.0)
                return mutableEventData
            }
        self.post(name: Notification.Name("com.rakuten.esd.sdk.events.\((type ?? .custom).rawValue)"), object: parameters)
    }
}
