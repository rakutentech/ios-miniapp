struct MiniAppJavaScriptMessageInfo: Decodable {
    let action: String
    let id: String
    let param: RequestParameters?
}

struct RequestParameters: Decodable {
    let permission: String?
    let customPermissions: [CustomPermissions]?
    let locationOptions: LocationOptions?
}

struct LocationOptions: Decodable {
    let enableHighAccuracy: Bool?
}

struct CustomPermissions: Decodable {
    let name: String?
    let description: String?
}
