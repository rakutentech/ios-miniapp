import MiniApp
import CoreLocation
import UIKit

extension ViewController: ContactsListDelegate {
    func contactsController(_ contactsController: ContactsListSettingsTableViewController, didSelect contacts: [MAContact]?) {
        if !contactsController.allowMultipleSelection {
            contactsController.dismiss(animated: true) {
                self.messageHandlerObj?(.success(contacts?.first?.id))
            }
        }
    }
}

extension ViewController: ChatMessageBridgeDelegate {
    typealias ChatMessageHandler = (Result<String?, MASDKError>) -> Void
    typealias ChatContactHandler = (Result<Void, MASDKError>) -> Void
    typealias ChatContactsHandler = (Result<[String], MASDKError>) -> Void

    public func sendMessageToContact(_ message: MessageToContact, completionHandler: @escaping ChatMessageHandler) {
        presentContactsPicker { controller in
            messageHandlerObj = completionHandler
            controller.message = message
            controller.title = NSLocalizedString("Pick a contact", comment: "")
        }
    }

    public func sendMessageToContact(_ contactId: String, message: MessageToContact, completionHandler: @escaping ChatContactHandler) {
        messageHandlerObj = nil
        if let contacts = getContacts(), let contact = contacts.first(where: { $0.id == contactId }) {
            presentContactsPicker { chatContactsSelectorViewController in
                chatContactsSelectorViewController.contactToSend = contact
                chatContactsSelectorViewController.contactHandlerJob = completionHandler
                chatContactsSelectorViewController.message = message
                chatContactsSelectorViewController.title = NSLocalizedString("Single contact", comment: "")
            }
        }
    }

    public func sendMessageToMultipleContacts(_ message: MessageToContact, completionHandler: @escaping ChatContactsHandler) {
        presentContactsPicker { chatContactsSelectorViewController in
            messageHandlerObj = nil
            chatContactsSelectorViewController.contactsHandlerJob = completionHandler
            chatContactsSelectorViewController.message = message
            chatContactsSelectorViewController.multipleSelection = true
            chatContactsSelectorViewController.title = NSLocalizedString("Select contacts", comment: "")
        }
    }

    func presentContactsPicker(controllerPresented: (() -> Void)? = nil, contactsPickerCreated: (ChatContactsSelectorViewController) -> Void) {
        if let viewController = UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "ChatContactsSelectorViewController") as? ChatContactsSelectorViewController {
            viewController.contactDelegate = self
            contactsPickerCreated(viewController)
            UINavigationController.topViewController()?.present(UINavigationController(rootViewController: viewController), animated: true, completion: controllerPresented)
        }
    }
}
