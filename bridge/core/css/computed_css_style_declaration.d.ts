import {CSSStyleDeclaration} from "./css_style_declaration";

interface ComputedCssStyleDeclaration extends CSSStyleDeclaration {
  // // @ts-ignore
  // cssText: SupportAsync<string>;
  cssText: string;
  // // @ts-ignore
  // readonly length: SupportAsync<int64>;
  readonly length: int64;
  // // @ts-ignore
  // getPropertyValue(property: string): SupportAsync<string>;
  getPropertyValue(property: string): string;
  // // @ts-ignore
  // Set to Computed style should be ignored.
  // setProperty(property: string, value: any): SupportAsyncManual<void>;
  // setProperty(property: string, value: any): void;
  // // @ts-ignore
  // removeProperty(property: string): SupportAsync<string>;
  removeProperty(property: string): string;

  readonly [prop: string]: any;
  new(): void;
}