export interface CSSStyleDeclaration {
  cssText: string;

  // @ts-ignore
  readonly length: int64;
  // @ts-ignore
  getPropertyValue(property: string): string;
  // @ts-ignore
  // getPropertyPriority(property: string): string;
  // @ts-ignore
  setProperty(property: string, value: any): void;
  // @ts-ignore
  removeProperty(property: string): string;

  // cssText: string;
  new(): void;
}
