import Foundation

public struct PreviewMiniAppInfo: Codable {
    public var miniapp: MiniAppInfo
    public var host: Host?
}

/// Host keys information
public struct Host: Codable {
    /// Host app ID of the project
    public var id: String?
    /// Subscription key of the project
    public var subscriptionkey: String?

    private enum CodingKeys: String, CodingKey {
        case id,
             subscriptionkey
    }
}
