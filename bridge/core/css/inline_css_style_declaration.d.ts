import {CSSStyleDeclaration} from "./css_style_declaration";

interface InlineCssStyleDeclaration extends CSSStyleDeclaration {
  // readonly parentRule?: CSSRule;
  // @ts-ignore
  // [prop: string]: any;
  new(): void;
}