/// Host app configurable analytics details
public struct MAAnalyticsConfig: Codable, Equatable {
    let acc: String
    let aid: String

    public init(acc: String, aid: String) {
        self.acc = acc
        self.aid = aid
    }
}
