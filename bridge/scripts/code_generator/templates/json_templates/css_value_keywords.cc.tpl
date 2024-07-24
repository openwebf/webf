%{
// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "css_value_keywords.h"
#include <string.h>
#include <assert.h>
#include "core/css/hash_tools.h"

#ifdef _MSC_VER
// Disable the warnings from casting a 64-bit pointer to 32-bit long
// warning C4302: 'type cast': truncation from 'char (*)[28]' to 'long'
// warning C4311: 'type cast': pointer truncation from 'char (*)[18]' to 'long'
#pragma warning(disable : 4302 4311)
#endif

namespace webf {

static const char valueListStringPool[] = {
    <% _.each(data, (key, index) => { %>
       "<%= key %>\0"
    <% }); %>
};

<% let current_offset = 0; %>
<% let keyword_offsets = []; %>
<% _.each(data, (key, index) => { %>
    <% keyword_offsets.push(current_offset) %>
    <% current_offset += key.length + 1 %>
<% }); %>

static const uint16_t valueListStringOffsets[] = {
<% _.each(keyword_offsets, (offset, index) => { %>
    <%= offset %>,
<% }); %>
};

%}
%struct-type
struct Value;
%omit-struct-type
%language=C++
%readonly-tables
%compare-strncmp
%define class-name CSSValueKeywordsHash
%define lookup-function-name findValueImpl
%define hash-function-name value_hash_function
%define slot-name name_offset
%define word-array-name value_word_list
%pic
%enum
%%
<% _.each(data, (key, index) => { %>
<%= key.toLowerCase() %>, static_cast<int>(CSSValueID::<%= enumKeyForCSSKeywords(key) %>)
<% }); %>
%%

const Value* FindValue(const char* str, unsigned int len) {
  return CSSValueKeywordsHash::findValueImpl(str, len);
}

const char* getValueName(CSSValueID id) {
  assert(id > CSSValueID::kInvalid);
  assert(static_cast<int>(id) < numCSSValueKeywords);
  return valueListStringPool + valueListStringOffsets[static_cast<int>(id) - 1];
}

bool isValueAllowedInMode(CSSValueID id, CSSParserMode mode) {
  return true;
}

} // namespace blink