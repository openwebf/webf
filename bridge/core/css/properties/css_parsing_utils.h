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
#include "core/css/css_function_value.h"
#include "core/css/css_identifier_value.h"
#include "core/css/css_numeric_literal_value.h"
#include "core/css/css_primitive_value.h"
#include "core/css/css_repeat_style_value.h"
#include "core/css/css_string_value.h"
#include "core/css/css_uri_value.h"
#include "core/css/css_value_list.h"
#include "core/css/parser/css_parser_local_context.h"
#include "core/css/parser/css_parser_token.h"
#include "core/css/parser/css_parser_token_range.h"
#include "core/css/parser/css_parser_token_stream.h"
#include "core/css/parser/css_property_parser.h"
#include "core/style/grid_area.h"
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
class CSSShadowValue;
class CSSValuePair;
class StylePropertyShorthand;

namespace cssvalue {

class CSSFontFeatureValue;

}

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
                                                                      std::shared_ptr<const CSSParserContext> context,
                                                                      bool use_legacy_parsing);
using IsResetOnlyFunction = bool (*)(CSSPropertyID);
using IsPositionKeyword = bool (*)(CSSValueID);

constexpr size_t kMaxNumAnimationLonghands = 12;

void Complete4Sides(std::shared_ptr<const CSSValue> side[4]);

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

inline bool AtIdent(const CSSParserToken& token, const char* ident) {
  return token.GetType() == kIdentToken && EqualIgnoringASCIICase(std::string(token.Value()), ident);
}

std::shared_ptr<const CSSPrimitiveValue> ConsumeInteger(CSSParserTokenRange&,
                                                        std::shared_ptr<const CSSParserContext> context,
                                                        double minimum_value = -std::numeric_limits<double>::max(),
                                                        const bool is_percentage_allowed = true);
std::shared_ptr<const CSSPrimitiveValue> ConsumeInteger(CSSParserTokenStream&,
                                                        std::shared_ptr<const CSSParserContext> context,
                                                        double minimum_value = -std::numeric_limits<double>::max(),
                                                        const bool is_percentage_allowed = true);

template <typename T>
typename std::enable_if<std::is_same<T, CSSParserTokenStream>::value || std::is_same<T, CSSParserTokenRange>::value,
                        std::shared_ptr<const CSSPrimitiveValue>>::type
ConsumeIntegerOrNumberCalc(T& range,
                           std::shared_ptr<const CSSParserContext>,
                           CSSPrimitiveValue::ValueRange value_range = CSSPrimitiveValue::ValueRange::kInteger);
std::shared_ptr<const CSSPrimitiveValue> ConsumePositiveInteger(CSSParserTokenStream&,
                                                                std::shared_ptr<const CSSParserContext> context);
std::shared_ptr<const CSSPrimitiveValue> ConsumePositiveInteger(CSSParserTokenRange&,
                                                                std::shared_ptr<const CSSParserContext> context);
bool ConsumeNumberRaw(CSSParserTokenStream&, std::shared_ptr<const CSSParserContext>, double& result);
bool ConsumeNumberRaw(CSSParserTokenRange&, std::shared_ptr<const CSSParserContext>, double& result);
std::shared_ptr<const CSSPrimitiveValue> ConsumeNumber(CSSParserTokenRange&,
                                                       std::shared_ptr<const CSSParserContext> context,
                                                       CSSPrimitiveValue::ValueRange);
std::shared_ptr<const CSSPrimitiveValue> ConsumeNumber(CSSParserTokenStream&,
                                                       std::shared_ptr<const CSSParserContext> context,
                                                       CSSPrimitiveValue::ValueRange);
std::shared_ptr<const CSSPrimitiveValue> ConsumeLength(CSSParserTokenRange&,
                                                       std::shared_ptr<const CSSParserContext> context,
                                                       CSSPrimitiveValue::ValueRange,
                                                       UnitlessQuirk = UnitlessQuirk::kForbid);
std::shared_ptr<const CSSPrimitiveValue> ConsumeLength(CSSParserTokenStream&,
                                                       std::shared_ptr<const CSSParserContext> context,
                                                       CSSPrimitiveValue::ValueRange,
                                                       UnitlessQuirk = UnitlessQuirk::kForbid);
std::shared_ptr<const CSSPrimitiveValue> ConsumePercent(CSSParserTokenRange&,
                                                        std::shared_ptr<const CSSParserContext> context,
                                                        CSSPrimitiveValue::ValueRange);
std::shared_ptr<const CSSPrimitiveValue> ConsumePercent(CSSParserTokenStream&,
                                                        std::shared_ptr<const CSSParserContext> context,
                                                        CSSPrimitiveValue::ValueRange);

// Any percentages are converted to numbers.
std::shared_ptr<const CSSPrimitiveValue> ConsumeNumberOrPercent(CSSParserTokenRange&,
                                                                std::shared_ptr<const CSSParserContext> context,
                                                                CSSPrimitiveValue::ValueRange);
std::shared_ptr<const CSSPrimitiveValue> ConsumeNumberOrPercent(CSSParserTokenStream& stream,
                                                                std::shared_ptr<const CSSParserContext>,
                                                                CSSPrimitiveValue::ValueRange value_range);

