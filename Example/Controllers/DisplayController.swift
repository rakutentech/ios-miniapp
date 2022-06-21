import UIKit
import MiniApp

class DisplayController: RATViewController {

    @IBOutlet var backButton: UIBarButtonItem!
    @IBOutlet var forwardButton: UIBarButtonItem!
    weak var navBarDelegate: MiniAppNavigationBarDelegate?
    weak var miniAppDisplayDelegate: MiniAppDisplayDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.pageName = MASDKLocale.localize("demo.app.rat.page.name.display.miniapp")
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShown), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHidden), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidAppear(_ animated: Bool) {
        guard let controller = self.navigationController as? DisplayNavigationController,
              let miniAppDisplay = controller.miniAppDisplay else {
            return
        }

        title = controller.miniAppInfo?.displayName ?? "Mini app"
        miniAppDisplayDelegate = miniAppDisplay
        let miniAppView = miniAppDisplay.getMiniAppView()
        miniAppView.frame = view.bounds
        navBarDelegate = miniAppDisplay as? MiniAppNavigationBarDelegate
        view.addSubview(miniAppView)
        backButton.isEnabled = false
        forwardButton.isEnabled = false
    }

    @IBAction func done(_ sender: UIBarButtonItem) {
        if let alertInfo = navBarDelegate?.miniAppShouldClose(), alertInfo.shouldDisplay ?? false {
            let alertController = UIAlertController(title: alertInfo.title, message: alertInfo.description, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: MASDKLocale.localize(.ok), style: .default, handler: { (_) in
                self.dismiss(animated: true, completion: nil)
            }))
            alertController.addAction(UIAlertAction(title: MASDKLocale.localize(.cancel), style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }

    func refreshNavigationBarButtons(backButtonEnabled: Bool, forwardButtonEnabled: Bool) {
        backButton.isEnabled = backButtonEnabled
        forwardButton.isEnabled = forwardButtonEnabled
    }

    @IBAction func navigate(_ sender: UIBarButtonItem) {
        switch sender {
        case backButton:
            self.navBarDelegate?.miniAppNavigationBar(didTriggerAction: .back)
        case forwardButton:
            self.navBarDelegate?.miniAppNavigationBar(didTriggerAction: .forward)
        default:
            break
        }
    }

    @objc
    func keyboardShown(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        let navigationBarHeight = (navigationController?.navigationBar.bounds.height ?? 0) + (view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0)
        let screenHeight = view.bounds.height - navigationBarHeight
        let keyboardHeight = keyboardViewEndFrame.height
        MiniApp.shared(with: Config.current()).keyboardShown(navigationBarHeight: navigationBarHeight, screenHeight: screenHeight, keyboardheight: keyboardHeight)
    }

    @objc
    func keyboardHidden(notification: Notification) {
        MiniApp.shared(with: Config.current()).keyboardHidden(navigationBarHeight: 0, screenHeight: 0, keyboardheight: 0)
    }
}
