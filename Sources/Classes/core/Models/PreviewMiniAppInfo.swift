import Foundation

/// Model for Preview Mini app Info
public struct PreviewMiniAppInfo: Codable {
    /// Mini app Info object
    public var miniapp: MiniAppInfo
    /// Host info object that contains Project ID and Key details
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
