import {StyleSheet} from "./style_sheet";
import {CSSRuleList} from "./css_rule_list";

export interface CSSStyleSheet extends StyleSheet {
  readonly cssRules: CSSRuleList;
  insertRule(rule: string, index: double): double;
  deleteRule(index: double): void;
  new(): void;
}
