import type { RequestHostInfoSuccessAction } from './actions';
import { HostEnvironmentInfo } from 'js-miniapp-sdk';
import { REQUEST_HOST_ENVIRONMENT_INFO_SUCCESS } from './types';

const defaultInfo = {};
const HostEnvironmentInfoReducer = (
  state: ?HostEnvironmentInfo = defaultInfo,
  action: RequestHostInfoSuccessAction
): ?HostEnvironmentInfo => {
  switch (action.type) {
    case REQUEST_HOST_ENVIRONMENT_INFO_SUCCESS:
      return action.info;
    default:
      return state;
  }
};

export { HostEnvironmentInfoReducer };
