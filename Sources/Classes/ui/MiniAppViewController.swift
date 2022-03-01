import Foundation
import UIKit

public protocol MiniAppUIDelegate: AnyObject {
    func miniApp(_ viewController: MiniAppViewController, didLaunchWith config: MiniAppSdkConfig?)
    func miniApp(_ viewController: MiniAppViewController, shouldExecute action: MiniAppNavigationAction)
    func miniApp(_ viewController: MiniAppViewController, didLoadWith error: MASDKError?)
    func onClose()
}

public extension MiniAppUIDelegate {
    func miniApp(_ viewController: MiniAppViewController, didLaunchWith config: MiniAppSdkConfig?) {
        /* This is the default conformance to the MiniAppUIDelegate. */
    }
    func miniApp(_ viewController: MiniAppViewController, shouldExecute action: MiniAppNavigationAction) {
        /* This is the default conformance to the MiniAppUIDelegate. */
    }
    func miniApp(_ viewController: MiniAppViewController, didLoadWith error: MASDKError?) {
        /* This is the default conformance to the MiniAppUIDelegate. */
    }
}

public class MiniAppViewController: UIViewController {

    let appId: String
    let version: String?
    var config: MiniAppSdkConfig?
    var queryParams: String?
    var adsDisplayer: MiniAppAdDisplayer?
    var enableSharePreview: Bool
    var loadFromCacheIfFailed: Bool

    var state: ViewState = .loading {
        didSet { update() }
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.sendCustomEvent(MiniAppEvent.Event(type: .resume, comment: "MiniApp view did appear"))
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.sendCustomEvent(MiniAppEvent.Event(type: .pause, comment: "MiniApp view will disappear"))
    }

    weak var messageDelegate: MiniAppMessageDelegate?
    weak var navDelegate: MiniAppNavigationDelegate?
    weak var navBarDelegate: MiniAppNavigationBarDelegate?

    weak var miniAppUiDelegate: MiniAppUIDelegate?

