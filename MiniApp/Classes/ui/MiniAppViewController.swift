import Foundation
import UIKit

class MiniAppViewController: UIViewController {

    let appId: String
    var config: MiniAppSdkConfig?
    var queryParams: String?

    weak var messageDelegate: MiniAppMessageDelegate?
    weak var navDelegate: MiniAppNavigationDelegate?
    weak var navBarDelegate: MiniAppNavigationBarDelegate?

    var onError: ((Error) -> Void)?
    var onBackButton: (() -> Void)?
    var onForwardButton: (() -> Void)?

    // MARK: UI
    lazy var backButton: UIBarButtonItem = {
        let view = UIBarButtonItem(image: UIImage(named: "arrow_left")!, style: .plain, target: self, action: #selector(backPressed))
        return view
    }()

    lazy var forwardButton: UIBarButtonItem = {
        let view = UIBarButtonItem(image: UIImage(named: "arrow_right")!, style: .plain, target: self, action: #selector(forwardPressed))
        return view
    }()

    lazy var closeButton: UIBarButtonItem = {
        let view = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closePressed))
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
    }

    func setupUI() {
        view.backgroundColor = .white
        navigationItem.setLeftBarButtonItems([backButton, forwardButton], animated: true)
        navigationItem.setRightBarButton(closeButton, animated: true)
    }

    func setupMiniApp() {
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
                case .failure(let error):
                    self.onError?(error)
                }
            },
            messageInterface: messageDelegate
        )
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

}
