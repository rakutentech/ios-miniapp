import UIKit
import SwiftUI
import AdSupport
import AppTrackingTransparency
import GoogleMobileAds

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // scene implementation
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.requestPermission()
        }
    }

    func requestPermission() {
        ATTrackingManager.requestTrackingAuthorization { status in
            switch status {
            case .authorized:
                GADMobileAds.sharedInstance().start(completionHandler: nil)
                print("Authorized Tracking Permission")
            case .denied:
                print("Denied Tracking Permission")
            case .notDetermined:
                print("Not Determined Tracking Permission")
            case .restricted:
                print("Restricted Tracking Permission")
            @unknown default:
                print("Unknown Tracking Permission")
            }
        }
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
        case settings = "settings"
    }

    enum Target: Equatable, Identifiable {
        case unknown
        case qrcode(code: String)
        case deeplink(id: String)
        case settings(settingsParams: SettingsParams)

        var id: String {
            switch self {
            case .unknown:
                return "unknown"
            case let .qrcode(code):
                return code
            case let .deeplink(id):
                return id
            case let .settings(settingsParams):
                return settingsParams.projectId
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
        case .settings:
            guard url.pathComponents.count > 1 else { return .unknown }
            let settingsParams = self.getQueryItems(url.absoluteString)
            return .settings(settingsParams: settingsParams)
        }
    }

    func getQueryItems(_ urlString: String) -> SettingsParams {
        var queryItems: [String: String] = [:]
        let components: NSURLComponents? = getURLComonents(urlString)
        for item in components?.queryItems ?? [] {
            queryItems[item.name] = item.value?.removingPercentEncoding
        }
        var settingsParams = SettingsParams()
        settingsParams.tab = Int(queryItems["tab"] ?? "") ?? 1
        settingsParams.projectId = queryItems["projectid"] ?? ""
        settingsParams.subscriptionKey = queryItems["subscription"] ?? ""
        settingsParams.isProduction = Bool(queryItems["isProduction"] ?? "") ?? false
        settingsParams.isPreviewMode = Bool(queryItems["isPreviewMode"] ?? "") ?? false
        return settingsParams
    }

    func getURLComonents(_ urlString: String?) -> NSURLComponents? {
        var components: NSURLComponents?
        let linkUrl = URL(string: urlString?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? "")
        if let linkUrl = linkUrl {
            components = NSURLComponents(url: linkUrl, resolvingAgainstBaseURL: true)
        }
        return components
    }
}
