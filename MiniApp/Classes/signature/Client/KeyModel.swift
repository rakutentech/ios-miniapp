internal struct KeyModel: Codable, Equatable {
    let identifier: String
    let key: String
    let pem: String

    private enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case key = "ecKey"
        case pem = "pemKey"
    }

    init(identifier: String, key: String, pem: String) {
        self.identifier = identifier
        self.key = key
        self.pem = pem
    }
}
