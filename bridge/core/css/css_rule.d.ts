export interface CSSRule {
  readonly type: double;
  readonly cssText: string;
  new(): void;
}
