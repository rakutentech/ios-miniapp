struct MiniAppJavaScriptMessageInfo: Decodable {
    let action: String
    let id: String
    let param: RequestParameters?
}

struct RequestParameters: Decodable {
    let permission: [String]?
    let locationOptions: LocationOptions?
}

struct LocationOptions: Decodable {
    let enableHighAccuracy: Bool?
}
