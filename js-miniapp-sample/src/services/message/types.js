const SET_MESSAGE_TYPES = 'GET_MESSAGE_TYPE';

export const MessageTypeId = {
  SINGLE_CONTACT: 1,
  SINGLE_CONTACT_ID: 2,
  MULTIPLE_CONTACTS: 3,
};

type MessageType = {
  id: number,
  name: string,
};

type SetMessageTypeAction = {
  type: string,
  payload: Array<MessageType>,
};

export { SET_MESSAGE_TYPES };
export type { MessageType, SetMessageTypeAction };
