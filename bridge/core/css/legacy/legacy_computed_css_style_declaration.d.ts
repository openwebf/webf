import {LegacyCssStyleDeclaration} from "./legacy_css_style_declaration";

interface LegacyComputedCssStyleDeclaration extends LegacyCssStyleDeclaration {
  // @ts-ignore
  cssText: SupportAsync<string>;
  // @ts-ignore
  readonly length: SupportAsync<int64>;
  // @ts-ignore
  getPropertyValue(property: string): SupportAsync<string>;
  // @ts-ignore
  setProperty(property: string, value: any, priority?: string): SupportAsyncManual<void>;
  // @ts-ignore
  removeProperty(property: string): SupportAsync<string>;

  [prop: string]: any;
  new(): void;
}