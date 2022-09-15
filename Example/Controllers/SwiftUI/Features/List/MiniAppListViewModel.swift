import Foundation
import MiniApp
import Combine

@MainActor
class MiniAppListViewModel: ObservableObject {

    let store = MiniAppStore.shared

    @Published var type: MiniAppSettingsView.ListConfig
    @Published var state: ListState = .none
    @Published var indexedMiniAppInfoList: [String: [MiniAppInfo]] = [:]

    var bag = Set<AnyCancellable>()

    init(type: MiniAppSettingsView.ListConfig) {
        self.type = type
        setupObservers()
        if store.miniAppSetupCompleted {
            load()
        } else {
            state = .awaitsSetup
        }
    }

    func checkInitialLoad() {
        // checkSetup()
        // if store.miniAppSetupCompleted && indexedMiniAppInfoList.isEmpty {
        //     load()
        // }
    }

    func setupObservers() {
        switch type {
        case .listI:
            store
                .$miniAppInfoList
                .receive(on: DispatchQueue.main)
                .sink { [weak self] list in
                    guard let self = self, self.store.miniAppSetupCompleted else {
                        self?.state = .awaitsSetup
                        return
                    }
                    self.state = .success
                    self.indexedMiniAppInfoList = self.makeIndexed(infos: list)
                }
                .store(in: &bag)
        case .listII:
            store
                .$miniAppInfoList2
                .receive(on: DispatchQueue.main)
                .sink { [weak self] list in
                    guard let self = self, self.store.miniAppSetupCompleted else {
                        self?.state = .awaitsSetup
                        return
                    }
                    self.state = .success
                    self.indexedMiniAppInfoList = self.makeIndexed(infos: list)
                }
                .store(in: &bag)
        }
    }

    func makeIndexed(infos: [MiniAppInfo]) -> [String: [MiniAppInfo]] {
        let ids = Set<String>(infos.map({ $0.id }))
        var newList: [String: [MiniAppInfo]] = [:]
        for id in ids {
            newList[id] = infos.filter({ $0.id == id })
        }
        return newList
    }

    func checkSetup() {
        if !store.miniAppSetupCompleted {
            state = .awaitsSetup
        }
    }

    private func load() {
        state = .loading
        store.load(type: type)
    }

    var config: MiniAppSdkConfig {
        store.config.sdkConfig(list: type)
    }
}

enum ListState {
    case none
    case awaitsSetup
    case loading
    case success
}
