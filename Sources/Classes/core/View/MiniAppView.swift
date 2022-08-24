import Foundation
import UIKit
import WebKit

// MARK: - MiniAppView
public class MiniAppView: UIView, MiniAppViewable {

    internal var miniAppHandler: MiniAppViewHandler

    internal var webView: MiniAppWebView?

    internal var type: MiniAppType
    var state: MiniAppViewState = .none {
        didSet { updateViewState(state: state) }
    }

    internal var stateImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    internal var activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        view.color = .systemGray2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    internal var activityLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = "-"
        view.textAlignment = .center
        view.textColor = .systemGray
        view.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        view.numberOfLines = 5
        return view
    }()

    public init(
        config: MiniAppConfig,
        type: MiniAppType,
        appId: String,
        version: String? = nil,
        queryParams: String? = nil
    ) {
        self.type = type
        self.miniAppHandler = MiniAppViewHandler(
            config: config,
            appId: appId,
            version: version,
            queryParams: queryParams
        )
        super.init(frame: .zero)
        setupInterface()
    }

    public init(
        config: MiniAppConfig,
        type: MiniAppType,
        url: URL,
        queryParams: String? = nil
    ) {
        self.type = type
        self.miniAppHandler = MiniAppViewHandler(
            config: config,
            url: url,
            queryParams: queryParams
        )
        super.init(frame: .zero)
        setupInterface()
    }

    deinit {
        MiniAppLogger.d("deallocated MiniAppView")
    }

    required init?(coder: NSCoder) { return nil }

    // MARK: - Interface

    internal func setupInterface() {
        backgroundColor = .systemBackground

        self.addSubview(activityIndicatorView)
        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -30)
        ])

        self.addSubview(activityLabel)
        NSLayoutConstraint.activate([
            activityLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 40),
            activityLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -40),
            activityLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])

        self.addSubview(stateImageView)
        NSLayoutConstraint.activate([
            stateImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            stateImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -30),
            stateImageView.widthAnchor.constraint(equalToConstant: 25),
            stateImageView.heightAnchor.constraint(equalToConstant: 25)
        ])

        // just for testing purpose
        switch type {
        case .miniapp:
            self.layer.borderWidth = 0
        case .widget:
            self.layer.cornerRadius = 10
            self.clipsToBounds = true
        }
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

    internal func updateViewState(state: MiniAppViewState) {
        DispatchQueue.main.async {
            switch self.state {
            case .none: self.activityLabel.text = ""
            case .loading: self.activityLabel.text = "Loading..."
            case .active: self.activityLabel.text = "Active"
            case .inactive: self.activityLabel.text = "Inactive"
            case .error(let error): self.activityLabel.text = error.localizedDescription
            }

            switch self.state {
            case .none, .active, .inactive, .error:
                self.activityIndicatorView.stopAnimating()
            case .loading:
                self.activityIndicatorView.startAnimating()
            }

            switch self.state {
            case .active:
                self.stateImageView.image = UIImage(systemName: "checkmark.circle")
                self.stateImageView.tintColor = .systemGreen
            case .error:
                self.stateImageView.image = UIImage(systemName: "xmark.circle")
                self.stateImageView.tintColor = .systemRed
            default:
                self.stateImageView.image = nil
            }
        }
    }

    // MARK: - Public

    public func load(fromCache: Bool = false, completion: @escaping ((Result<Bool, MASDKError>) -> Void)) {
        guard webView == nil else {
            completion(.failure(.unknownError(domain: "", code: 0, description: "miniapp already loaded")))
            return
        }
        state = .loading
        if fromCache {
            miniAppHandler.loadFromCache { [weak self] result in
                switch result {
                case let .success(webView):
                    self?.state = .active
                    self?.setupWebView(webView: webView)
                    completion(.success(true))
                case let .failure(error):
                    self?.state = .error(error)
                    completion(.failure(error))
                }
            }
        } else {
            miniAppHandler.load { [weak self] result in
                switch result {
                case let .success(webView):
                    self?.state = .active
                    self?.setupWebView(webView: webView)
                    completion(.success(true))
                case let .failure(error):
                    self?.state = .error(error)
                    completion(.failure(error))
                }
            }
        }
    }

    public func loadAsync(fromCache: Bool = false) async throws -> LoadStatus {
        guard webView == nil else {
            throw MASDKError.unknownError(domain: "", code: 0, description: "miniapp already loaded")
        }
        state = .loading
        return try await withCheckedThrowingContinuation { continutation in
            self.miniAppHandler.load { [weak self] result in
                switch result {
                case let .success(webView):
                    self?.state = .active
                    self?.setupWebView(webView: webView)
                    continutation.resume(returning: .success)
                case let .failure(error):
                    continutation.resume(throwing: error)
                }
            }
        }
    }

    public var alertInfo: CloseAlertInfo? {
        return miniAppHandler.miniAppShouldClose()
    }

    public enum LoadStatus {
        case success
    }
}
