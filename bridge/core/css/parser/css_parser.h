// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CSS_PARSER_H
#define WEBF_CSS_PARSER_H

#include "foundation/macros.h"
#include "bindings/qjs/atomic_string.h"
#include "css_parser_mode.h"

namespace webf {

class CSSParserContext;
class StyleSheetContents;
enum class ParseSheetResult;

// This class serves as the public API for the css/parser subsystem
class CSSParser {
  WEBF_STATIC_ONLY(CSSParser);

 public:
  static ParseSheetResult ParseSheet(std::shared_ptr<const CSSParserContext>,
                                     std::shared_ptr<StyleSheetContents>,
                                     const AtomicString&,
                                     CSSDeferPropertyParsing defer_property_parsing = CSSDeferPropertyParsing::kNo,
                                     bool allow_import_rules = true);
};


}  // namespace webf

#endif  // WEBF_CSS_PARSER_H
