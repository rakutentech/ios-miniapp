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
        self.window?.tintColor = UIColor.accent
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        AnalyticsManager.shared().set(loggingLevel: .debug)
        if let url = launchOptions?[.url] as? URL {
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                return true
            }
            DispatchQueue.main.asyncAfter(deadline: .now()+2, execute: {
                self.deepLinkToMiniApp(using: components.path.replacingOccurrences(of: "/preview/", with: ""))
            })
        }
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

    func deepLinkToMiniApp(using token: String) {
        let rootController = window?.rootViewController as? UINavigationController
        guard let controllersStack = rootController?.viewControllers else { return }
        if let homeViewController = controllersStack.first(where: { $0 is ViewController }) as? ViewController {
            homeViewController.getMiniAppPreviewInfo(previewToken: token, config: Config.current(pinningEnabled: true))
        } else if let firstLaunchController = controllersStack.first(where: { $0 is FirstLaunchViewController }) as? FirstLaunchViewController {
            firstLaunchController.previewUsingQRToken = token
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
