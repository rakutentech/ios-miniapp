import UIKit
import MiniApp
import AVKit
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window?.tintColor = #colorLiteral(red: 0.7472071648, green: 0, blue: 0, alpha: 1)
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        return true
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if window?.isKeyWindow != true {
            return .all
        } else if MiniApp.MAOrientationLock.isEmpty {
            return .all
        } else {
            return MiniApp.MAOrientationLock
        }
    }
}

extension AVPlayerViewController {
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if MiniApp.MAOrientationLock.isEmpty {
            return .all
        } else {
            return MiniApp.MAOrientationLock
        }
    }
}
