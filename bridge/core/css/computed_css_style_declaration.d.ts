import {CSSStyleDeclaration} from "./css_style_declaration";

interface ComputedCssStyleDeclaration extends CSSStyleDeclaration {
  // readonly parentRule?: CSSRule;
  // @ts-ignore
  [prop: string]: string;
  new(): void;
}