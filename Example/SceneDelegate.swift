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
        case deeplink = "dl"
    }

    enum Target: Equatable, Identifiable {
        case unknown
        case qrcode(code: String)
        case deeplink(id: String)

        var id: String {
            switch self {
            case .unknown:
                return "unknown"
            case let .qrcode(code):
                return code
            case let .deeplink(id):
                return id
            }
        }
    }

    func manage(url: URL) -> Target {
        guard url.scheme == DeepLinkConstants.scheme,
              url.host == DeepLinkConstants.host,
              !url.pathComponents.isEmpty,
              let path = Path(rawValue: url.pathComponents[1])
        else { return .unknown }

        switch path {
        case .qrcode:
            guard url.pathComponents.count > 1 else { return .unknown }
            return .qrcode(code: url.pathComponents[2])
        case .deeplink:
            guard url.pathComponents.count > 1 else { return .unknown }
            return .deeplink(id: url.pathComponents[2])
        }
    }
}
