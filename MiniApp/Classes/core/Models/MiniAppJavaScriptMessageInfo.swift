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
}

struct LocationOptions: Decodable {
    let enableHighAccuracy: Bool?
}

struct ShareInfoParameters: Decodable {
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
    let name, status: String
}
