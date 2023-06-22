import Foundation
import UIKit
import WebKit
import Combine

// MARK: - MiniAppView
public class MiniAppView: UIView, MiniAppViewable {

    internal var miniAppHandler: MiniAppViewHandler

    internal var webView: MiniAppWebView?

    internal var type: MiniAppType

    public let state = PassthroughSubject<MiniAppViewState, Never>()
    public var progressStateView: MiniAppProgressViewable? {
        didSet {
            oldValue?.removeFromSuperview()
            oldValue?.constraints.forEach({ self.removeConstraint($0) })
            guard let progressStateView = progressStateView else {
                return
            }
            self.addSubview(progressStateView)
            NSLayoutConstraint.activate([
                progressStateView.topAnchor.constraint(equalTo: self.topAnchor),
                progressStateView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                progressStateView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                progressStateView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            ])
        }
    }
    var cancellables = Set<AnyCancellable>()

    public init(params: MiniAppViewParameters) {
        switch params {
        case let .default(params):
            self.type = params.type
            self.miniAppHandler = MiniAppViewHandler(
                config: params.config,
                appId: params.appId,
                version: params.version,
                queryParams: params.queryParams
            )
        case let .url(urlParams):
            self.type = urlParams.type
            self.miniAppHandler = MiniAppViewHandler(
                config: urlParams.config,
                url: urlParams.url,
                queryParams: urlParams.queryParams
            )
        case let .info(infoParams):
            self.type = infoParams.type
            self.miniAppHandler = MiniAppViewHandler(
                config: infoParams.config,
                appId: infoParams.info.id,
                version: infoParams.info.version.versionId,
                queryParams: infoParams.queryParams
            )
        }
        super.init(frame: .zero)
        setupInterface()
        setupObservers()
    }

    deinit {
        MiniAppLogger.d("deallocated MiniAppView")
    }

    required init?(coder: NSCoder) { return nil }

    // MARK: - Interface

    internal func setupInterface() {
        backgroundColor = .systemBackground

        switch type {
        case .miniapp:
            self.layer.borderWidth = 0
        case .widget:
            self.layer.cornerRadius = 10
            self.clipsToBounds = true
            self.isUserInteractionEnabled = false
        }
    }

    internal func setupObservers() {
        state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.progressStateView?.updateViewState(state: state)
            }
            .store(in: &cancellables)
    }

    internal func setupWebView(webView: MiniAppWebView) {
        self.webView = webView
        webView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: self.topAnchor),
            webView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }

    // MARK: - Public

    public func load(fromCache: Bool = false, completion: @escaping ((Result<Bool, MASDKError>) -> Void)) {
        guard webView == nil else {
            completion(.failure(.unknownError(domain: "", code: 0, description: "miniapp already loaded")))
            return
        }
        state.send(.loading)
        if fromCache {
            miniAppHandler.loadFromCache { [weak self] result in
                switch result {
                case let .success(webView):
                    self?.state.send(.active)
                    self?.setupWebView(webView: webView)
                    completion(.success(true))
                case let .failure(error):
                    self?.state.send(.error(error))
                    completion(.failure(error))
                }
            }
        } else {
            miniAppHandler.load { [weak self] result in
                switch result {
                case let .success(webView):
                    self?.state.send(.active)
                    self?.setupWebView(webView: webView)
                    completion(.success(true))
                case let .failure(error):
                    self?.state.send(.error(error))
                    completion(.failure(error))
                }
            }
        }
    }

    public func loadAsync(fromCache: Bool = false) async throws -> MiniAppLoadStatus {
        guard webView == nil else {
            throw MASDKError.unknownError(domain: "", code: 0, description: "miniapp already loaded")
        }
        state.send(.loading)
        return try await withCheckedThrowingContinuation { continutation in
            self.miniAppHandler.load { [weak self] result in
                switch result {
                case let .success(webView):
                    self?.state.send(.active)
                    self?.setupWebView(webView: webView)
                    continutation.resume(returning: .success)
                case let .failure(error):
                    self?.state.send(.error(error))
                    continutation.resume(throwing: error)
                }
            }
        }
    }
    
    public func loadFromBundle(completion: @escaping ((Result<Bool, MASDKError>) -> Void)) {
        guard webView == nil else {
            completion(.failure(.unknownError(domain: "", code: 0, description: "miniapp already loaded")))
            return
        }
        state.send(.loading)
        miniAppHandler.loadFromBundle { [weak self] result in
            switch result {
            case let .success(webView):
                self?.state.send(.active)
                self?.setupWebView(webView: webView)
                completion(.success(true))
            case let .failure(error):
                self?.state.send(.error(error))
                completion(.failure(error))
            }
        }
    }


    public var alertInfo: CloseAlertInfo? {
        return miniAppHandler.miniAppShouldClose()
    }

    public var miniAppTitle: String {
        return miniAppHandler.title.isEmpty ? "MiniApp" : miniAppHandler.title
    }

    public enum MiniAppLoadStatus {
        case success
    }
}

extension MiniAppView: MiniAppNavigationBarDelegate {
    public func miniAppNavigationBar(didTriggerAction action: MiniAppNavigationAction) -> Bool {
        miniAppHandler.miniAppNavigationBar(didTriggerAction: action)
    }

    public func miniAppShouldClose() -> CloseAlertInfo? {
        miniAppHandler.closeAlertInfo
    }
}

// MARK: - Universal Bridge
extension MiniAppView {
    public func sendJsonToMiniApp(string jsonString: String) {
        miniAppHandler.sendJsonToMiniApp(string: jsonString)
    }
}
