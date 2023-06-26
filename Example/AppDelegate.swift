import UIKit
import MiniApp
import AVKit
import GoogleMobileAds
import AppCenter
import AppCenterCrashes
import RAnalytics
import SwiftUI

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        MiniApp.configure()
        MiniApp.unzipMiniApp(fileName: "js-miniapp-sample", miniAppId: "mini-app-testing-appid", versionId: "mini-app-testing-versionid")
        AppCenter.start(withAppSecret: Bundle.main.value(for: "AppCenterSecret"), services: [Crashes.self])

        GADMobileAds.sharedInstance().start(completionHandler: nil)
        AnalyticsManager.shared().set(loggingLevel: .debug)

        return true
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if window?.isKeyWindow != true {
            return [.portrait, .portraitUpsideDown]
        } else if MiniApp.MAOrientationLock.isEmpty {
            return [.portrait, .portraitUpsideDown]
        } else {
            return MiniApp.MAOrientationLock
        }
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        //
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
