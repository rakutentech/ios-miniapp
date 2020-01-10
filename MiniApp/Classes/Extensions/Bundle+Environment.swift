extension Bundle: EnvironmentProtocol {

    var valueNotFound: String {
        return "NONE"
    }

    func value(for key: String) -> String? {
        return self.object(forInfoDictionaryKey: key) as? String
    }
}
