import MiniApp from 'js-miniapp-sdk';

import { SET_UUID, UUID_FETCH_ERROR } from './types';

type GetUUIDAction = { type: String, payload: ?string, error: ?string };

type UUIDAction = GetUUIDAction;

const setUUID = (): Function => {
  return (dispatch) => {
    MiniApp.getUniqueId()
      .then((uuidFromSDK) => {
        dispatch({
          type: SET_UUID,
          payload: uuidFromSDK,
        });
      })
      .catch((error) => {
        dispatch({
          type: UUID_FETCH_ERROR,
          error,
        });
      });
  };
};

export { setUUID };
export type { UUIDAction };
