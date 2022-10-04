import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // scene implementation
    }
}

class DeeplinkManager {

    class DeepLinkConstants {
        static let scheme = "miniappdemo"
        static let host = "miniapp"
    }

    enum Path: String {
        case qrcode = "preview"
    }

    enum Target: Equatable, Identifiable {
        case unknown
        case qrcode(code: String)

        var id: String {
            switch self {
            case .unknown:
                return "unknown"
            case .qrcode(let code):
                return code
            }
        }
    }

    func manage(url: URL) -> Target {
        guard url.scheme == DeepLinkConstants.scheme,
              url.host == DeepLinkConstants.host,
              let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              !url.pathComponents.isEmpty,
              let path = Path(rawValue: url.pathComponents[1])
        else { return .unknown }

        switch path {
        case .qrcode:
            guard url.pathComponents.count > 1 else { return .unknown }
            return .qrcode(code: url.pathComponents[2])
        }
    }
}
