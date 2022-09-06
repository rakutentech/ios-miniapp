import Foundation
import MiniApp
import Combine

@MainActor
class MiniAppListViewModel: ObservableObject {

    let store = MiniAppStore.shared

    @Published var state: ListState = .none
    @Published var indexedMiniAppInfoList: [String: [MiniAppInfo]] = [:]

    var bag = Set<AnyCancellable>()

    init() {
        state = .loading
        store.$indexedMiniAppInfoList
            .sink { [weak self] list in
                self?.state = .success
                self?.indexedMiniAppInfoList = list
            }
            .store(in: &bag)
    }
}

enum ListState {
    case none
    case loading
    case success
}
