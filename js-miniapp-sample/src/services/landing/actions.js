import { REQUEST_HOST_ENVIRONMENT_INFO_SUCCESS, REQUEST_HOST_ENVIRONMENT_INFO_ERROR } from './types';
import MiniApp from 'js-miniapp-sdk';
import { HostEnvironmentInfo } from 'js-miniapp-sdk';

type RequestHostInfoSuccessAction = { type: String, info: HostEnvironmentInfo };

const setHostEnvironmentInfo = (): Function => {
  return (dispatch) => {
    MiniApp.getHostEnvironmentInfo()
      .then((info) => {
        dispatch({
          type: REQUEST_HOST_ENVIRONMENT_INFO_SUCCESS,
          info: info,
        });
      })
      .catch((error) => {
        dispatch({
          type: REQUEST_HOST_ENVIRONMENT_INFO_ERROR,
          error,
        });
      });
  };
};

export { setHostEnvironmentInfo };
export type { RequestHostInfoSuccessAction };
