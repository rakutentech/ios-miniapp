struct ResponseDecoder {
    static func decode<T: Decodable>(decodeType: T.Type, data: Data) -> T? {
        do {
            return try JSONDecoder().decode(decodeType, from: data)
        } catch let error {
            Logger.e("Decoding Failed", error)
            return nil
        }
    }
}