    // MARK: UI - Navigation
    private lazy var backButton: UIBarButtonItem = {
        let view = UIBarButtonItem(image: UIImage(named: "arrow_left-24", in: Bundle.miniAppSDKBundle, with: .none), style: .plain, target: self, action: #selector(backPressed))
        return view
    }()

    private lazy var forwardButton: UIBarButtonItem = {
        let view = UIBarButtonItem(image: UIImage(named: "arrow_right-24", in: Bundle.miniAppSDKBundle, with: .none), style: .plain, target: self, action: #selector(forwardPressed))
        return view
    }()

    private lazy var shareButton: UIBarButtonItem = {
        let view = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(sharePressed))
        return view
    }()

    private lazy var closeButton: UIBarButtonItem = {
        let view = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closePressed))
        return view
    }()

    // MARK: UI - ActivityIndicator
    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        return view
    }()

    // MARK: UI - Fallback
    public lazy var fallbackView: MiniAppFallbackViewable = {
        let view = FallbackView()
        view.isHidden = true
        return view
    }()

    init(
        title: String,
        appId: String,
        version: String? = nil,
        config: MiniAppSdkConfig? = nil,
        messageDelegate: MiniAppMessageDelegate,
        navDelegate: MiniAppNavigationDelegate? = nil,
        queryParams: String? = nil,
        adsDisplayer: MiniAppAdDisplayer? = nil,
        enableSharePreview: Bool = false,
        loadFromCacheIfFailed: Bool = false
    ) {
        self.appId = appId
        self.version = version
        self.config = config
        self.messageDelegate = messageDelegate
        self.navDelegate = navDelegate
        self.queryParams = queryParams
        self.adsDisplayer = adsDisplayer
        self.enableSharePreview = enableSharePreview
        self.loadFromCacheIfFailed = loadFromCacheIfFailed
        super.init(nibName: nil, bundle: nil)
        self.title = title
        if navDelegate == nil {
            self.navDelegate = self
        }
    }

    required init?(coder: NSCoder) { return nil }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupMiniApp()
        setupFallback()
    }

    func setupUI() {

        view.backgroundColor = .white

        if navigationController != nil {
            if navigationItem.leftBarButtonItems == nil {
                navigationItem.setLeftBarButtonItems([backButton, forwardButton], animated: true)
            }
            if navigationItem.rightBarButtonItems == nil {
                navigationItem.setRightBarButtonItems(
                    enableSharePreview ? [closeButton, shareButton] : [closeButton], animated: true
                )
            }
        }

        view.addSubview(activityIndicatorView)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        view.addSubview(fallbackView)
        fallbackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            fallbackView.topAnchor.constraint(equalTo: view.topAnchor),
            fallbackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            fallbackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            fallbackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        backButton.isEnabled = false
        forwardButton.isEnabled = false
    }

    func setupMiniApp() {

        state = .loading

        guard let messageDelegate = messageDelegate else { return }
        let navSettings = MiniAppNavigationConfig(
            navigationBarVisibility: .never,
            navigationDelegate: navDelegate,
            customNavigationView: nil
        )
        MiniApp
            .shared(with: config, navigationSettings: navSettings)
            .create(
                appId: appId,
                version: version,
                queryParams: queryParams,
                completionHandler: { [weak self] (result) in
                    guard let self = self else { return }
                    switch result {
                    case .success(let miniAppDisplay):
                        let view = miniAppDisplay.getMiniAppView()
                        view.frame = self.view.bounds
                        self.view.addSubview(view)
                        self.navBarDelegate = miniAppDisplay as? MiniAppNavigationBarDelegate
                        self.miniAppUiDelegate?.miniApp(self, didLoadWith: nil)
                        self.state = .success
                    case .failure(let error):
                        if self.loadFromCacheIfFailed {
                            self.loadFromCache(navSettings: navSettings, messageDelegate: messageDelegate)
                        } else {
                            self.miniAppUiDelegate?.miniApp(self, didLoadWith: error)
                            self.state = .error
                        }
                    }
                },
                messageInterface: messageDelegate,
                adsDisplayer: adsDisplayer
            )
    }

    func loadFromCache(navSettings: MiniAppNavigationConfig?, messageDelegate: MiniAppMessageDelegate) {
        MiniApp
            .shared(with: config, navigationSettings: navSettings)
            .create(
                appId: appId,
                version: version,
                queryParams: queryParams,
                completionHandler: { [weak self] (result) in
                    guard let self = self else { return }
                    switch result {
                    case .success(let miniAppDisplay):
                        let view = miniAppDisplay.getMiniAppView()
                        view.frame = self.view.bounds
                        self.view.addSubview(view)
                        self.navBarDelegate = miniAppDisplay as? MiniAppNavigationBarDelegate
                        self.miniAppUiDelegate?.miniApp(self, didLoadWith: nil)
                        self.state = .success
                    case .failure(let error):
                        self.miniAppUiDelegate?.miniApp(self, didLoadWith: error)
                        self.state = .error
                    }
                },
                messageInterface: messageDelegate,
                adsDisplayer: adsDisplayer,
                fromCache: true
            )
    }

    func setupFallback() {
        fallbackView.onRetry = { [weak self] in
            guard let self = self else { return }
            self.setupMiniApp()
        }
    }

    func update() {
        DispatchQueue.main.async {
            switch self.state {
            case .loading:
                self.activityIndicatorView.startAnimating()
                self.fallbackView.isHidden = true
            case .error:
                self.activityIndicatorView.stopAnimating()
                self.fallbackView.isHidden = false
            case .success:
                self.activityIndicatorView.stopAnimating()
                self.fallbackView.isHidden = true
            }
        }
    }

    @objc
    public func backPressed() {
        navBarDelegate?.miniAppNavigationBar(didTriggerAction: .back)
    }

    @objc
    public func forwardPressed() {
        navBarDelegate?.miniAppNavigationBar(didTriggerAction: .forward)
    }

    @objc
    public func closePressed() {
        if miniAppUiDelegate == nil {
            dismiss(animated: true, completion: nil)
        } else {
            miniAppUiDelegate?.onClose()
        }
    }

    public func refreshNavigationBarButtons(backButtonEnabled: Bool, forwardButtonEnabled: Bool) {
        backButton.isEnabled = backButtonEnabled
        forwardButton.isEnabled = forwardButtonEnabled
    }

    // MARK: - Sharing
    @objc
    public func sharePressed() {
        MiniApp
            .shared(with: config, navigationSettings: .none)
            .info(miniAppId: appId, miniAppVersion: version) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let info):
                    guard
                        let text = info.promotionalText,
                        let imageUrl = info.promotionalImageUrl
                    else {
                        return
                    }
                    DispatchQueue.main.async {
                        self.showShareAlert(text: text, imageUrl: imageUrl)
                    }
                case .failure(let error):
                    print(error)
                }
        }
    }

    private func showShareAlert(text: String, imageUrl: String) {
        let shareVC = MiniAppSharePreviewViewController(promotionText: text, promotionImageUrl: imageUrl)
        let nvc = UINavigationController(rootViewController: shareVC)
        nvc.navigationBar.isTranslucent = false
        nvc.navigationBar.barTintColor = .systemBackground
        present(nvc, animated: true, completion: nil)
    }
}

// MARK: - MiniAppNavigationDelegate
extension MiniAppViewController: MiniAppNavigationDelegate {

    /// will be used soon when knowing the cases to react to
    public func miniAppNavigation(shouldOpen url: URL, with responseHandler: @escaping MiniAppNavigationResponseHandler) {
        // Implement navigation handling when necessary (todo raises a swiftlint error)
    }

}
