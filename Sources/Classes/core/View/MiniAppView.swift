import Foundation
import WebKit
import SwiftUI

// MARK: - MiniAppView
public class MiniAppView: UIView, MiniAppViewable {

    internal var miniAppHandler: MiniAppViewHandler

    internal var webView: MiniAppWebView?

    internal var type: MiniAppType
    internal var state: MiniAppViewState = .none {
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
        config: MiniAppNewConfig,
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
        config: MiniAppNewConfig,
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

    public func load(fromCache: Bool = false) async throws -> AsyncThrowingStream<Void, Error> {
        guard webView == nil else {
            throw MASDKError.unknownError(domain: "", code: 0, description: "miniapp already loaded")
        }
        state = .loading
        if fromCache {
            return AsyncThrowingStream { continuation in
                self.miniAppHandler.load { [weak self] result in
                    switch result {
                    case let .success(webView):
                        self?.state = .active
                        self?.setupWebView(webView: webView)
                        continuation.yield(())
                    case let .failure(error):
                        self?.state = .error(error)
                        continuation.yield(with: .failure(error))
                    }
                }
            }
        } else {
            return AsyncThrowingStream { continuation in
                self.miniAppHandler.loadFromCache { [weak self] result in
                    switch result {
                    case let .success(webView):
                        self?.state = .active
                        self?.setupWebView(webView: webView)
                        continuation.yield(())
                    case let .failure(error):
                        self?.state = .error(error)
                        continuation.yield(with: .failure(error))
                    }
                }
            }
        }
    }

    public var alertInfo: CloseAlertInfo? {
        return miniAppHandler.miniAppShouldClose()
    }
}

// MARK: - MiniAppViewCollectionCell
public class MiniAppViewCollectionCell: UICollectionViewCell {

    var miniAppView: MiniAppView?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .systemOrange
    }

    required init?(coder: NSCoder) {
        return nil
    }

    func setup(config: MiniAppNewConfig, type: MiniAppType, appId: String) {
        guard miniAppView != nil else { return }
        let view = MiniAppView(config: config, type: type, appId: appId)
        self.miniAppView = view
        self.addSubview(view)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: contentView.topAnchor),
            view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        view.load { result in
            switch result {
            case .success(let succeeded):
                print(succeeded)
            case .failure(let error):
                MiniAppLogger.e("error: ", error)
            }
        }
    }

    public override func prepareForReuse() {
        super.prepareForReuse()
        miniAppView?.constraints.forEach({ contentView.removeConstraint($0) })
        miniAppView?.removeFromSuperview()
    }
}

// MARK: - MiniAppSUView
public struct MiniAppSUView: UIViewRepresentable {

    var config: MiniAppNewConfig
    var type: MiniAppType
    var appId: String?
    var version: String?
    var queryParams: String?
    var url: URL?

    public init(params: MiniAppViewDefaultParams) {
        self.config = params.config
        self.type = params.type
        self.appId = params.appId
        self.version = params.version
        self.queryParams = params.queryParams
    }

    public init(params: MiniAppViewUrlParams) {
        self.config = params.config
        self.type = params.type
        self.url = params.url
        self.queryParams = params.queryParams
    }

    public func makeUIView(context: Context) -> MiniAppView {
        if let appId = appId {
            let view = MiniAppView(
                config: config,
                type: type,
                appId: appId,
                version: version,
                queryParams: queryParams
            )
            view.load { result in
                print(result)
            }
            return view
        } else if let url = url {
            let view = MiniAppView(
                config: config,
                type: type,
                url: url,
                queryParams: queryParams
            )
            view.load { result in
                print(result)
            }
            return view
        } else {
            fatalError()
        }
    }

    public func updateUIView(_ uiView: MiniAppView, context: Context) {
        // update
    }
}
