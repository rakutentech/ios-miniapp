import UIKit
import MiniApp
import AVKit
import GoogleMobileAds
import AppCenter
import AppCenterCrashes
import RAnalytics
import SwiftUI

//@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        MiniApp.configure()
        AppCenter.start(withAppSecret: Bundle.main.value(for: "AppCenterSecret"), services: [Crashes.self])

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

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return false
        }
        deepLinkToMiniApp(using: components.path.replacingOccurrences(of: "/preview/", with: ""))
        return true
    }

    override init() {
        super.init()
        UIControl.swizzleSendAction()
    }

    func deepLinkToMiniApp(using token: String) {
        let rootController = window?.rootViewController as? UINavigationController
        guard let controllersStack = rootController?.viewControllers else { return }
//        if let homeViewController = controllersStack.first(where: { $0 is ViewController }) as? ViewController {
//            homeViewController.getMiniAppPreviewInfo(previewToken: token, config: Config.current(pinningEnabled: true))
//        } else if let firstLaunchController = controllersStack.first(where: { $0 is FirstLaunchViewController }) as? FirstLaunchViewController {
//            firstLaunchController.previewUsingQRToken = token
//        }
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
