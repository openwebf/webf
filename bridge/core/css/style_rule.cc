/*
 * (C) 1999-2003 Lars Knoll (knoll@kde.org)
 * (C) 2002-2003 Dirk Mueller (mueller@kde.org)
 * Copyright (C) 2002, 2005, 2006, 2008, 2012 Apple Inc. All rights reserved.
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

#include "style_rule.h"
#include "core/css/css_markup.h"
#include "css_selector_list.h"

namespace webf {

std::string StyleRuleBase::LayerNameAsString(const webf::StyleRuleBase::LayerName& name_parts) {
  StringBuilder result;
  for (const auto& part : name_parts) {
    if (!result.empty()) {
      result.Append(".");
    }
    SerializeIdentifier(part, result);
  }
  return result.ReleaseString();
}

std::shared_ptr<const StyleRuleBase> StyleRuleBase::Copy() const {
  //  switch (GetType()) {
  //    case kStyle:
  //      return To<StyleRule>(this)->Copy();
  //    case kPage:
  //      return To<StyleRulePage>(this)->Copy();
  //    case kPageMargin:
  //      return To<StyleRulePageMargin>(this)->Copy();
  //    case kProperty:
  //      return To<StyleRuleProperty>(this)->Copy();
  //    case kFontFace:
  //      return To<StyleRuleFontFace>(this)->Copy();
  //    case kFontPaletteValues:
  //      return To<StyleRuleFontPaletteValues>(this)->Copy();
  //    case kFontFeatureValues:
  //      return To<StyleRuleFontFeatureValues>(this)->Copy();
  //    case kFontFeature:
  //      return To<StyleRuleFontFeature>(this)->Copy();
  //    case kMedia:
  //      return To<StyleRuleMedia>(this)->Copy();
  //    case kScope:
  //      return To<StyleRuleScope>(this)->Copy();
  //    case kSupports:
  //      return To<StyleRuleSupports>(this)->Copy();
  //    case kImport:
  //      // FIXME: Copy import rules.
  //      NOTREACHED_IN_MIGRATION();
  //      return nullptr;
  //    case kKeyframes:
  //      return To<StyleRuleKeyframes>(this)->Copy();
  //    case kLayerBlock:
  //      return To<StyleRuleLayerBlock>(this)->Copy();
  //    case kLayerStatement:
  //      return To<StyleRuleLayerStatement>(this)->Copy();
  //    case kNamespace:
  //      return To<StyleRuleNamespace>(this)->Copy();
  //    case kCharset:
  //    case kKeyframe:
  //    case kFunction:
  //    case kMixin:
  //    case kApplyMixin:
  //      NOTREACHED_IN_MIGRATION();
  //      return nullptr;
  //    case kContainer:
  //      return To<StyleRuleContainer>(this)->Copy();
  //    case kCounterStyle:
  //      return To<StyleRuleCounterStyle>(this)->Copy();
  //    case kStartingStyle:
  //      return To<StyleRuleStartingStyle>(this)->Copy();
  //    case kViewTransition:
  //      return To<StyleRuleViewTransition>(this)->Copy();
  //    case kPositionTry:
  //      return To<StyleRulePositionTry>(this)->Copy();
  //  }
  assert(false);
  return shared_from_this();
}

CSSRule* StyleRuleBase::CreateCSSOMWrapper(uint32_t position_hint,
                                           webf::CSSStyleSheet* parent_sheet,
                                           bool trigger_use_counters) const {
  return CreateCSSOMWrapper(position_hint, parent_sheet, nullptr, trigger_use_counters);
}

CSSRule* StyleRuleBase::CreateCSSOMWrapper(uint32_t position_hint,
                                           webf::CSSRule* parent_rule,
                                           bool trigger_use_counters) const {
  return CreateCSSOMWrapper(position_hint, nullptr, parent_rule, trigger_use_counters);
}

CSSRule* StyleRuleBase::CreateCSSOMWrapper(uint32_t position_hint,
                                           webf::CSSStyleSheet* parent_sheet,
                                           webf::CSSRule* parent_rule,
                                           bool trigger_use_counters) const {
  CSSRule* rule = nullptr;
  StyleRuleBase* self = const_cast<StyleRuleBase*>(this);
  //  switch (GetType()) {
  //    case kStyle:
  //      rule = MakeGarbageCollected<CSSStyleRule>(To<StyleRule>(self),
  //                                                parent_sheet, position_hint);
  //      break;
  //    case kPage:
  //      if (trigger_use_counters && parent_sheet) {
  //        UseCounter::Count(parent_sheet->OwnerDocument(),
  //                          WebFeature::kCSSPageRule);
  //      }
  //      rule = MakeGarbageCollected<CSSPageRule>(To<StyleRulePage>(self),
  //                                               parent_sheet);
  //      break;
  //    case kPageMargin:
  //      rule = MakeGarbageCollected<CSSMarginRule>(To<StyleRulePageMargin>(self),
  //                                                 parent_sheet);
  //      break;
  //    case kProperty:
  //      rule = MakeGarbageCollected<CSSPropertyRule>(To<StyleRuleProperty>(self),
  //                                                   parent_sheet);
  //      break;
  //    case kFontFace:
  //      rule = MakeGarbageCollected<CSSFontFaceRule>(To<StyleRuleFontFace>(self),
  //                                                   parent_sheet);
  //      break;
  //    case kFontPaletteValues:
  //      rule = MakeGarbageCollected<CSSFontPaletteValuesRule>(
  //          To<StyleRuleFontPaletteValues>(self), parent_sheet);
  //      break;
  //    case kFontFeatureValues:
  //      rule = MakeGarbageCollected<CSSFontFeatureValuesRule>(
  //          To<StyleRuleFontFeatureValues>(self), parent_sheet);
  //      break;
  //    case kMedia:
  //      rule = MakeGarbageCollected<CSSMediaRule>(To<StyleRuleMedia>(self),
  //                                                parent_sheet);
  //      break;
  //    case kScope:
  //      rule = MakeGarbageCollected<CSSScopeRule>(To<StyleRuleScope>(self),
  //                                                parent_sheet);
  //      break;
  //    case kSupports:
  //      rule = MakeGarbageCollected<CSSSupportsRule>(To<StyleRuleSupports>(self),
  //                                                   parent_sheet);
  //      break;
  //    case kImport:
  //      rule = MakeGarbageCollected<CSSImportRule>(To<StyleRuleImport>(self),
  //                                                 parent_sheet);
  //      break;
  //    case kKeyframes:
  //      rule = MakeGarbageCollected<CSSKeyframesRule>(
  //          To<StyleRuleKeyframes>(self), parent_sheet);
  //      break;
  //    case kLayerBlock:
  //      rule = MakeGarbageCollected<CSSLayerBlockRule>(
  //          To<StyleRuleLayerBlock>(self), parent_sheet);
  //      break;
  //    case kLayerStatement:
  //      rule = MakeGarbageCollected<CSSLayerStatementRule>(
  //          To<StyleRuleLayerStatement>(self), parent_sheet);
  //      break;
  //    case kNamespace:
  //      rule = MakeGarbageCollected<CSSNamespaceRule>(
  //          To<StyleRuleNamespace>(self), parent_sheet);
  //      break;
  //    case kContainer:
  //      rule = MakeGarbageCollected<CSSContainerRule>(
  //          To<StyleRuleContainer>(self), parent_sheet);
  //      break;
  //    case kCounterStyle:
  //      rule = MakeGarbageCollected<CSSCounterStyleRule>(
  //          To<StyleRuleCounterStyle>(self), parent_sheet);
  //      break;
  //    case kStartingStyle:
  //      rule = MakeGarbageCollected<CSSStartingStyleRule>(
  //          To<StyleRuleStartingStyle>(self), parent_sheet);
  //      break;
  //    case kViewTransition:
  //      rule = MakeGarbageCollected<CSSViewTransitionRule>(
  //          To<StyleRuleViewTransition>(self), parent_sheet);
  //      break;
  //    case kPositionTry:
  //      rule = MakeGarbageCollected<CSSPositionTryRule>(
  //          To<StyleRulePositionTry>(self), parent_sheet);
  //      break;
  //    case kFontFeature:
  //    case kKeyframe:
  //    case kCharset:
  //    case kFunction:
  //    case kMixin:
  //    case kApplyMixin:
  //      NOTREACHED_IN_MIGRATION();
  //      return nullptr;
  //  }
  //  if (parent_rule) {
  //    rule->SetParentRule(parent_rule);
  //  }
  //  return rule;
  return nullptr;
}

void StyleRuleBase::Reparent(webf::StyleRule* old_parent, webf::StyleRule* new_parent) {
  //  switch (GetType()) {
  //    case kStyle:
  //      CSSSelectorList::Reparent(To<StyleRule>(this)->SelectorArray(),
  //                                new_parent);
  //      break;
  //    case kScope:
  //    case kLayerBlock:
  //    case kContainer:
  //    case kMedia:
  //    case kSupports:
  //    case kStartingStyle:
  //      for (StyleRuleBase* child :
  //           DynamicTo<StyleRuleGroup>(this)->ChildRules()) {
  //        child->Reparent(new_parent);
  //      }
  //      break;
  //    case kPage:
  //      for (StyleRuleBase* child :
  //           DynamicTo<StyleRulePage>(this)->ChildRules()) {
  //        child->Reparent(new_parent);
  //      }
  //      break;
  //    case kMixin:
  //    case kApplyMixin:
  //      // The parent pointers in mixins don't really matter;
  //      // they are always replaced during application anyway.
  //      break;
  //    case kPageMargin:
  //    case kProperty:
  //    case kFontFace:
  //    case kFontPaletteValues:
  //    case kFontFeatureValues:
  //    case kFontFeature:
  //    case kImport:
  //    case kKeyframes:
  //    case kLayerStatement:
  //    case kNamespace:
  //    case kCounterStyle:
  //    case kKeyframe:
  //    case kCharset:
  //    case kViewTransition:
  //    case kFunction:
  //    case kPositionTry:
  //      // Cannot have any child rules.
  //      break;
  //  }
}

void StyleRuleBase::Trace(webf::GCVisitor* gc_visitor) const {
  //  switch (GetType()) {
  //    case kCharset:
  //      To<StyleRuleCharset>(this)->TraceAfterDispatch(visitor);
  //      return;
  //    case kStyle:
  //      To<StyleRule>(this)->TraceAfterDispatch(visitor);
  //      return;
  //    case kPage:
  //      To<StyleRulePage>(this)->TraceAfterDispatch(visitor);
  //      return;
  //    case kPageMargin:
  //      To<StyleRulePageMargin>(this)->TraceAfterDispatch(visitor);
  //      return;
  //    case kProperty:
  //      To<StyleRuleProperty>(this)->TraceAfterDispatch(visitor);
  //      return;
  //    case kFontFace:
  //      To<StyleRuleFontFace>(this)->TraceAfterDispatch(visitor);
  //      return;
  //    case kFontPaletteValues:
  //      To<StyleRuleFontPaletteValues>(this)->TraceAfterDispatch(visitor);
  //      return;
  //    case kFontFeatureValues:
  //      To<StyleRuleFontFeatureValues>(this)->TraceAfterDispatch(visitor);
  //      return;
  //    case kFontFeature:
  //      To<StyleRuleFontFeature>(this)->TraceAfterDispatch(visitor);
  //      return;
  //    case kMedia:
  //      To<StyleRuleMedia>(this)->TraceAfterDispatch(visitor);
  //      return;
  //    case kScope:
  //      To<StyleRuleScope>(this)->TraceAfterDispatch(visitor);
  //      return;
  //    case kSupports:
  //      To<StyleRuleSupports>(this)->TraceAfterDispatch(visitor);
  //      return;
  //    case kImport:
  //      To<StyleRuleImport>(this)->TraceAfterDispatch(visitor);
  //      return;
  //    case kKeyframes:
  //      To<StyleRuleKeyframes>(this)->TraceAfterDispatch(visitor);
  //      return;
  //    case kKeyframe:
  //      To<StyleRuleKeyframe>(this)->TraceAfterDispatch(visitor);
  //      return;
  //    case kLayerBlock:
  //      To<StyleRuleLayerBlock>(this)->TraceAfterDispatch(visitor);
  //      return;
  //    case kLayerStatement:
  //      To<StyleRuleLayerStatement>(this)->TraceAfterDispatch(visitor);
  //      return;
  //    case kNamespace:
  //      To<StyleRuleNamespace>(this)->TraceAfterDispatch(visitor);
  //      return;
  //    case kContainer:
  //      To<StyleRuleContainer>(this)->TraceAfterDispatch(visitor);
  //      return;
  //    case kCounterStyle:
  //      To<StyleRuleCounterStyle>(this)->TraceAfterDispatch(visitor);
  //      return;
  //    case kStartingStyle:
  //      To<StyleRuleStartingStyle>(this)->TraceAfterDispatch(visitor);
  //      return;
  //    case kViewTransition:
  //      To<StyleRuleViewTransition>(this)->TraceAfterDispatch(visitor);
  //      return;
  //    case kFunction:
  //      To<StyleRuleFunction>(this)->TraceAfterDispatch(visitor);
  //      return;
  //    case kMixin:
  //      To<StyleRuleMixin>(this)->TraceAfterDispatch(visitor);
  //      return;
  //    case kApplyMixin:
  //      To<StyleRuleApplyMixin>(this)->TraceAfterDispatch(visitor);
  //      return;
  //    case kPositionTry:
  //      To<StyleRulePositionTry>(this)->TraceAfterDispatch(visitor);
  //      return;
  //  }
  //  DUMP_WILL_BE_NOTREACHED();
}

void StyleRuleBase::FinalizeGarbageCollectedObject() {
  //  switch (GetType()) {
  //    case kCharset:
  //      To<StyleRuleCharset>(this)->~StyleRuleCharset();
  //      return;
  //    case kStyle:
  //      To<StyleRule>(this)->~StyleRule();
  //      return;
  //    case kPage:
  //      To<StyleRulePage>(this)->~StyleRulePage();
  //      return;
  //    case kPageMargin:
  //      To<StyleRulePageMargin>(this)->~StyleRulePageMargin();
  //      return;
  //    case kProperty:
  //      To<StyleRuleProperty>(this)->~StyleRuleProperty();
  //      return;
  //    case kFontFace:
  //      To<StyleRuleFontFace>(this)->~StyleRuleFontFace();
  //      return;
  //    case kFontPaletteValues:
  //      To<StyleRuleFontPaletteValues>(this)->~StyleRuleFontPaletteValues();
  //      return;
  //    case kFontFeatureValues:
  //      To<StyleRuleFontFeatureValues>(this)->~StyleRuleFontFeatureValues();
  //      return;
  //    case kFontFeature:
  //      To<StyleRuleFontFeature>(this)->~StyleRuleFontFeature();
  //      return;
  //    case kMedia:
  //      To<StyleRuleMedia>(this)->~StyleRuleMedia();
  //      return;
  //    case kScope:
  //      To<StyleRuleScope>(this)->~StyleRuleScope();
  //      return;
  //    case kSupports:
  //      To<StyleRuleSupports>(this)->~StyleRuleSupports();
  //      return;
  //    case kImport:
  //      To<StyleRuleImport>(this)->~StyleRuleImport();
  //      return;
  //    case kKeyframes:
  //      To<StyleRuleKeyframes>(this)->~StyleRuleKeyframes();
  //      return;
  //    case kKeyframe:
  //      To<StyleRuleKeyframe>(this)->~StyleRuleKeyframe();
  //      return;
  //    case kLayerBlock:
  //      To<StyleRuleLayerBlock>(this)->~StyleRuleLayerBlock();
  //      return;
  //    case kLayerStatement:
  //      To<StyleRuleLayerStatement>(this)->~StyleRuleLayerStatement();
  //      return;
  //    case kNamespace:
  //      To<StyleRuleNamespace>(this)->~StyleRuleNamespace();
  //      return;
  //    case kContainer:
  //      To<StyleRuleContainer>(this)->~StyleRuleContainer();
  //      return;
  //    case kCounterStyle:
  //      To<StyleRuleCounterStyle>(this)->~StyleRuleCounterStyle();
  //      return;
  //    case kStartingStyle:
  //      To<StyleRuleStartingStyle>(this)->~StyleRuleStartingStyle();
  //      return;
  //    case kViewTransition:
  //      To<StyleRuleViewTransition>(this)->~StyleRuleViewTransition();
  //      return;
  //    case kFunction:
  //      To<StyleRuleFunction>(this)->~StyleRuleFunction();
  //      return;
  //    case kMixin:
  //      To<StyleRuleMixin>(this)->~StyleRuleMixin();
  //      return;
  //    case kApplyMixin:
  //      To<StyleRuleApplyMixin>(this)->~StyleRuleApplyMixin();
  //      return;
  //    case kPositionTry:
  //      To<StyleRulePositionTry>(this)->~StyleRulePositionTry();
  //      return;
  //  }
  //  NOTREACHED_IN_MIGRATION();
}

bool StyleRuleBase::IsInvisible() const {
  auto* style_rule = DynamicTo<StyleRule>(this);
  return style_rule && style_rule->FirstSelector()->IsInvisible();
}

bool StyleRuleBase::IsSignaling() const {
  auto* style_rule = DynamicTo<StyleRule>(this);
  return style_rule && (style_rule->FirstSelector()->GetSignal() != CSSSelector::Signal::kNone);
}

void StyleRuleBase::ChildRuleVector::Iterator::operator++() {
  ++position_;
  // Skip invisible rules.
  while (position_ != end_ && position_->get()->IsInvisible()) {
    ++position_;
  }
}

std::shared_ptr<StyleRuleBase::ChildRuleVector> StyleRuleBase::ChildRuleVector::Copy() const {
  auto child_rule_vector = std::make_shared<ChildRuleVector>();
  child_rule_vector->rules_.reserve(rules_.size());
  for (auto&& rule : rules_) {
    child_rule_vector->AddChildRule(rule->Copy());
  }
  return child_rule_vector;
}

void StyleRule::AddChildRule(std::shared_ptr<StyleRuleBase> child) {
  EnsureChildRules();
  if (child->IsSignaling()) {
    SetHasSignalingChildRule(true);
  }
  child_rule_vector_->AddChildRule(child);
}

void StyleRuleBase::ChildRuleVector::AddChildRule(const std::shared_ptr<const StyleRuleBase>& rule) {
  if (rule->IsInvisible()) {
    // Note that invisible rules can not be removed.
    ++num_invisible_rules_;
  }
  rules_.push_back(rule);
}

void StyleRuleBase::ChildRuleVector::WrapperInsertRule(unsigned index,
                                                       const std::shared_ptr<const StyleRuleBase>& rule) {
  assert(!rule->IsInvisible());
  rules_.insert(rules_.begin() + AdjustedIndex(index), rule);
}

void StyleRuleBase::ChildRuleVector::WrapperRemoveRule(unsigned int index) {
  rules_.erase(rules_.begin() + AdjustedIndex(index));
}

size_t StyleRuleBase::ChildRuleVector::AdjustedIndex(size_t index) const {
  if (num_invisible_rules_ == 0) {
    return index;
  }
  for (size_t i = 0; i < rules_.size(); ++i) {
    if (rules_[i]->IsInvisible()) {
      continue;
    }
    if (index == 0) {
      return i;
    }
    --index;
  }
  // All invisible rules, or no rules at all.
  return rules_.size();
}

StyleRule::StyleRule(webf::PassKey<StyleRule>,
                     tcb::span<CSSSelector> selector_vector,
                     std::shared_ptr<const CSSPropertyValueSet> properties)
    : StyleRuleBase(kStyle), properties_(properties) {}

StyleRule::StyleRule(webf::PassKey<StyleRule>,
                     tcb::span<CSSSelector> selector_vector,
                     std::shared_ptr<CSSLazyPropertyParser> lazy_property_parser)
    : StyleRuleBase(kStyle), lazy_property_parser_(std::move(lazy_property_parser)) {
  CSSSelectorList::AdoptSelectorVector(selector_vector, SelectorArray());
}

StyleRule::StyleRule(webf::PassKey<StyleRule>,
                     tcb::span<CSSSelector> selector_vector)
    : StyleRuleBase(kStyle) {
  CSSSelectorList::AdoptSelectorVector(selector_vector, SelectorArray());
}

StyleRule::StyleRule(webf::PassKey<StyleRule>,
                     tcb::span<CSSSelector> selector_vector,
                     StyleRule&& other)
    : StyleRuleBase(kStyle),
      properties_(other.properties_),
      lazy_property_parser_(other.lazy_property_parser_),
      child_rule_vector_(std::move(other.child_rule_vector_)) {
  CSSSelectorList::AdoptSelectorVector(selector_vector, SelectorArray());
}


StyleRule::StyleRule(const StyleRule& other, size_t flattened_size)
    : StyleRuleBase(kStyle), properties_(other.Properties().MutableCopy()) {
  for (unsigned i = 0; i < flattened_size; ++i) {
    new (&SelectorArray()[i]) CSSSelector(other.SelectorArray()[i]);
  }
  if (other.child_rule_vector_ != nullptr) {
    // Since we are getting copied, we also need to copy any child rules
    // so that both old and new can be freely mutated. This also
    // parses them eagerly (see comment in StyleSheetContents'
    // copy constructor).
    child_rule_vector_ = other.child_rule_vector_->Copy();
  }
  SetHasSignalingChildRule(other.HasSignalingChildRule());
}

StyleRule::~StyleRule() {
  // Clean up any RareData that the selectors may be owning.
  CSSSelector* selector = SelectorArray();
  for (;;) {
    bool is_last = selector->IsLastInSelectorList();
    selector->~CSSSelector();
    if (is_last) {
      break;
    } else {
      ++selector;
    }
  }
}

const CSSPropertyValueSet& StyleRule::Properties() const {
  if (!properties_) {
    properties_ = lazy_property_parser_->ParseProperties();
    lazy_property_parser_ = nullptr;
  }
  return *properties_;
}

}  // namespace webf
