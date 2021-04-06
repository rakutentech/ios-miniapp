import Foundation
import UIKit

public protocol MiniAppUIDelegate: class {
    func onError(error: Error)
    func onSuccess()
    func onForward()
    func onBackward()
    func onClose()
}
public extension MiniAppUIDelegate {
    func onError(error: Error) {}
    func onSuccess() {}
    func onForward() {}
    func onBackward() {}
}

public class MiniAppViewController: UIViewController {

    let appId: String
    var config: MiniAppSdkConfig?
    var queryParams: String?
    var state: ViewState = .loading {
        didSet { update() }
    }

    weak var messageDelegate: MiniAppMessageDelegate?
    weak var navDelegate: MiniAppNavigationDelegate?
    weak var navBarDelegate: MiniAppNavigationBarDelegate?

    weak var delegate: MiniAppUIDelegate?

    // MARK: UI - Navigation
    private lazy var backButton: UIBarButtonItem = {
        let view = UIBarButtonItem(image: UIImage(named: "arrow_left-24", in: Bundle.miniAppSDKBundle(), with: .none), style: .plain, target: self, action: #selector(backPressed))
        return view
    }()

    private lazy var forwardButton: UIBarButtonItem = {
        let view = UIBarButtonItem(image: UIImage(named: "arrow_right-24", in: Bundle.miniAppSDKBundle(), with: .none), style: .plain, target: self, action: #selector(forwardPressed))
        return view
    }()

    private lazy var closeButton: UIBarButtonItem = {
        let view = UIBarButtonItem(title: "ui_close_button_title".localizedString(), style: .plain, target: self, action: #selector(closePressed))
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

    init(title: String, appId: String, config: MiniAppSdkConfig? = nil, messageDelegate: MiniAppMessageDelegate, navDelegate: MiniAppNavigationDelegate? = nil, queryParams: String? = nil) {
        self.appId = appId
        self.config = config
        self.queryParams = queryParams
        self.messageDelegate = messageDelegate
        self.navDelegate = navDelegate
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }

    required init?(coder: NSCoder) { return nil }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupMiniApp()
        setup()
    }

    func setupUI() {

        view.backgroundColor = .white

        if navigationController != nil {
            if navigationItem.leftBarButtonItems == nil {
                navigationItem.setLeftBarButtonItems([backButton, forwardButton], animated: true)
            }
            if navigationItem.rightBarButtonItems == nil {
                navigationItem.setRightBarButton(closeButton, animated: true)
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
                    self.delegate?.onSuccess()
                    self.state = .success
                case .failure(let error):
                    self.delegate?.onError(error: error)
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
    public func backPressed() {
        if delegate == nil {
            delegate?.onBackward()
        } else {
            navBarDelegate?.miniAppNavigationBar(didTriggerAction: .back)
        }
    }

    @objc
    public func forwardPressed() {
        if delegate == nil {
            delegate?.onForward()
        } else {
            navBarDelegate?.miniAppNavigationBar(didTriggerAction: .forward)
        }
    }

    @objc
    public func closePressed() {
        if delegate == nil {
            dismiss(animated: true, completion: nil)
        } else {
            delegate?.onClose()
        }
    }

}
