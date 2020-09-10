import MiniApp, {
  CustomPermission,
  CustomPermissionResult,
} from 'js-miniapp-sdk';

import {
  REQUEST_PERMISSIONS_SUCCESS,
  REQUEST_PERMISSIONS_FAILURE,
} from './types';

type PermissionsSuccessAction = {
  type: String,
  permissions: CustomPermissionResult[],
};

const requestCustomPermissions = (
  requestedPermssions: CustomPermission[]
): Function => {
  return (dispatch) => {
    return MiniApp.requestCustomPermissions(requestedPermssions)
      .then((permissions) => {
        dispatch({
          type: REQUEST_PERMISSIONS_SUCCESS,
          permissions,
        });

        return permissions;
      })
      .catch((_) => {
        dispatch({
          type: REQUEST_PERMISSIONS_FAILURE,
        });
      });
  };
};

export { requestCustomPermissions };
export type { PermissionsSuccessAction };
