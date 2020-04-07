/**
 * A module layer for webapps and mobile native interaction.
 */
export interface MiniAppInterface {
  /** @returns The Promise of provided id of mini app from injected side. */
  getUniqueId(): Promise<string>;
}

/* tslint:disable:no-any */
export class MiniApp implements MiniAppInterface {
  getUniqueId(): Promise<string> {
    return (window as any).MiniAppBridge.getUniqueId();
  }
}

module.exports = MiniApp;
