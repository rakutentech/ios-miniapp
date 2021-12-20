import Foundation

public protocol ChatMessageBridgeDelegate: AnyObject {
    /// Triggered when Mini App wants to send a message to a contact.
    /// Should open a contact chooser which allows the user to choose a single contact,
    /// and should then send the message to the chosen contact.
    /// Should invoke completionHandler success with the ID of the contact which was sent the message.
    /// If the user cancelled sending the message, should invoke completionHandler success with nil value.
    /// Should invoke completionHandler error when there was an error.
    func sendMessageToContact(_ message: MessageToContact, completionHandler: @escaping (Result<String?, MASDKError>) -> Void)

    /// Triggered when Mini App wants to send a message to a specific contact.
    /// Should send a message to the specified contactId without any prompt to the User.
    /// Should invoke completionHandler success with the ID of the contact which was sent the message.
    /// If the user cancelled sending the message, should invoke completionHandler success with nil value.
    /// Should invoke completionHandler error when there was an error.
    func sendMessageToContactId(_ contactId: String, message: MessageToContact, completionHandler: @escaping (Result<String?, MASDKError>) -> Void)

    /// Triggered when Mini App wants to send a message to multiple contacts.
    /// Should open a contact chooser which allows the user to choose multiple contacts,
    /// and should then send the message to all chosen contacts.
    /// Should invoke completionHandler success with a list of IDs of the contacts which were successfully sent the message.
    /// If the user cancelled sending the message, should invoked completionHandler success with nil value.
    /// Should invoke completionHandler error when there was an error.
    func sendMessageToMultipleContacts(_ message: MessageToContact, completionHandler: @escaping (Result<[String]?, MASDKError>) -> Void)
}
