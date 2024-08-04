// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef WEBF_CORE_CSS_PARSER_CSS_PARSER_FAST_PATH_H_
#define WEBF_CORE_CSS_PARSER_CSS_PARSER_FAST_PATH_H_

#include "core/css/parser/css_parser_context.h"
#include "core/css/properties/css_bitset.h"
#include "core/platform/graphics/color.h"
#include "css_property_names.h"
#include "css_value_keywords.h"
#include "foundation/macros.h"

namespace webf {

class CSSValue;

enum class ParseColorResult {
  kFailure,

  // The string identified a color keyword.
  kKeyword,

  // The string identified a valid color.
  kColor,
};

class CSSParserFastPaths {
  WEBF_STATIC_ONLY(CSSParserFastPaths);

 public:
  // Parses simple values like '10px' or 'green', but makes no guarantees
  // about handling any property completely.
  static std::shared_ptr<const CSSValue> MaybeParseValue(CSSPropertyID, const std::string&, const CSSParserContext*);

  // NOTE: Properties handled here shouldn't be explicitly handled in
  // CSSPropertyParser, so if this returns true, the fast path is the only path.
  static bool IsHandledByKeywordFastPath(CSSPropertyID property_id) {
    return handled_by_keyword_fast_paths_properties_.Has(property_id);
  }

  static bool IsValidKeywordPropertyAndValue(CSSPropertyID, CSSValueID, CSSParserMode);

  static bool IsValidSystemFont(CSSValueID);

  // Tries parsing a string as a color, returning the result. Sets `color` if
  // the result is `kColor`.
  static ParseColorResult ParseColor(const std::string&, CSSParserMode, Color& color);

 private:
  static CSSBitset handled_by_keyword_fast_paths_properties_;
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_PARSER_CSS_PARSER_FAST_PATH_H_
