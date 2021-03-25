/** @internal */
export interface NativeTokenData {
  token: string;
  validUntil: number;
  scopes: NativeTokenScopes;
}

/** @internal */
export interface NativeTokenScopes {
  audience: string;
  scopes: string[];
}

/** Token data type. */
export class AccessTokenData {
  readonly token: string;
  readonly validUntil: Date;
  readonly scopes: AccessTokenScopes;

  constructor(baseToken: NativeTokenData) {
    this.token = baseToken.token;
    this.validUntil = new Date(baseToken.validUntil);
    this.scopes = new AccessTokenScopes(baseToken.scopes);
  }
}

/** Token permission type. */
export class AccessTokenScopes {
  readonly audience: string;
  readonly scopes: string[];

  constructor(basePermission: NativeTokenScopes) {
    this.audience = basePermission.audience;
    this.scopes = basePermission.scopes;
  }
}
