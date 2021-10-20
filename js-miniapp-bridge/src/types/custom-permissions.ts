export enum CustomPermissionName {
  USER_NAME = 'rakuten.miniapp.user.USER_NAME',
  PROFILE_PHOTO = 'rakuten.miniapp.user.PROFILE_PHOTO',
  CONTACT_LIST = 'rakuten.miniapp.user.CONTACT_LIST',
  ACCESS_TOKEN = 'rakuten.miniapp.user.ACCESS_TOKEN',
  LOCATION = 'rakuten.miniapp.device.LOCATION',
  SEND_MESSAGE = 'rakuten.miniapp.user.action.SEND_MESSAGE',
  POINTS = 'rakuten.miniapp.user.POINTS',
  FILE_DOWNLOAD = 'rakuten.miniapp.device.FILE_DOWNLOAD',
}

export enum CustomPermissionStatus {
  ALLOWED = 'ALLOWED',
  DENIED = 'DENIED',
  PERMISSION_NOT_AVAILABLE = 'PERMISSION_NOT_AVAILABLE',
}

export interface CustomPermission {
  name: CustomPermissionName;
  description: string;
}

export interface CustomPermissionResult {
  name: CustomPermissionName;
  status: CustomPermissionStatus;
}

export interface CustomPermissionResponse {
  permissions: CustomPermissionResult[];
}