std::shared_ptr<const CSSPrimitiveValue> ConsumeAlphaValue(CSSParserTokenStream&,
                                                           std::shared_ptr<const CSSParserContext> context);
std::shared_ptr<const CSSPrimitiveValue> ConsumeLengthOrPercent(CSSParserTokenRange&,
                                                                std::shared_ptr<const CSSParserContext> context,
                                                                CSSPrimitiveValue::ValueRange,
                                                                UnitlessQuirk = UnitlessQuirk::kForbid,
                                                                CSSAnchorQueryTypes = kCSSAnchorQueryTypesNone,
                                                                AllowCalcSize = AllowCalcSize::kForbid);
std::shared_ptr<const CSSPrimitiveValue> ConsumeLengthOrPercent(CSSParserTokenStream&,
                                                                std::shared_ptr<const CSSParserContext> context,
                                                                CSSPrimitiveValue::ValueRange,
                                                                UnitlessQuirk = UnitlessQuirk::kForbid,
                                                                CSSAnchorQueryTypes = kCSSAnchorQueryTypesNone,
                                                                AllowCalcSize = AllowCalcSize::kForbid);
std::shared_ptr<const CSSPrimitiveValue> ConsumeSVGGeometryPropertyLength(
    CSSParserTokenStream&,
    std::shared_ptr<const CSSParserContext> context,
    CSSPrimitiveValue::ValueRange);

std::shared_ptr<const CSSPrimitiveValue> ConsumeAngle(CSSParserTokenRange&,
                                                      std::shared_ptr<const CSSParserContext> context);
std::shared_ptr<const CSSPrimitiveValue> ConsumeAngle(CSSParserTokenRange&,
                                                      std::shared_ptr<const CSSParserContext> context,
                                                      double minimum_value,
                                                      double maximum_value);
std::shared_ptr<const CSSPrimitiveValue> ConsumeAngle(CSSParserTokenStream&,
                                                      std::shared_ptr<const CSSParserContext> context);
std::shared_ptr<const CSSPrimitiveValue> ConsumeAngle(CSSParserTokenStream&,
                                                      std::shared_ptr<const CSSParserContext> context,
                                                      double minimum_value,
                                                      double maximum_value);

template <typename T>
typename std::enable_if<std::is_same<T, CSSParserTokenStream>::value || std::is_same<T, CSSParserTokenRange>::value,
                        std::shared_ptr<const CSSPrimitiveValue>>::type
ConsumeTime(T& range, std::shared_ptr<const CSSParserContext>, CSSPrimitiveValue::ValueRange value_range);

template <typename T>
typename std::enable_if<std::is_same<T, CSSParserTokenStream>::value || std::is_same<T, CSSParserTokenRange>::value,
                        std::shared_ptr<const CSSPrimitiveValue>>::type
ConsumeResolution(T& range, std::shared_ptr<const CSSParserContext>);

std::shared_ptr<const CSSValue> ConsumeRatio(CSSParserTokenStream&, std::shared_ptr<const CSSParserContext> context);
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

template <CSSValueID... names>
std::shared_ptr<const CSSIdentifierValue> ConsumeIdent(CSSParserTokenRange& range) {
  if (range.Peek().GetType() != kIdentToken || !IdentMatches<names...>(range.Peek().Id())) {
    return nullptr;
  }
  return CSSIdentifierValue::Create(range.ConsumeIncludingWhitespace().Id());
}

template <CSSValueID... names>
std::shared_ptr<const CSSIdentifierValue> ConsumeIdent(CSSParserTokenStream& stream) {
  if (stream.Peek().GetType() != kIdentToken || !IdentMatches<names...>(stream.Peek().Id())) {
    return nullptr;
  }
  return CSSIdentifierValue::Create(stream.ConsumeIncludingWhitespace().Id());
}

std::shared_ptr<const CSSCustomIdentValue> ConsumeCustomIdent(CSSParserTokenRange&,
                                                              std::shared_ptr<const CSSParserContext> context);
std::shared_ptr<const CSSCustomIdentValue> ConsumeCustomIdent(CSSParserTokenStream&,
                                                              std::shared_ptr<const CSSParserContext> context);

template <typename T>
typename std::enable_if<std::is_same<T, CSSParserTokenStream>::value || std::is_same<T, CSSParserTokenRange>::value,
                        std::shared_ptr<const CSSCustomIdentValue>>::type
ConsumeDashedIdent(T& range, std::shared_ptr<const CSSParserContext>);
std::shared_ptr<const CSSStringValue> ConsumeString(CSSParserTokenStream&);
std::shared_ptr<const CSSStringValue> ConsumeString(CSSParserTokenRange& range);
std::string ConsumeStringAsString(CSSParserTokenStream& stream, bool* is_string_null);
std::shared_ptr<cssvalue::CSSURIValue> ConsumeUrl(CSSParserTokenStream&,
                                                  std::shared_ptr<const CSSParserContext> context);

std::shared_ptr<const CSSValue> ConsumeCSSWideKeyword(CSSParserTokenRange&);
std::shared_ptr<const CSSValue> ConsumeCSSWideKeyword(CSSParserTokenStream&);

