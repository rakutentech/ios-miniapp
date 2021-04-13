import { SET_MESSAGE_TYPES } from './types';
import type { SetMessageTypeAction } from './types';
import MiniApp from 'js-miniapp-sdk';
import { MessageToContact } from 'js-miniapp-sdk';

const getMessageTypeList = (): SetMessageTypeAction => {
  return {
    type: SET_MESSAGE_TYPES,
    payload: [
      {
        id: 1,
        name: 'Send a message to a single contact',
      },
      {
        id: 2,
        name: 'Send a message to a specific contact',
      },
      {
        id: 3,
        name: 'Send a message to multiple contacts',
      },
    ],
  };
};

const sendMessageToContact = (
  image: String,
  text: String,
  caption: String,
  action: String
): Function => {
  return (dispatch) => {
    const messageToContact: MessageToContact = {
      text: text,
      image: image,
      caption: caption,
      action: action,
    };
    return MiniApp.chatService.sendMessageToContact(messageToContact);
  };
};

const sendMessageToContactId = (
  contactId: String,
  image: String,
  text: String,
  caption: String,
  action: String
): Function => {
  return (dispatch) => {
    const messageToContact: MessageToContact = {
      text: text,
      image: image,
      caption: caption,
      action: action,
    };
    return MiniApp.chatService.sendMessageToContactId(
      contactId,
      messageToContact
    );
  };
};

const sendMessageToMultipleContacts = (
  image: String,
  text: String,
  caption: String,
  action: String
): Function => {
  return (dispatch) => {
    const messageToContact: MessageToContact = {
      text: text,
      image: image,
      caption: caption,
      action: action,
    };
    return MiniApp.chatService.sendMessageToMultipleContacts(messageToContact);
  };
};

export {
  getMessageTypeList,
  sendMessageToContact,
  sendMessageToContactId,
  sendMessageToMultipleContacts,
};
