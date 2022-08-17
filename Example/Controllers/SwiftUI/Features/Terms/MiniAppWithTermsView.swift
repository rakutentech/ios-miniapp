import SwiftUI
import MiniApp

@MainActor
class MiniAppWithTermsViewModel: ObservableObject {

    let permissionService = MiniAppPermissionService()
    
    @Published var viewState: MiniAppPermissionService.ViewState = .none
    
    @Published var miniAppId: String
    @Published var miniAppVersion: String?
    @Published var miniAppType: MiniAppType

    init(
        miniAppId: String,
        miniAppVersion: String? = nil,
        miniAppType: MiniAppType = .miniapp
    ) {
        self.miniAppId = miniAppId
        self.miniAppVersion = miniAppVersion
        self.miniAppType = miniAppType
        self.load()
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
}

struct MiniAppWithTermsView: View {
    
    @ObservedObject var viewModel: MiniAppWithTermsViewModel

    @State private var didAcceptTerms: Bool = false
    
//    init(miniAppId: String, miniAppVersion: String? = nil, miniAppType: MiniAppType = .miniapp) {
//        _viewModel = StateObject(wrappedValue:
//            MiniAppWithTermsViewModel(miniAppId: miniAppId, miniAppVersion: miniAppVersion, miniAppType: miniAppType)
//        )
//    }

    var body: some View {
        VStack {
            switch viewModel.viewState {
            case .none:
                EmptyView()
            case .loading:
                ProgressView()
            case let .permissionRequested(info, manifest):
                MiniAppTermsView(
                    didAccept: $didAcceptTerms,
                    request: MiniAppPermissionRequest(info: info, manifest: manifest)
                )
            case .error(let error):
                Text(error.localizedDescription)
                    .font(.system(size: 14, weight: .medium))
                    .padding(.horizontal, 40)
            case .success:
                MiniAppSUView(params:
                    MiniAppViewDefaultParams(
                        config: MiniAppNewConfig(
                            config: Config.current(),
                            adsDisplayer: nil,
                            messageInterface: MiniAppViewDelegator(miniAppId: viewModel.miniAppId)
                        ),
                        type: viewModel.miniAppType,
                        appId: viewModel.miniAppId,
                        version: viewModel.miniAppVersion
                    )
                )
            }
        }
        .onChange(of: didAcceptTerms, perform: { accepted in
            if accepted {
                viewModel.viewState = .success
            }
        })
    }
}

struct MiniAppWithTermsView_Previews: PreviewProvider {
    static var previews: some View {
        MiniAppWithTermsView(viewModel: MiniAppWithTermsViewModel(miniAppId: ""))
    }
}
