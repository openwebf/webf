import {CSSRule} from "./css_rule";
import {CSSRuleList} from "./css_rule_list";

export interface CSSLayerBlockRule extends CSSRule {
  readonly name: string;
  readonly cssRules: CSSRuleList;
  insertRule(rule: string, index: double): double;
  deleteRule(index: double): void;
  new(): void;
}