// Some properties accept non-standard colors, like rgb values without a
// preceding hash, in quirks mode.
std::shared_ptr<const CSSValue> ConsumeColorMaybeQuirky(CSSParserTokenStream&,
                                                        std::shared_ptr<const CSSParserContext> context);

// https://drafts.csswg.org/css-color-5/#typedef-color
template <typename T>
typename std::enable_if<std::is_same<T, CSSParserTokenStream>::value || std::is_same<T, CSSParserTokenRange>::value,
                        std::shared_ptr<const CSSValue>>::type
ConsumeColor(T& range, std::shared_ptr<const CSSParserContext>);

// https://drafts.csswg.org/css-color-5/#absolute-color
std::shared_ptr<const CSSValue> ConsumeAbsoluteColor(CSSParserTokenRange&,
                                                     std::shared_ptr<const CSSParserContext> context);

std::shared_ptr<const CSSValue> ConsumeLineWidth(CSSParserTokenRange&,
                                                 std::shared_ptr<const CSSParserContext> context,
                                                 UnitlessQuirk);
std::shared_ptr<const CSSValue> ConsumeLineWidth(CSSParserTokenStream&,
                                                 std::shared_ptr<const CSSParserContext> context,
                                                 UnitlessQuirk);

template <typename T>
typename std::enable_if<std::is_same<T, CSSParserTokenStream>::value || std::is_same<T, CSSParserTokenRange>::value,
                        std::shared_ptr<const CSSValuePair>>::type
ConsumePosition(T& range, std::shared_ptr<const CSSParserContext>, UnitlessQuirk unitless);

bool ConsumePosition(CSSParserTokenRange&,
                     std::shared_ptr<const CSSParserContext> context,
                     UnitlessQuirk,
                     std::shared_ptr<const CSSValue>& result_x,
                     std::shared_ptr<const CSSValue>& result_y);
bool ConsumePosition(CSSParserTokenStream&,
                     std::shared_ptr<const CSSParserContext> context,
                     UnitlessQuirk,
                     std::shared_ptr<const CSSValue>& result_x,
                     std::shared_ptr<const CSSValue>& result_y);

template <typename T>
typename std::enable_if<std::is_same<T, CSSParserTokenStream>::value || std::is_same<T, CSSParserTokenRange>::value,
                        bool>::type
ConsumeOneOrTwoValuedPosition(T& range,
                              std::shared_ptr<const CSSParserContext>,
                              UnitlessQuirk unitless,
                              std::shared_ptr<const CSSValue>& result_x,
                              std::shared_ptr<const CSSValue>& result_y);

bool ConsumeBorderShorthand(CSSParserTokenStream&,
                            std::shared_ptr<const CSSParserContext> context,
                            const CSSParserLocalContext&,
                            std::shared_ptr<const CSSValue>& result_width,
                            std::shared_ptr<const CSSValue>& result_style,
                            std::shared_ptr<const CSSValue>& result_color);

std::shared_ptr<const CSSValue> ConsumeBorderWidth(CSSParserTokenStream&,
                                                   std::shared_ptr<const CSSParserContext> context,
                                                   UnitlessQuirk);

std::shared_ptr<const CSSValue> ParseBorderWidthSide(CSSParserTokenStream&,
                                                     std::shared_ptr<const CSSParserContext> context,
                                                     const CSSParserLocalContext&);

std::shared_ptr<const CSSValue> ParseBorderStyleSide(CSSParserTokenStream&,
                                                     std::shared_ptr<const CSSParserContext> context);

std::shared_ptr<const CSSValue> ConsumeBorderColorSide(CSSParserTokenStream&,
                                                       std::shared_ptr<const CSSParserContext> context,
                                                       const CSSParserLocalContext&);

std::shared_ptr<const CSSValue> ParseLonghand(CSSPropertyID unresolved_property,
                                              CSSPropertyID current_shorthand,
                                              std::shared_ptr<const CSSParserContext>,
                                              CSSParserTokenStream& stream);

void WarnInvalidKeywordPropertyUsage(CSSPropertyID, std::shared_ptr<const CSSParserContext> context, CSSValueID);

bool ValidWidthOrHeightKeyword(CSSValueID id, std::shared_ptr<const CSSParserContext>);

std::shared_ptr<const CSSValue> ConsumeMaxWidthOrHeight(CSSParserTokenStream&,
                                                        std::shared_ptr<const CSSParserContext> context,
                                                        UnitlessQuirk = UnitlessQuirk::kForbid);
std::shared_ptr<const CSSValue> ConsumeWidthOrHeight(CSSParserTokenStream&,
                                                     std::shared_ptr<const CSSParserContext> context,
                                                     UnitlessQuirk = UnitlessQuirk::kForbid);

std::shared_ptr<const CSSValue> ConsumeMarginOrOffset(CSSParserTokenStream&,
                                                      std::shared_ptr<const CSSParserContext> context,
                                                      UnitlessQuirk,
                                                      CSSAnchorQueryTypes = kCSSAnchorQueryTypesNone);
std::shared_ptr<const CSSValue> ConsumeScrollPadding(CSSParserTokenStream&,
                                                     std::shared_ptr<const CSSParserContext> context);
std::shared_ptr<const CSSValue> ConsumeScrollStart(CSSParserTokenStream&,
                                                   std::shared_ptr<const CSSParserContext> context);
