//
//  MiniAppStore.swift
//  Sample SPM
//
//  Created by Timotheus Laubengaier on 2022/08/17.
//

import Foundation
import SwiftUI
import MiniApp

private struct MiniAppStoreKey: EnvironmentKey {
    static var defaultValue: MiniAppStore { .empty() }
}

extension EnvironmentValues {
    var appStore: MiniAppStore {
        get { self[MiniAppStoreKey.self] }
        set { self[MiniAppStoreKey.self] = newValue }
    }
}

class MiniAppStore: ObservableObject {
    
    static let shared = MiniAppStore()
    
    var testString: String = "lul"
    
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
    
    init() {
        load()
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
    
    static func empty() -> MiniAppStore {
        return MiniAppStore()
    }
}

extension MiniAppStore {
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
