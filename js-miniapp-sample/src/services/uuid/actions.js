import MiniApp from 'js-miniapp-sdk';

import { getUUIDFromMobileSdk, isMobile } from './../../js_sdk';
import { SET_UUID, UUID_FETCH_ERROR } from './types';

type GetUUIDAction = { type: String, payload: string };

type UUIDAction = GetUUIDAction;

const setUUID = (): Function => {
  return (dispatch) => {
    if (!isMobile()) {
      const uuid = getUUIDFromMobileSdk();
      dispatch({
        type: SET_UUID,
        payload: uuid,
      });
    } else {
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
    }
  };
};

export { setUUID };
export type { UUIDAction };
