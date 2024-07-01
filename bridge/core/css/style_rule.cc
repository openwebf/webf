//
// Created by 谢作兵 on 11/06/24.
//

#include "style_rule.h"
#include "css_selector_list.h"

namespace webf {

StyleRule::StyleRule(webf::PassKey<StyleRule>,
                     std::span<CSSSelector> selector_vector,
                     std::shared_ptr<CSSLazyPropertyParser> lazy_property_parser)
    : StyleRuleBase(kStyle), lazy_property_parser_(std::move(lazy_property_parser)) {
  //TODO(xiezuobing): CSSSelectList
  CSSSelectorList::AdoptSelectorVector(selector_vector, SelectorArray());
}



}  // namespace webf