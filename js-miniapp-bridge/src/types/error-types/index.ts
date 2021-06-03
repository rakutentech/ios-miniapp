/**
 * Enum for supported SDK error types
 */
export enum MiniAppErrorType {
  AudienceNotSupportedError = 'AudienceNotSupportedError',
  ScopesNotSupportedError = 'ScopesNotSupportedError',
  AuthorizationFailureError = 'AuthorizationFailureError',
}

interface MiniAppJson {
  message?: string;
  type?: string;
}

export function parseMiniAppError(jsonString: string): MiniAppJson {
  return JSON.parse(jsonString);
}

/**
 * This class is a representation of an error sent from MiniApp mobile SDK
 */
export class MiniAppError extends Error {
  constructor(public errorInput: MiniAppJson) {
    super();
    Object.setPrototypeOf(this, MiniAppError.prototype);
    this.name = errorInput.type;
    this.setMessage(errorInput.message);
  }

  protected setMessage(newMessage: string | undefined): void {
    if (newMessage !== undefined) {
      const enumKey = MiniAppErrorType[newMessage];
      if (enumKey !== undefined) {
        this.message = errorTypesDescriptions.get(enumKey);
      }
    }
    if (!this.message || /^\s*$/.test(this.message)) {
      this.message = newMessage;
    }
  }
}

export class AudienceNotSupportedError extends MiniAppError {
  constructor(public errorInput: MiniAppJson) {
    super(errorInput);
    Object.setPrototypeOf(this, AudienceNotSupportedError.prototype);
    super.setMessage(MiniAppErrorType.AudienceNotSupportedError);
  }
}

export class ScopesNotSupportedError extends MiniAppError {
  constructor(public errorInput: MiniAppJson) {
    super(errorInput);
    Object.setPrototypeOf(this, ScopesNotSupportedError.prototype);
    super.setMessage(MiniAppErrorType.ScopesNotSupportedError);
  }
}

export class AuthorizationFailureError extends MiniAppError {
  constructor(public errorInput: MiniAppJson) {
    super(errorInput);
    Object.setPrototypeOf(this, AuthorizationFailureError.prototype);
  }
}

export const errorTypesDescriptions = new Map<MiniAppErrorType, string>([
  [
    MiniAppErrorType.AudienceNotSupportedError,
    "The value passed for 'audience' is not supported.",
  ],
  [
    MiniAppErrorType.ScopesNotSupportedError,
    "The value passed for 'scopes' is not supported.",
  ],
]);
