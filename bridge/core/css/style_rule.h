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
#include "core/base/memory/shared_ptr.h"
#include "core/base/types/pass_key.h"
#include "core/css/container_query.h"
#include "core/css/css_selector.h"
#include "core/css/css_syntax_definition.h"
#include "core/css/css_variable_data.h"
#include "core/css/media_list.h"
#include "core/css/style_scope.h"
#include "css_at_rule_id.h"
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
    kScope,
    kSupports,
    kStartingStyle,
    kViewTransition,
    kFunction,
    kMixin,
    kApplyMixin,
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
  bool IsMixinRule() const { return GetType() == kMixin; }
  bool IsApplyMixinRule() const { return GetType() == kApplyMixin; }
  bool IsFunctionRule() const { return GetType() == kFunction; }
  bool IsPositionTryRule() const { return GetType() == kPositionTry; }

  std::shared_ptr<const StyleRuleBase> Copy() const;

  CSSRule* CreateCSSOMWrapper(uint32_t position_hint = std::numeric_limits<uint32_t>::max(),
                              CSSStyleSheet* parent_sheet = nullptr,
                              bool trigger_use_counters = false) const;
  CSSRule* CreateCSSOMWrapper(uint32_t position_hint, CSSRule* parent_rule, bool trigger_use_counters = false) const;

  // Move this rule to being a child of new_parent, updating parent
  // pointers in the selector. This happens only when we need to reallocate a
  // StyleRule because its selector changed.
  void Reparent(StyleRule* new_parent);

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

    [[nodiscard]] const std::vector<std::shared_ptr<const StyleRuleBase>>& RawChildRules() const { return rules_; }

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
  static size_t AdditionalBytesForSelectors(size_t flattened_size) {
    constexpr size_t padding_bytes = base::bits::AlignUp(sizeof(StyleRule), alignof(CSSSelector)) - sizeof(StyleRule);
    return (sizeof(CSSSelector) * flattened_size) + padding_bytes;
  }

 public:
  static std::shared_ptr<StyleRule> Create(tcb::span<CSSSelector> selectors,
                                           std::shared_ptr<const CSSPropertyValueSet> properties) {
    return MakeSharedPtrWithAdditionalBytes<StyleRule>(AdditionalBytesForSelectors(selectors.size()),
                                                       webf::PassKey<StyleRule>(), selectors, std::move(properties));
  }
  static std::shared_ptr<StyleRule> Create(tcb::span<CSSSelector> selectors,
                                           std::shared_ptr<CSSLazyPropertyParser> lazy_property_parser) {
    return MakeSharedPtrWithAdditionalBytes<StyleRule>(AdditionalBytesForSelectors(selectors.size()),
                                                       webf::PassKey<StyleRule>(), selectors,
                                                       std::move(lazy_property_parser));
  }

  // See comment on the corresponding constructor.
  static std::shared_ptr<StyleRule> Create(tcb::span<CSSSelector> selectors) {
    return MakeSharedPtrWithAdditionalBytes<StyleRule>(AdditionalBytesForSelectors(selectors.size()),
                                                       webf::PassKey<StyleRule>(), selectors);
  }

  // Creates a StyleRule with the selectors changed (used by setSelectorText()).
  static std::shared_ptr<StyleRule> Create(tcb::span<CSSSelector> selectors, StyleRule&& other) {
    return MakeSharedPtrWithAdditionalBytes<StyleRule>(AdditionalBytesForSelectors(selectors.size()),
                                                       webf::PassKey<StyleRule>(), selectors, std::move(other));
  }

  // Constructors. Note that these expect that the StyleRule has been
  // allocated on the Oilpan heap, with <flattened_size> * sizeof(CSSSelector)
  // additional bytes after the StyleRule (flattened_size is the number of
  // selectors). Do not call them directly; they are public only so that
  // MakeGarbageCollected() can call them. Instead, use Create() above or
  // Copy() below, as appropriate.
  StyleRule(webf::PassKey<StyleRule>,
            tcb::span<CSSSelector> selector_vector,
            std::shared_ptr<const CSSPropertyValueSet>);
  StyleRule(webf::PassKey<StyleRule>, tcb::span<CSSSelector> selector_vector, std::shared_ptr<CSSLazyPropertyParser>);
  // If you use this constructor, the object will not be fully constructed until
  // you call SetProperties().
  StyleRule(webf::PassKey<StyleRule>, tcb::span<CSSSelector> selector_vector);
  StyleRule(webf::PassKey<StyleRule>, tcb::span<CSSSelector> selector_vector, StyleRule&&);
  StyleRule(const StyleRule&, size_t flattened_size);
  StyleRule(const StyleRule&) = delete;
  ~StyleRule();

  void SetProperties(std::shared_ptr<CSSPropertyValueSet> properties) {
    assert(properties_.get() == nullptr);
    properties_ = std::move(properties);
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
    }
    return SelectorIndex(*next);
  }
  std::string SelectorsText() const { return CSSSelectorList::SelectorsText(FirstSelector()); }

  const CSSPropertyValueSet& Properties() const;
  MutableCSSPropertyValueSet& MutableProperties();

  std::shared_ptr<StyleRule> Copy() const {
    const CSSSelector* selector_array = SelectorArray();
    size_t flattened_size = 1;
    while (!selector_array[flattened_size - 1].IsLastInSelectorList()) {
      ++flattened_size;
    }
    return std::make_shared<StyleRule>(*this, flattened_size);
  }

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
  void AddChildRule(std::shared_ptr<StyleRuleBase>);

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
    return reinterpret_cast<CSSSelector*>(
        base::bits::AlignUp(reinterpret_cast<uint8_t*>(this + 1), alignof(CSSSelector)));
  }
  const CSSSelector* SelectorArray() const { return const_cast<StyleRule*>(this)->SelectorArray(); }

  mutable std::shared_ptr<const CSSPropertyValueSet> properties_;
  mutable std::shared_ptr<CSSLazyPropertyParser> lazy_property_parser_;
  std::shared_ptr<ChildRuleVector> child_rule_vector_;
};

