import { MessageToContact } from '../../../js-miniapp-bridge/src';
import { getBridge } from '../utils';

interface ChatServiceProvider {
  /**
   * Opens a contact chooser which allows the user to choose a single contact,
   * and then sends the message to the chosen contact.
   * @param message The message to send to contact.
   * @returns Promise resolves with the contact id received a message.
   * Can also resolve with empty (undefined) response in the case that the message was not sent to a contact, such as if the user cancelled sending the message.
   * Promise rejects in the case that there was an error.
   */
  sendMessageToContact(message: MessageToContact): Promise<string | undefined>;

  /**
   * Send a message to the specific contact.
   * @param id The id of the contact receiving a message.
   * @param message The message to send to contact.
   * @returns Promise resolves with the contact id received a message.
   * @see {sendMessageToContact}
   */
  sendMessageToContactId(
    id: string,
    message: MessageToContact
  ): Promise<string | undefined>;

  /**
   * Opens a contact chooser which allows the user to choose a multiple contacts
   * and then sends the message to the all chosen contacts.
   * @param message The message to send to contact.
   * @returns Promise resolves with an array of contact id which were sent the message.
   * Can also resolve with an empty array in the case that the message was not sent to any contacts, such as if the user cancelled sending the message.
   * Promise rejects in the case that there was an error.
   */
   sendMessageToMultipleContacts(message: MessageToContact): Promise<string[] | undefined>;
}

/** @internal */
export class ChatService {
  sendMessageToContact(message: MessageToContact): Promise<string | undefined> {
    return getBridge().sendMessageToContact(message);
  }

  sendMessageToContactId(
    id: string,
    message: MessageToContact
  ): Promise<string | undefined> {
    return getBridge().sendMessageToContactId(id, message);
  }

  sendMessageToMultipleContacts(message: MessageToContact): Promise<string[] | undefined> {
    return getBridge().sendMessageToMultipleContacts(message);
  }
}
