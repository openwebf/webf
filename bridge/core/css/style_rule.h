/*
 * (C) 1999-2003 Lars Knoll (knoll@kde.org)
 * (C) 2002-2003 Dirk Mueller (mueller@kde.org)
 * Copyright (C) 2002, 2006, 2008, 2012, 2013 Apple Inc. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public License
 * along with this library; see the file COPYING.LIB.  If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301, USA.
 */

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_STYLE_RULE_H
#define WEBF_STYLE_RULE_H

#include <cstdint>
#include <span>
#include "core/base/bits.h"
#include "core/base/types/pass_key.h"
#include "core/css/css_selector.h"
#include "css_property_value_set.h"
#include "css_selector_list.h"

namespace webf {

class CascadeLayer;
class CSSRule;
class CSSStyleSheet;
class ExecutingContext;
class StyleSheetContents;

class StyleRuleBase : public std::enable_shared_from_this<StyleRuleBase> {
 public:
  enum RuleType {
    kCharset,
    kStyle,
    kImport,
    kMedia,
    kFontFace,
    kFontPaletteValues,
    kFontFeatureValues,
    kFontFeature,
    kPage,
    kPageMargin,
    kProperty,
    kKeyframes,
    kKeyframe,
    kLayerBlock,
    kLayerStatement,
    kNamespace,
    kContainer,
    kCounterStyle,
    kScope,
    kSupports,
    kStartingStyle,
    kViewTransition,
    kFunction,
    kPositionTry,
  };

  // Name of a cascade layer as given by an @layer rule, split at '.' into a
  // vector. Note that this may not be the full layer name if the rule is nested
  // in another @layer rule or in a layered @import.
  using LayerName = std::vector<std::string>;
  static std::string LayerNameAsString(const LayerName&);

  RuleType GetType() const { return static_cast<RuleType>(type_); }

  bool IsCharsetRule() const { return GetType() == kCharset; }
  bool IsContainerRule() const { return GetType() == kContainer; }
  bool IsCounterStyleRule() const { return GetType() == kCounterStyle; }
  bool IsFontFaceRule() const { return GetType() == kFontFace; }
  bool IsFontPaletteValuesRule() const { return GetType() == kFontPaletteValues; }
  bool IsFontFeatureValuesRule() const { return GetType() == kFontFeatureValues; }
  bool IsFontFeatureRule() const { return GetType() == kFontFeature; }
  bool IsKeyframesRule() const { return GetType() == kKeyframes; }
  bool IsKeyframeRule() const { return GetType() == kKeyframe; }
  bool IsLayerBlockRule() const { return GetType() == kLayerBlock; }
  bool IsLayerStatementRule() const { return GetType() == kLayerStatement; }
  bool IsNamespaceRule() const { return GetType() == kNamespace; }
  bool IsMediaRule() const { return GetType() == kMedia; }
  bool IsPageRule() const { return GetType() == kPage; }
  bool IsPageRuleMargin() const { return GetType() == kPageMargin; }
  bool IsPropertyRule() const { return GetType() == kProperty; }
  bool IsStyleRule() const { return GetType() == kStyle; }
  bool IsScopeRule() const { return GetType() == kScope; }
  bool IsSupportsRule() const { return GetType() == kSupports; }
  bool IsImportRule() const { return GetType() == kImport; }
  bool IsStartingStyleRule() const { return GetType() == kStartingStyle; }
  bool IsViewTransitionRule() const { return GetType() == kViewTransition; }
  bool IsConditionRule() const {
    return GetType() == kContainer || GetType() == kMedia || GetType() == kSupports || GetType() == kStartingStyle;
  }
  bool IsFunctionRule() const { return GetType() == kFunction; }
  bool IsPositionTryRule() const { return GetType() == kPositionTry; }

  std::shared_ptr<const StyleRuleBase> Copy() const;

