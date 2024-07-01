//
// Created by 谢作兵 on 17/06/24.
//

#include "css_selector_list.h"

namespace webf {

std::shared_ptr<CSSSelectorList> CSSSelectorList::Empty() {
  std::shared_ptr<CSSSelectorList> list =
      std::make_shared<CSSSelectorList>(webf::PassKey<CSSSelectorList>());
  new (list->first_selector_) CSSSelector();
  list->first_selector_[0].SetMatch(CSSSelector::kInvalidList);
  assert(!list->IsValid());
  return list;
}


void CSSSelectorList::AdoptSelectorVector(
    std::span<CSSSelector> selector_vector,
    CSSSelector* selector_array) {
  std::uninitialized_move(selector_vector.begin(), selector_vector.end(),
                          selector_array);
  selector_array[selector_vector.size() - 1].SetLastInSelectorList(true);
}

std::shared_ptr<CSSSelectorList> CSSSelectorList::AdoptSelectorVector(
    std::span<CSSSelector> selector_vector) {
  if (selector_vector.empty()) {
    return CSSSelectorList::Empty();
  }

  std::shared_ptr<CSSSelectorList> list = std::make_shared<CSSSelectorList>(
      webf::PassKey<CSSSelectorList>());
  AdoptSelectorVector(selector_vector, list->first_selector_);
  return list;
}

}  // namespace webf