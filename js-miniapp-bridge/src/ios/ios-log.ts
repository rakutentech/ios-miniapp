/* tslint:disable:no-any */
import { MiniAppSDKLogger, PlatformLogger } from '../common-log';

class IOSSDKLogger implements PlatformLogger {
  log(emoji, type, args) {
    (window as any).webkit.messageHandlers.MiniAppLogging.postMessage(
      `${emoji} console.${type}: ${Object.values(args)
        .map(v =>
          typeof v === 'undefined'
            ? 'undefined'
            : typeof v === 'object'
            ? JSON.stringify(v)
            : v.toString()
        )
        .map(v => v.substring(0, 3000)) // Limit msg to 3000 chars
        .join(', ')}`
    );
  }
}

const iOSLogger = new IOSSDKLogger();
(window as any).MiniAppSDKLogger = new MiniAppSDKLogger(iOSLogger);
