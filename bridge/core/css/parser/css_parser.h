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
#include "core/css/css_property_value_set.h"
#include "css_parser_mode.h"

namespace webf {

class CSSParserContext;
class StyleSheetContents;
enum class ParseSheetResult;

// This class serves as the public API for the css/parser subsystem
class CSSParser {
  WEBF_STATIC_ONLY(CSSParser);

 public:

  static MutableCSSPropertyValueSet::SetResult ParseValue(
      MutableCSSPropertyValueSet*,
      CSSPropertyID unresolved_property,
      const std::string& value,
      bool important,
      const ExecutingContext* execution_context = nullptr);
  static MutableCSSPropertyValueSet::SetResult ParseValue(
      MutableCSSPropertyValueSet*,
      CSSPropertyID unresolved_property,
      const std::string& value,
      bool important,
      StyleSheetContents*,
      const ExecutingContext* execution_context = nullptr);

  static MutableCSSPropertyValueSet::SetResult ParseValueForCustomProperty(
      MutableCSSPropertyValueSet*,
      const std::string& property_name,
      const std::string& value,
      bool important,
      StyleSheetContents*,
      bool is_animation_tainted);


  static ParseSheetResult ParseSheet(const std::shared_ptr<const CSSParserContext>&,
                                     const std::shared_ptr<StyleSheetContents>&,
                                     const std::string&,
                                     CSSDeferPropertyParsing defer_property_parsing = CSSDeferPropertyParsing::kNo,
                                     bool allow_import_rules = true);
};


}  // namespace webf

#endif  // WEBF_CSS_PARSER_H
