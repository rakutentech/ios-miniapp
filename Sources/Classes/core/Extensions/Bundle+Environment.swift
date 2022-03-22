import Foundation

extension Bundle {
     class func miniAppBundle(_ name: String) -> Bundle {
        // Get the bundle containing the binary with the current class.
        // If frameworks are used, this is the frameworks bundle (.framework),
        // if static libraries are used, this is the main app bundle (.app).
        let myBundle = Bundle(for: MiniApp.self)

        // Get the URL to the resource bundle within the bundle
        // of the current class.
        var resourceBundleURL = myBundle.url(forResource: name, withExtension: "bundle")
        if resourceBundleURL == nil {
            resourceBundleURL = myBundle.resourceURL?.appendingPathComponent("Frameworks/MiniApp.framework/\(name).bundle")
        }

        guard let finalURL = resourceBundleURL else { fatalError("\(name).bundle not found!") }

        // Create a bundle object for the bundle found at that URL.
        guard let resourceBundle = Bundle(url: finalURL) else { fatalError("Cannot access \(name).bundle!") }

        return resourceBundle
    }

    public class var miniAppSDKBundle: Bundle {
        miniAppBundle("MiniApp")
    }

    class var miniAppLocalizationBundle: Bundle {
        miniAppBundle("Localization")
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
}