std::shared_ptr<const CSSValue> ConsumeScrollStartTarget(CSSParserTokenStream&);
std::shared_ptr<const CSSValue> ConsumeOffsetPath(CSSParserTokenStream&,
                                                  std::shared_ptr<const CSSParserContext> context);
std::shared_ptr<const CSSValue> ConsumeOffsetRotate(CSSParserTokenStream&,
                                                    std::shared_ptr<const CSSParserContext> context);
std::shared_ptr<const CSSValue> ConsumeInitialLetter(CSSParserTokenStream&,
                                                     std::shared_ptr<const CSSParserContext> context);

std::shared_ptr<const CSSValue> ConsumeAnimationIterationCount(CSSParserTokenStream&,
                                                               std::shared_ptr<const CSSParserContext> context);
// https://drafts.csswg.org/scroll-animations-1/#typedef-timeline-range-name
std::shared_ptr<const CSSValue> ConsumeTimelineRangeName(CSSParserTokenStream&);
std::shared_ptr<const CSSValue> ConsumeTimelineRangeName(CSSParserTokenRange&);
std::shared_ptr<const CSSValue> ConsumeAnimationName(CSSParserTokenStream&,
                                                     std::shared_ptr<const CSSParserContext> context,
                                                     bool allow_quoted_name);
std::shared_ptr<const CSSValue> ConsumeAnimationRange(CSSParserTokenStream&,
                                                      std::shared_ptr<const CSSParserContext> context,
                                                      double default_offset_percent);

std::shared_ptr<const CSSValue> ConsumeAnimationTimeline(CSSParserTokenStream&,
                                                         std::shared_ptr<const CSSParserContext> context);
std::shared_ptr<const CSSValue> ConsumeAnimationTimingFunction(CSSParserTokenStream&,
                                                               std::shared_ptr<const CSSParserContext> context);
std::shared_ptr<const CSSValue> ConsumeAnimationDuration(CSSParserTokenStream&,
                                                         std::shared_ptr<const CSSParserContext> context);

template <typename T>
typename std::enable_if<std::is_same_v<T, CSSParserTokenStream> || std::is_same_v<T, CSSParserTokenRange>,
                        std::shared_ptr<const CSSIdentifierValue>>::type
ConsumeFontTechIdent(T& stream);

bool ConsumeAnimationShorthand(const StylePropertyShorthand&,
                               std::vector<std::shared_ptr<CSSValueList>>&,
                               ConsumeAnimationItemValue,
                               IsResetOnlyFunction,
                               CSSParserTokenStream&,
                               std::shared_ptr<const CSSParserContext> context,
                               bool use_legacy_parsing);

enum class IsImplicitProperty { kNotImplicit, kImplicit };

void AddProperty(CSSPropertyID resolved_property,
                 CSSPropertyID current_shorthand,
                 std::shared_ptr<const CSSValue> value,
                 bool important,
                 IsImplicitProperty implicit,
                 std::vector<CSSPropertyValue>& properties);

bool ConsumeBackgroundPosition(CSSParserTokenStream&,
                               std::shared_ptr<const CSSParserContext> context,
                               UnitlessQuirk,
                               std::shared_ptr<const CSSValue>& result_x,
                               std::shared_ptr<const CSSValue>& result_y);

std::shared_ptr<const CSSValue> ConsumeBackgroundAttachment(CSSParserTokenStream& stream);
std::shared_ptr<const CSSValue> ConsumeBackgroundBoxOrText(CSSParserTokenStream& stream);
std::shared_ptr<const CSSValue> ConsumeBackgroundBox(CSSParserTokenStream&);
std::shared_ptr<const CSSValue> ConsumePrefixedBackgroundBox(CSSParserTokenStream&, AllowTextValue);
std::shared_ptr<const CSSValue> ConsumeMaskComposite(CSSParserTokenStream&);
std::shared_ptr<const CSSValue> ConsumePrefixedMaskComposite(CSSParserTokenStream&);
std::shared_ptr<const CSSValue> ConsumeMaskMode(CSSParserTokenStream&);

std::shared_ptr<const CSSValue> ConsumeCoordBoxOrNoClip(CSSParserTokenStream&);

std::shared_ptr<const CSSValue> ConsumeImageOrNone(CSSParserTokenStream& stream,
                                                   std::shared_ptr<const CSSParserContext>);

enum class ConsumeGeneratedImagePolicy { kAllow, kForbid };
enum class ConsumeStringUrlImagePolicy { kAllow, kForbid };
enum class ConsumeImageSetImagePolicy { kAllow, kForbid };

std::shared_ptr<const CSSValue> ConsumeImage(CSSParserTokenStream&,
                                             std::shared_ptr<const CSSParserContext> context,
                                             const ConsumeGeneratedImagePolicy = ConsumeGeneratedImagePolicy::kAllow,
                                             const ConsumeStringUrlImagePolicy = ConsumeStringUrlImagePolicy::kForbid,
                                             const ConsumeImageSetImagePolicy = ConsumeImageSetImagePolicy::kAllow);

bool ParseBackgroundOrMask(bool,
                           CSSParserTokenStream&,
                           std::shared_ptr<const CSSParserContext> context,
                           const CSSParserLocalContext&,
                           std::vector<CSSPropertyValue>&);

