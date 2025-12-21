/*
 * Copyright (C) 1999 Lars Knoll (knoll@kde.org)
 * Copyright (C) 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010, 2011 Apple Inc.
 * All rights reserved.
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
 *
 */

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CSS_RESOLVER_STYLE_RESOLVER_H
#define WEBF_CSS_RESOLVER_STYLE_RESOLVER_H

#include <memory>
#include <vector>
#include "core/animation/interpolation.h"
#include "core/animation/property_handle.h"
#include "core/css/color_scheme_flags.h"
#include "core/css/element_rule_collector.h"
#include "core/css/resolver/matched_properties_cache.h"
#include "core/css/resolver/style_builder.h"
#include "core/css/resolver/style_resolver_state.h"
#include "core/css/selector_checker.h"
#include "core/css/selector_filter.h"
#include "core/css/style_request.h"
#include "core/style/computed_style.h"
#include "foundation/macros.h"

namespace webf {

// Represents the ordinal position of a scope in the cascade
using ScopeOrdinal = unsigned;

// Page margins style container
struct PageMarginsStyle {
  std::shared_ptr<const ComputedStyle> top;
  std::shared_ptr<const ComputedStyle> bottom;
  std::shared_ptr<const ComputedStyle> left;
  std::shared_ptr<const ComputedStyle> right;
  std::shared_ptr<const ComputedStyle> top_left_corner;
  std::shared_ptr<const ComputedStyle> top_left;
  std::shared_ptr<const ComputedStyle> top_center;
  std::shared_ptr<const ComputedStyle> top_right;
  std::shared_ptr<const ComputedStyle> top_right_corner;
  std::shared_ptr<const ComputedStyle> bottom_left_corner;
  std::shared_ptr<const ComputedStyle> bottom_left;
  std::shared_ptr<const ComputedStyle> bottom_center;
  std::shared_ptr<const ComputedStyle> bottom_right;
  std::shared_ptr<const ComputedStyle> bottom_right_corner;
  std::shared_ptr<const ComputedStyle> left_top;
  std::shared_ptr<const ComputedStyle> left_middle;
  std::shared_ptr<const ComputedStyle> left_bottom;
  std::shared_ptr<const ComputedStyle> right_top;
  std::shared_ptr<const ComputedStyle> right_middle;
  std::shared_ptr<const ComputedStyle> right_bottom;
};

class CompositorKeyframeValue;
class ContainerSelector;
class CSSPropertyValueSet;
class CSSValue;
class Document;
class Element;
class Font;
class Interpolation;
class MatchResult;
class PageMarginsStyle;
class PropertyHandle;
class StyleCascade;
class StyleRecalcContext;

// Tracks usage of style rules for DevTools
class StyleRuleUsageTracker {
 public:
  virtual ~StyleRuleUsageTracker() = default;
  virtual void Track(const StyleRule*) = 0;
};

// This class selects a ComputedStyle for a given element in a document based on
// the document's collection of stylesheets (user styles, author styles, UA
// style). There is a 1-1 relationship of StyleResolver and Document.
class StyleResolver final {
  WEBF_DISALLOW_NEW();

 public:
  explicit StyleResolver(Document&);
  StyleResolver(const StyleResolver&) = delete;
  StyleResolver& operator=(const StyleResolver&) = delete;
  ~StyleResolver();
  void Dispose();

  std::shared_ptr<const ComputedStyle> ResolveStyle(Element*,
                                                    const StyleRecalcContext&,
                                                    const StyleRequest& = StyleRequest());

  // Resolve base style for an element passing in the base styles for the parent
  // and the layout parent. Normally, base styles are computed as part of
  // ResolveStyle, inheriting from the parent's stored ComputedStyle, but for
  // after-change computations, the after-change style inherits from the
  // parent's after-change style, which is basically the parent's base style.
  const ComputedStyle& ResolveBaseStyle(
      Element&,
      const ComputedStyle* parent_base_style,
      const ComputedStyle* layout_parent_base_style,
      const StyleRecalcContext&);

  // Return a reference to the initial style singleton.
  const ComputedStyle& InitialStyle() const;

  // Create a new ComputedStyleBuilder based on the initial style singleton.
  ComputedStyleBuilder CreateComputedStyleBuilder() const;

  // Create a new ComputedStyleBuilder inheriting from the given style.
  ComputedStyleBuilder CreateComputedStyleBuilderInheritingFrom(
      const ComputedStyle& parent_style) const;

  // Create a ComputedStyle for initial styles to be used as the basis for the
  // root element style. In addition to initial values things like zoom, font,
  // forced color mode etc. is set.
  ComputedStyleBuilder InitialStyleBuilderForElement() const;

  static std::shared_ptr<const ComputedStyle> StyleForDocument(Document&);

  // Create a ComputedStyle for a Document or ShadowRoot.
  std::shared_ptr<const ComputedStyle> StyleForDocumentOrShadowRoot(ShadowRoot* shadow_root = nullptr);

  std::shared_ptr<const ComputedStyle> CreateAnonymousStyleWithDisplay(
      const ComputedStyle& parent_style,
      EDisplay);
  std::shared_ptr<const ComputedStyle> CreateInheritedDisplayContentsStyleIfNeeded(
      const ComputedStyle& parent_style,
      const ComputedStyle& layout_parent_style);

  // Public methods used by StyleResolver only during style resolution.
  // Create a ComputedStyle for <text> elements.
  static std::shared_ptr<const ComputedStyle> StyleForText(Text*);

  // Various methods to compute styles for pseudo elements.
  std::shared_ptr<const ComputedStyle> ResolveInheritedOnly(
      Element& element,
      const ComputedStyle& parent_style,
      const ComputedStyle& layout_parent_style) const;

