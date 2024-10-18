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
#include "core/css/css_style_sheet.h"
#include "core/css/parser/css_parser.h"
#include "core/css/parser/container_query_parser.h"
#include "core/css/parser/css_tokenizer.h"
#include "core/css/style_sheet_contents.h"
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

void StyleRuleBase::Reparent(webf::StyleRule* new_parent) {
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

bool StyleRule::HasParsedProperties() const {
  // StyleRule should only have one of {lazy_property_parser_, properties_} set.
  DCHECK(lazy_property_parser_ || properties_);
  DCHECK(!lazy_property_parser_ || !properties_);
  return !lazy_property_parser_;
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
    : StyleRuleBase(kStyle), properties_(std::move(properties)) {
  CSSSelectorList::AdoptSelectorVector(selector_vector, SelectorArray());
}

StyleRule::StyleRule(webf::PassKey<StyleRule>,
                     tcb::span<CSSSelector> selector_vector,
                     std::shared_ptr<CSSLazyPropertyParser> lazy_property_parser)
    : StyleRuleBase(kStyle), lazy_property_parser_(std::move(lazy_property_parser)) {
  CSSSelectorList::AdoptSelectorVector(selector_vector, SelectorArray());
}

StyleRule::StyleRule(webf::PassKey<StyleRule>, tcb::span<CSSSelector> selector_vector) : StyleRuleBase(kStyle) {
  CSSSelectorList::AdoptSelectorVector(selector_vector, SelectorArray());
}

StyleRule::StyleRule(webf::PassKey<StyleRule>, tcb::span<CSSSelector> selector_vector, StyleRule&& other)
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

MutableCSSPropertyValueSet& StyleRule::MutableProperties() {
  // Ensure properties_ is initialized.
  if (!Properties().IsMutable()) {
    properties_ = std::const_pointer_cast<MutableCSSPropertyValueSet>(properties_->MutableCopy());
  }
  return *To<MutableCSSPropertyValueSet>(const_cast<CSSPropertyValueSet*>(properties_.get()));
}

bool StyleRule::PropertiesHaveFailedOrCanceledSubresources() const {
  return properties_ && properties_->HasFailedOrCanceledSubresources();
}

void StyleRule::TraceAfterDispatch(GCVisitor* visitor) const {
  StyleRuleBase::TraceAfterDispatch(visitor);
}

StyleRuleFontFace::StyleRuleFontFace(std::shared_ptr<CSSPropertyValueSet> properties)
    : StyleRuleBase(kFontFace), properties_(properties) {}

StyleRuleFontFace::StyleRuleFontFace(const StyleRuleFontFace& font_face_rule)
    : StyleRuleBase(font_face_rule),
      properties_(font_face_rule.properties_->MutableCopy()) {}

MutableCSSPropertyValueSet& StyleRuleFontFace::MutableProperties() {
  if (!properties_->IsMutable()) {
    properties_ = std::const_pointer_cast<MutableCSSPropertyValueSet>(properties_->MutableCopy());
  }
  return *To<MutableCSSPropertyValueSet>(const_cast<CSSPropertyValueSet*>(properties_.get()));
}

void StyleRuleFontFace::TraceAfterDispatch(webf::GCVisitor*) const {}

StyleRuleProperty::StyleRuleProperty(const std::string& name, std::shared_ptr<CSSPropertyValueSet> properties)
    : StyleRuleBase(kProperty), name_(name), properties_(std::move(properties)) {}

StyleRuleProperty::StyleRuleProperty(const StyleRuleProperty& property_rule)
    : StyleRuleBase(property_rule), name_(property_rule.name_), properties_(property_rule.properties_->MutableCopy()) {}

MutableCSSPropertyValueSet& StyleRuleProperty::MutableProperties() {
  if (!properties_->IsMutable()) {
    properties_ = properties_->MutableCopy();
  }
  return *To<MutableCSSPropertyValueSet>(const_cast<CSSPropertyValueSet*>(properties_.get()));
}

const std::shared_ptr<const CSSValue>* StyleRuleProperty::GetSyntax() const {
  return properties_->GetPropertyCSSValue(CSSPropertyID::kSyntax);
}

const std::shared_ptr<const CSSValue>* StyleRuleProperty::Inherits() const {
  return properties_->GetPropertyCSSValue(CSSPropertyID::kInherits);
}

const std::shared_ptr<const CSSValue>* StyleRuleProperty::GetInitialValue() const {
  return properties_->GetPropertyCSSValue(CSSPropertyID::kInitialValue);
}

bool StyleRuleProperty::SetNameText(const ExecutingContext* execution_context, const std::string& name_text) {
  DCHECK(!name_text.empty());
  std::string name = CSSParser::ParseCustomPropertyName(name_text);
  if (name.empty())
    return false;

  name_ = name;
  return true;
}

void StyleRuleProperty::TraceAfterDispatch(webf::GCVisitor*) const {}

StyleRuleGroup::StyleRuleGroup(RuleType type, std::vector<std::shared_ptr<StyleRuleBase>> rules)
    : StyleRuleBase(type), child_rule_vector_(std::make_shared<ChildRuleVector>()) {
  for (auto&& rule : rules) {
    if (rule->IsSignaling()) {
      SetHasSignalingChildRule(true);
    }
    child_rule_vector_->AddChildRule(rule);
  }
}

StyleRuleGroup::StyleRuleGroup(const StyleRuleGroup& group_rule)
    : StyleRuleBase(group_rule), child_rule_vector_(group_rule.child_rule_vector_->Copy()) {
  SetHasSignalingChildRule(group_rule.HasSignalingChildRule());
}

void StyleRuleGroup::WrapperInsertRule(CSSStyleSheet* parent_sheet,
                                       unsigned index,
                                       const std::shared_ptr<const StyleRuleBase> rule) {
  child_rule_vector_->WrapperInsertRule(index, rule);
  if (parent_sheet) {
    parent_sheet->Contents()->NotifyRuleChanged(const_cast<StyleRuleBase*>(rule.get()));
  }
}

void StyleRuleGroup::WrapperRemoveRule(CSSStyleSheet* parent_sheet, unsigned index) {
  if (parent_sheet) {
    parent_sheet->Contents()->NotifyRuleChanged(const_cast<StyleRuleBase*>((*child_rule_vector_)[index].get()));
  }
  child_rule_vector_->WrapperRemoveRule(index);
}

void StyleRuleGroup::TraceAfterDispatch(webf::GCVisitor*) const {}

StyleRulePage::StyleRulePage(std::shared_ptr<CSSSelectorList> selector_list,
                             std::shared_ptr<CSSPropertyValueSet> properties,
                             std::vector<std::shared_ptr<StyleRuleBase>> child_rules)
    : StyleRuleGroup(kPage, std::move(child_rules)),
      properties_(std::move(properties)),
      selector_list_(std::move(selector_list)) {}

StyleRulePage::StyleRulePage(const StyleRulePage& page_rule)
    : StyleRuleGroup(page_rule),
      properties_(page_rule.properties_->MutableCopy()),
      selector_list_(page_rule.selector_list_->Copy()) {}

MutableCSSPropertyValueSet& StyleRulePage::MutableProperties() {
  if (!properties_->IsMutable()) {
    properties_ = properties_->MutableCopy();
  }
  return *To<MutableCSSPropertyValueSet>(const_cast<CSSPropertyValueSet*>(properties_.get()));
}

void StyleRulePage::TraceAfterDispatch(webf::GCVisitor* visitor) const {}

StyleRuleScope::StyleRuleScope(const StyleScope& style_scope, std::vector<std::shared_ptr<StyleRuleBase>> rules)
    : StyleRuleGroup(kScope, std::move(rules)), style_scope_(&style_scope) {}

StyleRuleScope::StyleRuleScope(const StyleRuleScope& other)
    : StyleRuleGroup(other), style_scope_(std::make_shared<StyleScope>(*other.style_scope_)) {}

void StyleRuleScope::TraceAfterDispatch(GCVisitor* visitor) const {
  StyleRuleGroup::TraceAfterDispatch(visitor);
}

void StyleRuleScope::SetPreludeText(const ExecutingContext* execution_context,
                                    std::string value,
                                    CSSNestingType nesting_type,
                                    std::shared_ptr<const StyleRule> parent_rule_for_nesting,
                                    bool is_within_scope,
                                    std::shared_ptr<StyleSheetContents> style_sheet) {
  auto parser_context = std::make_shared<CSSParserContext>(execution_context);
  CSSTokenizer tokenizer(value);
  std::vector<CSSParserToken> tokens = tokenizer.TokenizeToEOF();
  tokens.reserve(32);

  style_scope_ =
      StyleScope::Parse(tokens, parser_context, nesting_type, parent_rule_for_nesting, is_within_scope, style_sheet);

  // Reparent rules within the @scope's body.
  Reparent(style_scope_->RuleForNesting());
}

StyleRulePageMargin::StyleRulePageMargin(CSSAtRuleID id, std::shared_ptr<CSSPropertyValueSet> properties)
    : StyleRuleBase(kPageMargin), id_(id), properties_(properties) {}

StyleRulePageMargin::StyleRulePageMargin(const StyleRulePageMargin& page_margin_rule)
    : StyleRuleBase(page_margin_rule), properties_(page_margin_rule.properties_->MutableCopy()) {}

MutableCSSPropertyValueSet& StyleRulePageMargin::MutableProperties() {
  if (!properties_->IsMutable()) {
    properties_ = properties_->MutableCopy();
  }
  return *To<MutableCSSPropertyValueSet>(const_cast<CSSPropertyValueSet*>(properties_.get()));
}

void StyleRulePageMargin::TraceAfterDispatch(webf::GCVisitor*) const {}

StyleRuleLayerBlock::StyleRuleLayerBlock(LayerName&& name, std::vector<std::shared_ptr<StyleRuleBase>> rules)
    : StyleRuleGroup(kLayerBlock, std::move(rules)), name_(std::move(name)) {}

StyleRuleLayerBlock::StyleRuleLayerBlock(const StyleRuleLayerBlock& other) = default;

void StyleRuleLayerBlock::TraceAfterDispatch(GCVisitor* visitor) const {
  StyleRuleGroup::TraceAfterDispatch(visitor);
}

StyleRuleLayerStatement::StyleRuleLayerStatement(std::vector<LayerName>&& names)
    : StyleRuleBase(kLayerStatement), names_(std::move(names)) {}

StyleRuleLayerStatement::StyleRuleLayerStatement(const StyleRuleLayerStatement& other) = default;

void StyleRuleLayerStatement::TraceAfterDispatch(GCVisitor* visitor) const {
  StyleRuleBase::TraceAfterDispatch(visitor);
}

StyleRuleCondition::StyleRuleCondition(RuleType type, std::vector<std::shared_ptr<StyleRuleBase>> rules)
    : StyleRuleGroup(type, std::move(rules)) {}

StyleRuleCondition::StyleRuleCondition(RuleType type,
                                       const std::string& condition_text,
                                       std::vector<std::shared_ptr<StyleRuleBase>> rules)
    : StyleRuleGroup(type, std::move(rules)), condition_text_(condition_text) {}

StyleRuleCondition::StyleRuleCondition(const StyleRuleCondition& condition_rule) = default;

StyleRuleMedia::StyleRuleMedia(std::shared_ptr<const MediaQuerySet> media,
                               std::vector<std::shared_ptr<StyleRuleBase>> rules)
    : StyleRuleCondition(kMedia, std::move(rules)), media_queries_(media) {}

void StyleRuleMedia::TraceAfterDispatch(GCVisitor* visitor) const {}

StyleRuleContainer::StyleRuleContainer(ContainerQuery& container_query,
                                       std::vector<std::shared_ptr<StyleRuleBase>> rules)
    : StyleRuleCondition(kContainer, container_query.ToString(), std::move(rules)),
      container_query_(&container_query) {}

StyleRuleContainer::StyleRuleContainer(const StyleRuleContainer& container_rule) : StyleRuleCondition(container_rule) {
  DCHECK(container_rule.container_query_);
  container_query_ = std::make_shared<ContainerQuery>(*container_rule.container_query_);
}

void StyleRuleContainer::SetConditionText(const ExecutingContext* execution_context, const std::string value) {
  auto context = std::make_shared<CSSParserContext>(execution_context);
  ContainerQueryParser parser(*context);

  if (std::shared_ptr<const MediaQueryExpNode> exp_node = parser.ParseCondition(value)) {
    condition_text_ = exp_node->Serialize();

    ContainerSelector selector(container_query_->Selector().Name(), *exp_node);
    container_query_ = std::make_shared<ContainerQuery>(std::move(selector), exp_node);
  }
}

void StyleRuleContainer::TraceAfterDispatch(GCVisitor* visitor) const {
  StyleRuleCondition::TraceAfterDispatch(visitor);
}

StyleRuleStartingStyle::StyleRuleStartingStyle(
    std::vector<std::shared_ptr<StyleRuleBase>> rules)
    : StyleRuleGroup(kStartingStyle, std::move(rules)) {}


StyleRuleFunction::StyleRuleFunction(
    const std::string& name,
    std::vector<StyleRuleFunction::Parameter> parameters,
    std::shared_ptr<CSSVariableData> function_body,
    StyleRuleFunction::Type return_type)
    : StyleRuleBase(kFunction),
      name_(name),
      parameters_(std::move(parameters)),
      function_body_(std::move(function_body)),
      return_type_(return_type) {}

void StyleRuleFunction::TraceAfterDispatch(GCVisitor* visitor) const {
  StyleRuleBase::TraceAfterDispatch(visitor);
}

StyleRuleMixin::StyleRuleMixin(const std::string& name, std::shared_ptr<StyleRule> fake_parent_rule)
    : StyleRuleBase(RuleType::kMixin),
      name_(std::move(name)),
      fake_parent_rule_(std::move(fake_parent_rule)) {}

void StyleRuleMixin::TraceAfterDispatch(GCVisitor* visitor) const {
  StyleRuleBase::TraceAfterDispatch(visitor);
}

StyleRuleApplyMixin::StyleRuleApplyMixin(const std::string& name)
    : StyleRuleBase(kApplyMixin), name_(name) {}

void StyleRuleApplyMixin::TraceAfterDispatch(GCVisitor* visitor) const {
  StyleRuleBase::TraceAfterDispatch(visitor);
}

}  // namespace webf
