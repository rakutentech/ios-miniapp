struct ResponseDecoder {
    static func decode<T: Decodable>(decodeType: T.Type, data: Data) -> T? {
        do {
            return try JSONDecoder().decode(decodeType, from: data)
        } catch let error {
            print("Decoding Failed with Error: ", error)
            return nil
        }
    }
}
