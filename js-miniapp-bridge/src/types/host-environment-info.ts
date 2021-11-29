import { Platform } from './platform';

/** HostEnvironmentInfo type. */
export interface HostEnvironmentInfo {
  platform?: Platform;
  platformVersion?: string;
  hostVersion?: string;
  sdkVersion?: string;
  hostLocale?: string;
}
