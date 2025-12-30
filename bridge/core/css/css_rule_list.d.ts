import {CSSRule} from "./css_rule";

export interface CSSRuleList {
  readonly length: double;
  item(index: double): CSSRule | null;
  readonly [key: number]: CSSRule | null;
  new(): void;
}
