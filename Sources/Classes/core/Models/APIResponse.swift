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

    private enum CodingKeys: String, CodingKey {
        case code,
        message
    }
}

struct UnauthorizedData: Decodable, Equatable {
    let errorDescription: String
    let error: String

    private enum CodingKeys: String, CodingKey {
        case errorDescription = "error_description",
        error
    }
}
