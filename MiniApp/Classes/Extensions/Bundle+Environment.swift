extension Bundle: EnvironmentProtocol {

    var valueNotFound: String {
        return "NONE"
    }

    func value(for key: String) -> String? {
        return self.object(forInfoDictionaryKey: key) as? String
    }

    func bool(for key: String) -> Bool? {
        return self.object(forInfoDictionaryKey: key) as? Bool
    }
}
