export enum CustomPermissionName {
  USER_NAME = 'rakuten.miniapp.user.USER_NAME',
  PROFILE_PHOTO = 'rakuten.miniapp.user.PROFILE_PHOTO',
  CONTACT_LIST = 'rakuten.miniapp.user.CONTACT_LIST',
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
