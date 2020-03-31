/**
 * Webapps (miniapps) interact with the mobile native via MiniApp namespace.
 * Required to be exported to use it as a module.
 * All functions of this namespace has no implentation because it will be injected
 * with interfaces from native SDK.
 */
export declare namespace MiniApp {
  export function getUniqueId(): Promise<string>;
}

module.exports = MiniApp;
