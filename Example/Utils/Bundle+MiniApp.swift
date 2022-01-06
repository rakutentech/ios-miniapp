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
       guard let resourceBundleURL = myBundle.url(
               forResource: name, withExtension: "bundle")
       else { fatalError("\(name).bundle not found!") }

       // Create a bundle object for the bundle found at that URL.
       guard let resourceBundle = Bundle(url: resourceBundleURL)
       else { fatalError("Cannot access \(name).bundle!") }

       return resourceBundle
   }

   public class var miniAppSDKBundle: Bundle {
       miniAppBundle("MiniApp")
   }

   class var miniAppLocalizationBundle: Bundle {
       miniAppBundle("Localization")
   }
}
