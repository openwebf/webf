// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "css_parser.h"
#include "css_parser_impl.h"

namespace webf {

ParseSheetResult CSSParser::ParseSheet(
    const std::shared_ptr<const CSSParserContext>& context,
    const std::shared_ptr<StyleSheetContents>& style_sheet,
    const std::string& text,
    CSSDeferPropertyParsing defer_property_parsing,
    bool allow_import_rules) {
  return CSSParserImpl::ParseStyleSheet(
      text, context, style_sheet, defer_property_parsing, allow_import_rules);
}

}  // namespace webf