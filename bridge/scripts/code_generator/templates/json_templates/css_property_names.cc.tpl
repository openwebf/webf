%{
// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "css_property_names.h"

#include <string.h>
#include "core/css/parser/css_property_parser.h"
#include "core/css/hash_tools.h"

#ifdef _MSC_VER
// Disable the warnings from casting a 64-bit pointer to 32-bit long
// warning C4302: 'type cast': truncation from 'char (*)[28]' to 'long'
// warning C4311: 'type cast': pointer truncation from 'char (*)[18]' to 'long'
#pragma warning(disable : 4302 4311)
#endif

namespace webf {
%}
%struct-type
struct Property;
%omit-struct-type
%language=C++
%readonly-tables
%compare-strncmp
%define class-name CSSPropertyNamesHash
%define lookup-function-name findPropertyImpl
%define hash-function-name property_hash_function
%define slot-name name_offset
%define word-array-name property_word_list
%enum
%%
<% _.each(properties.gperf_properties, (property, index) => { %>
<%= property.name %>, static_cast<int>(CSSPropertyID::<%= property.enum_key %>)
<% }); %>
%%

const Property* FindProperty(const char* str, unsigned int len) {
  return CSSPropertyNamesHash::findPropertyImpl(str, len);
}

CSSPropertyID CssPropertyID(const ExecutingContext* execution_context,
                            const std::string& string)
{
    return ResolveCSSPropertyID(UnresolvedCSSPropertyID(execution_context,
                                                        string));
}

int ResolveCSSPropertyAlias(int value) {
  static constexpr uint16_t kLookupTable[] = {
  <% _.each(properties.aliases, (property, index) => { %>
    <%= property.aliased_enum_value %>,
  <% }); %>
  };
  return kLookupTable[value - <%= properties.alias_offset %>];
}

}  // namespace webf
