/*
 * Copyright (C) 2013 Google Inc. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 *     * Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above
 * copyright notice, this list of conditions and the following disclaimer
 * in the documentation and/or other materials provided with the
 * distribution.
 *     * Neither the name of Google Inc. nor the names of its
 * contributors may be used to endorse or promote products derived from
 * this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#ifndef WEBF_CORE_CSS_RESOLVER_STYLE_BUILDER_CONVERTER_H_
#define WEBF_CORE_CSS_RESOLVER_STYLE_BUILDER_CONVERTER_H_

#include <memory>
#include "core/css/css_value.h"
#include "core/css/css_value_list.h"
#include "core/style/computed_style_constants.h"
#include "core/style/computed_style_base_constants.h"
#include "foundation/macros.h"
#include "core/platform/geometry/length.h"
#include "core/css/style_color.h"
#include "core/platform/fonts/font_selection_types.h"
#include "core/platform/fonts/font_family.h"
#include "core/platform/fonts/font_description.h"
#include "core/style/style_auto_color.h"
#include "core/style/style_content_alignment_data.h"
#include "core/style/style_self_alignment_data.h"
#include "core/style/style_aspect_ratio.h"
#include "core/platform/geometry/length_size.h"
#include "core/platform/geometry/length_box.h"
#include "core/platform/geometry/length_point.h"
#include "core/style/style_stubs.h"
#include "core/platform/geometry/layout_unit.h"
#include <optional>

namespace webf {

class CSSIdentifierValue;
class CSSPrimitiveValue;
class CSSValue;
class StyleResolverState;
class CSSToLengthConversionData;
class ScopedCSSNameList;
class ShadowList;
class ClipPathOperation;
class StyleIntrinsicLength;
class ComputedGridTemplateAreas;
class StyleInitialLetter;
class BasicShape;
class OffsetPathOperation;
class StyleOffsetRotation;
class QuotesData;
class RotateTransformOperation;
class ScaleTransformOperation;

// Converts CSS values to internal style representations.
// This is used during style building to convert parsed CSS values
// into the types used by ComputedStyle.
class StyleBuilderConverter {
  WEBF_STATIC_ONLY(StyleBuilderConverter);

 public:
  // Basic converters
  static Length ConvertLength(const StyleResolverState&, const CSSValue&);
  static Length ConvertLengthOrAuto(const StyleResolverState&, const CSSValue&);
  static Length ConvertLengthSizing(const StyleResolverState&, const CSSValue&);
  static Length ConvertLengthMaxSizing(const StyleResolverState&, const CSSValue&);
  
  // Numeric converters
  static float ConvertNumber(const StyleResolverState&, const CSSValue&);
  static float ConvertAlpha(const StyleResolverState&, const CSSValue&);
  static int ConvertInteger(const StyleResolverState&, const CSSValue&);
  
  // Color converters
  static StyleColor ConvertStyleColor(const StyleResolverState&, const CSSValue&);
  static Color ConvertColor(const StyleResolverState&, const CSSValue&);
  
  // Enum converters that exist in WebF
  static EDisplay ConvertDisplay(const StyleResolverState&, const CSSValue&);
  static EPosition ConvertPosition(const StyleResolverState&, const CSSValue&);
  static EFloat ConvertFloat(const StyleResolverState&, const CSSValue&);
  static EOverflow ConvertOverflow(const StyleResolverState&, const CSSValue&);
  
  // Font converters
  static FontDescription::FontSelectionValue ConvertFontWeight(const StyleResolverState&, const CSSValue&);
  static float ConvertFontSize(const StyleResolverState&, const CSSValue&);
  
  // Additional font converters
  static FontFamily ConvertFontFamily(StyleResolverState&, const CSSValue&);
  static int ConvertFontFeatureSettings(StyleResolverState&, const CSSValue&);
  static FontDescription::Kerning ConvertFontKerning(StyleResolverState&, const CSSValue&);
  static int ConvertFontOpticalSizing(StyleResolverState&, const CSSValue&);
  static int ConvertFontPalette(StyleResolverState&, const CSSValue&);
  static float ConvertFontSizeAdjust(StyleResolverState&, const CSSValue&);
  static FontDescription::FontSelectionValue ConvertFontStretch(StyleResolverState&, const CSSValue&);
  static FontDescription::FontSelectionValue ConvertFontStyle(StyleResolverState&, const CSSValue&);
  static int ConvertFontVariantAlternates(StyleResolverState&, const CSSValue&);
  static int ConvertFontVariantCaps(StyleResolverState&, const CSSValue&);
  static int ConvertFontVariantEastAsian(StyleResolverState&, const CSSValue&);
  static int ConvertFontVariantEmoji(StyleResolverState&, const CSSValue&);
  static int ConvertFontVariantLigatures(StyleResolverState&, const CSSValue&);
  static int ConvertFontVariantNumeric(StyleResolverState&, const CSSValue&);
  static int ConvertFontVariantPosition(StyleResolverState&, const CSSValue&);
  static int ConvertFontVariationSettings(StyleResolverState&, const CSSValue&);
  
  // Color converters
  static StyleAutoColor ConvertStyleAutoColor(StyleResolverState&, const CSSValue&, bool for_visited_link = false);
  static StyleColor ConvertStyleColor(const StyleResolverState&, const CSSValue&, bool for_visited_link);
  
  // Alignment converters
  static StyleContentAlignmentData ConvertContentAlignmentData(StyleResolverState&, const CSSValue&);
  static StyleSelfAlignmentData ConvertSelfOrDefaultAlignmentData(StyleResolverState&, const CSSValue&);
  
  // Additional converters
  static ScopedCSSNameList* ConvertAnchorName(StyleResolverState&, const CSSValue&);
  static ScopedCSSNameList* ConvertAnchorScope(StyleResolverState&, const CSSValue&);
  static StyleAspectRatio ConvertAspectRatio(StyleResolverState&, const CSSValue&);
  static int ConvertBorderWidth(StyleResolverState&, const CSSValue&);
  static LengthSize ConvertRadius(StyleResolverState&, const CSSValue&);
  static ShadowList* ConvertShadowList(StyleResolverState&, const CSSValue&);
  static LengthBox ConvertClip(StyleResolverState&, const CSSValue&);
  static ClipPathOperation* ConvertClipPath(StyleResolverState&, const CSSValue&);
  static Length ConvertGapLength(StyleResolverState&, const CSSValue&);
  static uint16_t ConvertColumnRuleWidth(StyleResolverState&, const CSSValue&);
  template<typename T>
  static T ConvertComputedLength(StyleResolverState&, const CSSValue&);
  template<typename T>
  static T ConvertFlags(StyleResolverState&, const CSSValue&);
  template<typename T, CSSValueID DefaultValue>
  static T ConvertFlags(StyleResolverState&, const CSSValue&);
  static StyleIntrinsicLength ConvertIntrinsicDimension(StyleResolverState&, const CSSValue&);
  static ScopedCSSNameList* ConvertContainerName(StyleResolverState&, const CSSValue&);
  
  // Grid converters
  static ComputedGridTrackList ConvertGridTrackSizeList(StyleResolverState&, const CSSValue&);
  static GridAutoFlow ConvertGridAutoFlow(StyleResolverState&, const CSSValue&);
  static GridPosition ConvertGridPosition(StyleResolverState&, const CSSValue&);
  static ComputedGridTemplateAreas* ConvertGridTemplateAreas(StyleResolverState&, const CSSValue&);
  static void ConvertGridTrackList(const CSSValue&, ComputedGridTrackList&, StyleResolverState&);
  
  // Additional missing converters
  static RespectImageOrientationEnum ConvertImageOrientation(StyleResolverState&, const CSSValue&);
  static StyleInitialLetter ConvertInitialLetter(StyleResolverState&, const CSSValue&);
  static float ConvertSpacing(StyleResolverState&, const CSSValue&);
  template<int DefaultValue>
  static int ConvertIntegerOrNone(StyleResolverState&, const CSSValue&);
  static Length ConvertQuirkyLength(StyleResolverState&, const CSSValue&);
  static StyleSVGResource* ConvertElementReference(StyleResolverState&, const CSSValue&);
  static LengthPoint ConvertPosition(StyleResolverState&, const CSSValue&);
  static BasicShape* ConvertObjectViewBox(StyleResolverState&, const CSSValue&);
  static OffsetPathOperation* ConvertOffsetPath(StyleResolverState&, const CSSValue&);
  static LengthPoint ConvertOffsetPosition(StyleResolverState&, const CSSValue&);
  static StyleOffsetRotation ConvertOffsetRotate(StyleResolverState&, const CSSValue&);
  static LengthPoint ConvertPositionOrAuto(StyleResolverState&, const CSSValue&);
  static QuotesData* ConvertQuotes(StyleResolverState&, const CSSValue&);
  static LayoutUnit ConvertLayoutUnit(StyleResolverState&, const CSSValue&);
  static std::optional<StyleOverflowClipMargin> ConvertOverflowClipMargin(StyleResolverState&, const CSSValue&);
  static AtomicString ConvertPage(StyleResolverState&, const CSSValue&);
  static float ConvertPerspective(StyleResolverState&, const CSSValue&);
  static float ConvertTimeValue(StyleResolverState&, const CSSValue&);
  static RotateTransformOperation* ConvertRotate(StyleResolverState&, const CSSValue&);
  static ScaleTransformOperation* ConvertScale(StyleResolverState&, const CSSValue&);
  static TabSize ConvertLengthOrTabSpaces(StyleResolverState&, const CSSValue&);
  static TextBoxEdge ConvertTextBoxEdge(StyleResolverState&, const CSSValue&);
  static TextDecorationThickness ConvertTextDecorationThickness(StyleResolverState&, const CSSValue&);
  static TextEmphasisPosition ConvertTextTextEmphasisPosition(StyleResolverState&, const CSSValue&);
  static Length ConvertTextUnderlineOffset(StyleResolverState&, const CSSValue&);
  static TextUnderlinePosition ConvertTextUnderlinePosition(StyleResolverState&, const CSSValue&);
  static ScopedCSSNameList* ConvertTimelineScope(StyleResolverState&, const CSSValue&);
  static TransformOperations ConvertTransformOperations(StyleResolverState&, const CSSValue&);
  static TransformOrigin ConvertTransformOrigin(StyleResolverState&, const CSSValue&);
  
  // Line height converter
  static Length ConvertLineHeight(const StyleResolverState&, const CSSValue&);

 private:
  // Helper methods
  static Length ConvertToLength(const StyleResolverState&,
                               const CSSPrimitiveValue&,
                               const CSSToLengthConversionData&);
  static float ConvertToFloat(const StyleResolverState&,
                             const CSSPrimitiveValue&);
  static int ConvertToInt(const StyleResolverState&,
                         const CSSPrimitiveValue&);
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_RESOLVER_STYLE_BUILDER_CONVERTER_H_