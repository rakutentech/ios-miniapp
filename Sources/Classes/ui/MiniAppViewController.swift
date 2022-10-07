import Foundation
import UIKit

// swiftlint:disable function_body_length

/// Protocol to track Miniapp loading/Close status
public protocol MiniAppUIDelegate: AnyObject {
    /// Interface that is used to get controller and config
    func miniApp(_ viewController: MiniAppViewController, didLaunchWith config: MiniAppSdkConfig?)
    /// Interface that is used to get controller and navigation action
    func miniApp(_ viewController: MiniAppViewController, shouldExecute action: MiniAppNavigationAction)
    /// Interface that is used to notify if Mini app failed to load
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

/// ViewController that can be used by Host app to display a MiniApp
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

    var miniAppView: MiniAppViewable?

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

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    required init?(coder: NSCoder) { return nil }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupMiniApp()
        setupFallback()
    }

    /// Overridden viewDidAppear to send analytics
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.sendCustomEvent(
            MiniAppEvent.Event(
                miniAppId: appId,
                miniAppVersion: version ?? "",
                type: .resume,
                comment: "MiniApp view did appear"
            )
        )
    }

    /// Overridden viewWillDisappear to send analytics
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.sendCustomEvent(
            MiniAppEvent.Event(
                miniAppId: appId,
                miniAppVersion: version ?? "",
                type: .pause,
                comment: "MiniApp view will disappear"
            )
        )
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
        updateNavigationBar()
        backButton.isEnabled = false
        forwardButton.isEnabled = false

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShown), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHidden), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func updateNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
    }

    @objc
    func keyboardShown(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        let navigationBarHeight = (navigationController?.navigationBar.bounds.height ?? 0) + (view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0)
        let screenHeight = view.bounds.height - navigationBarHeight
        let keyboardHeight = keyboardViewEndFrame.height
        MiniApp.shared(with: config).keyboardShown(navigationBarHeight: navigationBarHeight, screenHeight: screenHeight, keyboardheight: keyboardHeight)
    }

    @objc
    func keyboardHidden(notification: Notification) {
        MiniApp.shared(with: config).keyboardHidden(navigationBarHeight: 0, screenHeight: 0, keyboardheight: 0)
    }

    func setupMiniApp() {
        state = .loading

        guard let messageDelegate = messageDelegate else { return }

        let miniAppParams = MiniAppViewParameters.default(
            .init(
                config: MiniAppConfig(
                    config: config,
                    adsDisplayer: adsDisplayer,
                    messageDelegate: messageDelegate,
                    navigationDelegate: navDelegate
                ),
                type: .miniapp,
                appId: appId,
                version: version,
                queryParams: queryParams
            )
        )

        let miniAppView: MiniAppViewable = MiniAppView(params: miniAppParams)
        miniAppView.progressStateView = MiniAppProgressView()
        self.miniAppView = miniAppView
        self.navBarDelegate = miniAppView

        miniAppView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(miniAppView)
        NSLayoutConstraint.activate([
            miniAppView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            miniAppView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            miniAppView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            miniAppView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        miniAppView.load { result in
            switch result {
            case .success: ()
            case let .failure(error):
                if error.isQPSLimitError() {
                    self.miniAppUiDelegate?.miniApp(self, didLoadWith: error)
                    self.state = .error
                } else {
                    if self.loadFromCacheIfFailed {
                        miniAppView.load(fromCache: true) { result in
                            switch result {
                            case .success: ()
                            case let .failure(error):
                                self.miniAppUiDelegate?.miniApp(self, didLoadWith: error)
                                self.state = .error
                            }
                        }
                    } else {
                        self.miniAppUiDelegate?.miniApp(self, didLoadWith: error)
                        self.state = .error
                    }
                }
            }
        }
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
    /// Method that is called when back button is pressed
    public func backPressed() {
        navBarDelegate?.miniAppNavigationBar(didTriggerAction: .back)
    }

    @objc
    /// Method that is called when forward button is pressed
    public func forwardPressed() {
        navBarDelegate?.miniAppNavigationBar(didTriggerAction: .forward)
    }

    @objc
    /// Method that is called when mini app is closed
    public func closePressed() {
        if let alertInfo = navBarDelegate?.miniAppShouldClose(), alertInfo.shouldDisplay ?? false {
            let alertController = UIAlertController(title: alertInfo.title, message: alertInfo.description, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: MASDKLocale.localize(.ok), style: .default, handler: { (_) in
                self.closeMiniApp()
            }))
            alertController.addAction(UIAlertAction(title: MASDKLocale.localize(.cancel), style: .cancel, handler: nil))
            UIApplication.topViewController()?.present(alertController, animated: true, completion: nil)
        } else {
            self.closeMiniApp()
        }
    }

    func closeMiniApp() {
        if miniAppUiDelegate == nil {
            dismiss(animated: true, completion: nil)
        } else {
            miniAppUiDelegate?.onClose()
        }
    }
    /// Method that is called when navigation buttons need to be refreshed
    public func refreshNavigationBarButtons(backButtonEnabled: Bool, forwardButtonEnabled: Bool) {
        backButton.isEnabled = backButtonEnabled
        forwardButton.isEnabled = forwardButtonEnabled
    }

    // MARK: - Sharing
    @objc
    /// Method that is called when share button is pressed
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
                    MiniAppLogger.e("Could not retrieve info", error)
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