  // FIXME: There shouldn't be any need for the null parent version.
  CSSRule* CreateCSSOMWrapper(uint32_t position_hint = std::numeric_limits<uint32_t>::max(),
                              CSSStyleSheet* parent_sheet = nullptr,
                              bool trigger_use_counters = false) const;
  CSSRule* CreateCSSOMWrapper(uint32_t position_hint, CSSRule* parent_rule, bool trigger_use_counters = false) const;

  // Move this rule from being a child of old_parent (which is only given for
  // sake of DCHECK) to being a child of new_parent, updating parent pointers
  // in the selector. This happens only when we need to reallocate a StyleRule
  // because its selector changed.
  void Reparent(StyleRule* old_parent, StyleRule* new_parent);

  void Trace(GCVisitor*) const;
  void TraceAfterDispatch(GCVisitor* visitor) const {}
  void FinalizeGarbageCollectedObject();

  // See CSSSelector::IsInvisible.
  bool IsInvisible() const;
  // See CSSSelector::Signal.
  bool IsSignaling() const;

  bool HasSignalingChildRule() const { return has_signaling_child_rule_; }

  // This class mimics the API of HeapVector<Member<StyleRuleBase>>,
  // except that any invisible rule added to the vector isn't visible
  // through any member function except `RawChildRules`.
  //
  // TODO(crbug.com/1517290): Remove this when we're done use-counting.
  class ChildRuleVector {
   public:
    ChildRuleVector() = default;

    // An iterator which skips invisible rules.
    class Iterator {
      WEBF_STACK_ALLOCATED();

     public:
      Iterator(const std::shared_ptr<const StyleRuleBase>* position, const std::shared_ptr<const StyleRuleBase>* end)
          : position_(position), end_(end) {
        assert(position <= end);
      }

      void operator++();
      std::shared_ptr<const StyleRuleBase> operator*() const { return *position_; }
      bool operator==(const Iterator& o) const { return position_ == o.position_ && end_ == o.end_; }
      bool operator!=(const Iterator& o) const { return !(*this == o); }

     private:
      const std::shared_ptr<const StyleRuleBase>* position_;
      const std::shared_ptr<const StyleRuleBase>* end_;
    };

    std::shared_ptr<ChildRuleVector> Copy() const;

    Iterator begin() const {
      // The AdjustedIndex call ensures that we skip leading invisible rules.
      return Iterator(&rules_.front() + AdjustedIndex(0), &rules_.back());
    }
    Iterator end() const { return Iterator(&rules_.front(), &rules_.back()); }

    const std::shared_ptr<const StyleRuleBase>& operator[](uint32_t i) const { return rules_.at(AdjustedIndex(i)); }
    std::shared_ptr<const StyleRuleBase>& operator[](uint32_t i) { return rules_.at(AdjustedIndex(i)); }

    uint32_t size() const { return rules_.size() - num_invisible_rules_; }

    void AddChildRule(const std::shared_ptr<const StyleRuleBase>& rule);
    void WrapperInsertRule(unsigned index, const std::shared_ptr<const StyleRuleBase>& rule);
    void WrapperRemoveRule(unsigned index);

    const std::vector<std::shared_ptr<const StyleRuleBase>>& RawChildRules() const { return rules_; }

    void Trace(GCVisitor* visitor) const {}

   private:
    // Finds the real index of the Nth non-invisible child rule.
    // The provided `index` must be in the range [0, size()].
    size_t AdjustedIndex(size_t index) const;

    std::vector<std::shared_ptr<const StyleRuleBase>> rules_;
    uint32_t num_invisible_rules_ = 0;
  };

 protected:
  explicit StyleRuleBase(RuleType type) : type_(type), has_signaling_child_rule_(false) {}
  StyleRuleBase(const StyleRuleBase& rule)
      : type_(rule.type_), has_signaling_child_rule_(rule.has_signaling_child_rule_) {}

  void SetHasSignalingChildRule(bool has_signaling_child_rule) { has_signaling_child_rule_ = has_signaling_child_rule; }

 private:
  CSSRule* CreateCSSOMWrapper(uint32_t position_hint,
                              CSSStyleSheet* parent_sheet,
                              CSSRule* parent_rule,
                              bool trigger_use_counters) const;

