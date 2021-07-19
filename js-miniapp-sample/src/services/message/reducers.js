import type { MessageType, SetMessageTypeAction } from './types';
import { MessageTypeId, SET_MESSAGE_TYPES } from './types';

type MessageTypeState = {
  messageTypes: Array<MessageType>,
};

const messageTypeState = {
  messageTypes: [
    {
      id: MessageTypeId.SINGLE_CONTACT,
      name: 'Send a message to a single contact',
    },
    {
      id: MessageTypeId.SINGLE_CONTACT_ID,
      name: 'Send a message to a specific contact',
    },
    {
      id: MessageTypeId.MULTIPLE_CONTACTS,
      name: 'Send a message to multiple contacts',
    },
  ],
};

export default (state: MessageTypeState, action: SetMessageTypeAction) => {
  if (action.type === SET_MESSAGE_TYPES) {
    return { ...state, messageTypes: action.payload };
  }
  return messageTypeState;
};
