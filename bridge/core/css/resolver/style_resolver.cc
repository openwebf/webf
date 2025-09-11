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
#include <algorithm>
#include <string>

#include "foundation/logging.h"
#include "core/css/css_default_style_sheets.h"
#include "core/css/css_identifier_value.h"
#include "core/css/css_property_value_set.h"
#include "core/css/inline_css_style_declaration.h"
#include "core/css/css_rule_list.h"
#include "core/css/css_selector.h"
#include "core/css/css_style_rule.h"
#include "core/css/css_style_sheet.h"
#include "core/css/element_rule_collector.h"
#include "core/css/style_rule.h"
#include "core/css/media_query_evaluator.h"
#include "bindings/qjs/exception_state.h"
#include "core/css/resolver/match_request.h"
#include "core/css/resolver/style_builder.h"
#include "core/css/resolver/style_cascade.h"
#include "core/css/resolver/style_resolver_state.h"
#include "core/css/resolver/style_adjuster.h"
#include "core/css/rule_set.h"
#include "core/css/style_engine.h"
#include "core/css/style_sheet_contents.h"
#include "core/dom/document.h"
#include "core/dom/element.h"
#include "core/dom/shadow_root.h"
#include "core/dom/text.h"
#include "core/html/html_style_element.h"
#include "core/html/html_link_element.h"
#include "html_names.h"
#include "core/html/html_head_element.h"
#include "core/style/computed_style.h"
#include "core/style/computed_style_constants.h"
#include "code_gen/html_element_type_helper.h"

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
    AtomicString direction = AtomicString::CreateFromUTF8("ltr");
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

  // Initialize the state for style resolution (following Blink's pattern)
  StyleResolverState state(GetDocument(), *element);
  
  // Create cascade early (like Blink does)
  StyleCascade cascade(state);
  
  // Apply base style (this is the core of Blink's approach)
  ApplyBaseStyle(element, style_recalc_context, style_request, state, cascade);
  
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

void StyleResolver::ApplyBaseStyle(
    Element* element,
    const StyleRecalcContext& style_recalc_context,
    const StyleRequest& style_request,
    StyleResolverState& state,
    StyleCascade& cascade) {
  
  // For now, skip animation optimizations and go directly to ApplyBaseStyleNoCache
  // This follows Blink's pattern but without the caching optimizations
  ApplyBaseStyleNoCache(element, style_recalc_context, style_request, state, cascade);
}

void StyleResolver::ApplyBaseStyleNoCache(
    Element* element,
    const StyleRecalcContext& style_recalc_context,
    const StyleRequest& style_request,
    StyleResolverState& state,
    StyleCascade& cascade) {
  
  // Set parent style if not already set (following Blink's pattern)
  if (!state.ParentStyle()) {
    const ComputedStyle* parent_style = style_request.parent_override;
    if (!parent_style && element->parentElement()) {
      parent_style = element->parentElement()->GetComputedStyle();
    }
    if (!parent_style) {
      // Use initial style as parent for root elements
      parent_style = &InitialStyle();
    }
    state.SetParentStyle(parent_style);
    state.SetLayoutParentStyle(style_request.layout_parent_override ? 
                                style_request.layout_parent_override : parent_style);
  }
  
  // Create ElementRuleCollector and collect all matching rules
  ElementRuleCollector collector(state);
  MatchAllRules(state, collector, false);
  
  // Sort and transfer matched rules to the cascade
  collector.SortAndTransferMatchedRules();
  
  const auto& match_result = collector.GetMatchResult();
  
  // For pseudo elements, check if we have no matched properties
  if (style_request.IsPseudoStyleRequest()) {
    if (match_result.IsEmpty()) {
      InitStyle(*element, style_request, InitialStyle(), state.ParentStyle(), state);
      StyleAdjuster::AdjustComputedStyle(const_cast<ElementResolveContext&>(state.ElementContext()), 
                                         style_request,
                                         element,
                                         state.StyleBuilder());
      state.SetHadNoMatchedProperties();
      return;
    }
  }
  
  // This is where Blink gets the match result from the cascade
  const MatchResult& result = cascade.GetMatchResult();
  
  // Apply matched cache (simplified - skip caching for now)
  // CacheSuccess cache_success = ApplyMatchedCache(state, style_request, result);
  ComputedStyleBuilder& builder = state.StyleBuilder();
  
  // Initialize the style properly (like Blink's InitStyle)
  InitStyle(*element, style_request, InitialStyle(), state.ParentStyle(), state);
  
  // Copy the match result to the cascade
  cascade.MutableMatchResult() = match_result;
  
  // Apply properties from cascade (always apply since we skip caching)
  ApplyPropertiesFromCascade(state, cascade);
  
  // Apply style adjustments
  StyleAdjuster::AdjustComputedStyle(const_cast<ElementResolveContext&>(state.ElementContext()), 
                                     style_request,
                                     element,
                                     state.StyleBuilder());
}

