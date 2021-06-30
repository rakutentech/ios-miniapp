/** @internal */

/**
 * Main entry point for SDK
 */

import {
  Reward,
  CustomPermission,
  CustomPermissionName,
  CustomPermissionStatus,
  CustomPermissionResult,
  ShareInfoType,
  ScreenOrientation,
  AccessTokenData,
  Contact,
  Points,
  MessageToContact,
  MiniAppError,
  AudienceNotSupportedError,
  AuthorizationFailureError,
  ScopesNotSupportedError,
} from '../../js-miniapp-bridge/src';

import { MiniApp } from './miniapp';

/** @internal */
const miniAppInstance = new MiniApp();

export default miniAppInstance;
export {
  CustomPermission,
  CustomPermissionName,
  CustomPermissionStatus,
  CustomPermissionResult,
  Reward,
  ShareInfoType,
  ScreenOrientation,
  AccessTokenData,
  Contact,
  Points,
  MessageToContact,
  MiniAppError,
  AudienceNotSupportedError,
  AuthorizationFailureError,
  ScopesNotSupportedError,
};
