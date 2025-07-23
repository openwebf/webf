import {LegacyCssStyleDeclaration} from "./legacy_css_style_declaration";

interface LegacyInlineCssStyleDeclaration extends LegacyCssStyleDeclaration {
  // readonly parentRule?: CSSRule;
  // @ts-ignore
  [prop: string]: any;
  new(): void;
}