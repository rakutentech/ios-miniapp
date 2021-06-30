/** @internal */

/**
 * Exports the types for Mini App Bridge
 */

import { MiniAppBridge } from './common-bridge';
import { AdTypes } from './types/ad-types';
import { Reward } from './types/response-types/rewarded';
import { DevicePermission } from './types/device-permission';
import {
  CustomPermission,
  CustomPermissionName,
  CustomPermissionStatus,
  CustomPermissionResult,
} from './types/custom-permissions';
import { ShareInfoType } from './types/share-info';
import { ScreenOrientation } from './types/screen';
import { AccessTokenData } from './types/token-data';
import { Contact } from './types/contact';
import { Points } from './types/points';
import { MessageToContact } from './types/message-to-contact';
import {
  MiniAppError,
  AudienceNotSupportedError,
  AuthorizationFailureError,
  ScopesNotSupportedError,
  parseMiniAppError,
  errorTypesDescriptions,
  MiniAppErrorType,
} from './types/error-types';

export {
  MiniAppBridge,
  AdTypes,
  Reward,
  DevicePermission,
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
  parseMiniAppError,
  errorTypesDescriptions,
  MiniAppErrorType,
};
