// Copyright 2017 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifndef WEBF_CORE_CSS_PROPERTIES_CSS_PARSING_UTILS_H_
#define WEBF_CORE_CSS_PROPERTIES_CSS_PARSING_UTILS_H_

#include <optional>

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
#include "css_value_keywords.h"
#include "css_property_names.h"
#include "core/style/grid_area.h"
#include "bindings/qjs/cppgc/member.h"

namespace webf {

namespace cssvalue {
class CSSFontFeatureValue;
class CSSURIValue;
}  // namespace cssvalue
class CSSIdentifierValue;
class CSSParserContext;
class CSSParserLocalContext;
class CSSParserTokenStream;
class CSSPropertyValue;
class CSSShadowValue;
class CSSStringValue;
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
enum class TrackListType {
  kGridAuto,
  kGridTemplate,
  kGridTemplateNoRepeat,
  kGridTemplateSubgrid
};
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

CSSPrimitiveValue* ConsumeInteger(
    CSSParserTokenRange&,
    const CSSParserContext&,
    double minimum_value = -std::numeric_limits<double>::max(),
    const bool is_percentage_allowed = true);
CSSPrimitiveValue* ConsumeInteger(
    CSSParserTokenStream&,
    const CSSParserContext&,
    double minimum_value = -std::numeric_limits<double>::max(),
    const bool is_percentage_allowed = true);
template <typename T>
  requires std::is_same_v<T, CSSParserTokenStream> ||
           std::is_same_v<T, CSSParserTokenRange>
CSSPrimitiveValue* ConsumeIntegerOrNumberCalc(
    T&,
    const CSSParserContext&,
    CSSPrimitiveValue::ValueRange = CSSPrimitiveValue::ValueRange::kInteger);
CSSPrimitiveValue* ConsumePositiveInteger(CSSParserTokenStream&,
                                          const CSSParserContext&);
CSSPrimitiveValue* ConsumePositiveInteger(CSSParserTokenRange&,
                                          const CSSParserContext&);
bool ConsumeNumberRaw(CSSParserTokenStream&,
                      const CSSParserContext& context,
                      double& result);
bool ConsumeNumberRaw(CSSParserTokenRange&,
                      const CSSParserContext& context,
                      double& result);
CSSPrimitiveValue* ConsumeNumber(CSSParserTokenRange&,
                                 const CSSParserContext&,
                                 CSSPrimitiveValue::ValueRange);
CSSPrimitiveValue* ConsumeNumber(CSSParserTokenStream&,
                                 const CSSParserContext&,
                                 CSSPrimitiveValue::ValueRange);
CSSPrimitiveValue* ConsumeLength(CSSParserTokenRange&,
                                 const CSSParserContext&,
                                 CSSPrimitiveValue::ValueRange,
                                 UnitlessQuirk = UnitlessQuirk::kForbid);
CSSPrimitiveValue* ConsumeLength(CSSParserTokenStream&,
                                 const CSSParserContext&,
                                 CSSPrimitiveValue::ValueRange,
                                 UnitlessQuirk = UnitlessQuirk::kForbid);
CSSPrimitiveValue* ConsumePercent(CSSParserTokenRange&,
                                  const CSSParserContext&,
                                  CSSPrimitiveValue::ValueRange);
CSSPrimitiveValue* ConsumePercent(CSSParserTokenStream&,
                                  const CSSParserContext&,
                                  CSSPrimitiveValue::ValueRange);

// Any percentages are converted to numbers.
CSSPrimitiveValue* ConsumeNumberOrPercent(CSSParserTokenRange&,
                                          const CSSParserContext&,
                                          CSSPrimitiveValue::ValueRange);
CSSPrimitiveValue* ConsumeNumberOrPercent(
    CSSParserTokenStream& stream,
    const CSSParserContext& context,
    CSSPrimitiveValue::ValueRange value_range);

CSSPrimitiveValue* ConsumeAlphaValue(CSSParserTokenStream&,
                                     const CSSParserContext&);
CSSPrimitiveValue* ConsumeLengthOrPercent(
    CSSParserTokenRange&,
    const CSSParserContext&,
    CSSPrimitiveValue::ValueRange,
    UnitlessQuirk = UnitlessQuirk::kForbid,
    CSSAnchorQueryTypes = kCSSAnchorQueryTypesNone,
    AllowCalcSize = AllowCalcSize::kForbid);
CSSPrimitiveValue* ConsumeLengthOrPercent(
    CSSParserTokenStream&,
    const CSSParserContext&,
    CSSPrimitiveValue::ValueRange,
    UnitlessQuirk = UnitlessQuirk::kForbid,
    CSSAnchorQueryTypes = kCSSAnchorQueryTypesNone,
    AllowCalcSize = AllowCalcSize::kForbid);
CSSPrimitiveValue* ConsumeSVGGeometryPropertyLength(
    CSSParserTokenStream&,
    const CSSParserContext&,
    CSSPrimitiveValue::ValueRange);

