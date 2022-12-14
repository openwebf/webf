import {CSSStyleDeclaration} from "./css_style_declaration";

interface InlineCssStyleDeclaration extends CSSStyleDeclaration {
  new(): void;
}