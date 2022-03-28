import Foundation
import UIKit
import MiniApp

extension Bundle {
    var valueNotFound: String {
        return ""
    }

    func value(for key: String) -> String? {
        return self.object(forInfoDictionaryKey: key) as? String
    }

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

       guard let finalURL = resourceBundleURL
       else {
           print("🛑 \(name).bundle not found!")
           #if SWIFT_PACKAGE
           return Bundle.module
           #else
           fatalError("could not find resource bundle url")
           #endif
       }

       // Create a bundle object for the bundle found at that URL.
       guard let resourceBundle = Bundle(url: finalURL)
       else {
           print("🛑 Cannot access \(name).bundle!")
           #if SWIFT_PACKAGE
           return Bundle.module
           #else
           fatalError("could not load resource bundle")
           #endif
       }

       return resourceBundle
   }

   public class var miniAppSDKBundle: Bundle {
       miniAppBundle("MiniApp")
   }

   class var miniAppLocalizationBundle: Bundle {
       miniAppBundle("Localization")
   }
}