 CSSPrimitiveValue* ConsumeAngle(
    CSSParserTokenRange&,
    const CSSParserContext&,
    std::optional<WebFeature> unitless_zero_feature);
 CSSPrimitiveValue* ConsumeAngle(
    CSSParserTokenRange&,
    const CSSParserContext&,
    std::optional<WebFeature> unitless_zero_feature,
    double minimum_value,
    double maximum_value);
 CSSPrimitiveValue* ConsumeAngle(
    CSSParserTokenStream&,
    const CSSParserContext&,
    std::optional<WebFeature> unitless_zero_feature);
 CSSPrimitiveValue* ConsumeAngle(
    CSSParserTokenStream&,
    const CSSParserContext&,
    std::optional<WebFeature> unitless_zero_feature,
    double minimum_value,
    double maximum_value);
template <typename T>
  requires std::is_same_v<T, CSSParserTokenStream> ||
           std::is_same_v<T, CSSParserTokenRange>
CSSPrimitiveValue* ConsumeTime(T&,
                               const CSSParserContext&,
                               CSSPrimitiveValue::ValueRange);
CSSPrimitiveValue* ConsumeResolution(CSSParserTokenRange&,
                                     const CSSParserContext&);
CSSValue* ConsumeRatio(CSSParserTokenStream&, const CSSParserContext&);
CSSIdentifierValue* ConsumeIdent(CSSParserTokenRange&);
CSSIdentifierValue* ConsumeIdent(CSSParserTokenStream&);
CSSIdentifierValue* ConsumeIdentRange(CSSParserTokenRange&,
                                      CSSValueID lower,
                                      CSSValueID upper);
CSSIdentifierValue* ConsumeIdentRange(CSSParserTokenStream&,
                                      CSSValueID lower,
                                      CSSValueID upper);
template <CSSValueID, CSSValueID...>
inline bool IdentMatches(CSSValueID id);
template <CSSValueID... allowedIdents>
CSSIdentifierValue* ConsumeIdent(CSSParserTokenRange&);
template <CSSValueID... allowedIdents>
CSSIdentifierValue* ConsumeIdent(CSSParserTokenStream&);

CSSCustomIdentValue* ConsumeCustomIdent(CSSParserTokenRange&,
                                        const CSSParserContext&);
CSSCustomIdentValue* ConsumeCustomIdent(CSSParserTokenStream&,
                                        const CSSParserContext&);
template <typename T>
  requires std::is_same_v<T, CSSParserTokenStream> ||
           std::is_same_v<T, CSSParserTokenRange>
CSSCustomIdentValue* ConsumeDashedIdent(T&, const CSSParserContext&);
CSSStringValue* ConsumeString(CSSParserTokenRange&);
CSSStringValue* ConsumeString(CSSParserTokenStream&);
StringView ConsumeStringAsStringView(CSSParserTokenRange&);
cssvalue::CSSURIValue* ConsumeUrl(CSSParserTokenRange&,
                                  const CSSParserContext&);
cssvalue::CSSURIValue* ConsumeUrl(CSSParserTokenStream&,
                                  const CSSParserContext&);

// Some properties accept non-standard colors, like rgb values without a
// preceding hash, in quirks mode.
 CSSValue* ConsumeColorMaybeQuirky(CSSParserTokenStream&,
                                              const CSSParserContext&);

// https://drafts.csswg.org/css-color-5/#typedef-color
template <typename T>
  requires std::is_same_v<T, CSSParserTokenStream> ||
           std::is_same_v<T, CSSParserTokenRange>
 CSSValue* ConsumeColor(T&, const CSSParserContext&);

// https://drafts.csswg.org/css-color-5/#absolute-color
 CSSValue* ConsumeAbsoluteColor(CSSParserTokenRange&,
                                           const CSSParserContext&);

CSSValue* ConsumeLineWidth(CSSParserTokenRange&,
                           const CSSParserContext&,
                           UnitlessQuirk);
CSSValue* ConsumeLineWidth(CSSParserTokenStream&,
                           const CSSParserContext&,
                           UnitlessQuirk);

template <typename T>
  requires std::is_same_v<T, CSSParserTokenStream> ||
           std::is_same_v<T, CSSParserTokenRange>
CSSValuePair* ConsumePosition(T&,
                              const CSSParserContext&,
                              UnitlessQuirk,
                              std::optional<WebFeature> three_value_position);
bool ConsumePosition(CSSParserTokenRange&,
                     const CSSParserContext&,
                     UnitlessQuirk,
                     std::optional<WebFeature> three_value_position,
                     CSSValue*& result_x,
                     CSSValue*& result_y);
bool ConsumePosition(CSSParserTokenStream&,
                     const CSSParserContext&,
                     UnitlessQuirk,
                     std::optional<WebFeature> three_value_position,
                     CSSValue*& result_x,
                     CSSValue*& result_y);
template <typename T>
  requires std::is_same_v<T, CSSParserTokenStream> ||
           std::is_same_v<T, CSSParserTokenRange>
bool ConsumeOneOrTwoValuedPosition(T&,
                                   const CSSParserContext&,
                                   UnitlessQuirk,
                                   CSSValue*& result_x,
                                   CSSValue*& result_y);
bool ConsumeBorderShorthand(CSSParserTokenStream&,
                            const CSSParserContext&,
                            const CSSParserLocalContext&,
                            const CSSValue*& result_width,
                            const CSSValue*& result_style,
                            const CSSValue*& result_color);

enum class ConsumeGeneratedImagePolicy { kAllow, kForbid };
enum class ConsumeStringUrlImagePolicy { kAllow, kForbid };
enum class ConsumeImageSetImagePolicy { kAllow, kForbid };

template <typename T>
  requires std::is_same_v<T, CSSParserTokenStream> ||
           std::is_same_v<T, CSSParserTokenRange>
CSSValue* ConsumeImage(
    T&,
    const CSSParserContext&,
    const ConsumeGeneratedImagePolicy = ConsumeGeneratedImagePolicy::kAllow,
    const ConsumeStringUrlImagePolicy = ConsumeStringUrlImagePolicy::kForbid,
    const ConsumeImageSetImagePolicy = ConsumeImageSetImagePolicy::kAllow);
CSSValue* ConsumeImageOrNone(CSSParserTokenStream&, const CSSParserContext&);

CSSValue* ConsumeAxis(CSSParserTokenStream&, const CSSParserContext& context);

// Syntax: none | <length> | auto && <length> | auto && none
// If this returns a CSSIdentifierValue then it is "none"
// Otherwise, this returns a list of 1 or 2 elements for the rest of the syntax
CSSValue* ConsumeIntrinsicSizeLonghand(CSSParserTokenStream&,
                                       const CSSParserContext&);

CSSIdentifierValue* ConsumeShapeBox(CSSParserTokenStream&);
template <typename T>
  requires std::is_same_v<T, CSSParserTokenStream> ||
           std::is_same_v<T, CSSParserTokenRange>
CSSIdentifierValue* ConsumeVisualBox(T&);

CSSIdentifierValue* ConsumeCoordBox(CSSParserTokenStream&);

CSSIdentifierValue* ConsumeGeometryBox(CSSParserTokenRange&);
CSSIdentifierValue* ConsumeGeometryBox(CSSParserTokenStream&);

enum class IsImplicitProperty { kNotImplicit, kImplicit };

void AddProperty(CSSPropertyID resolved_property,
                 CSSPropertyID current_shorthand,
                 const CSSValue&,
                 bool important,
                 IsImplicitProperty,
                 HeapVector<CSSPropertyValue, 64>& properties);

void CountKeywordOnlyPropertyUsage(CSSPropertyID,
                                   const CSSParserContext&,
                                   CSSValueID);

void WarnInvalidKeywordPropertyUsage(CSSPropertyID,
                                     const CSSParserContext&,
                                     CSSValueID);

const CSSValue* ParseLonghand(CSSPropertyID unresolved_property,
                              CSSPropertyID current_shorthand,
                              const CSSParserContext&,
                              CSSParserTokenStream&);

bool ConsumeShorthandVia2Longhands(
    const StylePropertyShorthand&,
    bool important,
    const CSSParserContext&,
    CSSParserTokenStream&,
    HeapVector<CSSPropertyValue, 64>& properties);

bool ConsumeShorthandVia4Longhands(
    const StylePropertyShorthand&,
    bool important,
    const CSSParserContext&,
    CSSParserTokenStream&,
    HeapVector<CSSPropertyValue, 64>& properties);

bool ConsumeShorthandGreedilyViaLonghands(
    const StylePropertyShorthand&,
    bool important,
    const CSSParserContext&,
    CSSParserTokenStream&,
    HeapVector<CSSPropertyValue, 64>& properties,
    bool use_initial_value_function = false);

void AddExpandedPropertyForValue(CSSPropertyID prop_id,
                                 const CSSValue&,
                                 bool,
                                 HeapVector<CSSPropertyValue, 64>& properties);

template <typename T>
  requires std::is_same_v<T, CSSParserTokenStream> ||
           std::is_same_v<T, CSSParserTokenRange>
CSSValue* ConsumeTransformValue(T&, const CSSParserContext&);
template <typename T>
  requires std::is_same_v<T, CSSParserTokenStream> ||
           std::is_same_v<T, CSSParserTokenRange>
CSSValue* ConsumeTransformList(T&, const CSSParserContext&);
CSSValue* ConsumeFilterFunctionList(CSSParserTokenStream&,
                                    const CSSParserContext&);

bool IsBaselineKeyword(CSSValueID id);
bool IsSelfPositionKeyword(CSSValueID);
bool IsSelfPositionOrLeftOrRightKeyword(CSSValueID);
bool IsContentPositionKeyword(CSSValueID);
bool IsContentPositionOrLeftOrRightKeyword(CSSValueID);
 bool IsCSSWideKeyword(CSSValueID);
 bool IsCSSWideKeyword(StringView);
bool IsRevertKeyword(StringView);
bool IsDefaultKeyword(StringView);
bool IsHashIdentifier(const CSSParserToken&);
 bool IsDashedIdent(const CSSParserToken&);

CSSValue* ConsumeCSSWideKeyword(CSSParserTokenRange&);
CSSValue* ConsumeCSSWideKeyword(CSSParserTokenStream&);

// This function returns false for CSS-wide keywords, 'default', and any
// template parameters provided.
//
// https://drafts.csswg.org/css-values-4/#identifier-value
template <CSSValueID, CSSValueID...>
bool IsCustomIdent(CSSValueID);

// https://drafts.csswg.org/scroll-animations-1/#typedef-timeline-name
bool IsTimelineName(const CSSParserToken&);

CSSValue* ConsumeSelfPositionOverflowPosition(CSSParserTokenStream&,
                                              IsPositionKeyword);
CSSValue* ConsumeSimplifiedDefaultPosition(CSSParserTokenRange&,
                                           IsPositionKeyword);
CSSValue* ConsumeSimplifiedSelfPosition(CSSParserTokenRange&,
                                        IsPositionKeyword);
CSSValue* ConsumeContentDistributionOverflowPosition(CSSParserTokenStream&,
                                                     IsPositionKeyword);
CSSValue* ConsumeSimplifiedContentPosition(CSSParserTokenRange&,
                                           IsPositionKeyword);

CSSValue* ConsumeAnimationIterationCount(CSSParserTokenStream&,
                                         const CSSParserContext&);
CSSValue* ConsumeAnimationName(CSSParserTokenStream&,
                               const CSSParserContext&,
                               bool allow_quoted_name);
CSSValue* ConsumeScrollFunction(CSSParserTokenRange&, const CSSParserContext&);
CSSValue* ConsumeViewFunction(CSSParserTokenRange&, const CSSParserContext&);
CSSValue* ConsumeAnimationTimeline(CSSParserTokenStream&,
                                   const CSSParserContext&);
CSSValue* ConsumeAnimationTimingFunction(CSSParserTokenStream&,
                                         const CSSParserContext&);
CSSValue* ConsumeAnimationDuration(CSSParserTokenStream&,
                                   const CSSParserContext&);
// https://drafts.csswg.org/scroll-animations-1/#typedef-timeline-range-name
CSSValue* ConsumeTimelineRangeName(CSSParserTokenStream&);
CSSValue* ConsumeTimelineRangeName(CSSParserTokenRange&);
template <typename T>
  requires std::is_same_v<T, CSSParserTokenStream> ||
           std::is_same_v<T, CSSParserTokenRange>
CSSValue* ConsumeTimelineRangeNameAndPercent(T&, const CSSParserContext&);
CSSValue* ConsumeAnimationDelay(CSSParserTokenStream&, const CSSParserContext&);
CSSValue* ConsumeAnimationRange(CSSParserTokenStream&,
                                const CSSParserContext&,
                                double default_offset_percent);

bool ConsumeAnimationShorthand(
    const StylePropertyShorthand&,
    HeapVector<Member<CSSValueList>, kMaxNumAnimationLonghands>&,
    ConsumeAnimationItemValue,
    IsResetOnlyFunction,
    CSSParserTokenStream&,
    const CSSParserContext&,
    bool use_legacy_parsing);

CSSValue* ConsumeSingleTimelineAxis(CSSParserTokenStream&);
CSSValue* ConsumeSingleTimelineName(CSSParserTokenStream&,
                                    const CSSParserContext&);
template <typename T>
  requires std::is_same_v<T, CSSParserTokenStream> ||
           std::is_same_v<T, CSSParserTokenRange>
CSSValue* ConsumeSingleTimelineInset(T&, const CSSParserContext&);

void AddBackgroundValue(CSSValue*& list, const CSSValue*);
CSSValue* ConsumeBackgroundAttachment(CSSParserTokenStream&);
CSSValue* ConsumeBackgroundBlendMode(CSSParserTokenStream&);
CSSValue* ConsumeBackgroundBox(CSSParserTokenStream&);
CSSValue* ConsumeBackgroundBoxOrText(CSSParserTokenStream&);
CSSValue* ConsumeMaskComposite(CSSParserTokenStream&);
CSSValue* ConsumePrefixedMaskComposite(CSSParserTokenStream&);
CSSValue* ConsumeMaskMode(CSSParserTokenStream&);
template <typename T>
  requires std::is_same_v<T, CSSParserTokenStream> ||
           std::is_same_v<T, CSSParserTokenRange>
bool ConsumeBackgroundPosition(T&,
                               const CSSParserContext&,
                               UnitlessQuirk,
                               std::optional<WebFeature> three_value_position,
                               const CSSValue*& result_x,
                               const CSSValue*& result_y);
CSSValue* ConsumePrefixedBackgroundBox(CSSParserTokenStream&, AllowTextValue);
CSSValue* ParseBackgroundBox(CSSParserTokenStream&,
                             const CSSParserLocalContext&,
                             AllowTextValue alias_allow_text_value);
CSSValue* ParseBackgroundSize(CSSParserTokenStream&,
                              const CSSParserContext&,
                              const CSSParserLocalContext&,
                              std::optional<WebFeature> negative_size);
CSSValue* ParseMaskSize(CSSParserTokenStream&,
                        const CSSParserContext&,
                        const CSSParserLocalContext&,
                        std::optional<WebFeature> negative_size);
bool ParseBackgroundOrMask(bool,
                           CSSParserTokenStream&,
                           const CSSParserContext&,
                           const CSSParserLocalContext&,
                           HeapVector<CSSPropertyValue, 64>&);

CSSValue* ConsumeCoordBoxOrNoClip(CSSParserTokenStream&);

template <typename T>
  requires std::is_same_v<T, CSSParserTokenStream> ||
           std::is_same_v<T, CSSParserTokenRange>
CSSRepeatStyleValue* ConsumeRepeatStyleValue(T& range);
CSSValueList* ParseRepeatStyle(CSSParserTokenStream& stream);

CSSValue* ConsumeWebkitBorderImage(CSSParserTokenStream&,
                                   const CSSParserContext&);
bool ConsumeBorderImageComponents(CSSParserTokenStream&,
                                  const CSSParserContext&,
                                  CSSValue*& source,
                                  CSSValue*& slice,
                                  CSSValue*& width,
                                  CSSValue*& outset,
                                  CSSValue*& repeat,
                                  DefaultFill);
CSSValue* ConsumeBorderImageRepeat(CSSParserTokenStream&);
CSSValue* ConsumeBorderImageSlice(CSSParserTokenStream&,
                                  const CSSParserContext&,
                                  DefaultFill);
CSSValue* ConsumeBorderImageWidth(CSSParserTokenStream&,
                                  const CSSParserContext&);
CSSValue* ConsumeBorderImageOutset(CSSParserTokenStream&,
                                   const CSSParserContext&);

CSSValue* ParseBorderRadiusCorner(CSSParserTokenStream&,
                                  const CSSParserContext&);
CSSValue* ParseBorderWidthSide(CSSParserTokenStream&,
                               const CSSParserContext&,
                               const CSSParserLocalContext&);
const CSSValue* ParseBorderStyleSide(CSSParserTokenStream&,
                                     const CSSParserContext&);

CSSValue* ConsumeShadow(CSSParserTokenStream&,
                        const CSSParserContext&,
                        AllowInsetAndSpread);
template <typename T>
  requires std::is_same_v<T, CSSParserTokenStream> ||
           std::is_same_v<T, CSSParserTokenRange>
CSSShadowValue* ParseSingleShadow(T&,
                                  const CSSParserContext&,
                                  AllowInsetAndSpread);

CSSValue* ConsumeColumnCount(CSSParserTokenStream&, const CSSParserContext&);
CSSValue* ConsumeColumnWidth(CSSParserTokenStream&, const CSSParserContext&);
bool ConsumeColumnWidthOrCount(CSSParserTokenStream&,
                               const CSSParserContext&,
                               CSSValue*&,
                               CSSValue*&);
CSSValue* ConsumeGapLength(CSSParserTokenStream&, const CSSParserContext&);

CSSValue* ConsumeCounter(CSSParserTokenStream&, const CSSParserContext&, int);

CSSValue* ConsumeFontSize(CSSParserTokenStream&,
                          const CSSParserContext&,
                          UnitlessQuirk = UnitlessQuirk::kForbid);

CSSValue* ConsumeLineHeight(CSSParserTokenStream&, const CSSParserContext&);

CSSValue* ConsumeMathDepth(CSSParserTokenStream& stream,
                           const CSSParserContext& context);

template <typename T>
  requires std::is_same_v<T, CSSParserTokenStream> ||
           std::is_same_v<T, CSSParserTokenRange>
CSSValue* ConsumeFontPalette(T&, const CSSParserContext&);
template <typename T>
  requires std::is_same_v<T, CSSParserTokenStream> ||
           std::is_same_v<T, CSSParserTokenRange>
CSSValue* ConsumePaletteMixFunction(T&, const CSSParserContext&);
CSSValueList* ConsumeFontFamily(CSSParserTokenRange&);
CSSValueList* ConsumeFontFamily(CSSParserTokenStream&);
CSSValueList* ConsumeNonGenericFamilyNameList(CSSParserTokenRange& range);
CSSValue* ConsumeGenericFamily(CSSParserTokenRange&);
CSSValue* ConsumeGenericFamily(CSSParserTokenStream&);
template <typename T>
  requires std::is_same_v<T, CSSParserTokenStream> ||
           std::is_same_v<T, CSSParserTokenRange>
CSSValue* ConsumeFamilyName(T&);
template <typename T>
  requires std::is_same_v<T, CSSParserTokenStream> ||
           std::is_same_v<T, CSSParserTokenRange>
String ConcatenateFamilyName(T&);
template <typename T>
  requires std::is_same_v<T, CSSParserTokenStream> ||
           std::is_same_v<T, CSSParserTokenRange>
CSSIdentifierValue* ConsumeFontStretchKeywordOnly(T&, const CSSParserContext&);
template <typename T>
  requires std::is_same_v<T, CSSParserTokenStream> ||
           std::is_same_v<T, CSSParserTokenRange>
CSSValue* ConsumeFontStretch(T&, const CSSParserContext&);
template <typename T>
  requires std::is_same_v<T, CSSParserTokenStream> ||
           std::is_same_v<T, CSSParserTokenRange>
CSSValue* ConsumeFontStyle(T&, const CSSParserContext&);
template <typename T>
  requires std::is_same_v<T, CSSParserTokenStream> ||
           std::is_same_v<T, CSSParserTokenRange>
CSSValue* ConsumeFontWeight(T&, const CSSParserContext&);
template <typename T>
  requires std::is_same_v<T, CSSParserTokenStream> ||
           std::is_same_v<T, CSSParserTokenRange>
CSSValue* ConsumeFontFeatureSettings(T&, const CSSParserContext&);
template <typename T>
  requires std::is_same_v<T, CSSParserTokenStream> ||
           std::is_same_v<T, CSSParserTokenRange>
cssvalue::CSSFontFeatureValue* ConsumeFontFeatureTag(T&,
                                                     const CSSParserContext&);
template <typename T>
  requires std::is_same_v<T, CSSParserTokenStream> ||
           std::is_same_v<T, CSSParserTokenRange>
CSSIdentifierValue* ConsumeFontVariantCSS21(T&);
template <typename T>
  requires std::is_same_v<T, CSSParserTokenStream> ||
           std::is_same_v<T, CSSParserTokenRange>
CSSIdentifierValue* ConsumeFontTechIdent(T&);
template <typename T>
  requires std::is_same_v<T, CSSParserTokenStream> ||
           std::is_same_v<T, CSSParserTokenRange>
CSSIdentifierValue* ConsumeFontFormatIdent(T&);
CSSValueID FontFormatToId(String);
bool IsSupportedKeywordTech(CSSValueID keyword);
bool IsSupportedKeywordFormat(CSSValueID keyword);

CSSValue* ConsumeGridLine(CSSParserTokenStream&, const CSSParserContext&);
template <typename T>
  requires std::is_same_v<T, CSSParserTokenStream> ||
           std::is_same_v<T, CSSParserTokenRange>
CSSValue* ConsumeGridTrackList(T&, const CSSParserContext&, TrackListType);
bool ParseGridTemplateAreasRow(const WTF::String& grid_row_names,
                               NamedGridAreaMap&,
                               const wtf_size_t row_count,
                               wtf_size_t& column_count);
template <typename T>
  requires std::is_same_v<T, CSSParserTokenStream> ||
           std::is_same_v<T, CSSParserTokenRange>
CSSValue* ConsumeGridTemplatesRowsOrColumns(T&, const CSSParserContext&);
bool ConsumeGridItemPositionShorthand(bool important,
                                      CSSParserTokenStream&,
                                      const CSSParserContext&,
                                      CSSValue*& start_value,
                                      CSSValue*& end_value);
bool ConsumeGridTemplateShorthand(bool important,
                                  CSSParserTokenStream&,
                                  const CSSParserContext&,
                                  const CSSValue*& template_rows,
                                  const CSSValue*& template_columns,
                                  const CSSValue*& template_areas);

CSSValue* ConsumeHyphenateLimitChars(CSSParserTokenStream&,
                                     const CSSParserContext&);

// The fragmentation spec says that page-break-(after|before|inside) are to be
// treated as shorthands for their break-(after|before|inside) counterparts.
// We'll do the same for the non-standard properties
// -webkit-column-break-(after|before|inside).
bool ConsumeFromPageBreakBetween(CSSParserTokenStream&, CSSValueID&);
bool ConsumeFromColumnBreakBetween(CSSParserTokenStream&, CSSValueID&);
bool ConsumeFromColumnOrPageBreakInside(CSSParserTokenStream&, CSSValueID&);

bool ValidWidthOrHeightKeyword(CSSValueID id, const CSSParserContext& context);

CSSValue* ConsumeMaxWidthOrHeight(CSSParserTokenStream&,
                                  const CSSParserContext&,
                                  UnitlessQuirk = UnitlessQuirk::kForbid);
template <typename T>
  requires std::is_same_v<T, CSSParserTokenStream> ||
           std::is_same_v<T, CSSParserTokenRange>
CSSValue* ConsumeWidthOrHeight(T&,
                               const CSSParserContext&,
                               UnitlessQuirk = UnitlessQuirk::kForbid);

CSSValue* ConsumeMarginOrOffset(CSSParserTokenStream&,
                                const CSSParserContext&,
                                UnitlessQuirk,
                                CSSAnchorQueryTypes = kCSSAnchorQueryTypesNone);
CSSValue* ConsumeScrollPadding(CSSParserTokenStream&, const CSSParserContext&);
CSSValue* ConsumeScrollStart(CSSParserTokenStream&, const CSSParserContext&);
CSSValue* ConsumeScrollStartTarget(CSSParserTokenStream&);
CSSValue* ConsumeOffsetPath(CSSParserTokenStream&, const CSSParserContext&);
CSSValue* ConsumePathOrNone(CSSParserTokenStream&);
CSSValue* ConsumeOffsetRotate(CSSParserTokenStream&, const CSSParserContext&);
CSSValue* ConsumeInitialLetter(CSSParserTokenStream&, const CSSParserContext&);

CSSValue* ConsumeBasicShape(
    CSSParserTokenRange&,
    const CSSParserContext&,
    AllowPathValue = AllowPathValue::kAllow,
    AllowBasicShapeRectValue = AllowBasicShapeRectValue::kAllow,
    AllowBasicShapeXYWHValue = AllowBasicShapeXYWHValue::kAllow);
CSSValue* ConsumeBasicShape(
    CSSParserTokenStream&,
    const CSSParserContext&,
    AllowPathValue = AllowPathValue::kAllow,
    AllowBasicShapeRectValue = AllowBasicShapeRectValue::kAllow,
    AllowBasicShapeXYWHValue = AllowBasicShapeXYWHValue::kAllow);
template <typename T>
  requires std::is_same_v<T, CSSParserTokenStream> ||
           std::is_same_v<T, CSSParserTokenRange>
bool ConsumeRadii(CSSValue* horizontal_radii[4],
                  CSSValue* vertical_radii[4],
                  T&,
                  const CSSParserContext&,
                  bool use_legacy_parsing);

CSSValue* ConsumeTextDecorationLine(CSSParserTokenStream&);
CSSValue* ConsumeTextBoxEdge(CSSParserTokenStream&);

// Consume the `autospace` production.
// https://drafts.csswg.org/css-text-4/#typedef-autospace
CSSValue* ConsumeAutospace(CSSParserTokenStream&);
// Consume the `spacing-trim` production.
// https://drafts.csswg.org/css-text-4/#typedef-spacing-trim
CSSValue* ConsumeSpacingTrim(CSSParserTokenStream&);

template <typename T>
  requires std::is_same_v<T, CSSParserTokenStream> ||
           std::is_same_v<T, CSSParserTokenRange>
CSSValue* ConsumeTransformValue(T&,
                                const CSSParserContext&,
                                bool use_legacy_parsing);
template <typename T>
  requires std::is_same_v<T, CSSParserTokenStream> ||
           std::is_same_v<T, CSSParserTokenRange>
CSSValue* ConsumeTransformList(T&,
                               const CSSParserContext&,
                               const CSSParserLocalContext&);
CSSValue* ConsumeTransitionProperty(CSSParserTokenStream&,
                                    const CSSParserContext&);
bool IsValidPropertyList(const CSSValueList&);
bool IsValidTransitionBehavior(const CSSValueID&);
bool IsValidTransitionBehaviorList(const CSSValueList&);

CSSValue* ConsumeBorderColorSide(CSSParserTokenStream&,
                                 const CSSParserContext&,
                                 const CSSParserLocalContext&);
CSSValue* ConsumeBorderWidth(CSSParserTokenStream&,
                             const CSSParserContext&,
                             UnitlessQuirk);
CSSValue* ConsumeSVGPaint(CSSParserTokenStream&, const CSSParserContext&);
CSSValue* ParseSpacing(CSSParserTokenStream&, const CSSParserContext&);

template <typename T>
  requires std::is_same_v<T, CSSParserTokenStream> ||
           std::is_same_v<T, CSSParserTokenRange>
CSSValue* ConsumeSingleContainerName(T&, const CSSParserContext&);
CSSValue* ConsumeContainerName(CSSParserTokenStream&, const CSSParserContext&);
CSSValue* ConsumeContainerType(CSSParserTokenStream&);

UnitlessQuirk UnitlessUnlessShorthand(const CSSParserLocalContext&);

// https://drafts.csswg.org/css-counter-styles-3/#typedef-counter-style-name
template <typename T>
  requires std::is_same_v<T, CSSParserTokenStream> ||
           std::is_same_v<T, CSSParserTokenRange>
CSSCustomIdentValue* ConsumeCounterStyleName(T&, const CSSParserContext&);
AtomicString ConsumeCounterStyleNameInPrelude(CSSParserTokenRange&,
                                              const CSSParserContext&);

CSSValue* ConsumeFontSizeAdjust(CSSParserTokenStream&, const CSSParserContext&);

// When parsing a counter style name, it should be ASCII lowercased if it's an
// ASCII case-insensitive match of any predefined counter style name.
bool ShouldLowerCaseCounterStyleNameOnParse(const AtomicString&,
                                            const CSSParserContext&);

// https://drafts.csswg.org/css-anchor-position-1/#typedef-inset-area
template <class T>
  requires std::is_same_v<T, CSSParserTokenStream> ||
           std::is_same_v<T, CSSParserTokenRange>
const CSSValue* ConsumeInsetArea(T&);

// inset-area can take one or two keywords. If the second is omitted, either the
// first is repeated, or the second is span-all. This method returns true if the
// omitted value should be the first one repeated.
bool IsRepeatedInsetAreaValue(CSSValueID value_id);

// Template implementations are at the bottom of the file for readability.

template <typename... emptyBaseCase>
inline bool IdentMatches(CSSValueID id) {
  return false;
}
template <CSSValueID head, CSSValueID... tail>
inline bool IdentMatches(CSSValueID id) {
  return id == head || IdentMatches<tail...>(id);
}

template <typename...>
bool IsCustomIdent(CSSValueID id) {
  return !IsCSSWideKeyword(id) && id != CSSValueID::kDefault;
}

template <CSSValueID head, CSSValueID... tail>
bool IsCustomIdent(CSSValueID id) {
  return id != head && IsCustomIdent<tail...>(id);
}

template <CSSValueID... names>
CSSIdentifierValue* ConsumeIdent(CSSParserTokenRange& range) {
  if (range.Peek().GetType() != kIdentToken ||
      !IdentMatches<names...>(range.Peek().Id())) {
    return nullptr;
  }
  return CSSIdentifierValue::Create(range.ConsumeIncludingWhitespace().Id());
}

template <CSSValueID... names>
CSSIdentifierValue* ConsumeIdent(CSSParserTokenStream& stream) {
  if (stream.Peek().GetType() != kIdentToken ||
      !IdentMatches<names...>(stream.Peek().Id())) {
    return nullptr;
  }
  return CSSIdentifierValue::Create(stream.ConsumeIncludingWhitespace().Id());
}

// ConsumeCommaSeparatedList and ConsumeSpaceSeparatedList take a callback
// function to call on each item in the list, followed by the arguments to pass
// to this callback.  The first argument to the callback must be the
// CSSParserTokenRange
template <typename Func, typename... Args>
CSSValueList* ConsumeCommaSeparatedList(Func callback,
                                        CSSParserTokenRange& range,
                                        Args&&... args) {
  CSSValueList* list = CSSValueList::CreateCommaSeparated();
  do {
    CSSValue* value = callback(range, std::forward<Args>(args)...);
    if (!value) {
      return nullptr;
    }
    list->Append(*value);
  } while (ConsumeCommaIncludingWhitespace(range));
  assert(list->length());
  return list;
}

template <typename Func, typename... Args>
CSSValueList* ConsumeCommaSeparatedList(Func callback,
                                        CSSParserTokenStream& stream,
                                        Args&&... args) {
  CSSValueList* list = CSSValueList::CreateCommaSeparated();
  do {
    CSSValue* value = callback(stream, std::forward<Args>(args)...);
    if (!value) {
      return nullptr;
    }
    list->Append(*value);
  } while (ConsumeCommaIncludingWhitespace(stream));
  assert(list->length());
  return list;
}

template <typename Func, typename... Args>
CSSValueList* ConsumeSpaceSeparatedList(Func callback,
                                        CSSParserTokenStream& stream,
                                        Args&&... args) {
  CSSValueList* list = CSSValueList::CreateSpaceSeparated();
  do {
    CSSValue* value = callback(stream, std::forward<Args>(args)...);
    if (!value) {
      return list->length() > 0 ? list : nullptr;
    }
    list->Append(*value);
  } while (!stream.AtEnd());
  assert(list->length());
  return list;
}

template <typename T, typename Func, typename... Args>
  requires std::is_same_v<T, CSSParserTokenStream> ||
           std::is_same_v<T, CSSParserTokenRange>
CSSValueList* ConsumeCommaSeparatedList(Func callback,
                                        T& stream,
                                        Args&&... args) {
  CSSValueList* list = CSSValueList::CreateCommaSeparated().get();
  do {
    CSSValue* value = callback(stream, std::forward<Args>(args)...);
    if (!value) {
      return nullptr;
    }
    list->Append(*value);
  } while (ConsumeCommaIncludingWhitespace(stream));
  assert(list->length());
  return list;
}

template <CSSValueID start, CSSValueID end, typename T>
  requires std::is_same_v<T, CSSParserTokenStream> ||
           std::is_same_v<T, CSSParserTokenRange>
CSSValue* ConsumePositionLonghand(T& range, const CSSParserContext& context) {
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
    return CSSNumericLiteralValue::Create(
        percent, CSSPrimitiveValue::UnitType::kPercentage);
  }
  return ConsumeLengthOrPercent(range, context,
                                CSSPrimitiveValue::ValueRange::kAll);
}

