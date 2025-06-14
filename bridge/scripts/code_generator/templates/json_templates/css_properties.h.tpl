// Copyright 2019 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef WEBF_CORE_CSS_CSS_PROPERTIES_<%= isShortHand ? 'SHORTHANDS' : 'LONGHANDS' %>_NAMES_H_
#define WEBF_CORE_CSS_CSS_PROPERTIES_<%= isShortHand ? 'SHORTHANDS' : 'LONGHANDS' %>_NAMES_H_

#include "core/css/properties/<%= isShortHand ? 'shorthand.h' : 'longhand.h' %>"
#include "core/css/properties/css_direction_aware_resolver.h"

namespace webf {

class ComputedStyle;
class CSSParserContext;
class CSSParserLocalContext;
class CSSValue;
class LayoutObject;
class Node;

namespace css_<%= isShortHand ? 'shorthand' : 'longhand' %> {

<% _.each(properties, (property, index) => { %>
<% let class_name = upperCamelCase(property.name) %>
<% let is_alias = property.alias_for %>
<% let is_surrogate = property.surrogate_for || (property.logical_property_group && property.logical_property_group.is_logical) %>
<% let property_id = 'CSSPropertyID::' + property.enum_key %>
<% let separator = '\'' + (property.separator || '\\0') + '\'' %>
<% let flags = [
    property.interpolable ? 'kInterpolable' : '',
    property.is_descriptor ? 'kDescriptor' : '',
    property.compositable ? 'kCompositableProperty' : '',
    property.is_property ? 'kProperty' : '',
    property.inherited ? 'kInherited' : '',
    property.visited ? 'kVisited' : '',
    property.is_internal ? 'kInternal' : '',
    property.is_animation_property ? 'kAnimation' : '',
    property.supports_incremental_style ? 'kSupportsIncrementalStyle' : '',
    property.idempotent ? 'kIdempotent' : '',
    property.accepts_numeric_literal ? 'kAcceptsNumericLiteral' : '',
    (property.overlapping || property.legacy_overlapping) ? 'kOverlapping' : '',
    property.legacy_overlapping ? 'kLegacyOverlapping' : '',
    property.valid_for_first_letter ? 'kValidForFirstLetter' : '',
    property.valid_for_first_line ? 'kValidForFirstLine' : '',
    property.valid_for_cue ? 'kValidForCue' : '',
    property.valid_for_marker ? 'kValidForMarker' : '',
    property.valid_for_formatted_text ? 'kValidForFormattedText' : '',
    property.valid_for_formatted_text_run ? 'kValidForFormattedTextRun' : '',
    property.valid_for_keyframe ? 'kValidForKeyframe' : '',
    property.valid_for_position_try ? 'kValidForPositionTry' : '',
    property.valid_for_limited_page_context ? 'kValidForLimitedPageContext' : '',
    property.valid_for_page_context ? 'kValidForPageContext' : '',
    property.valid_for_permission_element ? 'kValidForPermissionElement' : '',
    property.surrogate_for || (property.logical_property_group && property.logical_property_group.is_logical) ? 'kSurrogate' : '',
    property.font ? 'kAffectsFont' : '',
    property.is_background ? 'kBackground' : '',
    property.is_border ? 'kBorder' : '',
    property.is_border_radius ? 'kBorderRadius' : '',
    property.is_highlight_colors ? 'kHighlightColors' : '',
    property.is_visited_highlight_colors ? 'kVisitedHighlightColors' : '',
    property.valid_for_highlight_legacy ? 'kValidForHighlightLegacy' : '',
    property.valid_for_highlight ? 'kValidForHighlight' : '',
    property.logical_property_group ? 'kInLogicalPropertyGroup' : '',
    ].filter(flag => flag !== '').join(' | '); %>
<% let ctor_args = !is_alias ? [property_id, flags, separator] : []; %>
// <%= property.name %>
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).

class <%= class_name %> final : public <%= property.superclass %> {
 public:
  constexpr <%= class_name %>() : <%= property.superclass %>(<%= ctor_args.join(', ') %>  ) { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  <% if(property.alternative) { %>
  CSSPropertyID GetAlternative() const override {
    return CSSPropertyID::<%= property.alternative.enum_key %>;
  }
  <% } %>
  <% if (!is_alias) { %>
  <% if (!property.affected_by_all) { %>
  bool IsAffectedByAll() const override { return false; }
  <% } %>
  <% if (property.layout_dependent) { %>
  bool IsLayoutDependentProperty() const override { return true; }
  bool IsLayoutDependent(const ComputedStyle*, LayoutObject*) const override;
  <% } %>
  <% if(is_surrogate) { %>
  const CSSProperty* SurrogateFor(WritingDirectionMode) const override;
  <% } %>
  <% _.each(property.property_methods, (property_method, index) => { %>
  <%= property_method.return_type %> <%= property_method.name %><%= property_method.parameters %> const override;
  <% }); %>
  <% if (property.logical_property_group) { %>
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
    <% if(property.logical_property_group.is_logical) { %>
  const CSSProperty& ResolveDirectionAwarePropertyInternal(WritingDirectionMode) const override;
  std::shared_ptr<const CSSValue> CSSValueFromComputedStyleInternal(
      const ComputedStyle&,
      const LayoutObject*,
      bool allow_visited_style,
      CSSValuePhase value_phase) const override {
    // Directional properties are resolved by CSSDirectionAwareResolver
    // before calling CSSValueFromComputedStyleInternal.
    assert(false);
    return nullptr;
  }
    <% } %>
  <% } %>
  <% if(property.style_builder_declare) { %>
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
  <% } %>
  <% } %>
};


<% }); %>

}  // namespace  css_<%= isShortHand ? 'shorthand' : 'longhand' %>
}  // namespace webf

#endif  // WEBF_CORE_CSS_CSS_PROPERTIES_<%= isShortHand ? 'SHORTHANDS' : 'LONGHANDS' %>_NAMES_H_