bool ConsumeShorthandVia2Longhands(const StylePropertyShorthand&,
                                   bool important,
                                   std::shared_ptr<const CSSParserContext> context,
                                   CSSParserTokenStream&,
                                   std::vector<CSSPropertyValue>& properties);

bool ConsumeShorthandVia4Longhands(const StylePropertyShorthand&,
                                   bool important,
                                   std::shared_ptr<const CSSParserContext> context,
                                   CSSParserTokenStream&,
                                   std::vector<CSSPropertyValue>& properties);

bool ConsumeShorthandGreedilyViaLonghands(const StylePropertyShorthand&,
                                          bool important,
                                          std::shared_ptr<const CSSParserContext> context,
                                          CSSParserTokenStream&,
                                          std::vector<CSSPropertyValue>& properties,
                                          bool use_initial_value_function = false);

void AddExpandedPropertyForValue(CSSPropertyID prop_id,
                                 const std::shared_ptr<const CSSValue>&,
                                 bool,
                                 std::vector<CSSPropertyValue>& properties);

bool ConsumeBorderImageComponents(CSSParserTokenStream& stream,
                                  std::shared_ptr<const CSSParserContext>,
                                  std::shared_ptr<const CSSValue>& source,
                                  std::shared_ptr<const CSSValue>& slice,
                                  std::shared_ptr<const CSSValue>& width,
                                  std::shared_ptr<const CSSValue>& outset,
                                  std::shared_ptr<const CSSValue>& repeat,
                                  DefaultFill default_fill);

std::shared_ptr<const CSSValue> ConsumeBorderImageRepeat(CSSParserTokenStream&);
std::shared_ptr<const CSSValue> ConsumeBorderImageSlice(CSSParserTokenStream&,
                                                        std::shared_ptr<const CSSParserContext> context,
                                                        DefaultFill);
std::shared_ptr<const CSSValue> ConsumeBorderImageWidth(CSSParserTokenStream&,
                                                        std::shared_ptr<const CSSParserContext> context);
std::shared_ptr<const CSSValue> ConsumeBorderImageOutset(CSSParserTokenStream&,
                                                         std::shared_ptr<const CSSParserContext> context);
bool ConsumeColumnWidthOrCount(CSSParserTokenStream& stream,
                               std::shared_ptr<const CSSParserContext>,
                               std::shared_ptr<const CSSValue>& column_width,
                               std::shared_ptr<const CSSValue>& column_count);

std::shared_ptr<const CSSValue> ParseBorderRadiusCorner(CSSParserTokenStream&,
                                                        std::shared_ptr<const CSSParserContext> context);
std::shared_ptr<const CSSValue> ParseBorderWidthSide(CSSParserTokenStream&,
                                                     std::shared_ptr<const CSSParserContext> context,
                                                     const CSSParserLocalContext&);
std::shared_ptr<const CSSValue> ParseBorderStyleSide(CSSParserTokenStream&,
                                                     std::shared_ptr<const CSSParserContext> context);

bool ConsumeRadii(std::shared_ptr<const CSSValue> horizontal_radii[4],
                  std::shared_ptr<const CSSValue> vertical_radii[4],
                  CSSParserTokenStream& stream,
                  std::shared_ptr<const CSSParserContext>,
                  bool use_legacy_parsing);

template <typename T>
typename std::enable_if<std::is_same<T, CSSParserTokenStream>::value || std::is_same<T, CSSParserTokenRange>::value,
                        std::shared_ptr<const CSSValue>>::type
ConsumeSingleContainerName(T& range, std::shared_ptr<const CSSParserContext>);
std::shared_ptr<const CSSValue> ConsumeContainerName(CSSParserTokenStream&,
                                                     std::shared_ptr<const CSSParserContext> context);

std::shared_ptr<const CSSValue> ConsumeContainerType(CSSParserTokenStream& stream);

std::shared_ptr<const CSSValue> ConsumeShadow(CSSParserTokenStream&,
                                              std::shared_ptr<const CSSParserContext> context,
                                              AllowInsetAndSpread);

std::shared_ptr<const CSSShadowValue> ParseSingleShadow(CSSParserTokenStream&,
                                                        std::shared_ptr<const CSSParserContext> context,
                                                        AllowInsetAndSpread);

std::shared_ptr<const CSSValue> ConsumeColumnCount(CSSParserTokenStream&,
                                                   std::shared_ptr<const CSSParserContext> context);
std::shared_ptr<const CSSValue> ConsumeColumnWidth(CSSParserTokenStream&,
                                                   std::shared_ptr<const CSSParserContext> context);
bool ConsumeColumnWidthOrCount(CSSParserTokenStream&,
                               std::shared_ptr<const CSSParserContext> context,
                               std::shared_ptr<const CSSValue>&,
                               std::shared_ptr<const CSSValue>&);
std::shared_ptr<const CSSValue> ConsumeGapLength(CSSParserTokenStream&,
                                                 std::shared_ptr<const CSSParserContext> context);

std::shared_ptr<const CSSValue> ConsumeCounter(CSSParserTokenStream&,
                                               std::shared_ptr<const CSSParserContext> context,
                                               int);

