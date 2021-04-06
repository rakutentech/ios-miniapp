import Foundation
import UIKit

class MiniAppViewController: UIViewController {

    let appId: String
    var config: MiniAppSdkConfig?
    var queryParams: String?
    var state: ViewState = .loading {
        didSet { update() }
    }

    weak var messageDelegate: MiniAppMessageDelegate?
    weak var navDelegate: MiniAppNavigationDelegate?
    weak var navBarDelegate: MiniAppNavigationBarDelegate?

    var onError: ((Error) -> Void)?
    var onBackButton: (() -> Void)?
    var onForwardButton: (() -> Void)?

    // MARK: UI - Navigation
    private lazy var backButton: UIBarButtonItem = {
        let view = UIBarButtonItem(image: UIImage(named: "arrow_left")!, style: .plain, target: self, action: #selector(backPressed))
        return view
    }()

    private lazy var forwardButton: UIBarButtonItem = {
        let view = UIBarButtonItem(image: UIImage(named: "arrow_right")!, style: .plain, target: self, action: #selector(forwardPressed))
        return view
    }()

    private lazy var closeButton: UIBarButtonItem = {
        let view = UIBarButtonItem(title: "ui_close_button_title".localizedString(), style: .plain, target: self, action: #selector(closePressed))
        return view
    }()

    // MARK: UI - Fallback
    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        return view
    }()

    private lazy var fallbackView: FallbackView = {
        let view = FallbackView()
        view.isHidden = true
        return view
    }()

    init(appId: String, config: MiniAppSdkConfig?, messageDelegate: MiniAppMessageDelegate, navDelegate: MiniAppNavigationDelegate?, queryParams: String?) {
        self.appId = appId
        self.config = config
        self.queryParams = queryParams
        self.messageDelegate = messageDelegate
        self.navDelegate = navDelegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { return nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupMiniApp()
        setup()
    }

    func setupUI() {
        view.backgroundColor = .white
        navigationItem.setLeftBarButtonItems([backButton, forwardButton], animated: true)
        navigationItem.setRightBarButton(closeButton, animated: true)

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
    }

    func setupMiniApp() {

        state = .loading

        guard let messageDelegate = messageDelegate else { return }
        MiniApp.shared(with: config).create(
            appId: appId,
            queryParams: queryParams,
            completionHandler: { [weak self] (result) in
                guard let self = self else { return }
                switch result {
                case .success(let miniAppDisplay):
                    let view = miniAppDisplay.getMiniAppView()
                    view.frame = self.view.bounds
                    self.view.addSubview(view)
                    self.navBarDelegate = miniAppDisplay as? MiniAppNavigationBarDelegate
                    self.state = .success
                case .failure(let error):
                    self.onError?(error)
                    self.showFallback()
                    self.state = .error
                }
            },
            messageInterface: messageDelegate
        )
    }

    func setup() {
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
    func backPressed() {
        onBackButton?()
        navBarDelegate?.miniAppNavigationBar(didTriggerAction: .back)
    }

    @objc
    func forwardPressed() {
        onForwardButton?()
        navBarDelegate?.miniAppNavigationBar(didTriggerAction: .forward)
    }

    @objc
    func closePressed() {
        dismiss(animated: true, completion: nil)
    }

    private func showFallback() {
        DispatchQueue.main.async {
            self.fallbackView.isHidden = false
        }
    }

}