// This should only be used within the CSS Parser
class StyleRuleCharset : public StyleRuleBase {
 public:
  StyleRuleCharset() : StyleRuleBase(kCharset) {}
  void TraceAfterDispatch(GCVisitor* visitor) const { StyleRuleBase::TraceAfterDispatch(visitor); }

 private:
};

class StyleRuleFontFace : public StyleRuleBase {
 public:
  explicit StyleRuleFontFace(std::shared_ptr<CSSPropertyValueSet>);
  StyleRuleFontFace(const StyleRuleFontFace&);

  const CSSPropertyValueSet& Properties() const { return *properties_; }
  MutableCSSPropertyValueSet& MutableProperties();

  std::shared_ptr<StyleRuleFontFace> Copy() const { return std::make_shared<StyleRuleFontFace>(*this); }

  void SetCascadeLayer(std::shared_ptr<const CascadeLayer> layer) { layer_ = layer; }
  const CascadeLayer* GetCascadeLayer() const { return layer_.get(); }

  void TraceAfterDispatch(GCVisitor*) const;

 private:
  std::shared_ptr<const CSSPropertyValueSet> properties_;  // Cannot be null.
  std::shared_ptr<const CascadeLayer> layer_;
};

class StyleRuleProperty : public StyleRuleBase {
 public:
  StyleRuleProperty(const std::string& name, std::shared_ptr<CSSPropertyValueSet>);
  StyleRuleProperty(const StyleRuleProperty&);

  const CSSPropertyValueSet& Properties() const { return *properties_; }
  MutableCSSPropertyValueSet& MutableProperties();
  const std::string& GetName() const { return name_; }
  const std::shared_ptr<const CSSValue>* GetSyntax() const;
  const std::shared_ptr<const CSSValue>* Inherits() const;
  const std::shared_ptr<const CSSValue>* GetInitialValue() const;

  bool SetNameText(const ExecutingContext* execution_context, const std::string& name_text);

  void SetCascadeLayer(std::shared_ptr<const CascadeLayer> layer) { layer_ = layer; }
  const CascadeLayer* GetCascadeLayer() const { return layer_.get(); }

  std::shared_ptr<StyleRuleProperty> Copy() const { return std::make_shared<StyleRuleProperty>(*this); }

  void TraceAfterDispatch(GCVisitor*) const;

 private:
  std::string name_;
  std::shared_ptr<const CSSPropertyValueSet> properties_;
  std::shared_ptr<const CascadeLayer> layer_;
};

class StyleRuleGroup : public StyleRuleBase {
 public:
  const ChildRuleVector& ChildRules() const { return *child_rule_vector_; }
  ChildRuleVector& ChildRules() { return *child_rule_vector_; }

  void WrapperInsertRule(CSSStyleSheet*, unsigned, const std::shared_ptr<const StyleRuleBase>);
  void WrapperRemoveRule(CSSStyleSheet*, unsigned);

  void TraceAfterDispatch(GCVisitor*) const;