std::shared_ptr<const CSSValue> ConsumeFontSize(CSSParserTokenStream&,
                                                std::shared_ptr<const CSSParserContext> context,
                                                UnitlessQuirk = UnitlessQuirk::kForbid);

std::shared_ptr<const CSSValue> ConsumeLineHeight(CSSParserTokenStream&,
                                                  std::shared_ptr<const CSSParserContext> context);
std::shared_ptr<const CSSValue> ConsumeMathDepth(CSSParserTokenStream& stream, std::shared_ptr<const CSSParserContext>);

std::shared_ptr<const CSSValue> ConsumeFontPalette(CSSParserTokenStream&,
                                                   std::shared_ptr<const CSSParserContext> context);
std::shared_ptr<const CSSValueList> ConsumeFontFamily(CSSParserTokenRange&);
std::shared_ptr<const CSSValueList> ConsumeFontFamily(CSSParserTokenStream&);
std::shared_ptr<const CSSValueList> ConsumeNonGenericFamilyNameList(CSSParserTokenRange& range);
std::shared_ptr<const CSSValue> ConsumeGenericFamily(CSSParserTokenRange&);
std::shared_ptr<const CSSValue> ConsumeGenericFamily(CSSParserTokenStream&);

template <typename T>
typename std::enable_if<std::is_same<T, CSSParserTokenStream>::value || std::is_same<T, CSSParserTokenRange>::value,
                        std::shared_ptr<const CSSValue>>::type
ConsumeFamilyName(T& range);

template <typename T>
typename std::enable_if<std::is_same<T, CSSParserTokenStream>::value || std::is_same<T, CSSParserTokenRange>::value,
                        std::string>::type
ConcatenateFamilyName(T& range);

template <typename T>
typename std::enable_if<std::is_same<T, CSSParserTokenStream>::value || std::is_same<T, CSSParserTokenRange>::value,
                        std::shared_ptr<const CSSIdentifierValue>>::type
ConsumeFontStretchKeywordOnly(T& range, std::shared_ptr<const CSSParserContext>);

template <typename T>
typename std::enable_if<std::is_same<T, CSSParserTokenStream>::value || std::is_same<T, CSSParserTokenRange>::value,
                        std::shared_ptr<const CSSValue>>::type
ConsumeFontStretch(T& range, std::shared_ptr<const CSSParserContext>);
template <typename T>
typename std::enable_if<std::is_same<T, CSSParserTokenStream>::value || std::is_same<T, CSSParserTokenRange>::value,
                        std::shared_ptr<const CSSValue>>::type
ConsumeFontStyle(T& range, std::shared_ptr<const CSSParserContext>);
template <typename T>
typename std::enable_if<std::is_same<T, CSSParserTokenStream>::value || std::is_same<T, CSSParserTokenRange>::value,
                        std::shared_ptr<const CSSValue>>::type
ConsumeFontWeight(T& range, std::shared_ptr<const CSSParserContext>);
template <typename T>
typename std::enable_if<std::is_same<T, CSSParserTokenStream>::value || std::is_same<T, CSSParserTokenRange>::value,
                        std::shared_ptr<const CSSValue>>::type
ConsumeFontFeatureSettings(T& range, std::shared_ptr<const CSSParserContext>);
template <typename T>
typename std::enable_if<std::is_same<T, CSSParserTokenStream>::value || std::is_same<T, CSSParserTokenRange>::value,
                        std::shared_ptr<const cssvalue::CSSFontFeatureValue>>::type
ConsumeFontFeatureTag(T& range, std::shared_ptr<const CSSParserContext>);

template <typename T>
typename std::enable_if<std::is_same<T, CSSParserTokenStream>::value || std::is_same<T, CSSParserTokenRange>::value,
                        std::shared_ptr<const CSSIdentifierValue>>::type
ConsumeFontVariantCSS21(T& range);

template <typename T>
typename std::enable_if<std::is_same<T, CSSParserTokenStream>::value || std::is_same<T, CSSParserTokenRange>::value,
                        std::shared_ptr<const CSSIdentifierValue>>::type
ConsumeFontFormatIdent(T& range);

template <typename Func, typename... Args>
std::shared_ptr<const CSSValueList> ConsumeSpaceSeparatedList(Func callback,
                                                              CSSParserTokenStream& stream,
                                                              Args&&... args) {
  std::shared_ptr<CSSValueList> list = CSSValueList::CreateSpaceSeparated();
  do {
    std::shared_ptr<CSSValue> value = callback(stream, std::forward<Args>(args)...);
    if (!value) {
      return list->length() > 0 ? list : nullptr;
    }
    list->Append(value);
  } while (!stream.AtEnd());
  DCHECK(list->length());
  return list;
}

bool ParseGridTemplateAreasRow(const std::string& grid_row_names,
                               NamedGridAreaMap& grid_area_map,
                               const size_t row_count,
                               size_t& column_count);

// ConsumeCommaSeparatedList and ConsumeSpaceSeparatedList take a callback
// function to call on each item in the list, followed by the arguments to pass
// to this callback.  The first argument to the callback must be the
// CSSParserTokenStream
template <typename Func, typename... Args>
std::shared_ptr<const CSSValueList> ConsumeCommaSeparatedList(Func callback,
                                                              CSSParserTokenStream& stream,
                                                              Args&&... args) {
  std::shared_ptr<CSSValueList> list = CSSValueList::CreateCommaSeparated();
  do {
    std::shared_ptr<const CSSValue> value = callback(stream, std::forward<Args>(args)...);
    if (!value) {
      return nullptr;
    }
    list->Append(value);
  } while (ConsumeCommaIncludingWhitespace(stream));
  DCHECK(list->length());
  return list;
}

