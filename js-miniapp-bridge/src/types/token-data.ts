/** @internal */
export interface NativeTokenData {
  token: string;
  validUntil: number;
}

/** Token data type. */
export class AccessTokenData {
  readonly token: string;
  readonly validUntil: Date;

  constructor(baseToken: NativeTokenData) {
    this.token = baseToken.token;
    this.validUntil = new Date(baseToken.validUntil);
  }
}