void StyleResolver::InitStyle(
    Element& element,
    const StyleRequest& style_request,
    const ComputedStyle& source_for_noninherited,
    const ComputedStyle* parent_style,
    StyleResolverState& state) {
  
  // Following Blink's InitStyle implementation:
  // state.CreateNewStyle(source_for_noninherited, *parent_style);
  // Since CreateNewStyle is not implemented in WebF, we need to do what it does:
  // Create a ComputedStyleBuilder that takes non-inherited properties from
  // source_for_noninherited and inherited properties from parent_style
  
  // First create from parent to get inherited properties
  ComputedStyleBuilder builder = CreateComputedStyleBuilderInheritingFrom(*parent_style);
  
  // But we need a proper way to copy non-inherited properties from source_for_noninherited
  // In Blink, this is done inside the ComputedStyleBuilder constructor
  // For now, WebF's builder doesn't support this pattern, so we keep the simple approach
  
  // Set the builder on the state
  state.SetComputedStyleBuilder(std::move(builder));
}

void StyleResolver::ApplyPropertiesFromCascade(
    StyleResolverState& state,
    StyleCascade& cascade) {
  
  // Apply the cascade (this is where CSS properties are actually applied)
  cascade.Apply();
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
  
  // Match inline style (highest priority)
  if (element.IsStyledElement()) {
    auto inline_style_set = const_cast<Element&>(element).EnsureMutableInlineStyle();
    if (inline_style_set && inline_style_set->PropertyCount() > 0) {
      collector.AddElementStyleProperties(inline_style_set,
                                         PropertyAllowedInMode::kAll);
    }
  }
}

void StyleResolver::MatchUARules(ElementRuleCollector& collector) {
  // Initialize UA stylesheets if not already done
  CSSDefaultStyleSheets::Init();
  
  // Match rules from the default HTML stylesheet
  auto html_style = CSSDefaultStyleSheets::DefaultHTMLStyle();
  if (html_style && html_style->RuleCount() > 0) {
    // Create a RuleSet from the stylesheet for matching
    // TODO: This should be cached for performance
    auto rule_set = std::make_shared<RuleSet>();
    MediaQueryEvaluator evaluator("screen");
    rule_set->AddRulesFromSheet(html_style, evaluator, kRuleHasNoSpecialState);
    
    // Create match request and collect matching rules
    MatchRequest request(rule_set, CascadeOrigin::kUserAgent);
    collector.CollectMatchingRules(request);
  }
  
  // Apply quirks mode stylesheet if in quirks mode
  // TODO: Implement quirks mode detection in Document
  // For now, we'll skip quirks mode styles
  /*
  if (document_->InQuirksMode()) {
    auto quirks_style = CSSDefaultStyleSheets::QuirksStyle();
    if (quirks_style && quirks_style->RuleCount() > 0) {
      auto rule_set = std::make_shared<RuleSet>();
      MediaQueryEvaluator evaluator("screen");
      rule_set->AddRulesFromSheet(quirks_style, evaluator, kRuleHasNoSpecialState);
      MatchRequest request(rule_set, CascadeOrigin::kUserAgent);
      collector.CollectMatchingRules(request);
    }
  }
  */
  
  // TODO: Add SVG and MathML stylesheets when elements support them
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
  // Match rules from author stylesheets (style elements, link elements)
  Document& document = element.GetDocument();
  
  // Get all style elements in the document by traversal; link-based sheets come from StyleEngine registry.
  std::vector<Element*> style_elements;
  
  // Helper function to recursively find style elements
  std::function<void(Node*)> findStyleElements = [&](Node* node) {
    if (!node) return;
    
    if (node->IsElementNode()) {
      Element* elem = static_cast<Element*>(node);
      // Use HasTagName for robust tag matching
      if (elem->HasTagName(html_names::kStyle)) {
        style_elements.push_back(elem);
      }
    }
    
    for (Node* child = node->firstChild(); child; child = child->nextSibling()) {
      findStyleElements(child);
    }
  };
  
  // Start from document element
  findStyleElements(document.documentElement());
  
  // Create a media query evaluator for the current document
  MediaQueryEvaluator media_evaluator("screen");
  
  for (auto* style_element : style_elements) {
    if (!style_element) {
      continue;
    }
    
    // Check if this is a style element
    // Note: tagName() returns uppercase for HTML elements
    if (!style_element->HasTagName(html_names::kStyle)) {
      continue;
    }
    
    // Cast to HTMLStyleElement - safe because we checked the tag name
    auto* html_style = static_cast<HTMLStyleElement*>(style_element);
    if (!html_style) {
      continue;
    }
    
    CSSStyleSheet* sheet = html_style->sheet();
    if (!sheet || !sheet->Contents()) {
      continue;
    }
    
    // Get or create the RuleSet from the style sheet contents
    auto rule_set_ptr = sheet->Contents()->EnsureRuleSet(media_evaluator);
    
    // Create a match request for this style sheet
    MatchRequest match_request(rule_set_ptr);
    collector.CollectMatchingRules(match_request);
  }

  // Process link-based author stylesheets from StyleEngine registry (robust even if DOM traversal misses links)
  const auto& author_sheets = document.EnsureStyleEngine().AuthorSheets();
  unsigned author_index = 0;
  for (const auto& contents : author_sheets) {
    if (!contents) { author_index++; continue; }
    auto rule_set_ptr = contents->EnsureRuleSet(media_evaluator);
    // Preserve stylesheet order so later sheets override earlier ones.
    MatchRequest match_request(rule_set_ptr, CascadeOrigin::kAuthor, author_index);
    collector.CollectMatchingRules(match_request);
    author_index++;
  }
}

// Old method - can be removed as it's replaced by ApplyBaseStyleNoCache flow
// void StyleResolver::ApplyMatchedPropertiesAndCustomPropertyAnimations(...) { ... }

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
