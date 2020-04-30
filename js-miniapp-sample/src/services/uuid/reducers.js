import type { UUIDAction } from './actions';
import { SET_UUID, UUID_FETCH_ERROR } from './types';

type UUIDState = {
  +uuid: ?string,
};

const defaultState: UUIDState = {
  uuid: undefined,
};

const UUIDReducer = (
  state: UUIDState = defaultState,
  action: UUIDAction = {}
): UUIDState => {
  if (action.type === SET_UUID) {
    return { ...defaultState, uuid: action.payload };
  } else if (action.type === UUID_FETCH_ERROR) {
    return { uuid: undefined };
  }
  return state;
};

export { UUIDReducer };