std::shared_ptr<const CSSValue> ConsumeGridLine(CSSParserTokenStream&, std::shared_ptr<const CSSParserContext> context);
bool ConsumeGridItemPositionShorthand(bool important,
                                      CSSParserTokenStream&,
                                      std::shared_ptr<const CSSParserContext> context,
                                      std::shared_ptr<const CSSValue>& start_value,
                                      std::shared_ptr<const CSSValue>& end_value);

bool ConsumeGridTemplateShorthand(bool important,
                                  CSSParserTokenStream&,
                                  std::shared_ptr<const CSSParserContext> context,
                                  std::shared_ptr<const CSSValue>& template_rows,
                                  std::shared_ptr<const CSSValue>& template_columns,
                                  std::shared_ptr<const CSSValue>& template_areas);

std::shared_ptr<const CSSValue> ConsumeGridTrackList(CSSParserTokenStream&,
                                                     std::shared_ptr<const CSSParserContext> context,
                                                     TrackListType);

std::shared_ptr<const CSSValue> ConsumeGridTemplatesRowsOrColumns(CSSParserTokenStream&,
                                                                  std::shared_ptr<const CSSParserContext> context);

// The fragmentation spec says that page-break-(after|before|inside) are to be
// treated as shorthands for their break-(after|before|inside) counterparts.
// We'll do the same for the non-standard properties
// -webkit-column-break-(after|before|inside).
bool ConsumeFromPageBreakBetween(CSSParserTokenStream&, CSSValueID&);
bool ConsumeFromColumnBreakBetween(CSSParserTokenStream&, CSSValueID&);
bool ConsumeFromColumnOrPageBreakInside(CSSParserTokenStream&, CSSValueID&);

bool IsBaselineKeyword(CSSValueID id);

std::shared_ptr<const CSSValue> ConsumeSingleTimelineAxis(CSSParserTokenStream&);
std::shared_ptr<const CSSValue> ConsumeSingleTimelineName(CSSParserTokenStream&,
                                                          std::shared_ptr<const CSSParserContext> context);
std::shared_ptr<const CSSValue> ConsumeSingleTimelineInset(CSSParserTokenStream&,
                                                           std::shared_ptr<const CSSParserContext> context);

std::shared_ptr<const CSSValue> ConsumeTransitionProperty(CSSParserTokenStream&,
                                                          std::shared_ptr<const CSSParserContext> context);

bool IsValidPropertyList(const CSSValueList&);
bool IsValidTransitionBehavior(const CSSValueID&);
bool IsValidTransitionBehaviorList(const CSSValueList&);

// Consume the `autospace` production.
// https://drafts.csswg.org/css-text-4/#typedef-autospace
std::shared_ptr<const CSSValue> ConsumeAutospace(CSSParserTokenStream&);
// Consume the `spacing-trim` production.
// https://drafts.csswg.org/css-text-4/#typedef-spacing-trim
std::shared_ptr<const CSSValue> ConsumeSpacingTrim(CSSParserTokenStream&);

std::shared_ptr<const CSSValue> ConsumeBaseline(CSSParserTokenStream& stream);

std::shared_ptr<const CSSValue> ConsumeSelfPositionOverflowPosition(CSSParserTokenStream&, IsPositionKeyword);
std::shared_ptr<const CSSValue> ConsumeContentDistributionOverflowPosition(CSSParserTokenStream&, IsPositionKeyword);
std::shared_ptr<const CSSValue> ConsumeFirstBaseline(CSSParserTokenStream& stream);

bool IsContentPositionKeyword(CSSValueID);

bool IsBaselineKeyword(CSSValueID id);
bool IsSelfPositionKeyword(CSSValueID);
bool IsSelfPositionOrLeftOrRightKeyword(CSSValueID);
bool IsContentPositionOrLeftOrRightKeyword(CSSValueID);
bool IsCSSWideKeyword(CSSValueID);
bool IsCSSWideKeyword(const std::string_view&);
bool IsRevertKeyword(const std::string_view&);
bool IsDefaultKeyword(const std::string_view&);
bool IsHashIdentifier(const CSSParserToken&);
bool IsDashedIdent(const CSSParserToken&);

bool ConsumeTranslate3d(CSSParserTokenStream& stream,
                        std::shared_ptr<const CSSParserContext>,
                        std::shared_ptr<CSSFunctionValue>& transform_value);
std::shared_ptr<const CSSValue> ConsumeTransformValue(CSSParserTokenStream&,
                                                      std::shared_ptr<const CSSParserContext> context);
std::shared_ptr<const CSSValue> ConsumeTransformList(CSSParserTokenStream&,
                                                     std::shared_ptr<const CSSParserContext> context);
std::shared_ptr<const CSSValue> ConsumeFilterFunctionList(CSSParserTokenStream&,
                                                          std::shared_ptr<const CSSParserContext> context);
