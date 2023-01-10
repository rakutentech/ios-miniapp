import Foundation
import MiniApp
import Combine

@MainActor
class MiniAppWithTermsViewModel: ObservableObject {

    let store = MiniAppStore.shared
    let permissionService: MiniAppPermissionService
    let sdkConfig: MiniAppSdkConfig

    @Published var viewState: ViewState = .none

    var miniAppId: String
    var miniAppVersion: String?
    var miniAppType: MiniAppType
    var messageInterface: MiniAppMessageDelegate
    var navigationDelegate: MiniAppNavigationDelegate

    var showMessageAlert: CurrentValueSubject<Bool, Never> = .init(false)
    var showJsonString: String?

    var shouldCloseMiniApp: CurrentValueSubject<Bool, Never> = .init(false)

    @Published var closeWithConfirmation: Bool = false

    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false

    init(
        miniAppId: String,
        miniAppVersion: String? = nil,
        miniAppType: MiniAppType = .miniapp,
        messageInterface: MiniAppMessageDelegate? = nil,
        navigationDelegate: MiniAppNavigationDelegate? = nil,
        listType: ListType
    ) {
        let updatedSdkConfig = ListConfiguration.current(type: listType)
        updatedSdkConfig.isPreviewMode = Reachability.isConnectedToNetwork() ? updatedSdkConfig.isPreviewMode : false
        self.miniAppId = miniAppId
        self.miniAppVersion = miniAppVersion
        self.miniAppType = miniAppType
        self.sdkConfig = updatedSdkConfig
        self.permissionService = MiniAppPermissionService(config: updatedSdkConfig)

        if let navigationDelegate = navigationDelegate {
            self.navigationDelegate = navigationDelegate
        } else {
            self.navigationDelegate = MiniAppViewNavigationDelegator()
        }

        if let messageInterface = messageInterface {
            self.messageInterface = messageInterface
        } else {
            let delegator = MiniAppViewMessageDelegator(miniAppId: miniAppId, miniAppVersion: miniAppVersion)
            self.messageInterface = delegator
            delegator.onSendMessage = {
                self.showMessageAlert.send(true)
                self.showJsonString = nil
            }
            delegator.onSendJsonToHostApp = { string in
                self.showMessageAlert.send(true)
                self.showJsonString = string
            }
            delegator.onShoudCloseMiniApp = { confirmation in
                self.closeWithConfirmation = confirmation
                self.shouldCloseMiniApp.send(true)
            }
        }

        self.load()

        if let navDelegate = self.navigationDelegate as? MiniAppViewNavigationDelegator {
            navDelegate.onChangeCanGoBackForward = { [weak self] (back, forward) in
                self?.canGoBack = back
                self?.canGoForward = forward
            }
        }
    }

    func load() {
        if !Reachability.isConnectedToNetwork() {
            if MiniApp.shared(with: sdkConfig).getDownloadedManifest(miniAppId: miniAppId) != nil {
                self.viewState = .offline
            } else {
                self.viewState = .error(LocalError.notCachedOffline)
            }
            return
        }

        viewState = .loading
        permissionService
            .checkPermissions(miniAppId: miniAppId, miniAppVersion: miniAppVersion ?? "") { [weak self] result in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch result {
                    case .success(let permState):
                        switch permState {
                        case .permissionGranted:
                            self.viewState = .success
                        case let .permissionRequested(info, manifest):
                            self.viewState = .permissionRequested(info: info, manifest: manifest)
                        }
                    case .failure(let error):
                        if self.isOffline(error: error) {
                            self.viewState = .offline
                        } else {
                            self.viewState = .error(error)
                        }
                    }
                }
        }
    }

    func fetchPermissionRequest(completion: @escaping ((Result<MiniAppPermissionRequest, Error>) -> Void)) {
        guard
            let manifest = permissionService.getCachedManifest(miniAppId: miniAppId)
        else {
            return
        }

        guard
            Reachability.isConnectedToNetwork()
        else
        {
            let request = MiniAppPermissionRequest(
                sdkConfig: sdkConfig,
                info: MiniAppInfo(
                    id: miniAppId,
                    icon: URL(string: "https://example.com")!,
                    version: Version(versionTag: "", versionId: miniAppVersion ?? "")
                ),
                manifest: manifest
            )
            completion(.success(request))
            return
        }

        permissionService.getInfo(miniAppId: miniAppId, miniAppVersion: miniAppVersion ?? "") { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let info):
                completion(.success(MiniAppPermissionRequest(sdkConfig: self.sdkConfig, info: info, manifest: manifest)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func getInfo(completion: @escaping ((Result<MiniAppInfo, Error>) -> Void)) {
        permissionService.getInfo(miniAppId: miniAppId, miniAppVersion: miniAppVersion ?? "") { result in
            switch result {
            case .success(let info):
                completion(.success(info))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func isOffline(error: Error) -> Bool {
        let error = error as NSError
        if let maSdkError = error as? MASDKError {
            return maSdkError.isDeviceOfflineDownloadError()
        }
        return [NSURLErrorNotConnectedToInternet, NSURLErrorTimedOut, NSURLErrorDataNotAllowed].contains(error.code)
    }

    var isSuccessOrOffline: Bool {
        switch viewState {
        case .success, .offline:
            return true
        default:
            return false
        }
    }

    func addHandlerToList(_ handler: MiniAppSUIViewHandler) {
        store.addHandlerToList(handler)
    }

    func removeHandlerFromList(_ handler: MiniAppSUIViewHandler) {
        store.removeHandlerFromList(handler)
    }
}

extension MiniAppWithTermsViewModel {
    enum ViewState: Equatable {
        static func == (lhs: ViewState, rhs: ViewState) -> Bool {
            switch (lhs, rhs) {
            case (.none, .none):
                return true
            case (.loading, .loading):
                return true
            case (.permissionRequested(let lhsInfo, let lhsManifest), .permissionRequested(let rhsInfo, let rhsManifest)):
                return lhsInfo.id == rhsInfo.id && lhsManifest.versionId == rhsManifest.versionId
            case (.error(let lhsError), .error(let rhsError)):
                return lhsError.localizedDescription == rhsError.localizedDescription
            case (.success, .success):
                return true
            default:
                return false
            }
        }

        case none
        case loading
        case permissionRequested(info: MiniAppInfo, manifest: MiniAppManifest)
        case error(Error)
        case offline
        case success
    }

    enum LocalError: Error, LocalizedError {
        case notCachedOffline

        var errorDescription: String? {
            switch self {
            case .notCachedOffline:
                return "Device is offline and MiniApp is not cached."
            }
        }
    }
}
