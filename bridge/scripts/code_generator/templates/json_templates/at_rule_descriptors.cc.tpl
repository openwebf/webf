%{
// Copyright 2017 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "at_rule_descriptors.h"
#include "core/css/hash_tools.h"
#include "foundation/ascii_types.h"

#ifdef _MSC_VER
// Disable the warnings from casting a 64-bit pointer to 32-bit long
// warning C4302: 'type cast': truncation from 'char (*)[28]' to 'long'
// warning C4311: 'type cast': pointer truncation from 'char (*)[18]' to 'long'
#pragma warning(disable : 4302 4311)
#endif

namespace webf {

namespace {

%}

%struct-type
struct Property;
%omit-struct-type
%language=C++
%readonly-tables
%compare-strncmp
%define class-name AtRuleDescriptorHash
%define lookup-function-name findDescriptorImpl
%define hash-function-name descriptor_hash_function
%define slot-name name_offset
%define word-array-name descriptor_word_list
%pic
%enum
%%

<% _.each(descriptors, descriptor => { %>
<%= descriptor.name %>, static_cast<int>(AtRuleDescriptorID::<%= upperCamelCase(descriptor.name) %>)
<% if (descriptor.alias) { %>
<%= descriptor.alias %>, static_cast<int>(AtRuleDescriptorID::<%= upperCamelCase(descriptor.name) %>)
<% } %>
<% }) %>


%%

const Property* FindDescriptor(const char* str, unsigned int len) {
  return AtRuleDescriptorHash::findDescriptorImpl(str, len);
}

template <typename CharacterType>
static AtRuleDescriptorID AsAtRuleDescriptorID(
    const CharacterType* descriptor_name,
    unsigned length) {
  if (length == 0)
    return AtRuleDescriptorID::Invalid;
  if (length > <%= longest_name_length %>)
    return AtRuleDescriptorID::Invalid;

  char buffer[<%= longest_name_length %> + 1];  // 1 for null character

  for (unsigned i = 0; i != length; ++i) {
    CharacterType c = descriptor_name[i];
    if (c == 0 || c >= 0x7F)
      return AtRuleDescriptorID::Invalid;  // illegal character
    buffer[i] = ToASCIILower(c);
  }
  buffer[length] = '\0';

  const char* name = buffer;
  const Property* hash_table_entry = FindDescriptor(name, length);
  if (!hash_table_entry)
    return AtRuleDescriptorID::Invalid;
  return static_cast<AtRuleDescriptorID>(hash_table_entry->id);
}

}  // namespace

AtRuleDescriptorID AsAtRuleDescriptorID(std::string_view string) {
  unsigned length = string.length();
  return AsAtRuleDescriptorID(string.data(), length);
}

CSSPropertyID AtRuleDescriptorIDAsCSSPropertyID(AtRuleDescriptorID id) {
  switch (id) {
<% _.each(descriptors, descriptor => { %>
  case AtRuleDescriptorID::<%= upperCamelCase(descriptor.name) %>:
    return CSSPropertyID::k<%= upperCamelCase(descriptor.name) %>;
<% }); %>
  default:
    NOTREACHED_IN_MIGRATION();
    return CSSPropertyID::kInvalid;
  }
}

AtRuleDescriptorID CSSPropertyIDAsAtRuleDescriptor(CSSPropertyID id) {
  switch (id) {
<% _.each(descriptors, descriptor => { %>
  case CSSPropertyID::k<%= upperCamelCase(descriptor.name) %>:
      return AtRuleDescriptorID::<%= upperCamelCase(descriptor.name) %>;
<% }); %>
  default:
    return AtRuleDescriptorID::Invalid;
  }
}

}  // namespace blink