 protected:
  StyleRuleGroup(RuleType, std::vector<std::shared_ptr<StyleRuleBase>> rules);
  StyleRuleGroup(const StyleRuleGroup&);

 private:
  std::shared_ptr<ChildRuleVector> child_rule_vector_;
};

class StyleRulePage : public StyleRuleGroup {
 public:
  StyleRulePage(std::shared_ptr<CSSSelectorList> selector_list,
                std::shared_ptr<CSSPropertyValueSet> properties,
                std::vector<std::shared_ptr<StyleRuleBase>> child_rules);
  StyleRulePage(const StyleRulePage&);

  const CSSSelector* Selector() const { return selector_list_->First(); }
  const CSSPropertyValueSet& Properties() const { return *properties_; }
  MutableCSSPropertyValueSet& MutableProperties();

  void WrapperAdoptSelectorList(std::shared_ptr<CSSSelectorList> selectors) { selector_list_ = std::move(selectors); }

  std::shared_ptr<StyleRulePage> Copy() const { return std::make_shared<StyleRulePage>(*this); }

  void SetCascadeLayer(std::shared_ptr<const CascadeLayer> layer) { layer_ = layer; }
  const CascadeLayer* GetCascadeLayer() const { return layer_.get(); }

  void TraceAfterDispatch(GCVisitor*) const;

 private:
  std::shared_ptr<const CSSPropertyValueSet> properties_;  // Cannot be null.
  std::shared_ptr<const CascadeLayer> layer_;
  std::shared_ptr<CSSSelectorList> selector_list_;
};

class StyleRuleScope : public StyleRuleGroup {
 public:
  StyleRuleScope(const StyleScope&, std::vector<std::shared_ptr<StyleRuleBase>> rules);
  StyleRuleScope(const StyleRuleScope&);

  std::shared_ptr<StyleRuleScope> Copy() const { return std::make_shared<StyleRuleScope>(*this); }

  void TraceAfterDispatch(GCVisitor*) const;

  const StyleScope& GetStyleScope() const { return *style_scope_; }

  void SetPreludeText(const ExecutingContext*,
                      std::string,
                      CSSNestingType,
                      std::shared_ptr<const StyleRule> parent_rule_for_nesting,
                      bool is_within_scope,
                      std::shared_ptr<StyleSheetContents> style_sheet);

 private:
  std::shared_ptr<const StyleScope> style_scope_;
};

class StyleRulePageMargin : public StyleRuleBase {
 public:
  StyleRulePageMargin(CSSAtRuleID id, std::shared_ptr<CSSPropertyValueSet> properties);
  StyleRulePageMargin(const StyleRulePageMargin&);

  const CSSPropertyValueSet& Properties() const { return *properties_; }
  MutableCSSPropertyValueSet& MutableProperties();
  CSSAtRuleID ID() const { return id_; }

  std::shared_ptr<StyleRulePageMargin> Copy() const { return std::make_shared<StyleRulePageMargin>(*this); }

  void TraceAfterDispatch(GCVisitor*) const;

 private:
  CSSAtRuleID id_;                                         // What margin, e.g. @top-right.
  std::shared_ptr<const CSSPropertyValueSet> properties_;  // Cannot be null.
};

// https://www.w3.org/TR/css-cascade-5/#layer-block
class StyleRuleLayerBlock : public StyleRuleGroup {
 public:
  StyleRuleLayerBlock(LayerName&& name, std::vector<std::shared_ptr<StyleRuleBase>> rules);
  StyleRuleLayerBlock(const StyleRuleLayerBlock&);

  const LayerName& GetName() const { return name_; }
  std::string GetNameAsString() const;

  std::shared_ptr<StyleRuleLayerBlock> Copy() const { return std::make_shared<StyleRuleLayerBlock>(*this); }

  void TraceAfterDispatch(GCVisitor*) const;

 private:
  LayerName name_;
};

// https://www.w3.org/TR/css-cascade-5/#layer-empty
class StyleRuleLayerStatement : public StyleRuleBase {
 public:
  explicit StyleRuleLayerStatement(std::vector<LayerName>&& names);
  StyleRuleLayerStatement(const StyleRuleLayerStatement& other);

  const std::vector<LayerName>& GetNames() const { return names_; }
  std::vector<std::string> GetNamesAsStrings() const;

  std::shared_ptr<StyleRuleLayerStatement> Copy() const { return std::make_shared<StyleRuleLayerStatement>(*this); }

  void TraceAfterDispatch(GCVisitor*) const;

