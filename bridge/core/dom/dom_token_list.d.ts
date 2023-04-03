interface DOMTokenList {
  readonly length: int64;
  item(index: int64): string | null;
  contains(token: string): boolean;
  add(...tokens: string[]): void;
  remove(...tokens: string[]): void;
  toggle(token: string, force?: boolean): boolean;
  replace(token: string, newToken: string): boolean;
  supports(token: string): boolean;
  toString(): string;
  readonly [key: number]: string;
  value: string;
  readonly forEach: JSArrayProtoMethod;
  readonly keys: JSArrayProtoMethod;
  readonly entries: JSArrayProtoMethod;
  readonly values: JSArrayProtoMethod;
  readonly [Symbol.iterator]: JSArrayProtoMethod;
  new(): void;
}