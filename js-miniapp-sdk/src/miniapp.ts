/**
 * A module layer for webapps and mobile native interaction.
 */
interface MiniApp {
  /** @returns The Promise of provided id of mini app from injected side. */
  getUniqueId(): Promise<string>;
}

/** @internal */
export class MiniAppImp implements MiniApp {
  getUniqueId(): Promise<string> {
    // tslint:disable-next-line:no-any
    return (window as any).MiniAppBridge.getUniqueId();
  }
}
