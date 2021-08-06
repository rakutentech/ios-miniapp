extension Bundle {
    open class var miniAppBundle: Bundle? {
        let bundle = Bundle(for: MiniApp.self)
        guard let resourcesBundleUrl = bundle.resourceURL?.appendingPathComponent("MiniApp.bundle") else {
            return nil
        }
        return Bundle(url: resourcesBundleUrl)
    }
}

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

    class func miniAppSDKBundle() -> Bundle {
        // Get the bundle containing the binary with the current class.
        // If frameworks are used, this is the frameworks bundle (.framework),
        // if static libraries are used, this is the main app bundle (.app).
        let myBundle = Bundle(for: MiniApp.self)

        // Get the URL to the resource bundle within the bundle
        // of the current class.
        guard let resourceBundleURL = myBundle.url(
            forResource: "MiniApp", withExtension: "bundle")
            else { fatalError("MiniApp.bundle not found!") }

        // Create a bundle object for the bundle found at that URL.
        guard let resourceBundle = Bundle(url: resourceBundleURL)
            else { fatalError("Cannot access MiniApp.bundle!") }

        return resourceBundle
    }
}
