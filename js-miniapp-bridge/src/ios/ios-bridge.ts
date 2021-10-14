import {
  PlatformExecutor,
  MiniAppBridge,
  Callback,
  mabMessageQueue,
} from '../common-bridge';
import { Platform } from '../types/platform';

/* tslint:disable:no-any */
let uniqueId = Math.random();

// tslint:disable-next-line: variable-name
const GeolocationPositionError = {
  PERMISSION_DENIED: 1,
  POSITION_UNAVAILABLE: 2,
  TIMEOUT: 3,
};

class IOSExecutor implements PlatformExecutor {
  execEvents(event): void {
    (window as any).dispatchEvent(event);
  }
  exec(action, param, onSuccess, onError) {
    const callback = {} as Callback;
    callback.onSuccess = onSuccess;
    callback.onError = onError;
    callback.id = String(++uniqueId);
    mabMessageQueue.unshift(callback);

    (window as any).webkit.messageHandlers.MiniAppiOS.postMessage(
      JSON.stringify({ action, param, id: callback.id })
    );
  }

  getPlatform(): string {
    return Platform.IOS;
  }
}

const iOSExecutor = new IOSExecutor();
(window as any).MiniAppBridge = new MiniAppBridge(iOSExecutor);

navigator.geolocation.getCurrentPosition = (success, error, options) => {
  return iOSExecutor.exec(
    'getCurrentPosition',
    { locationOptions: options },
    value => {
      try {
        const parsedData = JSON.parse(value);
        success(parsedData);
      } catch (error) {
        error({
          code: GeolocationPositionError.POSITION_UNAVAILABLE,
          message:
            'Failed to parse location object from MiniAppBridge: ' + error,
        });
      }
    },
    error => console.error(error)
  );
};
