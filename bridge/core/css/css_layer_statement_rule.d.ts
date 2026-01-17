import {CSSRule} from "./css_rule";

export interface CSSLayerStatementRule extends CSSRule {
  readonly nameList: string[];
  new(): void;
}

