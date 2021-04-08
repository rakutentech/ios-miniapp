import MiniApp
import CoreLocation
import UIKit

extension ViewController: ContactsListDelegate {
    func contactsController(_ contactsController: ContactsListSettingsTableViewController?, didSelect contacts: [MAContact]?) {
        if let contactsList = contacts {
            if let controller = contactsController,
               !controller.allowMultipleSelection {
                controller.dismiss(animated: true) {
                    self.messageHandlerObj?(.success(contactsList.first?.id))
                }
            }
        } else {
            messageHandlerObj?(.success(nil))
            messageIdHandlerObj?(.success(nil))
            messageMultipleHandlerObj?(.success(nil))
        }
    }
}

extension ViewController: ChatMessageBridgeDelegate {
    typealias ChatContactHandler = (Result<String?, MASDKError>) -> Void
    typealias ChatContactsHandler = (Result<[String]?, MASDKError>) -> Void

    public func sendMessageToContact(_ message: MessageToContact, completionHandler: @escaping ChatContactHandler) {
        presentContactsPicker { controller in
            switchCancelHandler(messageHandler: completionHandler)
            controller.message = message
            controller.title = NSLocalizedString("Pick a contact", comment: "")
        }
    }

    public func sendMessageToContact(_ contactId: String, message: MessageToContact, completionHandler: @escaping ChatContactHandler) {
        if let contacts = getContacts(), let contact = contacts.first(where: { $0.id == contactId }) {
            presentContactsPicker { chatContactsSelectorViewController in
                switchCancelHandler(singleIdHandler: completionHandler)
                chatContactsSelectorViewController.contactToSend = contact
                chatContactsSelectorViewController.contactHandlerJob = completionHandler
                chatContactsSelectorViewController.message = message
                chatContactsSelectorViewController.title = NSLocalizedString("Single contact", comment: "")
            }
        }
    }

    public func sendMessageToMultipleContacts(_ message: MessageToContact, completionHandler: @escaping ChatContactsHandler) {
        presentContactsPicker { chatContactsSelectorViewController in
            switchCancelHandler(messageMultipleHandler: completionHandler)
            chatContactsSelectorViewController.contactsHandlerJob = completionHandler
            chatContactsSelectorViewController.message = message
            chatContactsSelectorViewController.multipleSelection = true
            chatContactsSelectorViewController.title = NSLocalizedString("Select contacts", comment: "")
        }
    }

    func switchCancelHandler(messageHandler: ChatContactHandler? = nil, singleIdHandler: ChatContactHandler? = nil, messageMultipleHandler: ChatContactsHandler? = nil) {
        messageHandlerObj = messageHandler
        messageIdHandlerObj = singleIdHandler
        messageMultipleHandlerObj = messageMultipleHandler
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
