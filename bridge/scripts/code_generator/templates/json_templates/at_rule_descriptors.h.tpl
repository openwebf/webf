// Copyright 2017 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef THIRD_PARTY_BLINK_RENDERER_CORE_CSS_PARSER_AT_RULE_DESCRIPTORS_H_
#define THIRD_PARTY_BLINK_RENDERER_CORE_CSS_PARSER_AT_RULE_DESCRIPTORS_H_

#include "css_property_names.h"
#include <string_view>
#include <string.h>

namespace webf {

enum class AtRuleDescriptorID {
  Invalid = 0,
  <% _.each(descriptors, descriptor => { %>
  <%= upperCamelCase(descriptor.name) %> = <%= descriptor.enum_value %>,
  <% }) %>
};

const int numAtRuleDescriptors = <%= descriptors_count %>;

const char* getValueName(AtRuleDescriptorID);

AtRuleDescriptorID AsAtRuleDescriptorID(std::string_view string);

CSSPropertyID AtRuleDescriptorIDAsCSSPropertyID(AtRuleDescriptorID);
AtRuleDescriptorID CSSPropertyIDAsAtRuleDescriptor(CSSPropertyID id);

}  // namespace webf

#endif  // THIRD_PARTY_BLINK_RENDERER_CORE_CSS_PARSER_AT_RULE_DESCRIPTORS_H_