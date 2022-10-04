import SwiftUI

@main
struct SampleApp: App {

    @UIApplicationDelegateAdaptor var delegate: AppDelegate

    let deepLinkManager = DeeplinkManager()
    
    @State var deepLink: DeeplinkManager.Target?

    var body: some Scene {
        WindowGroup {
            ContentView()
                .accentColor(.red)
                .onOpenURL { url in
                    let receivedDeepLink = deepLinkManager.manage(url: url)
                    switch receivedDeepLink {
                    case .unknown:
                        return
                    default:
                        deepLink = receivedDeepLink
                    }
                }
                .sheet(item: $deepLink) {
                    deepLink = nil
                } content: { deeplink in
                    switch deeplink {
                    case .unknown:
                        Text("Invalid deeplink")
                    case .qrcode(let code):
                        Text(code)
                    }
                }
        }
    }
}
