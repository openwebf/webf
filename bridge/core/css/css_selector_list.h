//
// Created by 谢作兵 on 17/06/24.
//

#ifndef WEBF_CSS_SELECTOR_LIST_H
#define WEBF_CSS_SELECTOR_LIST_H

#include <memory>
#include <span>
#include "core/css/css_selector.h"
#include "core/base/types/pass_key.h"
#include "bindings/qjs/cppgc/gc_visitor.h"

namespace webf {

// This class represents a CSS selector, i.e. a pattern of one or more
// simple selectors. https://www.w3.org/TR/css3-selectors/

// More specifically, a CSS selector is a chain of one or more sequences
// of simple selectors separated by combinators.
//
// For example, "div.c1 > span.c2 + .c3#ident" is represented as a
// CSSSelectorList that owns six CSSSelector instances.
//
// The simple selectors are stored in memory in the following order:
// .c3, #ident, span, .c2, div, .c1
// (See CSSSelector.h for more information.)
//
// First() and Next() can be used to traverse from right to left through
// the chain of sequences: .c3#ident then span.c2 then div.c1
//
// SelectorAt and IndexOfNextSelectorAfter provide an equivalent API:
// size_t index = 0;
// do {
//   const CSSSelector& sequence = selectorList.SelectorAt(index);
//   ...
//   index = IndexOfNextSelectorAfter(index);
// } while (index != kNotFound);
//
// Use CSSSelector::NextSimpleSelector() and
// CSSSelector::IsLastInComplexSelector() to traverse through each sequence of
// simple selectors, from .c3 to #ident; from span to .c2; from div to .c1
//
// StyleRule stores its selectors in an identical memory layout,
// but not as part of a CSSSelectorList (see its class comments).
// It reuses many of the exposed static member functions from CSSSelectorList
// to provide a subset of its API.
class CSSSelectorList {
 public:
  // Constructs an empty selector list, for which IsValid() returns false.
  // TODO(sesse): Consider making this a singleton.
  static std::shared_ptr<CSSSelectorList> Empty();

  // Do not call; for Empty() and AdoptSelectorVector() only.
  explicit CSSSelectorList(webf::PassKey<CSSSelectorList>) {}

  CSSSelectorList(CSSSelectorList&& o) {
    memcpy(this, o.first_selector_, ComputeLength() * sizeof(CSSSelector));
  }
  ~CSSSelectorList() = default;

  static std::shared_ptr<CSSSelectorList> AdoptSelectorVector(std::span<CSSSelector> selector_vector);
  static void AdoptSelectorVector(std::span<CSSSelector> selector_vector, CSSSelector* selector_array);

  CSSSelectorList* Copy() const;

  bool IsValid() const {
    return first_selector_[0].Match() != CSSSelector::kInvalidList;
  }
  const CSSSelector* First() const {
    return IsValid() ? first_selector_ : nullptr;
  }
  static const CSSSelector* Next(const CSSSelector&);
  static CSSSelector* Next(CSSSelector&);

  // The CSS selector represents a single sequence of simple selectors.
  bool HasOneSelector() const { return IsValid() && !Next(*first_selector_); }
  const CSSSelector& SelectorAt(uint32_t index) const {
    assert(IsValid());
    return first_selector_[index];
  }

  uint32_t SelectorIndex(const CSSSelector& selector) const {
    assert(IsValid());
    return static_cast<uint32_t>(&selector - first_selector_);
  }

  uint32_t IndexOfNextSelectorAfter(uint32_t index) const {
    const CSSSelector& current = SelectorAt(index);
    const CSSSelector* next = Next(current);
    if (!next) {
      return UINT_MAX;
    }
    return SelectorIndex(*next);
  }

  AtomicString SelectorsText() const { return SelectorsText(First()); }
  static AtomicString SelectorsText(const CSSSelector* first);

  // Selector lists don't know their length, computing it is O(n) and should be
  // avoided when possible. Instead iterate from first() and using next().
  unsigned ComputeLength() const;

  // Return the specificity of the selector with the highest specificity.
  unsigned MaximumSpecificity() const;

  // See CSSSelector::Reparent.
  static void Reparent(CSSSelector* selector_list,
                       std::shared_ptr<StyleRule> old_parent,
                       std::shared_ptr<StyleRule> new_parent);

  void Reparent(std::shared_ptr<StyleRule> old_parent, std::shared_ptr<StyleRule> new_parent) {
    CSSSelectorList::Reparent(first_selector_, old_parent, new_parent);
  }

  CSSSelectorList(const CSSSelectorList&) = delete;
  CSSSelectorList& operator=(const CSSSelectorList&) = delete;

  void Trace(GCVisitor* visitor) const;

 private:
  // All of the remaining CSSSelector objects are allocated on
  // AdditionalBytes, and thus live immediately after this object. The length
  // is not stored explicitly anywhere: End of a multipart selector is
  // indicated by is_last_in_complexlector_ bit in the last item. End of the
  // array is indicated by is_last_in_selector_list_ bit in the last item.
  CSSSelector first_selector_[1];
};

}  // namespace webf

#endif  // WEBF_CSS_SELECTOR_LIST_H