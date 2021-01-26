@testable import MiniApp
import WebKit

class MockRealMiniAppView: RealMiniAppView {
    enum DialogButton {
        case okButton, cancelButton
    }

    var alertController: UIAlertController?

    override internal func presentAlert(alertController: UIAlertController) {
        self.alertController = alertController
    }

    func tapButton(_ button: DialogButton?) {
        if let title = button == .cancelButton ? "Cancel" : "OK" {
            tapAlertButton(title: title, actions: currentDialogController?.actions)
        }
    }

    func tapAlertButton(title: String, actions: [UIAlertAction]?) {
        typealias AlertHandler = @convention(block) (UIAlertAction) -> Void

        guard let action = alertController?.actions.first(where: { $0.title == title }), let block = action.value(forKey: "handler") else { return }
        let handler = unsafeBitCast(block as AnyObject, to: AlertHandler.self)
        handler(action)
    }
}