 private:
  std::vector<LayerName> names_;
};

// If you add new children of this class, remember to update IsConditionRule()
// above.
class StyleRuleCondition : public StyleRuleGroup {
 public:
  std::string ConditionText() const { return condition_text_; }

 protected:
  StyleRuleCondition(RuleType, std::vector<std::shared_ptr<StyleRuleBase>> rules);
  StyleRuleCondition(RuleType, const std::string& condition_text, std::vector<std::shared_ptr<StyleRuleBase>> rules);
  StyleRuleCondition(const StyleRuleCondition&);
  std::string condition_text_;
};

class StyleRuleMedia : public StyleRuleCondition {
 public:
  StyleRuleMedia(std::shared_ptr<const MediaQuerySet>, std::vector<std::shared_ptr<StyleRuleBase>> rules);
  StyleRuleMedia(const StyleRuleMedia&) = default;

  const MediaQuerySet* MediaQueries() const { return media_queries_.get(); }

  void SetMediaQueries(std::shared_ptr<const MediaQuerySet> media_queries) { media_queries_ = media_queries; }

  std::shared_ptr<StyleRuleMedia> Copy() const { return std::make_shared<StyleRuleMedia>(*this); }

  void TraceAfterDispatch(GCVisitor*) const;

 private:
  std::shared_ptr<const MediaQuerySet> media_queries_;
};

class StyleRuleSupports : public StyleRuleCondition {
 public:
  StyleRuleSupports(const std::string& condition_text,
                    bool condition_is_supported,
                    std::vector<std::shared_ptr<StyleRuleBase>> rules);
  StyleRuleSupports(const StyleRuleSupports&);

  bool ConditionIsSupported() const { return condition_is_supported_; }
  std::shared_ptr<StyleRuleSupports> Copy() const { return std::make_shared<StyleRuleSupports>(*this); }

  void SetConditionText(const ExecutingContext*, std::string);

  void TraceAfterDispatch(GCVisitor* visitor) const { StyleRuleCondition::TraceAfterDispatch(visitor); }

 private:
  bool condition_is_supported_;
};

class StyleRuleContainer : public StyleRuleCondition {
 public:
  StyleRuleContainer(ContainerQuery&, std::vector<std::shared_ptr<StyleRuleBase>> rules);
  StyleRuleContainer(const StyleRuleContainer&);

  ContainerQuery& GetContainerQuery() const { return *container_query_; }

  std::shared_ptr<StyleRuleContainer> Copy() const { return std::make_shared<StyleRuleContainer>(*this); }

  void SetConditionText(const ExecutingContext*, std::string);

  void TraceAfterDispatch(GCVisitor*) const;

 private:
  std::shared_ptr<ContainerQuery> container_query_;
};

class StyleRuleStartingStyle : public StyleRuleGroup {
 public:
  explicit StyleRuleStartingStyle(std::vector<std::shared_ptr<StyleRuleBase>> rules);
  StyleRuleStartingStyle(const StyleRuleStartingStyle&) = default;

  std::shared_ptr<StyleRuleStartingStyle> Copy() const { return std::make_shared<StyleRuleStartingStyle>(*this); }

  void TraceAfterDispatch(GCVisitor* visitor) const { StyleRuleGroup::TraceAfterDispatch(visitor); }
};

// An @function rule, representing a CSS function.
class StyleRuleFunction : public StyleRuleBase {
 public:
  struct Type {
    CSSSyntaxDefinition syntax;

    // Whether this is a numeric type, that would be accepted by calc()
    // (see https://drafts.csswg.org/css-values/#calc-func). This is used
    // to allow the user to not have to write calc() around every single
    // expression, so that one could do e.g. --foo(2 + 2) instead of
    // --foo(calc(2 + 2)). Since writing calc() around an expression of
    // such a type will never change its meaning, and nested calc is allowed,
    // this is always safe even when not needed.
    bool should_add_implicit_calc;
  };
  struct Parameter {
    std::string name;
    Type type;
  };

  StyleRuleFunction(const std::string& name,
                    std::vector<Parameter> parameters,
                    std::shared_ptr<CSSVariableData> function_body,
                    Type return_type);
  StyleRuleFunction(const StyleRuleFunction&) = delete;

  const std::string& GetName() const { return name_; }
  const std::vector<Parameter>& GetParameters() const { return parameters_; }
  CSSVariableData& GetFunctionBody() const { return *function_body_; }
  const Type& GetReturnType() const { return return_type_; }

  void TraceAfterDispatch(GCVisitor*) const;