  const uint8_t type_;
  // See CSSSelector::Signal.
  bool has_signaling_child_rule_;
};

// A single rule from a stylesheet. Contains a selector list (one or more
// complex selectors) and a collection of style properties to be applied where
// those selectors match. These are output by CSSParserImpl.
//
// Note that since this we generate so many StyleRule objects, and all of them
// have at least one selector, the selector list is not allocated separately as
// on a CSSSelectorList. Instead, we put the CSSSelectors immediately after the
// StyleRule object. This both saves memory (since we don't need the pointer,
// or any of the extra allocation overhead), and makes it likely that the
// CSSSelectors are on the same cache line as the StyleRule. (On the flip side,
// it makes it unlikely that the CSSSelector's RareData is on the same cache
// line as the CSSSelector itself, but it is still overall a good tradeoff
// for us.) StyleRule provides an API that is a subset of CSSSelectorList,
// partially implemented using its static member functions.
class StyleRule : public StyleRuleBase {
 public:
  static std::shared_ptr<StyleRule> Create(std::span<CSSSelector> selectors, std::shared_ptr<CSSPropertyValueSet> properties) {
    return std::make_shared<StyleRule>(webf::PassKey<StyleRule>(), selectors, properties);
  }
  static std::shared_ptr<StyleRule> Create(std::span<CSSSelector> selectors,
                                           std::shared_ptr<CSSLazyPropertyParser> lazy_property_parser) {
    return std::make_shared<StyleRule>(
        //        AdditionalBytesForSelectors(selectors.size()),
        webf::PassKey<StyleRule>(), selectors, lazy_property_parser);
  }

  // See comment on the corresponding constructor.
  static std::shared_ptr<StyleRule> Create(std::span<CSSSelector> selectors) {
    return std::make_shared<StyleRule>(
        //        AdditionalBytesForSelectors(selectors.size()),
        webf::PassKey<StyleRule>(), selectors);
  }

  // Creates a StyleRule with the selectors changed (used by setSelectorText()).
  static std::shared_ptr<StyleRule> Create(std::span<CSSSelector> selectors, StyleRule&& other) {
    return std::make_shared<StyleRule>(
        //        AdditionalBytesForSelectors(selectors.size()),
        webf::PassKey<StyleRule>(), selectors, std::move(other));
  }

  // Constructors. Note that these expect that the StyleRule has been
  // allocated on the Oilpan heap, with <flattened_size> * sizeof(CSSSelector)
  // additional bytes after the StyleRule (flattened_size is the number of
  // selectors). Do not call them directly; they are public only so that
  // MakeGarbageCollected() can call them. Instead, use Create() above or
  // Copy() below, as appropriate.
  StyleRule(webf::PassKey<StyleRule>, std::span<CSSSelector> selector_vector, std::shared_ptr<CSSPropertyValueSet>);
  StyleRule(webf::PassKey<StyleRule>, std::span<CSSSelector> selector_vector, std::shared_ptr<CSSLazyPropertyParser>);
  // If you use this constructor, the object will not be fully constructed until
  // you call SetProperties().
  StyleRule(webf::PassKey<StyleRule>, std::span<CSSSelector> selector_vector);
  StyleRule(webf::PassKey<StyleRule>, std::span<CSSSelector> selector_vector, StyleRule&&);
  StyleRule(const StyleRule&, size_t flattened_size);
  StyleRule(const StyleRule&) = delete;
  ~StyleRule();

  void SetProperties(std::shared_ptr<CSSPropertyValueSet> properties) {
    assert(properties_.get() == nullptr);
    properties_ = properties;
  }

