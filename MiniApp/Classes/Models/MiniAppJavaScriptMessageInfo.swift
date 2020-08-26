struct MiniAppJavaScriptMessageInfo: Decodable {
    let action: String
    let id: String
    let param: RequestParameters?
}

struct RequestParameters: Decodable {
    let permission: String?
    let customPermissions: [MiniAppCustomPermissionsRequest]?
    let locationOptions: LocationOptions?
}

struct LocationOptions: Decodable {
    let enableHighAccuracy: Bool?
}

struct MiniAppCustomPermissionsRequest: Decodable {
    let name: String?
    let description: String?
}

struct MiniAppCustomPermissionsResponse: Codable {
    let permissions: [MiniAppCustomPermissionsListResponse]
}

struct MiniAppCustomPermissionsListResponse: Codable {
    let name, isGranted: String
}
