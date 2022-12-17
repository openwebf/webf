interface DOMTokenList {
  readonly length: int64;
  item(index: int64): string | null;
  contains(token: string): boolean;
  add(...tokens: string[]): void;
  remove(...tokens: string[]): void;
  toggle(token: string, force?: boolean): boolean;
  replace(token: string, newToken: string): boolean;
  supports(token: string): boolean;
  value: string;
  new(): void;
}