std::shared_ptr<const CSSValue> ConsumeBackgroundBlendMode(CSSParserTokenStream& stream);

std::shared_ptr<const CSSValue> ParseBackgroundBox(CSSParserTokenStream& stream,
                                                   const CSSParserLocalContext& local_context,
                                                   AllowTextValue alias_allow_text_value);

std::shared_ptr<const CSSValue> ParseBackgroundSize(CSSParserTokenStream& stream,
                                                    std::shared_ptr<const CSSParserContext>,
                                                    const CSSParserLocalContext& local_context);

template <CSSValueID start, CSSValueID end>
std::shared_ptr<const CSSValue> ConsumePositionLonghand(CSSParserTokenStream& range,
                                                        std::shared_ptr<const CSSParserContext> context) {
  if (range.Peek().GetType() == kIdentToken) {
    CSSValueID id = range.Peek().Id();
    int percent;
    if (id == start) {
      percent = 0;
    } else if (id == CSSValueID::kCenter) {
      percent = 50;
    } else if (id == end) {
      percent = 100;
    } else {
      return nullptr;
    }
    range.ConsumeIncludingWhitespace();
    return CSSNumericLiteralValue::Create(percent, CSSPrimitiveValue::UnitType::kPercentage);
  }
  return ConsumeLengthOrPercent(range, context, CSSPrimitiveValue::ValueRange::kAll);
}

std::shared_ptr<const CSSValueList> ParseRepeatStyle(CSSParserTokenStream& stream);
std::shared_ptr<const CSSValue> ParseSpacing(CSSParserTokenStream&, std::shared_ptr<const CSSParserContext> context);
std::shared_ptr<const CSSValue> ParseMaskSize(CSSParserTokenStream&,
                                              std::shared_ptr<const CSSParserContext> context,
                                              const CSSParserLocalContext&);

std::shared_ptr<const CSSValue> ConsumeWebkitBorderImage(CSSParserTokenStream&,
                                                         std::shared_ptr<const CSSParserContext> context);

UnitlessQuirk UnitlessUnlessShorthand(const CSSParserLocalContext&);

std::shared_ptr<cssvalue::CSSURIValue> ConsumeUrl(CSSParserTokenStream& stream,
                                                  std::shared_ptr<const CSSParserContext>);
std::shared_ptr<cssvalue::CSSURIValue> ConsumeUrl(CSSParserTokenRange& range, std::shared_ptr<const CSSParserContext>);

std::shared_ptr<const CSSIdentifierValue> ConsumeShapeBox(CSSParserTokenStream&);
std::shared_ptr<const CSSIdentifierValue> ConsumeVisualBox(CSSParserTokenStream&);
std::shared_ptr<const CSSIdentifierValue> ConsumeCoordBox(CSSParserTokenStream& stream);
std::shared_ptr<const CSSIdentifierValue> ConsumeGeometryBox(CSSParserTokenStream&);

std::shared_ptr<const CSSValue> ConsumeBasicShape(CSSParserTokenStream&,
                                                  std::shared_ptr<const CSSParserContext> context,
                                                  AllowPathValue = AllowPathValue::kAllow,
                                                  AllowBasicShapeRectValue = AllowBasicShapeRectValue::kAllow,
                                                  AllowBasicShapeXYWHValue = AllowBasicShapeXYWHValue::kAllow);

std::shared_ptr<const CSSValue> ConsumeIntrinsicSizeLonghand(CSSParserTokenStream& stream,
                                                             std::shared_ptr<const CSSParserContext>);

std::shared_ptr<const CSSValue> ConsumeFontSizeAdjust(CSSParserTokenStream& stream,
                                                      std::shared_ptr<const CSSParserContext>);

std::shared_ptr<const CSSValue> ConsumeAxis(CSSParserTokenStream&, std::shared_ptr<const CSSParserContext>);

std::shared_ptr<const CSSValue> ConsumeTextDecorationLine(CSSParserTokenStream&);
std::shared_ptr<const CSSValue> ConsumeTextBoxEdge(CSSParserTokenStream&);

std::shared_ptr<const CSSValue> ConsumeTransformList(CSSParserTokenStream&,
                                                     std::shared_ptr<const CSSParserContext> context,
                                                     const CSSParserLocalContext&);

template <typename T>
typename std::enable_if<std::is_same<T, CSSParserTokenStream>::value || std::is_same<T, CSSParserTokenRange>::value,
                        std::shared_ptr<const CSSValue>>::type
ConsumeTimelineRangeNameAndPercent(T&, std::shared_ptr<const CSSParserContext> context);

CSSValueID FontFormatToId(std::string);
bool IsSupportedKeywordTech(CSSValueID keyword);
bool IsSupportedKeywordFormat(CSSValueID keyword);

template <typename T>
bool ConsumeIfIdent(T& range_or_stream, const char* ident) {
  if (!AtIdent(range_or_stream.Peek(), ident)) {
    return false;
  }
  range_or_stream.ConsumeIncludingWhitespace();
  return true;
}

bool MaybeConsumeImportant(CSSParserTokenStream& stream, bool allow_important_annotation);

}  // namespace css_parsing_utils
}  // namespace webf

#endif  // WEBF_CORE_CSS_PROPERTIES_CSS_PARSING_UTILS_H_
