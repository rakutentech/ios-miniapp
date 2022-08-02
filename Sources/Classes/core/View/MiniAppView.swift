import Foundation
import WebKit

// MARK: - MiniAppView
public class MiniAppView: UIView, MiniAppViewable {

    internal var miniAppHandler: MiniAppViewHandler

    internal var webView: MiniAppWebView?

    internal var type: MiniAppType
    internal var state: MiniAppViewState = .none {
        didSet { updateViewState(state: state) }
    }

    internal var activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        view.color = .systemGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    internal var activityLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = "-"
        view.textAlignment = .center
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

    deinit {
        MiniAppLogger.d("deallocated MiniAppView")
    }

    required init?(coder: NSCoder) { return nil }

    // MARK: - Interface

    internal func setupInterface() {
        backgroundColor = .white

        self.addSubview(activityIndicatorView)
        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        activityIndicatorView.startAnimating()

        self.addSubview(activityLabel)
        NSLayoutConstraint.activate([
            activityLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 40),
            activityLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -40),
            activityLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 30)
        ])

        // just for testing purpose
        switch type {
        case .miniapp: self.layer.borderWidth = 0
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
            case .none:
                self.activityLabel.text = ""
            case .loading:
                self.activityLabel.text = "Loading..."
            case .active:
                self.activityLabel.text = "Active"
            case .inactive:
                self.activityLabel.text = "Inactive"
            case .error(let error):
                self.activityLabel.text = error.localizedDescription
            }
        }
    }

    // MARK: - Public

    public func load(completion: @escaping ((Result<Bool, MASDKError>) -> Void)) {
        guard webView == nil else {
            completion(.failure(.unknownError(domain: "", code: 0, description: "miniapp already loaded")))
            return
        }
        state = .loading
        miniAppHandler.load { [weak self] result in
            switch result {
            case let .success(webView):
                self?.setupWebView(webView: webView)
                completion(.success(true))
            case let .failure(error):
                self?.state = .error(error)
                completion(.failure(error))
            }
        }
    }

    public func load() async throws -> AsyncThrowingStream<Void, Error> {
        guard webView == nil else {
            throw MASDKError.unknownError(domain: "", code: 0, description: "miniapp already loaded")
        }
        return AsyncThrowingStream { continuation in
            self.miniAppHandler.load { [weak self] result in
                switch result {
                case let .success(webView):
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
