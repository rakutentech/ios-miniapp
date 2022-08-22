import Foundation
import MiniApp

@MainActor
class MiniAppSegmentedViewModel: ObservableObject {

    let store = MiniAppStore.shared

    var interfaces: [String: MiniAppMessageDelegate] = [:]

    init() {
        let first = store.miniAppIdentifierTrippleFirst
        let vfirst = store.miniAppVersionTrippleFirst
        let second = store.miniAppIdentifierTrippleSecond
        let vsecond = store.miniAppVersionTrippleSecond
        let third = store.miniAppIdentifierTrippleThird
        let vthird = store.miniAppVersionTrippleThird
        interfaces[first] = MiniAppViewDelegator(miniAppId: first, miniAppVersion: vfirst)
        interfaces[second] = MiniAppViewDelegator(miniAppId: second, miniAppVersion: vsecond)
        interfaces[third] = MiniAppViewDelegator(miniAppId: third, miniAppVersion: vthird)
    }

    func messageInterface(for segment: MiniAppSegment) -> MiniAppMessageDelegate {
        return interfaces[getMiniAppId(segment: segment)] ?? MiniAppViewDelegator()
    }

    func getMiniAppId(segment: MiniAppSegment) -> String {
        var miniAppId: String = ""
        switch segment {
        case .one:
            miniAppId = store.miniAppIdentifierTrippleFirst
        case .two:
            miniAppId = store.miniAppIdentifierTrippleSecond
        case .three:
            miniAppId = store.miniAppIdentifierTrippleThird
        }
        return miniAppId
    }

    func getMiniAppVersion(segment: MiniAppSegment) -> String {
        var version: String = ""
        switch segment {
        case .one:
            version = store.miniAppVersionTrippleFirst
        case .two:
            version = store.miniAppVersionTrippleSecond
        case .three:
            version = store.miniAppVersionTrippleThird
        }
        return version
    }

    func termsViewModel(segment: MiniAppSegment) -> MiniAppWithTermsViewModel {
        MiniAppWithTermsViewModel(
            miniAppId: getMiniAppId(segment: segment),
            miniAppVersion: getMiniAppVersion(segment: segment),
            miniAppType: .miniapp,
            messageInterface: messageInterface(for: segment)
        )
    }

    enum MiniAppSegment: String, CaseIterable {
        case one
        case two
        case three
    }
}
