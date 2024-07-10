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

 /*
  * Copyright (C) 2022-present The WebF authors. All rights reserved.
  */

<%
// 定义sourceFilesForGeneratedFile函数，third_party/blink/renderer/build/scripts/templates/macros.tmpl
  function sourceFilesForGeneratedFile(templateFile, inputFiles) {
    if (!templateFile) {
      throw new Error("template_file must be defined in template scripts.");
    }
    if (!inputFiles) {
      throw new Error("input_files must be defined in template scripts.");
    }

    let result = `// Generated from template:\n//   ${templateFile}\n// and input files:\n`;
    inputFiles.sort().forEach(input => {
      result += `//   ${input}\n`;
    });

    return result;
  }
%>
<%= sourceFilesForGeneratedFile(templateFile, inputFiles) %>

#ifndef <%= headerGuard %>
#define <%= headerGuard %>

#include "core/css/css_property_names.h"
#include "core/css/properties/css_property.h"
//#include "third_party/blink/renderer/platform/wtf/vector.h"
#include<vector>

namespace webf {

class StylePropertyShorthand {
 public:
  constexpr StylePropertyShorthand()
      : properties_(nullptr),
        length_(0),
        shorthand_id_(CSSPropertyID::kInvalid) {}

  constexpr StylePropertyShorthand(CSSPropertyID id,
                                   const CSSProperty** properties,
                                   unsigned num_properties)
      : properties_(properties),
        length_(num_properties),
        shorthand_id_(id) {}

  const CSSProperty** properties() const { return properties_; }
  unsigned length() const { return length_; }
  CSSPropertyID id() const { return shorthand_id_; }

 private:
  const CSSProperty** properties_;
  unsigned length_;
  CSSPropertyID shorthand_id_;
};

<% properties.forEach(function(property) { %>
const StylePropertyShorthand& <%= property.name.toLowerCamelCase() %>Shorthand();
<% }); %>

const StylePropertyShorthand& transitionShorthandForParsing();

// Returns an empty list if the property is not a shorthand.
CORE_EXPORT const StylePropertyShorthand& shorthandForProperty(CSSPropertyID);

// Return the list of shorthands for a given longhand.
// The client must pass in an empty result vector.
void getMatchingShorthandsForLonghand(
    CSSPropertyID, Vector<StylePropertyShorthand, 4>* result);

unsigned indexOfShorthandForLonghand(CSSPropertyID,
                                     const Vector<StylePropertyShorthand, 4>&);

}  // namespace webf

#endif  // <%= headerGuard %>