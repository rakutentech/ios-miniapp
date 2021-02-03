const SET_MESSAGE_TYPES = 'GET_MESSAGE_TYPE';

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
