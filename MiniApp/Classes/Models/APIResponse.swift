struct ResponseData {
    let data: Data
    let httpResponse: HTTPURLResponse
    init(_ data: Data, _ httpResponse: HTTPURLResponse) {
        self.data = data
        self.httpResponse = httpResponse
    }
}

struct ErrorData: Decodable, Equatable {
    let code: Int
    let message: String
}
