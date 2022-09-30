import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            let dashboardView = MiniAppDashboardView()
            let dashboardVc = UIHostingController(rootView: dashboardView)

            self.window = UIWindow(windowScene: windowScene)
            self.window?.rootViewController = dashboardVc
            self.window?.makeKeyAndVisible()
        }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        let deeplinkManager = DeeplinkManager()
        let deeplink = deeplinkManager.manage(url: URLContexts.map({ $0.url }).first!)
        print("deeplink: \(deeplink)")
    }
}

class DeeplinkManager {

    class DeepLinkConstants {
        static let scheme = "miniappdemo"
    }

    enum Path: String {
        case qrcode = "preview"
    }

    enum Target: Equatable {
        case notSupported
        case qrcode(code: String)
    }

    func manage(url: URL) -> Target {
        guard url.scheme == DeepLinkConstants.scheme,
              let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let host = components.host,
              let path = Path(rawValue: host)
        else { return .notSupported }

        switch path {
        case .qrcode:
            return .qrcode(code: "abcd")
        }
    }
}
