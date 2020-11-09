struct ResponseDecoder {
    static func decode<T: Decodable>(decodeType: T.Type, data: Data) -> T? {
        do {
            return try JSONDecoder().decode(decodeType, from: data)
        } catch let error {
            MiniAppLogger.e("Decoding Failed", error)
            return nil
        }
    }
}

struct ResponseEncoder {
    static func encode<T: Encodable>(data: T) -> String? {
        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(data)
            return String(data: jsonData, encoding: .utf8)
        } catch let error {
            MiniAppLogger.e("Encoding Failed", error)
            return nil
        }
    }
}