  // Partial subset of the CSSSelector API.
  const CSSSelector* FirstSelector() const { return SelectorArray(); }
  const CSSSelector& SelectorAt(uint32_t index) const { return SelectorArray()[index]; }
  CSSSelector& MutableSelectorAt(uint32_t index) { return SelectorArray()[index]; }
  uint32_t SelectorIndex(const CSSSelector& selector) const {
    return static_cast<uint32_t>(&selector - FirstSelector());
  }
  uint32_t IndexOfNextSelectorAfter(uint32_t index) const {
    const CSSSelector& current = SelectorAt(index);
    const CSSSelector* next = CSSSelectorList::Next(current);
    if (!next) {
      return UINT_MAX;
      ;
    }
    return SelectorIndex(*next);
  }
  AtomicString SelectorsText() const { return CSSSelectorList::SelectorsText(FirstSelector()); }

  const CSSPropertyValueSet& Properties() const;
  // TODO(xiezuobing): MutableCSSPropertyValueSet
  MutableCSSPropertyValueSet& MutableProperties();

  std::shared_ptr<StyleRule> Copy() const {
    const CSSSelector* selector_array = SelectorArray();
    size_t flattened_size = 1;
    while (!selector_array[flattened_size - 1].IsLastInSelectorList()) {
      ++flattened_size;
    }
    return std::make_shared<StyleRule>(
        //        AdditionalBytesForSelectors(flattened_size),
        *this, flattened_size);
  }

  static unsigned AverageSizeInBytes();

  // Helper function to avoid parsing lazy properties when not needed.
  bool PropertiesHaveFailedOrCanceledSubresources() const;

  void TraceAfterDispatch(GCVisitor*) const;

  const ChildRuleVector* ChildRules() const { return child_rule_vector_.get(); }

  void EnsureChildRules() {
    // Allocate the child rule vector only when we need it,
    // since most rules won't have children (almost by definition).
    if (child_rule_vector_ == nullptr) {
      child_rule_vector_ = std::make_shared<ChildRuleVector>();
    }
  }

  // Note that if `child` is invisible (see CSSSelector::IsInvisible),
  // then the added child rule won't be visible through `ChildRules`.
  void AddChildRule(StyleRuleBase*);

  void WrapperInsertRule(unsigned index, const std::shared_ptr<const StyleRuleBase>& rule) {
    EnsureChildRules();
    child_rule_vector_->WrapperInsertRule(index, rule);
  }
  void WrapperRemoveRule(unsigned index) { child_rule_vector_->WrapperRemoveRule(index); }

 private:
  friend class StyleRuleBase;
  friend class CSSLazyParsingTest;

  bool HasParsedProperties() const;

  CSSSelector* SelectorArray() {
    return reinterpret_cast<CSSSelector*>(webf::AlignUp(reinterpret_cast<uint8_t*>(this + 1), alignof(CSSSelector)));
  }
  const CSSSelector* SelectorArray() const { return const_cast<StyleRule*>(this)->SelectorArray(); }

  mutable std::shared_ptr<CSSPropertyValueSet> properties_;
  mutable std::shared_ptr<CSSLazyPropertyParser> lazy_property_parser_;
  std::shared_ptr<ChildRuleVector> child_rule_vector_;
};

template <>
struct DowncastTraits<StyleRule> {
  static bool AllowFrom(const StyleRuleBase& rule) { return rule.IsStyleRule(); }
};

class StyleRuleFontFace : public StyleRuleBase {
 public:
  explicit StyleRuleFontFace(CSSPropertyValueSet*);
  StyleRuleFontFace(const StyleRuleFontFace&);

  const CSSPropertyValueSet& Properties() const { return *properties_; }
  MutableCSSPropertyValueSet& MutableProperties();

  std::shared_ptr<StyleRuleFontFace> Copy() const { return std::make_shared<StyleRuleFontFace>(*this); }

  void SetCascadeLayer(std::shared_ptr<const CascadeLayer> layer) { layer_ = layer; }
  const CascadeLayer* GetCascadeLayer() const { return layer_.get(); }

  void TraceAfterDispatch(GCVisitor*) const;

 private:
  std::shared_ptr<CSSPropertyValueSet> properties_;  // Cannot be null.
  std::shared_ptr<const CascadeLayer> layer_;
};

}  // namespace webf

#endif  // WEBF_STYLE_RULE_H
