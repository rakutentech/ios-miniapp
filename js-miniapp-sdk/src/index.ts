/** @internal */

/**
 * Main entry point for SDK
 */

import { MiniApp } from './miniapp';
import { AdTypes } from './types/adTypes';
import { Reward } from './types/responseTypes/rewarded';
import { ShareInfoType } from './types/ShareInfoType';
import {
  CustomPermission,
  CustomPermissionName,
  CustomPermissionStatus,
  CustomPermissionResult,
} from './types/CustomPermission';

/** @internal */
const miniAppInstance = new MiniApp();

export default miniAppInstance;
export {
  AdTypes,
  CustomPermission,
  CustomPermissionName,
  CustomPermissionStatus,
  CustomPermissionResult,
  Reward,
  ShareInfoType,
};
