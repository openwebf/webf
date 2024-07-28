// Copyright 2019 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "core/css/properties/<%= isShortHand ? 'shorthand.h' : 'longhand.h' %>"

#include "core/css/css_custom_ident_value.h"
#include "core/css/css_identifier_value.h"
#include "core/css/css_primitive_value.h"
#include "core/css/css_primitive_value_mappings.h"
#include "core/css/css_value_list.h"
#include "core/css/css_value_pair.h"
#include "core/css/properties/css_direction_aware_resolver.h"
#include "core/css/properties/style_building_utils.h"
#include "core/css/resolver/font_builder.h"
#include "core/css/resolver/style_builder_converter.h"
#include "core/css/resolver/style_resolver_state.h"
#include "core/execution_context/execution_context.h"
#include "core/style/computed_style.h"
#include "core/style/style_svg_resource.h"
#include "platform/runtime_enabled_features.h"

namespace webf {
namespace css_<%= isShortHand ? 'shorthand' : 'longhand' %> {

<% properties.forEach(property => { %>
  <% const class_name = upperCamelCase(property.name); %>
  <% const is_alias = property.alias_for; %>
  <% var exposed_property = property.ultimate_property; %>
  // <%= property.name %>

  <% function returnNoneIfAlternativeExposed(alternative) { %>
    <% if (alternative.alternative) { %>
      <%= returnNoneIfAlternativeExposed(alternative.alternative) %>
    <% } %>
    if (RuntimeEnabledFeatures.<%= alternative.runtime_flag %>Enabled(execution_context)) {
      // <%= alternative.name %>
      return CSSExposure.kNone;
    }
  <% } %>

  <% if (!property.known_exposed) { %>
CSSExposure <%= class_name %>::Exposure(const ExecutionContext* execution_context) const {
    <% if (property.alternative) { %>
        <%= returnNoneIfAlternativeExposed(property.alternative) %>
    <% } %>
    <% if (property.runtime_flag) { %>
  if (!RuntimeEnabledFeatures.<%= property.runtime_flag %>Enabled(execution_context)) {
    return CSSExposure.kNone;
  }
    <% } %>
    <% if (property.is_internal) { %>
  return CSSExposure.kUA;
    <% } else { %>
  return CSSExposure.kWeb;
    <% } %>
}
  <% } %>

const char* <%= class_name %>::GetPropertyName() const {
  return "<%= exposed_property.name %>";
}

const AtomicString& <%= class_name %>::GetPropertyNameAtomicString() const {
  DEFINE_STATIC_LOCAL(const AtomicString, name, ("<%= exposed_property.name %>"));
  return name;
}

const char* <%= class_name %>::GetJSPropertyName() const {
  return "<%= lowerCamelCase(exposed_property.name) %>";
}

  <% if (!is_alias) { %>

    <% if (property.surrogateFor) { %>
const CSSProperty* <%= class_name %>::SurrogateFor(TextDirection direction,
    webf::WritingMode writing_mode) const {
  return &GetCSSProperty<%= upperCamelCase(property.surrogateFor.name) %>();
}
    <% } %>
    <% if (property.logical_property_group) { %>
      <% const group = property.logical_property_group; %>
      <% const group_name = upperCamelCase(group.name); %>
      <% const resolver_name = upperCamelCase(group.resolver_name); %>
      <% if (group.is_logical) { %>
const CSSProperty* <%= class_name %>::SurrogateFor(TextDirection direction,
    webf::WritingMode writing_mode) const {
  return &ResolveDirectionAwarePropertyInternal(direction, writing_mode);
}

const CSSProperty& <%= class_name %>::ResolveDirectionAwarePropertyInternal(
    TextDirection direction,
    webf::WritingMode writing_mode) const {
  return CSSDirectionAwareResolver.Resolve<%= resolver_name %>(direction, writing_mode,
      CSSDirectionAwareResolver.Physical<%= group_name %>Mapping());
}

bool <%= class_name %>::IsInSameLogicalPropertyGroupWithDifferentMappingLogic(
    CSSPropertyID id) const {
  return CSSDirectionAwareResolver.Physical<%= group_name %>Mapping().Contains(id);
}
      <% } else { %>
bool <%= class_name %>::IsInSameLogicalPropertyGroupWithDifferentMappingLogic(
    CSSPropertyID id) const {
  return CSSDirectionAwareResolver.Logical<%= group_name %>Mapping().Contains(id);
}
      <% } %>
    <% } %>

  <% } %> <% /* not isAlias */ %>
<% }); %> <% /* properties */ %>


}  // <%= isShortHand ? 'shorthand' : 'longhand' %>
}  // namespace webf
