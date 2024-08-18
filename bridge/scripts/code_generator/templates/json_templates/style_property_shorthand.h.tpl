/*
 * (C) 1999-2003 Lars Knoll (knoll@kde.org)
 * Copyright (C) 2004, 2005, 2006, 2008 Apple Inc. All rights reserved.
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

#ifndef WEBF_CORE_CSS_CSS_PROPERTY_SHORTHAND_H_
#define WEBF_CORE_CSS_CSS_PROPERTY_SHORTHAND_H_

#include <span>
#include <vector>
#include "css_property_names.h"
#include "core/css/properties/css_property.h"

namespace webf {

class StylePropertyShorthand {
 public:
  using Properties = std::span<const CSSProperty* const>;
  constexpr StylePropertyShorthand()
      : shorthand_id_(CSSPropertyID::kInvalid) {}

  constexpr StylePropertyShorthand(CSSPropertyID id,
                                   Properties properties,
                                   unsigned num_properties)
      : properties_(properties),
        shorthand_id_(id) {}

  Properties properties() const { return properties_; }
  CSSPropertyID id() const { return shorthand_id_; }
  size_t length() const { return properties_.size(); }

 private:
  Properties properties_;
  CSSPropertyID shorthand_id_;
};

<% _.each(properties, (property, index) => { %>
const StylePropertyShorthand& <%= lowerCamelCase(property.name) %>Shorthand();
<% }); %>

const StylePropertyShorthand& transitionShorthandForParsing();

// Returns an empty list if the property is not a shorthand.
const StylePropertyShorthand& shorthandForProperty(CSSPropertyID);

// Return the list of shorthands for a given longhand.
// The client must pass in an empty result vector.
void getMatchingShorthandsForLonghand(
    CSSPropertyID, std::vector<StylePropertyShorthand>* result);

unsigned indexOfShorthandForLonghand(CSSPropertyID,
                                     const std::vector<StylePropertyShorthand>&);

}  // namespace blink

#endif  // WEBF_CORE_CSS_CSS_PROPERTY_SHORTHAND_H_
