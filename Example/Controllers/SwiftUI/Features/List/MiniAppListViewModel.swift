import Foundation
import MiniApp
import Combine

enum MiniAppListViewType {
    case listI
    case listII
}

@MainActor
class MiniAppListViewModel: ObservableObject {

    let store = MiniAppStore.shared

    @Published var type: MiniAppListViewType
    @Published var state: ListState = .none
    @Published var indexedMiniAppInfoList: [String: [MiniAppInfo]] = [:]

    var bag = Set<AnyCancellable>()

    init(type: MiniAppListViewType) {
        self.type = type
    }
    
    func checkSetup() {
        if !store.miniAppSetupCompleted {
            state = .awaitsSetup
        }
    }
    
    func load() {
        state = .loading

        switch type {
        case .listI:
            store.$indexedMiniAppInfoList
                .receive(on: DispatchQueue.main)
                .sink { [weak self] list in
                    self?.state = .success
                    self?.indexedMiniAppInfoList = list
                }
                .store(in: &bag)
        case .listII:
            store.$indexedMiniAppInfoList2
                .receive(on: DispatchQueue.main)
                .sink { [weak self] list in
                    self?.state = .success
                    self?.indexedMiniAppInfoList = list
                }
                .store(in: &bag)
        }
        
        store.load(type: type)
    }
}

enum ListState {
    case none
    case awaitsSetup
    case loading
    case success
}
