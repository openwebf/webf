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

  /*
   * Copyright (C) 2022-present The WebF authors. All rights reserved.
   */

<% /* Assuming source_files_for_generated_file function is imported or defined elsewhere */ %>
<%= source_files_for_generated_file(template_file, input_files) %>

#include "third_party/blink/renderer/core/style_property_shorthand.h"

#include <iterator>

#include "third_party/blink/renderer/core/css/properties/longhands.h"
#include "third_party/blink/renderer/platform/runtime_enabled_features.h"

<% /* Macro for defining shorthand properties */ %>
<% function defineShorthand(property, expansion) { %>
  static const CSSProperty* longhands[] = {
    <% expansion.enabledLonghands.forEach(function(longhand) { %>
    &Get<%= longhand.propertyId %>(),
    <% }); %>
  };

  static const StylePropertyShorthand shorthand(
      CSSPropertyID::<%= property.enumKey %>, longhands, std::size(longhands));
<% } %>
//
namespace blink {

<% properties.forEach(function(property) { %>
  <% var functionPrefix = property.name.toLowerCamelCase(); %>
  <% property.expansions.slice(1).forEach(function(expansion) { %>

static const StylePropertyShorthand* <%= functionPrefix %>Shorthand<%= expansion.index %>() {
    <% expansion.flags.forEach(function(flag) { %>
  if (<%= flag.enabled ? '!' : '' %>RuntimeEnabledFeatures::<%= flag.name %>Enabled())
    return nullptr;
    <% }); %>

  <% defineShorthand(property, expansion); %>
  return &shorthand;
}
  <% }); %>

const StylePropertyShorthand& <%= functionPrefix %>Shorthand() {
  <% if (property.expansions.length > 1) { %>
    <% property.expansions.slice(1).forEach(function(expansion) { %>
  if (const auto* s = <%= functionPrefix %>Shorthand<%= expansion.index %>())
    return *s;
    <% }); %>
  <% } %>
  <% if (property.expansions[0].flags) { %>
    <% property.expansions[0].flags.forEach(function(flag) { %>
  DCHECK(<%= flag.enabled ? '' : '!' %>RuntimeEnabledFeatures::<%= flag.name %>Enabled());
    <% }); %>
  <% } %>
  <% if (property.expansions[0].isEmpty) { %>
  static StylePropertyShorthand empty_shorthand;
  return empty_shorthand;
  <% } else { %>
  <% defineShorthand(property, property.expansions[0]); %>
  return shorthand;
  <% } %>
}
<% }); %>

// Returns an empty list if the property is not a shorthand
const StylePropertyShorthand& shorthandForProperty(CSSPropertyID propertyID) {
  static StylePropertyShorthand empty_shorthand;

  switch (propertyID) {
    <% properties.forEach(function(property) { %>
      <% var functionPrefix = property.name.toLowerCamelCase(); %>
    case CSSPropertyID::<%= property.enumKey %>:
      return <%= functionPrefix %>Shorthand();
    <% }); %>
    default: {
      return empty_shorthand;
    }
  }
}

void getMatchingShorthandsForLonghand(
    CSSPropertyID propertyID, Vector<StylePropertyShorthand, 4>* result) {
  DCHECK(!result->size());
  switch (propertyID) {
    <% for (var longhandEnumKey in longhandsDictionary) { %>
    case CSSPropertyID::<%= longhandEnumKey %>: {
      <% longhandsDictionary[longhandEnumKey].forEach(function(shorthand) { %>
        <% if (!shorthand.knownExposed) { %>
      if (CSSProperty::Get(CSSPropertyID::<%= shorthand.enumKey %>).IsWebExposed())
        result->UncheckedAppend(<%= shorthand.name.toLowerCamelCase() %>Shorthand());
        <% } else { %>
      DCHECK(CSSProperty::Get(CSSPropertyID::<%= shorthand.enumKey %>).IsWebExposed());
      result->UncheckedAppend(<%= shorthand.name.toLowerCamelCase() %>Shorthand());
        <% } %>
      <% }); %>
      break;
    }
    <% } %>
    default:
      break;
  }
}

} // namespace blink