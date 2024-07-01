// Copyright 2015 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "css_variable_parser.h"

namespace webf {



bool CSSVariableParser::IsValidVariableName(const CSSParserToken& token) {
  if (token.GetType() != kIdentToken) {
    return false;
  }

  return IsValidVariableName(token.Value());
}

bool CSSVariableParser::IsValidVariableName(StringView string) {
  return string.length() >= 3 && string[0] == '-' && string[1] == '-';
}

}  // namespace webf
