import { CustomPermissionName, CustomPermissionStatus } from 'js-miniapp-sdk';

import type { PermissionsSuccessAction } from './actions';
import { REQUEST_PERMISSIONS_SUCCESS } from './types';

const defaultState: CustomPermissionName[] = [];

const grantedPermissionsReducer = (
  state: CustomPermissionName[] = defaultState,
  action: PermissionsSuccessAction
): CustomPermissionName[] => {
  switch (action.type) {
    case REQUEST_PERMISSIONS_SUCCESS:
      return action.permissions
        .filter(
          (permission) => permission.status === CustomPermissionStatus.ALLOWED
        )
        .map((permission) => permission.name);
    default:
      return state;
  }
};

export { grantedPermissionsReducer };
