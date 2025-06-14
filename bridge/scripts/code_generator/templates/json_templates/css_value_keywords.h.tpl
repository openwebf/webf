// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef BRIDGE_CSS_VALUE_KEYWORDS_H_
#define BRIDGE_CSS_VALUE_KEYWORDS_H_

#include <string.h>
#include <stdint.h>

#include "core/css/parser/css_parser_mode.h"

namespace webf {

<% let maxLength = 0; %>

enum class CSSValueID {
  kInvalid = 0,
  <% _.each(data, (key, index) => { %>
    <% maxLength = Math.max(maxLength, key.length); %>
    <%= enumKeyForCSSKeywords(key) %> = <%= index + 1 %>,
  <% }); %>
};

const int numCSSValueKeywords = <%= data.length + 1 %>;
const size_t maxCSSValueKeywordLength = <%= maxLength %>;

inline bool IsValidCSSValueID(CSSValueID id)
{
    return id != CSSValueID::kInvalid;
}

const char* getValueName(CSSValueID);
bool isValueAllowedInMode(CSSValueID id, CSSParserMode mode);

}  // namespace blink

#endif  // BRIDGE_CSS_VALUE_KEYWORDS_H_
