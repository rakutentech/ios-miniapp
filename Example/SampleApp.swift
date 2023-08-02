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
                    case let .settings(settinsInfo):
                        prepareSettingsViewModel(with: settinsInfo)
                        deepLink = .settings(viewModel: self.sharedSettingsViewModel)
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
                        NavigationView {
                            MiniAppSettingsView(viewModel: viewModel, showFullProgress: .constant(false))
                        }
                        .accentColor(.red)
                    }
                }
        }
    }

    func prepareSettingsViewModel(with params: SettingsParams) {
        if params.tab == 1 {
            let list1 = self.setConfigValues(with: params, for: ListConfiguration(listType: .listI))
            sharedSettingsViewModel.listConfig = list1
            sharedSettingsViewModel.listConfigI = list1
            sharedSettingsViewModel.listConfigI.persist()
        } else {
            let list2 = self.setConfigValues(with: params, for: ListConfiguration(listType: .listII))
            sharedSettingsViewModel.listConfig = list2
            sharedSettingsViewModel.listConfigII = list2
            sharedSettingsViewModel.listConfigII.persist()
        }
        sharedSettingsViewModel.listConfig.persist()
        sharedSettingsViewModel.selectedListConfig = params.tab == 1 ? .listI : .listII
    }

    func setConfigValues(with params: SettingsParams, for listConfig: ListConfiguration) -> ListConfiguration {
        var listConfig = listConfig
        if params.isProduction {
            listConfig.environmentMode = .production
            listConfig.projectIdProd = params.projectId
            listConfig.subscriptionKey = params.subscriptionKey
        } else {
            listConfig.environmentMode = .staging
            listConfig.projectIdStaging = params.projectId
            listConfig.subscriptionKeyStaging = params.subscriptionKey
        }
        if params.isPreviewMode {
            listConfig.previewMode = .previewable
        } else {
            listConfig.previewMode = .published
        }
        listConfig.projectId = params.projectId
        listConfig.subscriptionKey = params.subscriptionKey
        listConfig.persist()
        return listConfig
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
