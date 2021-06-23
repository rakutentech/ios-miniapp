import UIKit
import MiniApp
import AVKit
import GoogleMobileAds
import AppCenter
import AppCenterCrashes
import RAnalytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        AppCenter.start(withAppSecret: Bundle.main.value(for: "AppCenterSecret"), services: [Crashes.self])
        self.window?.tintColor = UIColor(named: "Crimson")
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        AnalyticsManager.shared().set(loggingLevel: .debug)
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
