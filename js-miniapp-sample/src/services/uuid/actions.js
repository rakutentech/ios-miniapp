import MiniApp from 'js-miniapp-sdk';

import { SET_UUID, UUID_FETCH_ERROR } from './types';

type GetUUIDAction = { type: String, payload: string };

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
      .catch((_) => {
        dispatch({
          type: UUID_FETCH_ERROR,
        });
      });
  };
};

export { setUUID };
export type { UUIDAction };
