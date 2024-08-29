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
#include "core/style/grid_area.h"
#include "core/css/css_string_value.h"
#include "core/css/css_uri_value.h"
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
                                                                      const CSSParserContext&,
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
// https://drafts.csswg.org/scroll-animations-1/#typedef-timeline-range-name
std::shared_ptr<const CSSValue> ConsumeTimelineRangeName(CSSParserTokenStream&);
std::shared_ptr<const CSSValue> ConsumeTimelineRangeName(CSSParserTokenRange&);
std::shared_ptr<const CSSValue> ConsumeAnimationName(CSSParserTokenStream&,
                                                     const CSSParserContext&,
                                                     bool allow_quoted_name);
std::shared_ptr<const CSSValue> ConsumeAnimationRange(CSSParserTokenStream&,
                                                      const CSSParserContext&,
                                                      double default_offset_percent);

std::shared_ptr<const CSSValue> ConsumeAnimationTimeline(CSSParserTokenStream&, const CSSParserContext&);
std::shared_ptr<const CSSValue> ConsumeAnimationTimingFunction(CSSParserTokenStream&, const CSSParserContext&);
std::shared_ptr<const CSSValue> ConsumeAnimationDuration(CSSParserTokenStream&, const CSSParserContext&);

bool ConsumeAnimationShorthand(const StylePropertyShorthand&,
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
std::shared_ptr<const CSSValue> ConsumeMaskComposite(CSSParserTokenStream&);
std::shared_ptr<const CSSValue> ConsumePrefixedMaskComposite(CSSParserTokenStream&);
std::shared_ptr<const CSSValue> ConsumeMaskMode(CSSParserTokenStream&);

std::shared_ptr<const CSSValue> ConsumeCoordBoxOrNoClip(CSSParserTokenStream&);

std::shared_ptr<const CSSValue> ConsumeImageOrNone(CSSParserTokenStream& stream, const CSSParserContext& context);

enum class ConsumeGeneratedImagePolicy { kAllow, kForbid };
enum class ConsumeStringUrlImagePolicy { kAllow, kForbid };
enum class ConsumeImageSetImagePolicy { kAllow, kForbid };

std::shared_ptr<const CSSValue> ConsumeImage(CSSParserTokenStream&,
                                             const CSSParserContext&,
                                             const ConsumeGeneratedImagePolicy = ConsumeGeneratedImagePolicy::kAllow,
                                             const ConsumeStringUrlImagePolicy = ConsumeStringUrlImagePolicy::kForbid,
                                             const ConsumeImageSetImagePolicy = ConsumeImageSetImagePolicy::kAllow);

bool ParseBackgroundOrMask(bool,
                           CSSParserTokenStream&,
                           const CSSParserContext&,
                           const CSSParserLocalContext&,
                           std::vector<CSSPropertyValue>&);

bool ConsumeShorthandVia2Longhands(const StylePropertyShorthand&,
                                   bool important,
                                   const CSSParserContext&,
                                   CSSParserTokenStream&,
                                   std::vector<CSSPropertyValue>& properties);

bool ConsumeShorthandVia4Longhands(const StylePropertyShorthand&,
                                   bool important,
                                   const CSSParserContext&,
                                   CSSParserTokenStream&,
                                   std::vector<CSSPropertyValue>& properties);

bool ConsumeShorthandGreedilyViaLonghands(const StylePropertyShorthand&,
                                          bool important,
                                          const CSSParserContext&,
                                          CSSParserTokenStream&,
                                          std::vector<CSSPropertyValue>& properties,
                                          bool use_initial_value_function = false);

void AddExpandedPropertyForValue(CSSPropertyID prop_id,
                                 const std::shared_ptr<const CSSValue>&,
                                 bool,
                                 std::vector<CSSPropertyValue>& properties);

bool ConsumeBorderImageComponents(CSSParserTokenStream& stream,
                                  const CSSParserContext& context,
                                  std::shared_ptr<const CSSValue>& source,
                                  std::shared_ptr<const CSSValue>& slice,
                                  std::shared_ptr<const CSSValue>& width,
                                  std::shared_ptr<const CSSValue>& outset,
                                  std::shared_ptr<const CSSValue>& repeat,
                                  DefaultFill default_fill);

std::shared_ptr<const CSSValue> ConsumeBorderImageRepeat(CSSParserTokenStream&);
std::shared_ptr<const CSSValue> ConsumeBorderImageSlice(CSSParserTokenStream&, const CSSParserContext&, DefaultFill);
std::shared_ptr<const CSSValue> ConsumeBorderImageWidth(CSSParserTokenStream&, const CSSParserContext&);
std::shared_ptr<const CSSValue> ConsumeBorderImageOutset(CSSParserTokenStream&, const CSSParserContext&);
bool ConsumeColumnWidthOrCount(CSSParserTokenStream& stream,
                               const CSSParserContext& context,
                               std::shared_ptr<const CSSValue>& column_width,
                               std::shared_ptr<const CSSValue>& column_count);

std::shared_ptr<const CSSValue> ParseBorderRadiusCorner(CSSParserTokenStream&, const CSSParserContext&);
std::shared_ptr<const CSSValue> ParseBorderWidthSide(CSSParserTokenStream&,
                                                     const CSSParserContext&,
                                                     const CSSParserLocalContext&);
std::shared_ptr<const CSSValue> ParseBorderStyleSide(CSSParserTokenStream&, const CSSParserContext&);

bool ConsumeRadii(std::shared_ptr<const CSSValue> horizontal_radii[4],
                  std::shared_ptr<const CSSValue> vertical_radii[4],
                  CSSParserTokenStream& stream,
                  const CSSParserContext& context,
                  bool use_legacy_parsing);

template <typename T>
    requires std::is_same_v<T, CSSParserTokenStream> ||
    std::is_same_v<T, CSSParserTokenRange> std::shared_ptr<const CSSValue> ConsumeSingleContainerName(
        T&,
        const CSSParserContext&);
std::shared_ptr<const CSSValue> ConsumeContainerName(CSSParserTokenStream&, const CSSParserContext&);

std::shared_ptr<const CSSValue> ConsumeContainerType(CSSParserTokenStream& stream);

std::shared_ptr<const CSSValue> ConsumeShadow(CSSParserTokenStream&, const CSSParserContext&, AllowInsetAndSpread);

std::shared_ptr<const CSSShadowValue> ParseSingleShadow(CSSParserTokenStream&,
                                                        const CSSParserContext&,
                                                        AllowInsetAndSpread);

std::shared_ptr<const CSSValue> ConsumeColumnCount(CSSParserTokenStream&, const CSSParserContext&);
std::shared_ptr<const CSSValue> ConsumeColumnWidth(CSSParserTokenStream&, const CSSParserContext&);
bool ConsumeColumnWidthOrCount(CSSParserTokenStream&,
                               const CSSParserContext&,
                               std::shared_ptr<const CSSValue>&,
                               std::shared_ptr<const CSSValue>&);
std::shared_ptr<const CSSValue> ConsumeGapLength(CSSParserTokenStream&, const CSSParserContext&);

std::shared_ptr<const CSSValue> ConsumeCounter(CSSParserTokenStream&, const CSSParserContext&, int);

std::shared_ptr<const CSSValue> ConsumeFontSize(CSSParserTokenStream&,
                                                const CSSParserContext&,
                                                UnitlessQuirk = UnitlessQuirk::kForbid);

std::shared_ptr<const CSSValue> ConsumeLineHeight(CSSParserTokenStream&, const CSSParserContext&);
std::shared_ptr<const CSSValue> ConsumeMathDepth(CSSParserTokenStream& stream, const CSSParserContext& context);

std::shared_ptr<const CSSValue> ConsumeFontPalette(CSSParserTokenStream&, const CSSParserContext&);
std::shared_ptr<const CSSValueList> ConsumeFontFamily(CSSParserTokenRange&);
std::shared_ptr<const CSSValueList> ConsumeFontFamily(CSSParserTokenStream&);
std::shared_ptr<const CSSValueList> ConsumeNonGenericFamilyNameList(CSSParserTokenStream& stream);
std::shared_ptr<const CSSValue> ConsumeGenericFamily(CSSParserTokenRange&);
std::shared_ptr<const CSSValue> ConsumeGenericFamily(CSSParserTokenStream&);
template <typename T>
    requires std::is_same_v<T, CSSParserTokenStream> ||
    std::is_same_v<T, CSSParserTokenRange> std::shared_ptr<const CSSValue> ConsumeFamilyName(T&);
template <typename T>
    requires std::is_same_v<T, CSSParserTokenStream> ||
    std::is_same_v<T, CSSParserTokenRange> std::string ConcatenateFamilyName(T&);
template <typename T>
    requires std::is_same_v<T, CSSParserTokenStream> ||
    std::is_same_v<T, CSSParserTokenRange> std::shared_ptr<const CSSIdentifierValue> ConsumeFontStretchKeywordOnly(
        T&,
        const CSSParserContext&);
template <typename T>
    requires std::is_same_v<T, CSSParserTokenStream> ||
    std::is_same_v<T, CSSParserTokenRange> std::shared_ptr<const CSSValue> ConsumeFontStretch(T&,
                                                                                              const CSSParserContext&);
template <typename T>
    requires std::is_same_v<T, CSSParserTokenStream> ||
    std::is_same_v<T, CSSParserTokenRange> std::shared_ptr<const CSSValue> ConsumeFontStyle(T&,
                                                                                            const CSSParserContext&);
template <typename T>
    requires std::is_same_v<T, CSSParserTokenStream> ||
    std::is_same_v<T, CSSParserTokenRange> std::shared_ptr<const CSSValue> ConsumeFontWeight(T&,
                                                                                             const CSSParserContext&);
template <typename T>
    requires std::is_same_v<T, CSSParserTokenStream> ||
    std::is_same_v<T, CSSParserTokenRange> std::shared_ptr<const CSSValue> ConsumeFontFeatureSettings(
        T&,
        const CSSParserContext&);
template <typename T>
    requires std::is_same_v<T, CSSParserTokenStream> ||
    std::is_same_v<T, CSSParserTokenRange> std::shared_ptr<const cssvalue::CSSFontFeatureValue> ConsumeFontFeatureTag(
        T&,
        const CSSParserContext&);
template <typename T>
    requires std::is_same_v<T, CSSParserTokenStream> ||
    std::is_same_v<T, CSSParserTokenRange> std::shared_ptr<const CSSIdentifierValue> ConsumeFontVariantCSS21(T&);
template <typename T>
    requires std::is_same_v<T, CSSParserTokenStream> ||
    std::is_same_v<T, CSSParserTokenRange> std::shared_ptr<const CSSIdentifierValue> ConsumeFontFormatIdent(T&);


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

std::shared_ptr<const CSSValue> ConsumeGridLine(CSSParserTokenStream&, const CSSParserContext&);
bool ConsumeGridItemPositionShorthand(bool important,
                                      CSSParserTokenStream&,
                                      const CSSParserContext&,
                                      std::shared_ptr<const CSSValue>& start_value,
                                      std::shared_ptr<const CSSValue>& end_value);

bool ConsumeGridTemplateShorthand(bool important,
                                  CSSParserTokenStream&,
                                  const CSSParserContext&,
                                  std::shared_ptr<const CSSValue>& template_rows,
                                  std::shared_ptr<const CSSValue>& template_columns,
                                  std::shared_ptr<const CSSValue>& template_areas);

std::shared_ptr<const CSSValue> ConsumeGridTrackList(CSSParserTokenStream&, const CSSParserContext&, TrackListType);

std::shared_ptr<const CSSValue> ConsumeGridTemplatesRowsOrColumns(CSSParserTokenStream&, const CSSParserContext&);

// The fragmentation spec says that page-break-(after|before|inside) are to be
// treated as shorthands for their break-(after|before|inside) counterparts.
// We'll do the same for the non-standard properties
// -webkit-column-break-(after|before|inside).
bool ConsumeFromPageBreakBetween(CSSParserTokenStream&, CSSValueID&);
bool ConsumeFromColumnBreakBetween(CSSParserTokenStream&, CSSValueID&);
bool ConsumeFromColumnOrPageBreakInside(CSSParserTokenStream&, CSSValueID&);

bool IsBaselineKeyword(CSSValueID id);

std::shared_ptr<const CSSValue> ConsumeSingleTimelineAxis(CSSParserTokenStream&);
std::shared_ptr<const CSSValue> ConsumeSingleTimelineName(CSSParserTokenStream&, const CSSParserContext&);
std::shared_ptr<const CSSValue> ConsumeSingleTimelineInset(CSSParserTokenStream&, const CSSParserContext&);

std::shared_ptr<const CSSValue> ConsumeTransitionProperty(CSSParserTokenStream&, const CSSParserContext&);

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
bool IsCSSWideKeyword(const std::string&);
bool IsRevertKeyword(const std::string&);
bool IsDefaultKeyword(StringView);
bool IsHashIdentifier(const CSSParserToken&);
bool IsDashedIdent(const CSSParserToken&);

bool ConsumeTranslate3d(CSSParserTokenStream& stream,
                        const CSSParserContext& context,
                        std::shared_ptr<CSSFunctionValue>& transform_value);
std::shared_ptr<const CSSValue> ConsumeTransformValue(CSSParserTokenStream&, const CSSParserContext&);
std::shared_ptr<const CSSValue> ConsumeTransformList(CSSParserTokenStream&, const CSSParserContext&);
std::shared_ptr<const CSSValue> ConsumeFilterFunctionList(CSSParserTokenStream&, const CSSParserContext&);
std::shared_ptr<const CSSValue> ConsumeBackgroundBlendMode(CSSParserTokenStream& stream);

std::shared_ptr<const CSSValue> ParseBackgroundBox(CSSParserTokenStream& stream,
                                                   const CSSParserLocalContext& local_context,
                                                   AllowTextValue alias_allow_text_value);

std::shared_ptr<const CSSValue> ParseBackgroundSize(CSSParserTokenStream& stream,
                                                    const CSSParserContext& context,
                                                    const CSSParserLocalContext& local_context);

template <CSSValueID start, CSSValueID end>
std::shared_ptr<const CSSValue> ConsumePositionLonghand(CSSParserTokenStream& range, const CSSParserContext& context) {
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
std::shared_ptr<const CSSValue> ParseSpacing(CSSParserTokenStream&, const CSSParserContext&);
std::shared_ptr<const CSSValue> ParseMaskSize(CSSParserTokenStream&,
                                              const CSSParserContext&,
                                              const CSSParserLocalContext&);

std::shared_ptr<const CSSValue> ConsumeWebkitBorderImage(CSSParserTokenStream&, const CSSParserContext&);

UnitlessQuirk UnitlessUnlessShorthand(const CSSParserLocalContext&);

std::shared_ptr<cssvalue::CSSURIValue> ConsumeUrl(CSSParserTokenStream& stream, const CSSParserContext& context);

std::shared_ptr<const CSSIdentifierValue> ConsumeShapeBox(CSSParserTokenStream&);
std::shared_ptr<const CSSIdentifierValue> ConsumeVisualBox(CSSParserTokenStream&);
std::shared_ptr<const CSSIdentifierValue> ConsumeCoordBox(CSSParserTokenStream& stream);
std::shared_ptr<const CSSIdentifierValue> ConsumeGeometryBox(CSSParserTokenStream&);

std::shared_ptr<const CSSValue> ConsumeBasicShape(CSSParserTokenStream&,
                                                  const CSSParserContext&,
                                                  AllowPathValue = AllowPathValue::kAllow,
                                                  AllowBasicShapeRectValue = AllowBasicShapeRectValue::kAllow,
                                                  AllowBasicShapeXYWHValue = AllowBasicShapeXYWHValue::kAllow);

std::shared_ptr<const CSSValue> ConsumeIntrinsicSizeLonghand(CSSParserTokenStream& stream,
                                                             const CSSParserContext& context);

std::shared_ptr<const CSSValue> ConsumeFontSizeAdjust(CSSParserTokenStream& stream,
                                                      const CSSParserContext& context);

std::shared_ptr<const CSSValue> ConsumeAxis(CSSParserTokenStream&, const CSSParserContext& context);

std::shared_ptr<const CSSValue> ConsumeTextDecorationLine(CSSParserTokenStream&);
std::shared_ptr<const CSSValue> ConsumeTextBoxEdge(CSSParserTokenStream&);

std::shared_ptr<const CSSValue> ConsumeTransformList(CSSParserTokenStream&,
                               const CSSParserContext&,
                               const CSSParserLocalContext&);

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
