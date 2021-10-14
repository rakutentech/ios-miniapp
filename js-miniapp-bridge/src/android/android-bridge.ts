import {
  PlatformExecutor,
  MiniAppBridge,
  Callback,
  mabMessageQueue,
} from '../common-bridge';
import { Platform } from '../types/platform';

/* tslint:disable:no-any */
let uniqueId = Math.random();

class AndroidExecutor implements PlatformExecutor {
  execEvents(event) {
    (window as any).dispatchEvent(event);
  }
  exec(action, param, onSuccess, onError) {
    const callback = {} as Callback;
    callback.onSuccess = onSuccess;
    callback.onError = onError;
    callback.id = String(++uniqueId);
    mabMessageQueue.unshift(callback);

    (window as any).MiniAppAndroid.postMessage(
      JSON.stringify({ action, param, id: callback.id })
    );
  }

  getPlatform(): string {
    return Platform.ANDROID;
  }
}

(window as any).MiniAppBridge = new MiniAppBridge(new AndroidExecutor());
