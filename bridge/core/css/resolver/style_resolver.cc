/*
 * Copyright (C) 1999 Lars Knoll (knoll@kde.org)
 *           (C) 2004-2005 Allan Sandfeld Jensen (kde@carewolf.com)
 * Copyright (C) 2006, 2007 Nicholas Shanks (webkit@nickshanks.com)
 * Copyright (C) 2005, 2006, 2007, 2008, 2009, 2010, 2011, 2012, 2013 Apple Inc.
 * All rights reserved.
 * Copyright (C) 2007 Alexey Proskuryakov <ap@webkit.org>
 * Copyright (C) 2007, 2008 Eric Seidel <eric@webkit.org>
 * Copyright (C) 2008, 2009 Torch Mobile Inc. All rights reserved.
 * (http://www.torchmobile.com/)
 * Copyright (c) 2011, Code Aurora Forum. All rights reserved.
 * Copyright (C) Research In Motion Limited 2011. All rights reserved.
 * Copyright (C) 2012 Google Inc. All rights reserved.
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

#include "style_resolver.h"

#include "core/css/css_default_style_sheets.h"
#include "core/css/css_identifier_value.h"
#include "core/css/css_property_value_set.h"
#include "core/css/css_rule_list.h"
#include "core/css/css_selector.h"
#include "core/css/css_style_rule.h"
#include "core/css/css_style_sheet.h"
#include "core/css/resolver/style_builder.h"
#include "core/css/resolver/style_cascade.h"
#include "core/css/resolver/style_resolver_state.h"
#include "core/css/resolver/style_adjuster.h"
#include "core/css/style_engine.h"
#include "core/css/style_sheet_contents.h"
#include "core/dom/document.h"
#include "core/dom/element.h"
#include "core/dom/shadow_root.h"
#include "core/dom/text.h"
#include "core/style/computed_style.h"
#include "core/style/computed_style_constants.h"

namespace webf {

namespace {

bool ShouldSkipApplyingForAnimationAffectedProperty(const CSSPropertyID property_id) {
  switch (property_id) {
    case CSSPropertyID::kWebkitFontSmoothing:
      return true;
    default:
      return false;
  }
}

}  // namespace

StyleResolver::StyleResolver(Document& document) 
    : document_(&document),
      matched_properties_cache_(std::make_unique<MatchedPropertiesCache>()) {
}

StyleResolver::~StyleResolver() {
  Dispose();
}

void StyleResolver::Dispose() {
  matched_properties_cache_.reset();
}

const ComputedStyle& StyleResolver::InitialStyle() const {
  return ComputedStyle::GetInitialStyle();
}

ComputedStyleBuilder StyleResolver::CreateComputedStyleBuilder() const {
  return ComputedStyleBuilder(InitialStyle());
}

ComputedStyleBuilder StyleResolver::CreateComputedStyleBuilderInheritingFrom(
    const ComputedStyle& parent_style) const {
  return ComputedStyleBuilder(parent_style);
}

ComputedStyleBuilder StyleResolver::InitialStyleBuilderForElement() const {
  auto builder = CreateComputedStyleBuilder();
  
  // TODO: Implement quirks mode detection
  builder.SetIsQuirksModeDocumentForView(false);
  // TODO: Get content language
  builder.SetLocale(g_null_atom);
  
  TextDirection root_direction = TextDirection::kLtr;
  Element* document_element = document_->documentElement();
  if (document_element) {
    // TODO: Get dir attribute properly
    AtomicString direction("ltr");
    if (direction == "rtl") {
      root_direction = TextDirection::kRtl;
    }
  }
  builder.SetDirection(root_direction);
  
  FontDescription document_font_description = builder.GetFontDescription();
  // TODO: Font locale support
  // document_font_description.SetLocale(builder.Locale());
  builder.SetFontDescription(document_font_description);
  
  return builder;
}

std::shared_ptr<const ComputedStyle> StyleResolver::ResolveStyle(
    Element* element,
    const StyleRecalcContext& style_recalc_context,
    const StyleRequest& style_request) {
  
  if (!element) {
    return nullptr;
  }

  // Initialize the state for style resolution
  StyleResolverState state(GetDocument(), *element);
  
  InitStyleAndApplyInheritance(*element, style_request, state);
  
  // Collect matching rules
  ElementRuleCollector collector(state);
  MatchAllRules(state, collector, false);
  
  // Apply the collected properties
  if (collector.HasMatchedRules()) {
    ApplyMatchedPropertiesAndCustomPropertyAnimations(
        state, collector.GetMatchResult(), true);
  }
  
  // Load pending resources if any
  LoadPendingResources(state);
  
  // Return the computed style
  return state.TakeComputedStyle();
}

const ComputedStyle& StyleResolver::ResolveBaseStyle(
    Element& element,
    const ComputedStyle* parent_base_style,
    const ComputedStyle* layout_parent_base_style,
    const StyleRecalcContext& style_recalc_context) {
  
  StyleRequest style_request;
  style_request.parent_override = parent_base_style;
  style_request.layout_parent_override = layout_parent_base_style;
  
  auto style = ResolveStyle(&element, style_recalc_context, style_request);
  return *style;
}

void StyleResolver::InitStyleAndApplyInheritance(
    Element& element,
    const StyleRequest& style_request,
    StyleResolverState& state) {
  
  const ComputedStyle* parent_style = style_request.parent_override;
  const ComputedStyle* layout_parent_style = style_request.layout_parent_override;
  
  if (!parent_style) {
    parent_style = element.parentElement() ? 
        element.parentElement()->GetComputedStyle() : nullptr;
  }
  
  if (!layout_parent_style) {
    layout_parent_style = parent_style;
  }
  
  // Create initial style
  ComputedStyleBuilder builder = parent_style ?
      CreateComputedStyleBuilderInheritingFrom(*parent_style) :
      InitialStyleBuilderForElement();
  
  state.SetComputedStyleBuilder(std::move(builder));
  state.SetParentStyle(parent_style);
  state.SetLayoutParentStyle(layout_parent_style);
}

void StyleResolver::MatchAllRules(
    StyleResolverState& state,
    ElementRuleCollector& collector,
    bool include_smil_properties) {
  
  Element& element = state.GetElement();
  
  // Match UA rules
  MatchUARules(collector);
  
  // Match user rules
  MatchUserRules(collector);
  
  // Match presentation attribute rules
  MatchPresentationRules(element, collector);
  
  // Match author rules
  MatchAuthorRules(element, 0, collector);
}

void StyleResolver::MatchUARules(ElementRuleCollector& collector) {
  // TODO: Implement UA rules matching
  // This would match default styles from the UA stylesheet
}

void StyleResolver::MatchUserRules(ElementRuleCollector& collector) {
  // TODO: Implement user rules matching
  // This would match user-defined stylesheets
}

void StyleResolver::MatchPresentationRules(
    Element& element, 
    ElementRuleCollector& collector) {
  // TODO: Implement presentation attribute rules matching
  // This would match HTML presentation attributes like width, height, etc.
}

void StyleResolver::MatchAuthorRules(
    Element& element,
    ScopeOrdinal scope_ordinal,
    ElementRuleCollector& collector) {
  // TODO: Implement author rules matching
  // This would match rules from author stylesheets
}

void StyleResolver::ApplyMatchedPropertiesAndCustomPropertyAnimations(
    StyleResolverState& state,
    const MatchResult& match_result,
    bool apply_animations) {
  
  // Create cascade
  StyleCascade cascade(state);
  
  // Add match result to cascade and apply
  cascade.MutableMatchResult() = match_result;
  cascade.Apply();
  
  // Apply animations if needed
  if (apply_animations) {
    ApplyAnimatedStyle(state, cascade);
  }
  
  // Apply callback selectors
  ApplyCallbackSelectors(state);
  
  // Update font if needed
  UpdateFont(state);
  
  // Update color scheme if needed
  UpdateColorScheme(state);
  
  // Apply style adjustments
  StyleRequest style_request;  // TODO: Get proper style request
  StyleAdjuster::AdjustComputedStyle(const_cast<ElementResolveContext&>(state.ElementContext()), 
                                     style_request,
                                     &state.GetElement(),
                                     state.StyleBuilder());
}

bool StyleResolver::ApplyAnimatedStyle(
    StyleResolverState& state,
    StyleCascade& cascade) {
  // TODO: Implement animation application
  return false;
}

void StyleResolver::ApplyCallbackSelectors(StyleResolverState& state) {
  // TODO: Implement callback selectors
}

void StyleResolver::UpdateFont(StyleResolverState& state) {
  // TODO: Implement font update logic
  state.GetFontBuilder().CreateFont(state.StyleBuilder(), state.ParentStyle());
}

void StyleResolver::UpdateColorScheme(StyleResolverState& state) {
  // TODO: Implement color scheme update logic
}

void StyleResolver::LoadPendingResources(StyleResolverState& state) {
  // TODO: Implement resource loading
}

std::shared_ptr<const ComputedStyle> StyleResolver::StyleForDocument(Document& document) {
  StyleResolver resolver(document);
  return resolver.StyleForDocumentOrShadowRoot();
}

std::shared_ptr<const ComputedStyle> StyleResolver::StyleForDocumentOrShadowRoot(
    ShadowRoot* shadow_root) {
  
  ComputedStyleBuilder builder = InitialStyleBuilderForElement();
  
  // Set document-specific properties
  builder.SetDisplay(EDisplay::kBlock);
  builder.SetPosition(EPosition::kAbsolute);
  builder.SetOverflowX(EOverflow::kAuto);
  builder.SetOverflowY(EOverflow::kAuto);
  
  return builder.TakeStyle();
}

std::shared_ptr<const ComputedStyle> StyleResolver::CreateAnonymousStyleWithDisplay(
    const ComputedStyle& parent_style,
    EDisplay display) {
  
  ComputedStyleBuilder builder = CreateComputedStyleBuilderInheritingFrom(parent_style);
  builder.SetDisplay(display);
  return builder.TakeStyle();
}

std::shared_ptr<const ComputedStyle> StyleResolver::CreateInheritedDisplayContentsStyleIfNeeded(
    const ComputedStyle& parent_style,
    const ComputedStyle& layout_parent_style) {
  
  if (parent_style.InheritedEqual(layout_parent_style)) {
    return nullptr;
  }
  
  return CreateAnonymousStyleWithDisplay(parent_style, EDisplay::kContents);
}

std::shared_ptr<const ComputedStyle> StyleResolver::StyleForText(Text* text_node) {
  if (!text_node || !text_node->parentElement()) {
    return nullptr;
  }
  
  const ComputedStyle* style = text_node->parentElement()->GetComputedStyle();
  return style ? style->shared_from_this() : nullptr;
}

std::shared_ptr<const ComputedStyle> StyleResolver::ResolveInheritedOnly(
    Element& element,
    const ComputedStyle& parent_style,
    const ComputedStyle& layout_parent_style) const {
  
  ComputedStyleBuilder builder = CreateComputedStyleBuilderInheritingFrom(parent_style);
  
  // Only inherit properties, don't apply any rules
  return builder.TakeStyle();
}

std::shared_ptr<const ComputedStyle> StyleResolver::ResolveHighlightPseudoStyle(
    Element* element,
    const AtomicString& pseudo_argument,
    const ComputedStyle& highlighted_text_style) {
  // TODO: Implement highlight pseudo style resolution
  return nullptr;
}

std::shared_ptr<const ComputedStyle> StyleResolver::ResolvePseudoElementStyle(
    const Element& pseudo_host,
    const PseudoElementStyleRequest& request,
    const ComputedStyle* parent_style) {
  // TODO: Implement pseudo element style resolution
  return nullptr;
}

std::shared_ptr<const ComputedStyle> StyleResolver::ResolvePseudoElementStyleWithContext(
    const Element& pseudo_host,
    const PseudoElementStyleRequest& request,
    const StyleRequest& parent_request,
    const ComputedStyle* parent_style,
    const StyleRecalcContext& style_recalc_context) {
  // TODO: Implement pseudo element style resolution with context
  return nullptr;
}

std::shared_ptr<const ComputedStyle> StyleResolver::StyleForPage(
    uint32_t page_index, 
    const AtomicString& page_name) {
  // TODO: Implement page style resolution
  return nullptr;
}

std::unique_ptr<PageMarginsStyle> StyleResolver::StyleForPageMargins(
    int page_margin_type,
    uint32_t page_index,
    const ComputedStyle& page_style) {
  // TODO: Implement page margins style resolution
  return nullptr;
}

Document& StyleResolver::GetDocument() const {
  return *document_;
}

void StyleResolver::SetRuleUsageTracker(StyleRuleUsageTracker* tracker) {
  tracker_ = tracker;
}

void StyleResolver::SetResizedForViewportUnits() {
  // TODO: Implement viewport units resize handling
}

void StyleResolver::ClearResizedForViewportUnits() {
  // TODO: Implement viewport units resize clearing
}

ComputedStyleBuilder StyleResolver::CreateAnonymousStyleBuilderWithDisplay(
    const ComputedStyle& parent_style,
    EDisplay display) {
  
  ComputedStyleBuilder builder = CreateComputedStyleBuilderInheritingFrom(parent_style);
  builder.SetDisplay(display);
  return builder;
}

void StyleResolver::Trace(GCVisitor* visitor) const {
  // TODO: Implement tracing
}

void StyleResolver::UpdateMediaType() {
  // TODO: Implement media type update
}

bool StyleResolver::ShouldUpdateNeedsApplyPass(const Element& element) const {
  // TODO: Implement proper logic
  return false;
}

bool StyleResolver::NeedsApplyPass(const StyleResolverState& state) const {
  return apply_pass_flags_ != 0;
}

void StyleResolver::UpdateFontForZoomChange(StyleResolverState& state) {
  // TODO: Implement font zoom update
}

bool StyleResolver::IsInheritedOnlyProperty(CSSPropertyID property_id) const {
  // TODO: Implement property inheritance check
  return false;
}

bool StyleResolver::LangAttributeAffectsMatchType(
    CSSSelector::MatchType match_type,
    const Element& element,
    const AtomicString& lang_argument_string) {
  // TODO: Implement language attribute matching
  return false;
}

bool StyleResolver::IsAuthorSlottedForUnknownPseudoElements(const Element& element) {
  // TODO: Implement slotted element check
  return false;
}

}  // namespace webf