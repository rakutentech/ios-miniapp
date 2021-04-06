import MiniApp
import CoreLocation

extension ViewController: ChatMessageBridgeDelegate, ContactsListDelegate {
    typealias ChatMessageHandler = (Result<String?, MASDKBaseError>) -> Void
    typealias ChatContactHandler = (Result<Void, MASDKBaseError>) -> Void
    typealias ChatContactsHandler = (Result<[String], MASDKBaseError>) -> Void

    func contactsController(_ contactsController: ContactsListSettingsTableViewController, didSelect contact: MAContact?) {
        contactsController.dismiss(animated: true) {
            self.messageHandlerObj?(.success(contact?.id))
        }
    }

    public func sendMessageToContact(_ message: MessageToContact, completionHandler: @escaping ChatMessageHandler) {
        if let viewController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "ChatContactsSelectorViewController") as? ChatContactsSelectorViewController {
            viewController.contactDelegate = self
            let navigationController = UINavigationController(rootViewController: viewController)
            navigationController.navigationItem.title = NSLocalizedString("Send message", comment: "")
            UIViewController.topViewController()?.present(navigationController, animated: true) {
                self.messageHandlerObj = completionHandler
                viewController.message = message
            }
        }
    }

    public func sendMessageToContact(_ contactId: String, completionHandler: @escaping ChatContactHandler) {
    }

    public func sendMessageToMultipleContacts(_ message: MessageToContact, completionHandler: @escaping ChatContactsHandler) {
    }
}
