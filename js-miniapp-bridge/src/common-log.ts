/** @internal */
export interface PlatformLogger {
  log(...argumentsList): void;
}

/** @internal */
export function getLogger() {
  // tslint:disable:no-any
  if (typeof window !== 'undefined') {
    // when not running in webview or browser, window does not exist
    return (window as any).MiniAppSDKLogger as MiniAppSDKLogger;
  }
  return undefined;
}

/** @internal */
export class MiniAppSDKLogger {
  logger: PlatformLogger;
  lastLog;

  constructor(logger: PlatformLogger) {
    this.logger = logger;
  }

  logOnConsole(type, argumentsList) {
    getConsoleForLogType(type).apply(null, argumentsList);
  }

  log(type: LogType, argumentsList) {
    this.lastLog = {
      icon: type.icon,
      messageType: type.type,
      message: argumentsList,
    };
    this.logger.log(type.icon, type.type, argumentsList);
    this.logOnConsole(type, argumentsList);
  }
}

class LogType {
  static readonly debug = new LogType('debug', '📘');
  static readonly log = new LogType('log', '📗');
  static readonly warn = new LogType('warning', '📙');
  static readonly error = new LogType('error', '📕');

  private constructor(readonly type: string, readonly icon: string) {}
}

function getConsoleForLogType(type: LogType) {
  switch (type) {
    case LogType.debug:
      return originalDebug;
    case LogType.warn:
      return originalWarn;
    case LogType.error:
      return originalError;
    default:
      return originalLog;
  }
}

const originalLog = console.log;
const originalWarn = console.warn;
const originalError = console.error;
const originalDebug = console.debug;

function logMessage(type: LogType, argumentsList: any[]) {
  const logger = getLogger();
  if (logger !== undefined) {
    logger.log(type, argumentsList);
  } else {
    getConsoleForLogType(type).apply(null, argumentsList);
  }
}

console.log = (...argumentsList) => {
  logMessage(LogType.log, argumentsList);
};
console.warn = (...argumentsList) => {
  logMessage(LogType.warn, argumentsList);
};
console.error = (...argumentsList) => {
  logMessage(LogType.error, argumentsList);
};
console.debug = (...argumentsList) => {
  logMessage(LogType.debug, argumentsList);
};
