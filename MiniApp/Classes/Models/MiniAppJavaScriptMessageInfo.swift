struct MiniAppJavaScriptMessageInfo: Codable {
    let action: String
    let id: String
    let param: RequestParameters
}

struct RequestParameters: Codable {
    let permission: String
}
