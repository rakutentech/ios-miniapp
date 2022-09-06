import Foundation
import MiniApp
import Combine

@MainActor
class MiniAppSettingsViewModel: ObservableObject {

    let store = MiniAppStore.shared

    @Published var indexedMiniAppInfoList: [String: [MiniAppInfo]] = [:]

    var bag = Set<AnyCancellable>()

    init() {
        store.$indexedMiniAppInfoList
            .sink { [weak self] list in
                self?.indexedMiniAppInfoList = list
            }
            .store(in: &bag)
    }

    func getBuildVersionText() -> String {
        var versionText = ""
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionText.append("Build Version: \(version) - ")

        }
        if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            versionText.append("(\(build))")
        }
        return versionText
    }

    func save(config: MiniAppSettingsView.SettingsConfig) {
        print(config)
    }
}
