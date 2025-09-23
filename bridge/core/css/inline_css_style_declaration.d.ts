import {CSSStyleDeclaration} from "./css_style_declaration";

interface InlineCssStyleDeclaration extends CSSStyleDeclaration {
  // readonly parentRule?: CSSRule;
  // @ts-ignore
  [prop: string]: any;
  new(): void;

  // @ts-ignore
  getPropertyValue(property: string): string;
  // @ts-ignore
  // getPropertyPriority(property: string): string;
  // @ts-ignore
  setProperty(property: string, value: any, priority?: string): void;
  // @ts-ignore
  removeProperty(property: string): string;
}