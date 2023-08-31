import SwiftUI
import MiniApp

@main
struct SampleApp: App {

    @UIApplicationDelegateAdaptor var delegate: AppDelegate

    let store = MiniAppStore.shared
    let deepLinkManager = DeeplinkManager()

    @StateObject var sharedSettingsViewModel = MiniAppSettingsViewModel()
    @State var deepLink: SampleAppDeeplink?

    var body: some Scene {
        WindowGroup {
            ContentView(sharedSettingsVM: sharedSettingsViewModel)
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
                    case let .settings(_):
                        return
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
                    case .settings(let viewModel):
                        MiniAppDashboardView(sharedSettingsVM: viewModel, selection: 3)
                        .accentColor(.red)
                    }
                }
        }
    }
}

enum SampleAppDeeplink: Identifiable {
    case miniapp(info: MiniAppInfo)
    case settings(viewModel: MiniAppSettingsViewModel)

    var id: String {
        switch self {
        case .miniapp(let info):
            return info.id + "_" + info.version.versionId
        case .settings(let queryParams):
            return "SettingsConfig"
        }
    }
}
