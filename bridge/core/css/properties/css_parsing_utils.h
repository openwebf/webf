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
#include "core/css/css_string_value.h"
#include "core/css/css_value_list.h"
#include "core/css/parser/css_parser_local_context.h"
#include "core/css/parser/css_parser_token.h"
#include "core/css/parser/css_parser_token_range.h"
#include "core/css/parser/css_parser_token_stream.h"
#include "core/css/parser/css_property_parser.h"
// #include "core/style/grid_area.h"
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
enum class AllowCalcSize { kAllowWithAuto, kAllowWithoutAuto, kAllowWithAutoAndContent, kForbid };
enum class AllowedColors { kAll, kAbsolute };
enum class EmptyPathStringHandling { kFailure, kTreatAsNone };

using ConsumeAnimationItemValue = std::shared_ptr<const CSSValue> (*)(CSSPropertyID,
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

std::shared_ptr<const CSSPrimitiveValue> ConsumeInteger(CSSParserTokenRange&,
                                                        const CSSParserContext&,
                                                        double minimum_value = -std::numeric_limits<double>::max(),
                                                        const bool is_percentage_allowed = true);
std::shared_ptr<const CSSPrimitiveValue> ConsumeInteger(CSSParserTokenStream&,
                                                        const CSSParserContext&,
                                                        double minimum_value = -std::numeric_limits<double>::max(),
                                                        const bool is_percentage_allowed = true);
template <typename T>
    requires std::is_same_v<T, CSSParserTokenStream> ||
    std::is_same_v<T, CSSParserTokenRange> std::shared_ptr<const CSSPrimitiveValue> ConsumeIntegerOrNumberCalc(
        T&,
        const CSSParserContext&,
        CSSPrimitiveValue::ValueRange = CSSPrimitiveValue::ValueRange::kInteger);
std::shared_ptr<const CSSPrimitiveValue> ConsumePositiveInteger(CSSParserTokenStream&, const CSSParserContext&);
std::shared_ptr<const CSSPrimitiveValue> ConsumePositiveInteger(CSSParserTokenRange&, const CSSParserContext&);
bool ConsumeNumberRaw(CSSParserTokenStream&, const CSSParserContext& context, double& result);
bool ConsumeNumberRaw(CSSParserTokenRange&, const CSSParserContext& context, double& result);
std::shared_ptr<const CSSPrimitiveValue> ConsumeNumber(CSSParserTokenRange&,
                                                       const CSSParserContext&,
                                                       CSSPrimitiveValue::ValueRange);
std::shared_ptr<const CSSPrimitiveValue> ConsumeNumber(CSSParserTokenStream&,
                                                       const CSSParserContext&,
                                                       CSSPrimitiveValue::ValueRange);
std::shared_ptr<const CSSPrimitiveValue> ConsumeLength(CSSParserTokenRange&,
                                                       const CSSParserContext&,
                                                       CSSPrimitiveValue::ValueRange,
                                                       UnitlessQuirk = UnitlessQuirk::kForbid);
std::shared_ptr<const CSSPrimitiveValue> ConsumeLength(CSSParserTokenStream&,
                                                       const CSSParserContext&,
                                                       CSSPrimitiveValue::ValueRange,
                                                       UnitlessQuirk = UnitlessQuirk::kForbid);
std::shared_ptr<const CSSPrimitiveValue> ConsumePercent(CSSParserTokenRange&,
                                                        const CSSParserContext&,
                                                        CSSPrimitiveValue::ValueRange);
std::shared_ptr<const CSSPrimitiveValue> ConsumePercent(CSSParserTokenStream&,
                                                        const CSSParserContext&,
                                                        CSSPrimitiveValue::ValueRange);

// Any percentages are converted to numbers.
std::shared_ptr<const CSSPrimitiveValue> ConsumeNumberOrPercent(CSSParserTokenRange&,
                                                                const CSSParserContext&,
                                                                CSSPrimitiveValue::ValueRange);
std::shared_ptr<const CSSPrimitiveValue> ConsumeNumberOrPercent(CSSParserTokenStream& stream,
                                                                const CSSParserContext& context,
                                                                CSSPrimitiveValue::ValueRange value_range);

std::shared_ptr<const CSSPrimitiveValue> ConsumeAlphaValue(CSSParserTokenStream&, const CSSParserContext&);
std::shared_ptr<const CSSPrimitiveValue> ConsumeLengthOrPercent(CSSParserTokenRange&,
                                                                const CSSParserContext&,
                                                                CSSPrimitiveValue::ValueRange,
                                                                UnitlessQuirk = UnitlessQuirk::kForbid,
                                                                CSSAnchorQueryTypes = kCSSAnchorQueryTypesNone,
                                                                AllowCalcSize = AllowCalcSize::kForbid);
std::shared_ptr<const CSSPrimitiveValue> ConsumeLengthOrPercent(CSSParserTokenStream&,
                                                                const CSSParserContext&,
                                                                CSSPrimitiveValue::ValueRange,
                                                                UnitlessQuirk = UnitlessQuirk::kForbid,
                                                                CSSAnchorQueryTypes = kCSSAnchorQueryTypesNone,
                                                                AllowCalcSize = AllowCalcSize::kForbid);
std::shared_ptr<const CSSPrimitiveValue> ConsumeSVGGeometryPropertyLength(CSSParserTokenStream&,
                                                                          const CSSParserContext&,
                                                                          CSSPrimitiveValue::ValueRange);

std::shared_ptr<const CSSPrimitiveValue> ConsumeAngle(CSSParserTokenRange&, const CSSParserContext&);
std::shared_ptr<const CSSPrimitiveValue> ConsumeAngle(CSSParserTokenRange&,
                                                      const CSSParserContext&,
                                                      double minimum_value,
                                                      double maximum_value);
std::shared_ptr<const CSSPrimitiveValue> ConsumeAngle(CSSParserTokenStream&, const CSSParserContext&);
std::shared_ptr<const CSSPrimitiveValue> ConsumeAngle(CSSParserTokenStream&,
                                                      const CSSParserContext&,
                                                      double minimum_value,
                                                      double maximum_value);

template <typename T>
    requires std::is_same_v<T, CSSParserTokenStream> ||
    std::is_same_v<T, CSSParserTokenRange> std::shared_ptr<const CSSPrimitiveValue>
    ConsumeTime(T&, const CSSParserContext&, CSSPrimitiveValue::ValueRange);

template <typename T>
    requires std::is_same_v<T, CSSParserTokenStream> ||
    std::is_same_v<T, CSSParserTokenRange> std::shared_ptr<const CSSPrimitiveValue> ConsumeResolution(
        T&,
        const CSSParserContext&);

std::shared_ptr<const CSSValue> ConsumeRatio(CSSParserTokenStream&, const CSSParserContext&);
std::shared_ptr<const CSSIdentifierValue> ConsumeIdent(CSSParserTokenRange&);
std::shared_ptr<const CSSIdentifierValue> ConsumeIdent(CSSParserTokenStream&);
std::shared_ptr<const CSSIdentifierValue> ConsumeIdentRange(CSSParserTokenRange&, CSSValueID lower, CSSValueID upper);
std::shared_ptr<const CSSIdentifierValue> ConsumeIdentRange(CSSParserTokenStream&, CSSValueID lower, CSSValueID upper);

template <CSSValueID, CSSValueID...>
inline bool IdentMatches(CSSValueID id);

template <typename... emptyBaseCase>
inline bool IdentMatches(CSSValueID id) {
  return false;
}
template <CSSValueID head, CSSValueID... tail>
inline bool IdentMatches(CSSValueID id) {
  return id == head || IdentMatches<tail...>(id);
}

template <CSSValueID... allowedIdents>
std::shared_ptr<const CSSIdentifierValue> ConsumeIdent(CSSParserTokenRange&);
template <CSSValueID... allowedIdents>
std::shared_ptr<const CSSIdentifierValue> ConsumeIdent(CSSParserTokenStream&);

std::shared_ptr<const CSSCustomIdentValue> ConsumeCustomIdent(CSSParserTokenRange&, const CSSParserContext&);
std::shared_ptr<const CSSCustomIdentValue> ConsumeCustomIdent(CSSParserTokenStream&, const CSSParserContext&);

template <typename T>
    requires std::is_same_v<T, CSSParserTokenStream> ||
    std::is_same_v<T, CSSParserTokenRange> std::shared_ptr<const CSSCustomIdentValue> ConsumeDashedIdent(
        T&,
        const CSSParserContext&);
std::shared_ptr<const CSSStringValue> ConsumeString(CSSParserTokenRange&);
std::shared_ptr<const CSSStringValue> ConsumeString(CSSParserTokenStream&);
std::string ConsumeStringAsString(CSSParserTokenStream& stream);
// cssvalue::CSSURIValue* ConsumeUrl(CSSParserTokenRange&, const CSSParserContext&);
// cssvalue::CSSURIValue* ConsumeUrl(CSSParserTokenStream&, const CSSParserContext&);

// Some properties accept non-standard colors, like rgb values without a
// preceding hash, in quirks mode.
std::shared_ptr<const CSSValue> ConsumeColorMaybeQuirky(CSSParserTokenStream&, const CSSParserContext&);

// https://drafts.csswg.org/css-color-5/#typedef-color
template <typename T>
    requires std::is_same_v<T, CSSParserTokenStream> ||
    std::is_same_v<T, CSSParserTokenRange> std::shared_ptr<const CSSValue> ConsumeColor(T&, const CSSParserContext&);

// https://drafts.csswg.org/css-color-5/#absolute-color
std::shared_ptr<const CSSValue> ConsumeAbsoluteColor(CSSParserTokenRange&, const CSSParserContext&);

std::shared_ptr<const CSSValue> ConsumeLineWidth(CSSParserTokenRange&, const CSSParserContext&, UnitlessQuirk);
std::shared_ptr<const CSSValue> ConsumeLineWidth(CSSParserTokenStream&, const CSSParserContext&, UnitlessQuirk);

template <typename T>
    requires std::is_same_v<T, CSSParserTokenStream> ||
    std::is_same_v<T, CSSParserTokenRange> std::shared_ptr<const CSSValuePair> ConsumePosition(T&,
                                                                                               const CSSParserContext&,
                                                                                               UnitlessQuirk);
bool ConsumePosition(CSSParserTokenRange&,
                     const CSSParserContext&,
                     UnitlessQuirk,
                     std::shared_ptr<const CSSValue>& result_x,
                     std::shared_ptr<const CSSValue>& result_y);
bool ConsumePosition(CSSParserTokenStream&,
                     const CSSParserContext&,
                     UnitlessQuirk,
                     std::shared_ptr<const CSSValue>& result_x,
                     std::shared_ptr<const CSSValue>& result_y);

template <typename T>
    requires std::is_same_v<T, CSSParserTokenStream> ||
    std::is_same_v<T, CSSParserTokenRange> bool ConsumeOneOrTwoValuedPosition(
        T&,
        const CSSParserContext&,
        UnitlessQuirk,
        std::shared_ptr<const CSSValue>& result_x,
        std::shared_ptr<const CSSValue>& result_y);

bool ConsumeBorderShorthand(CSSParserTokenStream&,
                            const CSSParserContext&,
                            const CSSParserLocalContext&,
                            std::shared_ptr<const CSSValue>& result_width,
                            std::shared_ptr<const CSSValue>& result_style,
                            std::shared_ptr<const CSSValue>& result_color);

std::shared_ptr<const CSSValue> ConsumeBorderWidth(CSSParserTokenStream&, const CSSParserContext&, UnitlessQuirk);

std::shared_ptr<const CSSValue> ParseBorderWidthSide(CSSParserTokenStream&,
                                                     const CSSParserContext&,
                                                     const CSSParserLocalContext&);

std::shared_ptr<const CSSValue> ParseBorderStyleSide(CSSParserTokenStream&, const CSSParserContext&);

std::shared_ptr<const CSSValue> ConsumeBorderColorSide(CSSParserTokenStream&,
                                                       const CSSParserContext&,
                                                       const CSSParserLocalContext&);

std::shared_ptr<const CSSValue> ParseLonghand(CSSPropertyID unresolved_property,
                                              CSSPropertyID current_shorthand,
                                              const CSSParserContext& context,
                                              CSSParserTokenStream& stream);

void CountKeywordOnlyPropertyUsage(CSSPropertyID, const CSSParserContext&, CSSValueID);

void WarnInvalidKeywordPropertyUsage(CSSPropertyID, const CSSParserContext&, CSSValueID);

bool ValidWidthOrHeightKeyword(CSSValueID id, const CSSParserContext& context);

std::shared_ptr<const CSSValue> ConsumeMaxWidthOrHeight(CSSParserTokenStream&,
                                                        const CSSParserContext&,
                                                        UnitlessQuirk = UnitlessQuirk::kForbid);
std::shared_ptr<const CSSValue> ConsumeWidthOrHeight(CSSParserTokenStream&,
                                                     const CSSParserContext&,
                                                     UnitlessQuirk = UnitlessQuirk::kForbid);

std::shared_ptr<const CSSValue> ConsumeMarginOrOffset(CSSParserTokenStream&,
                                                      const CSSParserContext&,
                                                      UnitlessQuirk,
                                                      CSSAnchorQueryTypes = kCSSAnchorQueryTypesNone);
std::shared_ptr<const CSSValue> ConsumeScrollPadding(CSSParserTokenStream&, const CSSParserContext&);
std::shared_ptr<const CSSValue> ConsumeScrollStart(CSSParserTokenStream&, const CSSParserContext&);
std::shared_ptr<const CSSValue> ConsumeScrollStartTarget(CSSParserTokenStream&);
std::shared_ptr<const CSSValue> ConsumeOffsetPath(CSSParserTokenStream&, const CSSParserContext&);
std::shared_ptr<const CSSValue> ConsumeOffsetRotate(CSSParserTokenStream&, const CSSParserContext&);
std::shared_ptr<const CSSValue> ConsumeInitialLetter(CSSParserTokenStream&, const CSSParserContext&);

std::shared_ptr<const CSSValue> ConsumeAnimationIterationCount(CSSParserTokenStream&, const CSSParserContext&);
std::shared_ptr<const CSSValue> ConsumeAnimationName(CSSParserTokenStream&,
                                                     const CSSParserContext&,
                                                     bool allow_quoted_name);
std::shared_ptr<const CSSValue> ConsumeAnimationTimeline(CSSParserTokenStream&, const CSSParserContext&);
std::shared_ptr<const CSSValue> ConsumeAnimationTimingFunction(CSSParserTokenStream&, const CSSParserContext&);
std::shared_ptr<const CSSValue> ConsumeAnimationDuration(CSSParserTokenStream&, const CSSParserContext&);

bool ConsumeAnimationShorthand(
    const StylePropertyShorthand&,
    std::vector<std::shared_ptr<CSSValueList>>&,
    ConsumeAnimationItemValue,
    IsResetOnlyFunction,
    CSSParserTokenStream&,
    const CSSParserContext&,
    bool use_legacy_parsing);

enum class IsImplicitProperty { kNotImplicit, kImplicit };

void AddProperty(CSSPropertyID resolved_property,
                 CSSPropertyID current_shorthand,
                 const std::shared_ptr<const CSSValue>& value,
                 bool important,
                 IsImplicitProperty implicit,
                 std::vector<CSSPropertyValue>& properties);

bool ConsumeBackgroundPosition(CSSParserTokenStream&,
                               const CSSParserContext&,
                               UnitlessQuirk,
                               std::shared_ptr<const CSSValue>& result_x,
                               std::shared_ptr<const CSSValue>& result_y);

std::shared_ptr<const CSSValue> ConsumeBackgroundAttachment(CSSParserTokenStream& stream);
std::shared_ptr<const CSSValue> ConsumeBackgroundBoxOrText(CSSParserTokenStream& stream);
std::shared_ptr<const CSSValue> ConsumeBackgroundBox(CSSParserTokenStream&);
std::shared_ptr<const CSSValue> ConsumePrefixedBackgroundBox(CSSParserTokenStream&, AllowTextValue);

std::shared_ptr<const CSSValue> ConsumeImageOrNone(CSSParserTokenStream& stream,
                             const CSSParserContext& context);

enum class ConsumeGeneratedImagePolicy { kAllow, kForbid };
enum class ConsumeStringUrlImagePolicy { kAllow, kForbid };
enum class ConsumeImageSetImagePolicy { kAllow, kForbid };

std::shared_ptr<const CSSValue> ConsumeImage(
    CSSParserTokenStream&,
    const CSSParserContext&,
    const ConsumeGeneratedImagePolicy = ConsumeGeneratedImagePolicy::kAllow,
    const ConsumeStringUrlImagePolicy = ConsumeStringUrlImagePolicy::kForbid,
    const ConsumeImageSetImagePolicy = ConsumeImageSetImagePolicy::kAllow);

bool ParseBackgroundOrMask(bool,
                           CSSParserTokenStream&,
                           const CSSParserContext&,
                           const CSSParserLocalContext&,
                           std::vector<CSSPropertyValue>&);

template <typename T>
bool ConsumeIfIdent(T& range_or_stream, const char* ident) {
  if (!AtIdent(range_or_stream.Peek(), ident)) {
    return false;
  }
  range_or_stream.ConsumeIncludingWhitespace();
  return true;
}

}  // namespace css_parsing_utils
}  // namespace webf

#endif  // WEBF_CORE_CSS_PROPERTIES_CSS_PARSING_UTILS_H_
