import { MiniAppBridge } from '../../js-miniapp-bridge/src';

/** @internal */
export function getBridge() {
  // tslint:disable:no-any
  return (window as any).MiniAppBridge as MiniAppBridge;
}
