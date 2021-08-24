import MiniApp
import CoreLocation
import UIKit

extension ViewController: ChatMessageBridgeDelegate {
    typealias ChatContactHandler = (Result<String?, MASDKError>) -> Void
    typealias ChatContactsHandler = (Result<[String]?, MASDKError>) -> Void

    public func sendMessageToContact(_ message: MessageToContact, completionHandler: @escaping ChatContactHandler) {
        presentContactsPicker { controller in
            controller.message = message
            controller.contactHandlerJob = completionHandler
            controller.title = NSLocalizedString("Pick a contact", comment: "")
        }
    }

    public func sendMessageToContactId(_ contactId: String, message: MessageToContact, completionHandler: @escaping ChatContactHandler) {
        getContacts { result in
            switch result {
            case .success(let contacts):
                if let contact = contacts?.first(where: { $0.id == contactId }) {
                    self.presentContactsPicker { chatContactsSelectorViewController in
                        chatContactsSelectorViewController.sendById = true
                        chatContactsSelectorViewController.contactHandlerJob = completionHandler
                        chatContactsSelectorViewController.message = message
                        chatContactsSelectorViewController.selectedContacts = [contact]
                        chatContactsSelectorViewController.title = NSLocalizedString("Single contact", comment: "")
                    }
                } else {
                    fallthrough
                }
            default:
                completionHandler(.failure(.invalidContactId))
            }
        }
    }

    public func sendMessageToMultipleContacts(_ message: MessageToContact, completionHandler: @escaping ChatContactsHandler) {
        presentContactsPicker { chatContactsSelectorViewController in
            chatContactsSelectorViewController.contactsHandlerJob = completionHandler
            chatContactsSelectorViewController.message = message
            chatContactsSelectorViewController.multipleSelection = true
            chatContactsSelectorViewController.title = NSLocalizedString("Select contacts", comment: "")
        }
    }

     func presentContactsPicker(controllerPresented: (() -> Void)? = nil, contactsPickerCreated: (ChatContactsSelectorViewController) -> Void) {
        if let viewController = UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "ChatContactsSelectorViewController") as? ChatContactsSelectorViewController {
            contactsPickerCreated(viewController)
            UINavigationController.topViewController()?.present(UINavigationController(rootViewController: viewController), animated: true, completion: controllerPresented)
        }
    }
}