  std::shared_ptr<const ComputedStyle> ResolveHighlightPseudoStyle(
      Element*,
      const AtomicString& pseudo_argument,
      const ComputedStyle& highlighted_text_style);

  std::shared_ptr<const ComputedStyle> ResolvePseudoElementStyle(
      const Element& pseudo_host,
      const PseudoElementStyleRequest&,
      const ComputedStyle* parent_style = nullptr);

  std::shared_ptr<const ComputedStyle> ResolvePseudoElementStyleWithContext(
      const Element& pseudo_host,
      const PseudoElementStyleRequest&,
      const StyleRequest& parent_request,
      const ComputedStyle* parent_style,
      const StyleRecalcContext&);

  // Create ComputedStyle for pages.
  std::shared_ptr<const ComputedStyle> StyleForPage(uint32_t page_index, const AtomicString& page_name);
  std::unique_ptr<PageMarginsStyle> StyleForPageMargins(
      int page_margin_type,
      uint32_t page_index,
      const ComputedStyle& page_style);

 Document& GetDocument() const;

  void SetRuleUsageTracker(StyleRuleUsageTracker*);

  void SetResizedForViewportUnits();
  void ClearResizedForViewportUnits();

  ComputedStyleBuilder CreateAnonymousStyleBuilderWithDisplay(
      const ComputedStyle& parent_style,
      EDisplay);

  void Trace(GCVisitor*) const;

  // Media queries and container queries may change the ComputedStyle used for
  // the given element. This is called during RecalcStyle when such changes are
  // detected.
  void UpdateMediaType();

  bool IsSkippingStyleRecalcForContainer() const {
    return skipping_style_recalc_for_container_;
  }

  // Expose rule matching for external callers who need the matched declarations
  // without computing computed style.
  void CollectAllRules(StyleResolverState& state,
                       ElementRuleCollector& collector,
                       bool include_smil_properties = false) {
    MatchAllRules(state, collector, include_smil_properties);
  }

 private:
  void ApplyBaseStyle(Element*,
                     const StyleRecalcContext&,
                     const StyleRequest&,
                     StyleResolverState&,
                     StyleCascade&);
  
  void ApplyBaseStyleNoCache(Element*,
                            const StyleRecalcContext&,
                            const StyleRequest&,
                            StyleResolverState&,
                            StyleCascade&);
  
  void InitStyle(Element& element,
                const StyleRequest&,
                const ComputedStyle& source_for_noninherited,
                const ComputedStyle* parent_style,
                StyleResolverState&);
  
  void ApplyPropertiesFromCascade(StyleResolverState&, StyleCascade&);
  
  void ApplyAllProperty(StyleResolverState&,
                       const CSSValue&,
                       TextDirection,
                       CSSPropertyValueSet::PropertySetFlag);

  template <CSSPropertyID>
  void ApplyInheritedOnlyProperty(StyleResolverState&, const CSSValue&);

  void UpdateFont(StyleResolverState&);
  void UpdateColorScheme(StyleResolverState&);

  bool IsInheritedOnlyProperty(CSSPropertyID property_id) const;

  // True if the given element matches the :lang() pseudo class parameter.
  static bool LangAttributeAffectsMatchType(
      CSSSelector::MatchType match_type, 
      const Element& element,
      const AtomicString& lang_argument_string);

  static bool IsAuthorSlottedForUnknownPseudoElements(const Element& element);

  struct CascadeScope {
    CascadeScope() = default;
    explicit CascadeScope(const CSSSelector* selector) : selector(selector) {}
    const CSSSelector* selector = nullptr;
  };

  void MatchUARules(ElementRuleCollector&);
  void MatchUserRules(ElementRuleCollector&);
  void MatchPresentationRules(Element& element, ElementRuleCollector&);
  void MatchAuthorRules(Element& element,
                       ScopeOrdinal scope_ordinal,
                       ElementRuleCollector&);
  void MatchAllRules(StyleResolverState&,
                    ElementRuleCollector&,
                    bool include_smil_properties);
  void ApplyMatchedPropertiesAndCustomPropertyAnimations(
      StyleResolverState&,
      const MatchResult&,
      bool apply_animations);
  bool ApplyAnimatedStyle(StyleResolverState&, StyleCascade&);
  void ApplyCallbackSelectors(StyleResolverState&);

  // False if shorthand properties should not be expanded to their longhands.
  bool ShouldUpdateNeedsApplyPass(const Element&) const;

  void CollectUserRulesFromUASheets(ElementRuleCollector&) const;

  // These flags indicate whether an @apply rule was encountered while
  // computing style for the element, and therefore whether we need to do
  // a second pass.
  enum ApplyPassFlags {
    kApplyRuleReferencedFromNonApplyRule = 1 << 0,
  };

  void IncrementApplyPassFlags(uint8_t flags) { apply_pass_flags_ |= flags; }

  bool NeedsApplyPass(const StyleResolverState&) const;

  // CSSPropertyID version of UpdateFont().
  void UpdateFontForZoomChange(StyleResolverState&);

  void LoadPendingResources(StyleResolverState&);

  void ResolveSVGPaint(const StyleRequest&,
                      ComputedStyleBuilder&,
                      Element* element,
                      const CSSPropertyID property_id,
                      const AtomicString& fallback_color,
                      const String& visited_fallback_color);

  Document* document_;
  SelectorFilter selector_filter_;

  std::unique_ptr<MatchedPropertiesCache> matched_properties_cache_;
  StyleRuleUsageTracker* tracker_ = nullptr;

  bool skipping_style_recalc_for_container_ = false;

  uint8_t apply_pass_flags_ = 0;
};

}  // namespace webf

#endif  // WEBF_CSS_RESOLVER_STYLE_RESOLVER_H
