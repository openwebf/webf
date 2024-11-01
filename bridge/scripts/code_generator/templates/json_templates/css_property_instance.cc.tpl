// Copyright 2019 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// clang-format off

#include "css_property_instance.h"

#include "longhands.h"
#include "shorthands.h"
#include "core/css/properties/longhands/variable.h"

namespace webf {

<% const all_properties = properties.concat(alias) %>


// NOTE: Everything in here must be reinterpret_cast-able
// to CSSUnresolvedProperty! In particular, this means that
// multiple inheritance is forbidden. We enforce this through
// DCHECKs as much as we can; this also checks (compile-time)
// that everything inherits from CSSUnresolvedProperty.
union alignas(kCSSPropertyUnionBytes) CSSPropertyUnion {
  constexpr CSSPropertyUnion() {}  // For kInvalid.
  constexpr CSSPropertyUnion(Variable property)
    : variable_(std::move(property)) {
    assert(reinterpret_cast<const CSSUnresolvedProperty *>(this) ==
        static_cast<const CSSUnresolvedProperty *>(&variable_));
  }

  <% _.each(all_properties, (property, index) => { %>
  constexpr CSSPropertyUnion(::webf::<%= property.namespace %>::<%= property.classname %> property)
      : <%= property.property_id.toLowerCase() %>_(std::move(property)) {
      assert(reinterpret_cast<const CSSUnresolvedProperty *>(this) ==
          static_cast<const CSSUnresolvedProperty *>(&<%= property.property_id.toLowerCase() %>_));
    }
  <% }); %>


  Variable variable_;

  <% _.each(all_properties, (property, index) => { %>
  ::webf::<%= property.namespace %>::<%= property.classname %> <%= property.property_id.toLowerCase() %>_;
  <% }); %>
};
static_assert(sizeof(CSSPropertyUnion) == kCSSPropertyUnionBytes);

const CSSPropertyUnion kCssProperties[] = {
  {},  // kInvalid.
  Variable(),

  <% _.each(all_properties, (property, index) => { %>
  ::webf::<%= property.namespace %>::<%= property.classname %>(),
  <% }); %>
};

// Mapping from a property's ID to that of its visited counterpart,
// or kInvalid if it has none.
const uint8_t kPropertyVisitedIDs[] = {
  static_cast<uint8_t>(CSSPropertyID::kInvalid),
  static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kVariable.
  <% _.each(all_properties, (property, index) => { %>
    <% if (property.visited_property) { %>
    static_cast<uint8_t>(CSSPropertyID::<%= property.visited_property.enum_key %>),  // <%= property.enum_key %>.
    <% } else { %>
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // <%= property.enum_key %>.
    <% } %>
  <% }); %>
};

// Verify that all properties (used in the array) fit into a uint8_t.
// If this stops holding, we'll either need to switch types of
// kPropertyVisitedIDs, or reorganize the ordering of the enum
// so that the kInternalVisited* ones are earlier.
static_assert(static_cast<size_t>(CSSPropertyID::kInvalid) < 256);

<% _.each(all_properties, (property, index) => { %>
  <% if(property.visited_property) { %>
    static_assert(static_cast<size_t>(CSSPropertyID::<%= property.visited_property.enum_key %>) < 256);
  <% } %>
<% }); %>

// Similar, for unvisited IDs. Note that this array is much less
// hot than kPropertyVisitedIDs, so it's definitely fine that it's uint16_t.
const uint16_t kPropertyUnvisitedIDs[] = {
  static_cast<uint16_t>(CSSPropertyID::kInvalid),
  static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kVariable.

  <% _.each(all_properties, (property, index) => { %>
    <% if (property.unvisited_property) { %>
      static_cast<uint16_t>(CSSPropertyID::<%= property.unvisited_property.enum_key %>),  // <%= property.enum_key %>.
    <% } else { %>
      static_cast<uint16_t>(CSSPropertyID::kInvalid),  // <%= property.enum_key %>.
    <% } %>
  <% }); %>
};

// Same check as for kPropertyVisitedIDs.
static_assert(static_cast<size_t>(CSSPropertyID::kInvalid) < 65536);
<% _.each(properties, (property, index) => { %>
  <% if (property.unvisited_property) { %>
  static_assert(static_cast<size_t>(CSSPropertyID::<%= property.unvisited_property.enum_key %>) < 65536);
  <% } %>
<% }); %>

}  // namespace blink
