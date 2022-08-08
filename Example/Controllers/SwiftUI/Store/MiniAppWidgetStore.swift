import Foundation
import SwiftUI
import Combine
import MiniApp

final class MiniAppWidgetStore: ObservableObject {

    @AppStorage(Constants.miniAppIdentifierSingle.rawValue) var miniAppIdentifierSingle = ""
    @AppStorage(Constants.miniAppVersionSingle.rawValue) var miniAppVersionSingle = ""

    @AppStorage(Constants.miniAppIdentifierTrippleFirst.rawValue) var miniAppIdentifierTrippleFirst = ""
    @AppStorage(Constants.miniAppVersionTrippleFirst.rawValue) var miniAppVersionTrippleFirst = ""

    @AppStorage(Constants.miniAppIdentifierTrippleSecond.rawValue) var miniAppIdentifierTrippleSecond = ""
    @AppStorage(Constants.miniAppVersionTrippleSecond.rawValue) var miniAppVersionTrippleSecond = ""
    
    @AppStorage(Constants.miniAppIdentifierTrippleThird.rawValue) var miniAppIdentifierTrippleThird = ""
    @AppStorage(Constants.miniAppVersionTrippleThird.rawValue) var miniAppVersionTrippleThird = ""
    
    @Published
    var miniAppInfoList: [MiniAppInfo] = []
    
    @Published
    var indexedMiniAppInfoList: [String: [MiniAppInfo]] = [:]

    var messageInterfaces: [String: MiniAppViewDelegator] = [:]
    
    init() {
        
    }

    func load() {
        MiniApp.shared().list { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(infos):
                    self.miniAppInfoList = infos
                    
                    let ids = Set<String>(infos.map({ $0.id }))
                    for id in ids {
                        self.indexedMiniAppInfoList[id] = infos.filter({ $0.id == id })
                    }
                case let .failure(error):
                    print(error)
                }
            }
        }
    }
}

extension MiniAppWidgetStore {
    enum Constants: String {
        case miniAppIdentifierSingle = "kMiniAppIdentifierSingle"
        case miniAppVersionSingle = "kMiniAppVersionSingle"
        case miniAppIdentifierTrippleFirst = "kMiniAppIdentifierTrippleFirst"
        case miniAppVersionTrippleFirst = "kMiniAppVersionTrippleFirst"
        case miniAppIdentifierTrippleSecond = "kMiniAppIdentifierTrippleSecond"
        case miniAppVersionTrippleSecond = "kMiniAppVersionTrippleSecond"
        case miniAppIdentifierTrippleThird = "kMiniAppIdentifierTrippleThird"
        case miniAppVersionTrippleThird = "kMiniAppVersionTrippleThird"
    }
}