 private:
  std::string name_;
  std::vector<Parameter> parameters_;
  std::shared_ptr<CSSVariableData> function_body_;
  Type return_type_;
};

// An @mixin rule, representing a CSS mixin. We store all of the rules
// and declarations under a dummy rule that serves as the parent;
// when @apply comes, we clone all the children below that rule and
// reparent them into the point of @apply.
class StyleRuleMixin : public StyleRuleBase {
 public:
  StyleRuleMixin(const std::string& name, std::shared_ptr<StyleRule> fake_parent_rule);
  StyleRuleMixin(const StyleRuleMixin&) = delete;

  const std::string& GetName() const { return name_; }
  StyleRule& FakeParentRule() const { return *fake_parent_rule_; }

  void TraceAfterDispatch(GCVisitor*) const;

 private:
  std::string name_;
  std::shared_ptr<StyleRule> fake_parent_rule_;
};

// An @apply rule, representing applying a mixin.
class StyleRuleApplyMixin : public StyleRuleBase {
 public:
  explicit StyleRuleApplyMixin(const std::string& name);
  StyleRuleApplyMixin(const StyleRuleMixin&) = delete;

  const std::string& GetName() const { return name_; }

  void TraceAfterDispatch(GCVisitor*) const;

 private:
  std::string name_;
};

template <>
struct DowncastTraits<StyleRule> {
  static bool AllowFrom(const StyleRuleBase& rule) { return rule.IsStyleRule(); }
};

template <>
struct DowncastTraits<StyleRuleFontFace> {
  static bool AllowFrom(const StyleRuleBase& rule) { return rule.IsFontFaceRule(); }
};

template <>
struct DowncastTraits<StyleRulePage> {
  static bool AllowFrom(const StyleRuleBase& rule) { return rule.IsPageRule(); }
};

template <>
struct DowncastTraits<StyleRulePageMargin> {
  static bool AllowFrom(const StyleRuleBase& rule) { return rule.IsPageRuleMargin(); }
};

template <>
struct DowncastTraits<StyleRuleProperty> {
  static bool AllowFrom(const StyleRuleBase& rule) { return rule.IsPropertyRule(); }
};

template <>
struct DowncastTraits<StyleRuleScope> {
  static bool AllowFrom(const StyleRuleBase& rule) { return rule.IsScopeRule(); }
};

template <>
struct DowncastTraits<StyleRuleGroup> {
  static bool AllowFrom(const StyleRuleBase& rule) {
    return rule.IsMediaRule() || rule.IsSupportsRule() || rule.IsContainerRule() || rule.IsLayerBlockRule() ||
           rule.IsScopeRule() || rule.IsStartingStyleRule();
  }
};

template <>
struct DowncastTraits<StyleRuleLayerBlock> {
  static bool AllowFrom(const StyleRuleBase& rule) { return rule.IsLayerBlockRule(); }
};

template <>
struct DowncastTraits<StyleRuleLayerStatement> {
  static bool AllowFrom(const StyleRuleBase& rule) { return rule.IsLayerStatementRule(); }
};

template <>
struct DowncastTraits<StyleRuleMedia> {
  static bool AllowFrom(const StyleRuleBase& rule) { return rule.IsMediaRule(); }
};

template <>
struct DowncastTraits<StyleRuleSupports> {
  static bool AllowFrom(const StyleRuleBase& rule) { return rule.IsSupportsRule(); }
};

template <>
struct DowncastTraits<StyleRuleContainer> {
  static bool AllowFrom(const StyleRuleBase& rule) { return rule.IsContainerRule(); }
};

template <>
struct DowncastTraits<StyleRuleCharset> {
  static bool AllowFrom(const StyleRuleBase& rule) { return rule.IsCharsetRule(); }
};

template <>
struct DowncastTraits<StyleRuleStartingStyle> {
  static bool AllowFrom(const StyleRuleBase& rule) { return rule.IsStartingStyleRule(); }
};

template <>
struct DowncastTraits<StyleRuleFunction> {
  static bool AllowFrom(const StyleRuleBase& rule) { return rule.IsFunctionRule(); }
};

template <>
struct DowncastTraits<StyleRuleMixin> {
  static bool AllowFrom(const StyleRuleBase& rule) { return rule.IsMixinRule(); }
};

template <>
struct DowncastTraits<StyleRuleApplyMixin> {
  static bool AllowFrom(const StyleRuleBase& rule) { return rule.IsApplyMixinRule(); }
};

}  // namespace webf

#endif  // WEBF_STYLE_RULE_H
