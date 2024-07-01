//
// Created by 谢作兵 on 13/06/24.
//

#ifndef WEBF_CSS_PARSER_OBSERVER_H
#define WEBF_CSS_PARSER_OBSERVER_H

#include "core/css/css_at_rule_id.h"
#include "core/css/style_rule.h"


namespace webf {

enum class CSSPropertyID;

// TODO: 做css inspect调试的时候使用吧，暂时先不实现哦
// This is only for the inspector and shouldn't be used elsewhere.
class CSSParserObserver {
 public:
  virtual void StartRuleHeader(StyleRule::RuleType, unsigned offset) = 0;
  virtual void EndRuleHeader(unsigned offset) = 0;
  virtual void ObserveSelector(unsigned start_offset, unsigned end_offset) = 0;
  virtual void StartRuleBody(unsigned offset) = 0;
  virtual void EndRuleBody(unsigned offset) = 0;
  virtual void ObserveProperty(unsigned start_offset,
                               unsigned end_offset,
                               bool is_important,
                               bool is_parsed) = 0;
  virtual void ObserveComment(unsigned start_offset, unsigned end_offset) = 0;
  virtual void ObserveErroneousAtRule(
      unsigned start_offset,
      CSSAtRuleID id,
      const std::vector<CSSPropertyID>& invalid_properties) = 0;


};

}  // namespace webf

#endif  // WEBF_CSS_PARSER_OBSERVER_H
