// Copyright 2019 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "<%= isShortHand ? 'shorthands.h' : 'longhands.h' %>"
#include "core/css/properties/<%= isShortHand ? 'shorthand.h' : 'longhand.h' %>"

#include "core/css/css_custom_ident_value.h"
#include "core/css/css_identifier_value.h"
#include "core/css/css_primitive_value.h"
// #include "core/css/css_primitive_value_mappings.h"
#include "core/css/css_value_list.h"
#include "core/css/css_value_pair.h"
#include "core/css/resolver/style_resolver_state.h"

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



const char* <%= class_name %>::GetPropertyName() const {
  return "<%= exposed_property.name %>";
}

const char* <%= class_name %>::GetJSPropertyName() const {
  return "<%= lowerCamelCase(exposed_property.name) %>";
}

  <% if (!is_alias) { %>

    <% if (property.surrogateFor) { %>
const CSSProperty* <%= class_name %>::SurrogateFor(WritingDirectionMode) const {
  return &GetCSSProperty<%= upperCamelCase(property.surrogateFor.name) %>();
}
    <% } %>
    <% if (property.logical_property_group) { %>
      <% const group = property.logical_property_group; %>
      <% const group_name = group.name.toUpperCamelCase(); %>
      <% const resolver_name = group.resolver_name.toUpperCamelCase(); %>
      <% if (group.is_logical) { %>
const CSSProperty* <%= class_name %>::SurrogateFor(WritingDirectionMode writing_direction) const {
  return &ResolveDirectionAwarePropertyInternal(writing_direction);
}

const CSSProperty& <%= class_name %>::ResolveDirectionAwarePropertyInternal(
    WritingDirectionMode writing_direction) const {
  return CSSDirectionAwareResolver::Resolve<%= resolver_name %>(writing_direction,
      CSSDirectionAwareResolver::Physical<%= group_name %>Mapping());
}

bool <%= class_name %>::IsInSameLogicalPropertyGroupWithDifferentMappingLogic(
    CSSPropertyID id) const {
  return CSSDirectionAwareResolver::Physical<%= group_name %>Mapping().Contains(id);
}
      <% } else { %>
bool <%= class_name %>::IsInSameLogicalPropertyGroupWithDifferentMappingLogic(
    CSSPropertyID id) const {
  return CSSDirectionAwareResolver::Logical<%= group_name %>Mapping().Contains(id);
}
      <% } %>
    <% } %>

  <% } %> <% /* not isAlias */ %>
<% }); %> <% /* properties */ %>


}  // <%= isShortHand ? 'shorthand' : 'longhand' %>
}  // namespace webf
