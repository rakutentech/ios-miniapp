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
}
