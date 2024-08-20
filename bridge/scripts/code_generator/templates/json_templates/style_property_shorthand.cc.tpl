/*
 * (C) 1999-2003 Lars Knoll (knoll@kde.org)
 * Copyright (C) 2004, 2005, 2006, 2007, 2008 Apple Inc. All rights reserved.
 * Copyright (C) 2013 Intel Corporation. All rights reserved.
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


#include <iterator>
#include "css_property_instance.h"
#include "style_property_shorthand.h"
#include "longhands.h"

<% function define_shorthand(property, expansion) { %>
  static const CSSProperty* longhands[] = {
    <% expansion.enabled_longhands.forEach(longhand => { %>
    &Get<%= longhand.property_id %>(),
    <% }); %>
  };

  static const StylePropertyShorthand shorthand(
      CSSPropertyID::<%= property.enum_key %>, longhands);
<% } %>


namespace webf {

<% _.each(properties, (property, index) => { %>
  <% const function_prefix = lowerCamelCase(property.name) %>
  <% _.each(property.expansions.slice(1), (expansion, index) => { %>

static const StylePropertyShorthand* <%= function_prefix %>Shorthand<%= expansion.index %>() {
  <% define_shorthand(property, expansion) %>
  return &shorthand;
}

  <% }) %>

const StylePropertyShorthand& <%= function_prefix %>Shorthand() {
  <% if (property.expansions.length > 1) { %>
    <% _.each(property.expansions.slice(1), (expansion) => { %>
  if (const auto* s = <%= function_prefix %>Shorthand<%= expansion.index %>())
   return *s;
    <% }); %>
  <% } %>
  <% if (property.expansions[0].is_empty) { %>
  static StylePropertyShorthand empty_shorthand;
  return empty_shorthand;
  <% } else { %>
  <% define_shorthand(property, property.expansions[0]) %>
  return shorthand;
  <% } %>
}

<% }); %>

// Returns an empty list if the property is not a shorthand
const StylePropertyShorthand& shorthandForProperty(CSSPropertyID propertyID) {
  // FIXME: We shouldn't switch between shorthand/not shorthand based on a runtime flag
  static StylePropertyShorthand empty_shorthand;

  switch (propertyID) {
    <% _.each(properties, (property) => { %>
      <% const function_prefix = lowerCamelCase(property.name) %>
    case CSSPropertyID::<%= property.enum_key %>:
      return <%= function_prefix %>Shorthand();
    <% }); %>
    default: {
      return empty_shorthand;
    }
  }
}

void getMatchingShorthandsForLonghand(
    CSSPropertyID propertyID, std::vector<StylePropertyShorthand>* result) {
  assert(!result->size());
  switch (propertyID) {
  <% for (const [longhand_enum_key, shorthands] of longhands_dictionary) { %>

    case CSSPropertyID::<%= longhand_enum_key %>: {
      <% _.each(shorthands, shorthand => { %>
        <% if (!shorthand.known_exposed) { %>
      if (CSSProperty::Get(CSSPropertyID::<%= shorthand.enum_key %>).IsWebExposed())
        result->emplace_back(<%= lowerCamelCase(shorthand.name) %>Shorthand());
        <% } else { %>
        assert(CSSProperty::Get(CSSPropertyID::<%= shorthand.enum_key %>).IsWebExposed());
        result->emplace_back(<%= lowerCamelCase(shorthand.name) %>Shorthand());
        <% } %>
      <% }); %>
      break;
    }
  <% } %>
    default:
      break;
  }
}

} // namespace webf
