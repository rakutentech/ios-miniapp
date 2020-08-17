import {
  PlatformExecutor,
  MiniAppBridge,
  Callback,
  mabMessageQueue,
} from '../common-bridge';

/* tslint:disable:no-any */
let uniqueId = Math.random();

class AndroidExcecutor implements PlatformExecutor {
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
}

(window as any).MiniAppBridge = new MiniAppBridge(new AndroidExcecutor());
