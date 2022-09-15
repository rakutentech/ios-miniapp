import Foundation
import MiniApp
import Combine

@MainActor
class MiniAppWithTermsViewModel: ObservableObject {
    
    let store = MiniAppStore.shared
    let permissionService: MiniAppPermissionService
    let sdkConfig: MiniAppSdkConfig

    @Published var viewState: MiniAppPermissionService.ViewState = .none

    var miniAppId: String
    var miniAppVersion: String?
    var miniAppType: MiniAppType
    var messageInterface: MiniAppMessageDelegate
    var navigationDelegate: MiniAppNavigationDelegate

    var showMessageAlert: CurrentValueSubject<Bool, Never> = .init(false)

    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false

    init(
        miniAppId: String,
        miniAppVersion: String? = nil,
        miniAppType: MiniAppType = .miniapp,
        messageInterface: MiniAppMessageDelegate? = nil,
        navigationDelegate: MiniAppNavigationDelegate? = nil,
        sdkConfig: MiniAppSdkConfig
    ) {
        self.miniAppId = miniAppId
        self.miniAppVersion = miniAppVersion
        self.miniAppType = miniAppType
        self.sdkConfig = sdkConfig
        self.permissionService = MiniAppPermissionService(config: sdkConfig)

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
        viewState = .loading
        permissionService
            .checkPermissions(miniAppId: miniAppId, miniAppVersion: miniAppVersion ?? "") { [weak self] result in
            switch result {
            case .success(let permState):
                switch permState {
                case .permissionGranted:
                    self?.viewState = .success
                case let .permissionRequested(info, manifest):
                    self?.viewState = .permissionRequested(info: info, manifest: manifest)
                }
            case .failure(let error):
                self?.viewState = .error(error)
            }
        }
    }

    func fetchPermissionRequest(completion: @escaping ((Result<MiniAppPermissionRequest, Error>) -> Void)) {
        guard
            let manifest = permissionService.getCachedManifest(miniAppId: miniAppId)
        else {
            return
        }

        permissionService.getInfo(miniAppId: miniAppId, miniAppVersion: miniAppVersion ?? "") { result in
            switch result {
            case .success(let info):
                completion(.success(MiniAppPermissionRequest(info: info, manifest: manifest)))
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
}
