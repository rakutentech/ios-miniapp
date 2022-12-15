struct MiniAppJavaScriptMessageInfo: Decodable {
    let action: String
    let id: String
    let param: RequestParameters?
}

struct RequestParameters: Decodable {
    let action: String?
    let permission: String?
    let permissions: [MiniAppCustomPermissionsRequest]?
    let locationOptions: LocationOptions?
    let shareInfo: ShareInfoParameters?
    let adType: Int?
    let adUnitId: String?
    let audience: String?
    let scopes: [String]?
    let messageToContact: MessageToContact?
    let contactId: String?
    let filename: String?
    let url: String?
    let headers: DownloadHeaders?
    let secureStorageKey: String?
    let secureStorageItems: [String: String]?
    let secureStorageKeyList: [String]?
    let closeAlertInfo: CloseAlertInfo?
    let jsonInfo: JsonStringInfoParameters?
}

struct LocationOptions: Decodable {
    let enableHighAccuracy: Bool?
}

struct ShareInfoParameters: Decodable {
    var content: String
}

struct JsonStringInfoParameters: Codable {
    var content: String
}

struct MiniAppCustomPermissionsRequest: Decodable {
    let name: String?
    let description: String?
}

struct MiniAppCustomPermissionsResponse: Codable {
    let permissions: [MiniAppCustomPermissionsListResponse]
}

struct MiniAppCustomPermissionsListResponse: Codable {
    let name: String
    let status: String
}

public struct CloseAlertInfo: Codable {
    public let shouldDisplay: Bool?
    public let title: String?
    public let description: String?
}
