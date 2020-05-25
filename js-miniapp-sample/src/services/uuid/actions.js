import MiniApp from 'js-miniapp-sdk';

import { isMobile } from '../../js_sdk';
import { SET_UUID, UUID_FETCH_ERROR } from './types';

type GetUUIDAction = { type: String, payload: string };

type UUIDAction = GetUUIDAction;

const setUUID = (): Function => {
  return (dispatch) => {
    if (!isMobile()) {
      console.error('MiniApp must run inside Mobile to fetch UniqueId');
      dispatch({
        type: UUID_FETCH_ERROR,
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