inline bool AtIdent(const CSSParserToken& token, const char* ident) {
  return token.GetType() == kIdentToken &&
         EqualIgnoringASCIICase(token.Value(), ident);
}

template <typename T>
bool ConsumeIfIdent(T& range_or_stream, const char* ident) {
  if (!AtIdent(range_or_stream.Peek(), ident)) {
    return false;
  }
  range_or_stream.ConsumeIncludingWhitespace();
  return true;
}

inline bool AtDelimiter(const CSSParserToken& token, UChar c) {
  return token.GetType() == kDelimiterToken && token.Delimiter() == c;
}

template <typename T>
bool ConsumeIfDelimiter(T& range_or_stream, UChar c) {
  if (!AtDelimiter(range_or_stream.Peek(), c)) {
    return false;
  }
  range_or_stream.ConsumeIncludingWhitespace();
  return true;
}

CSSValue* ConsumeSinglePositionTryOption(CSSParserTokenStream&,
                                                     const CSSParserContext&);
CSSValue* ConsumePositionTryOptions(CSSParserTokenStream&,
                                    const CSSParserContext&);

// If the stream starts with “!important”, consumes it and returns true.
// If the stream is at EOF, returns false.
// If parse error, also returns false, but the stream position is unchanged
// and thus guaranteed to not be at EOF.
//
// The typical usage pattern for this is: Call the function,
// then immediately check stream.AtEnd(). If stream.AtEnd(), then
// the parse succeeded and you can use the return value for whether
// the property is important or not. However, if !stream.AtEnd(),
// there has been a parse error (e.g. random junk that was not
// !important, or !important but with more tokens afterwards).
//
// If allow_important_annotation is false, just consumes whitespace
// and returns false. The same pattern as above holds.
template <typename T>
  requires std::is_same_v<T, CSSParserTokenStream> ||
           std::is_same_v<T, CSSParserTokenRange>
bool MaybeConsumeImportant(T& stream, bool allow_important_annotation);

}  // namespace css_parsing_utils
}  // namespace webf

#endif  // WEBF_CORE_CSS_PROPERTIES_CSS_PARSING_UTILS_H_