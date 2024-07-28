// Copyright 2017 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifndef WEBF_CORE_CSS_PROPERTIES_CSS_PARSING_UTILS_H_
#define WEBF_CORE_CSS_PROPERTIES_CSS_PARSING_UTILS_H_

#include <optional>

#include "bindings/qjs/cppgc/member.h"
#include "core/css/css_anchor_query_enums.h"
#include "core/css/css_custom_ident_value.h"
#include "core/css/css_identifier_value.h"
#include "core/css/css_numeric_literal_value.h"
#include "core/css/css_primitive_value.h"
#include "core/css/css_repeat_style_value.h"
#include "core/css/css_value_list.h"
#include "core/css/parser/css_parser_token.h"
#include "core/css/parser/css_parser_token_range.h"
#include "core/css/parser/css_parser_token_stream.h"
#include "core/css/parser/css_property_parser.h"
#include "core/style/grid_area.h"
#include "css_property_names.h"
#include "css_value_keywords.h"

namespace webf {

class CSSIdentifierValue;
class CSSParserContext;
class CSSParserTokenStream;
class CSSPropertyValue;
class CSSValue;
class CSSValueList;
class CSSValuePair;
class StylePropertyShorthand;

// "Consume" functions, when successful, should consume all the relevant tokens
// as well as any trailing whitespace. When the start of the range doesn't
// match the type we're looking for, the range should not be modified.
namespace css_parsing_utils {

enum class AllowInsetAndSpread { kAllow, kForbid };
enum class AllowTextValue { kAllow, kForbid };
enum class AllowPathValue { kAllow, kForbid };
enum class AllowBasicShapeRectValue { kAllow, kForbid };
enum class AllowBasicShapeXYWHValue { kAllow, kForbid };
enum class DefaultFill { kFill, kNoFill };
enum class ParsingStyle { kLegacy, kNotLegacy };
enum class TrackListType { kGridAuto, kGridTemplate, kGridTemplateNoRepeat, kGridTemplateSubgrid };
enum class UnitlessQuirk { kAllow, kForbid };
enum class AllowCalcSize { kAllowWithAuto, kAllowWithoutAuto, kForbid };
enum class AllowedColors { kAll, kAbsolute };
enum class EmptyPathStringHandling { kFailure, kTreatAsNone };

using ConsumeAnimationItemValue = CSSValue* (*)(CSSPropertyID,
                                                CSSParserTokenStream&,
                                                const CSSParserContext&,
                                                bool use_legacy_parsing);
using IsResetOnlyFunction = bool (*)(CSSPropertyID);
using IsPositionKeyword = bool (*)(CSSValueID);

constexpr size_t kMaxNumAnimationLonghands = 12;

void Complete4Sides(CSSValue* side[4]);

// TODO(timloh): These should probably just be consumeComma and consumeSlash.
bool ConsumeCommaIncludingWhitespace(CSSParserTokenRange&);
bool ConsumeCommaIncludingWhitespace(CSSParserTokenStream&);
bool ConsumeSlashIncludingWhitespace(CSSParserTokenRange&);
bool ConsumeSlashIncludingWhitespace(CSSParserTokenStream&);
// consumeFunction expects the range starts with a FunctionToken.
CSSParserTokenRange ConsumeFunction(CSSParserTokenRange&);
CSSParserTokenRange ConsumeFunction(CSSParserTokenStream&);

// https://drafts.csswg.org/css-syntax/#typedef-any-value
//
// Consumes component values until it reaches a token that is not allowed
// for <any-value>.
bool ConsumeAnyValue(CSSParserTokenRange&);

CSSPrimitiveValue* ConsumeInteger(CSSParserTokenRange&,
                                  const CSSParserContext&,
                                  double minimum_value = -std::numeric_limits<double>::max(),
                                  const bool is_percentage_allowed = true);
CSSPrimitiveValue* ConsumeInteger(CSSParserTokenStream&,
                                  const CSSParserContext&,
                                  double minimum_value = -std::numeric_limits<double>::max(),
                                  const bool is_percentage_allowed = true);
template <typename T>
    requires std::is_same_v<T, CSSParserTokenStream> ||
    std::is_same_v<T, CSSParserTokenRange> CSSPrimitiveValue* ConsumeIntegerOrNumberCalc(
        T&,
        const CSSParserContext&,
        CSSPrimitiveValue::ValueRange = CSSPrimitiveValue::ValueRange::kInteger);
CSSPrimitiveValue* ConsumePositiveInteger(CSSParserTokenStream&, const CSSParserContext&);
CSSPrimitiveValue* ConsumePositiveInteger(CSSParserTokenRange&, const CSSParserContext&);
bool ConsumeNumberRaw(CSSParserTokenStream&, const CSSParserContext& context, double& result);
bool ConsumeNumberRaw(CSSParserTokenRange&, const CSSParserContext& context, double& result);
CSSPrimitiveValue* ConsumeNumber(CSSParserTokenRange&, const CSSParserContext&, CSSPrimitiveValue::ValueRange);
CSSPrimitiveValue* ConsumeNumber(CSSParserTokenStream&, const CSSParserContext&, CSSPrimitiveValue::ValueRange);
CSSPrimitiveValue* ConsumeLength(CSSParserTokenRange&,
                                 const CSSParserContext&,
                                 CSSPrimitiveValue::ValueRange,
                                 UnitlessQuirk = UnitlessQuirk::kForbid);
CSSPrimitiveValue* ConsumeLength(CSSParserTokenStream&,
                                 const CSSParserContext&,
                                 CSSPrimitiveValue::ValueRange,
                                 UnitlessQuirk = UnitlessQuirk::kForbid);
CSSPrimitiveValue* ConsumePercent(CSSParserTokenRange&, const CSSParserContext&, CSSPrimitiveValue::ValueRange);
CSSPrimitiveValue* ConsumePercent(CSSParserTokenStream&, const CSSParserContext&, CSSPrimitiveValue::ValueRange);

}  // namespace css_parsing_utils
}  // namespace webf

#endif  // WEBF_CORE_CSS_PROPERTIES_CSS_PARSING_UTILS_H_
