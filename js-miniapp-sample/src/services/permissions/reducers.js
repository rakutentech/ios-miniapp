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
      const denied = action.permissions
        .filter((it) => it.status === CustomPermissionStatus.DENIED)
        .map((it) => it.name);
      const allowed = action.permissions
        .filter((it) => it.status === CustomPermissionStatus.ALLOWED)
        .map((it) => it.name);

      const array = state
        .concat(allowed)
        .filter((permission) => denied.indexOf(permission) <= -1);

      return Array.from(new Set(array));
    default:
      return state;
  }
};

export { grantedPermissionsReducer };
