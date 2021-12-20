/// Host app configurable analytics details
public struct MAAnalyticsConfig: Codable, Equatable {
    public let acc: String
    public let aid: String

    public init(acc: String, aid: String) {
        self.acc = acc
        self.aid = aid
    }
}
