import { OS } from './dataType.js';

// tslint:disable-next-line:no-namespace
export namespace MiniApp {
  export interface MiniAppInterface {
    getUniqueId(): string;
  }

  export class MiniAppImpl implements MiniAppInterface {
    getOS(): OS {
      if (window.navigator.userAgent.match(/Android/i)) {
        return OS.Android;
      } else if (window.navigator.userAgent.match(/iPhone|iPad|iPod/i)) {
        return OS.iOS;
      } else {
        return OS.Unknown;
      }
    }

    /* tslint:disable:no-any */
    getUniqueId(): string {
      if (this.getOS() === OS.iOS) {
        return (window as any).webkit.messageHandlers.MiniApp.getUniqueId();
      } else {
        return (window as any).MiniApp.getUniqueId();
      }
    }
  }
}
