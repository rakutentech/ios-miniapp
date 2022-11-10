import SwiftUI
import MiniApp

@main
struct SampleApp: App {

    @UIApplicationDelegateAdaptor var delegate: AppDelegate

    let store = MiniAppStore.shared
    let deepLinkManager = DeeplinkManager()

    @State var deepLink: SampleAppDeeplink?

    var body: some Scene {
        WindowGroup {
            ContentView()
                .accentColor(.red)
                .onOpenURL { url in
                    let receivedDeepLink = deepLinkManager.manage(url: url)
                    switch receivedDeepLink {
                    case .unknown:
                        return
                    case let .qrcode(code):
                        Task {
                            do {
                                if let info = try await store.getMiniAppPreviewInfo(previewToken: code) {
                                    deepLink = .miniapp(info: info)
                                }
                            } catch {
                                print(error)
                            }
                        }
                    case let .deeplink(id):
                        Task {
                            do {
                                if let info = try await store.getMiniAppInfo(miniAppId: id) {
                                    deepLink = .miniapp(info: info)
                                }
                            } catch {
                                print(error)
                            }
                        }
                    }
                }
                .sheet(item: $deepLink) {
                    deepLink = nil
                } content: { deeplink in
                    switch deeplink {
                    case .miniapp(let info):
                        NavigationView {
                            MiniAppSingleView(
                                listType: .listI,
                                miniAppId: info.id,
                                miniAppVersion: info.version.versionId,
                                miniAppType: .miniapp
                            )
                        }
                        .accentColor(.red)
                    }
                }
        }
    }
}

enum SampleAppDeeplink: Identifiable {
    case miniapp(info: MiniAppInfo)

    var id: String {
        switch self {
        case .miniapp(let info):
            return info.id + "_" + info.version.versionId
        }
    }
}
