/*
 * Copyright (C) 2011 Andreas Kling (kling@webkit.org)
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY APPLE COMPUTER, INC. ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL APPLE COMPUTER, INC. OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "css_value.h"
#include "core/css/css_alternate_value.h"
#include "core/css/css_appearance_auto_base_select_value_pair.h"
#include "core/css/css_axis_value.h"
#include "core/css/css_basic_shape_value.h"
#include "core/css/css_border_image_slice_value.h"
#include "core/css/css_bracketed_value_list.h"
#include "core/css/css_color.h"
#include "core/css/css_content_distribution_value.h"
#include "core/css/css_crossfade_value.h"
#include "core/css/css_font_face_src_value.h"
#include "core/css/css_font_family_value.h"
#include "core/css/css_font_feature_value.h"
#include "core/css/css_font_style_range_value.h"
#include "core/css/css_font_variation_value.h"
#include "core/css/css_gradient_value.h"
#include "core/css/css_grid_auto_repeat_value.h"
#include "core/css/css_grid_integer_repeat_value.h"
#include "core/css/css_grid_template_areas_value.h"
#include "core/css/css_image_set_option_value.h"
#include "core/css/css_image_set_type_value.h"
#include "core/css/css_image_set_value.h"
#include "core/css/css_image_value.h"
#include "core/css/css_inherit_value.h"
#include "core/css/css_initial_color_value.h"
#include "core/css/css_initial_value.h"
#include "core/css/css_invalid_variable_value.h"
#include "core/css/css_keyframe_shorthand_value.h"
#include "core/css/css_light_dart_value_pair.h"
#include "core/css/css_math_function_value.h"
#include "core/css/css_numeric_literal_value.h"
#include "core/css/css_pending_substitution_value.h"
#include "core/css/css_pending_system_font_value.h"
#include "core/css/css_primitive_value.h"
#include "core/css/css_ratio_value.h"
#include "core/css/css_ray_value.h"
#include "core/css/css_reflect_value.h"
#include "core/css/css_repeat_style_value.h"
#include "core/css/css_revert_layer_value.h"
#include "core/css/css_revert_value.h"
#include "core/css/css_scroll_value.h"
#include "core/css/css_shadow_value.h"
#include "core/css/css_raw_value.h"
#include "core/css/css_string_value.h"
#include "core/css/css_timing_function_value.h"
#include "core/css/css_unparsed_declaration_value.h"
#include "core/css/css_unset_value.h"
#include "core/css/css_uri_value.h"
#include "core/css/css_value_list.h"
#include "core/css/css_view_value.h"
#include "core/css/parser/css_parser_idioms.h"
#include "core/platform/geometry/length.h"
#include "css_identifier_value.h"
#include "foundation/string/character_visitor.h"

namespace webf {

std::shared_ptr<const CSSValue> CSSValue::Create(const webf::Length& value, float zoom) {
  switch (value.GetType()) {
    case Length::kAuto:
    case Length::kMinContent:
    case Length::kMaxContent:
    case Length::kFillAvailable:
    case Length::kFitContent:
    case Length::kContent:
    case Length::kExtendToZoom:
    case Length::kNormal:
      return CSSIdentifierValue::Create(value);
    case Length::kPercent:
    case Length::kFixed:
    case Length::kCalculated:
    case Length::kFlex:
      return CSSPrimitiveValue::CreateFromLength(value, zoom);
    case Length::kDeviceWidth:
    case Length::kDeviceHeight:
    case Length::kMinIntrinsic:
    case Length::kNone:
      assert(false);
      break;
  }
  return nullptr;
}

String CSSValue::CssText() const {
  switch (GetClassType()) {
    case kAxisClass:
      return To<cssvalue::CSSAxisValue>(this)->CustomCSSText();
    case kBasicShapeInsetClass:
      return To<cssvalue::CSSBasicShapeInsetValue>(this)->CustomCSSText();
    case kBasicShapeRectClass:
      return To<cssvalue::CSSBasicShapeRectValue>(this)->CustomCSSText();
    case kBasicShapeXYWHClass:
      return To<cssvalue::CSSBasicShapeXYWHValue>(this)->CustomCSSText();
    case kBorderImageSliceClass:
      return To<cssvalue::CSSBorderImageSliceValue>(this)->CustomCSSText();
    case kColorClass:
      return To<cssvalue::CSSColor>(this)->CustomCSSText();
    case kFontFaceSrcClass:
      return To<CSSFontFaceSrcValue>(this)->CustomCSSText();
    case kFontFamilyClass:
      return To<CSSFontFamilyValue>(this)->CustomCSSText();
    case kFontFeatureClass:
      return To<cssvalue::CSSFontFeatureValue>(this)->CustomCSSText();
    case kFontStyleRangeClass:
      return To<cssvalue::CSSFontStyleRangeValue>(this)->CustomCSSText();
    case kFontVariationClass:
      return To<cssvalue::CSSFontVariationValue>(this)->CustomCSSText();
    case kAlternateClass:
      return To<cssvalue::CSSAlternateValue>(this)->CustomCSSText();
    case kFunctionClass:
      return To<CSSFunctionValue>(this)->CustomCSSText();
    case kLinearGradientClass:
      return To<cssvalue::CSSLinearGradientValue>(this)->CustomCSSText();
    case kRadialGradientClass:
      return To<cssvalue::CSSRadialGradientValue>(this)->CustomCSSText();
    case kConicGradientClass:
      return To<cssvalue::CSSConicGradientValue>(this)->CustomCSSText();
    case kConstantGradientClass:
      return To<cssvalue::CSSConstantGradientValue>(this)->CustomCSSText();
    case kCrossfadeClass:
      return To<cssvalue::CSSCrossfadeValue>(this)->CustomCSSText();
    case kCustomIdentClass:
      return To<CSSCustomIdentValue>(this)->CustomCSSText();
    case kImageClass:
      return To<CSSImageValue>(this)->CustomCSSText();
    case kInheritedClass:
      return To<CSSInheritedValue>(this)->CustomCSSText();
    case kUnsetClass:
      return To<cssvalue::CSSUnsetValue>(this)->CustomCSSText();
    case kRevertClass:
      return To<cssvalue::CSSRevertValue>(this)->CustomCSSText();
    case kRevertLayerClass:
      return To<cssvalue::CSSRevertLayerValue>(this)->CustomCSSText();
    case kInitialClass:
      return To<CSSInitialValue>(this)->CustomCSSText();
    case kGridAutoRepeatClass:
      return To<cssvalue::CSSGridAutoRepeatValue>(this)->CustomCSSText();
    case kGridIntegerRepeatClass:
      return To<cssvalue::CSSGridIntegerRepeatValue>(this)->CustomCSSText();
    case kGridLineNamesClass:
      return To<CSSBracketedValueList>(this)->CustomCSSText();
    case kGridTemplateAreasClass:
      return To<cssvalue::CSSGridTemplateAreasValue>(this)->CustomCSSText();
    case kNumericLiteralClass:
      return To<CSSNumericLiteralValue>(this)->CustomCSSText();
    case kMathFunctionClass:
      return To<CSSMathFunctionValue>(this)->CustomCSSText();
    case kRayClass:
      return To<cssvalue::CSSRayValue>(this)->CustomCSSText();
    case kIdentifierClass:
      return To<CSSIdentifierValue>(this)->CustomCSSText();
    case kKeyframeShorthandClass:
      return To<CSSKeyframeShorthandValue>(this)->CustomCSSText();
    case kInitialColorValueClass:
      return To<CSSInitialColorValue>(this)->CustomCSSText();
    case kQuadClass:
      return To<CSSQuadValue>(this)->CustomCSSText();
    case kReflectClass:
      return To<cssvalue::CSSReflectValue>(this)->CustomCSSText();
    case kShadowClass:
      return To<CSSShadowValue>(this)->CustomCSSText();
    case kStringClass:
      return To<CSSStringValue>(this)->CustomCSSText();
    case kRawClass:
      return To<CSSRawValue>(this)->CustomCSSText();
    case kLinearTimingFunctionClass:
      return To<cssvalue::CSSLinearTimingFunctionValue>(this)->CustomCSSText();
    case kCubicBezierTimingFunctionClass:
      return To<cssvalue::CSSCubicBezierTimingFunctionValue>(this)->CustomCSSText();
    case kStepsTimingFunctionClass:
      return To<cssvalue::CSSStepsTimingFunctionValue>(this)->CustomCSSText();
    case kURIClass:
      return To<cssvalue::CSSURIValue>(this)->CustomCSSText();
    case kValuePairClass:
      return To<CSSValuePair>(this)->CustomCSSText();
    case kValueListClass:
      return To<CSSValueList>(this)->CustomCSSText();
    case kImageSetTypeClass:
      return To<CSSImageSetTypeValue>(this)->CustomCSSText();
    case kImageSetOptionClass:
      return To<CSSImageSetOptionValue>(this)->CustomCSSText();
    case kImageSetClass:
      return To<CSSImageSetValue>(this)->CustomCSSText();
    case kCSSContentDistributionClass:
      return To<cssvalue::CSSContentDistributionValue>(this)->CustomCSSText();
    case kUnparsedDeclarationClass:
      return To<CSSUnparsedDeclarationValue>(this)->CustomCSSText();
    case kPendingSubstitutionValueClass:
      return To<cssvalue::CSSPendingSubstitutionValue>(this)->CustomCSSText();
    case kPendingSystemFontValueClass:
      return To<cssvalue::CSSPendingSystemFontValue>(this)->CustomCSSText();
    case kInvalidVariableValueClass:
      return To<CSSInvalidVariableValue>(this)->CustomCSSText();
    case kLightDarkValuePairClass:
      return To<CSSLightDarkValuePair>(this)->CustomCSSText();
    case kAppearanceAutoBaseSelectValuePairClass:
      return To<CSSAppearanceAutoBaseSelectValuePair>(this)->CustomCSSText();
    case kScrollClass:
      return To<cssvalue::CSSScrollValue>(this)->CustomCSSText();
    case kViewClass:
      return To<cssvalue::CSSViewValue>(this)->CustomCSSText();
    case kRatioClass:
      return To<cssvalue::CSSRatioValue>(this)->CustomCSSText();
    case kRepeatStyleClass:
      return To<CSSRepeatStyleValue>(this)->CustomCSSText();
    default:
      NOTREACHED_IN_MIGRATION();
      return String::EmptyString();
  }
}

String CSSValue::CssTextForSerialization() const {
  if (HasRawText()) {
    return RawText();
  }
  // WEBF_LOG(VERBOSE) << "The type that didn't have raw text: " << GetClassTypeName();
  return CssText();
}

bool CSSValue::HasFailedOrCanceledSubresources() const {
  //  if (IsValueList()) {
  //    return To<CSSValueList>(this)->HasFailedOrCanceledSubresources();
  //  }
  //  if (GetClassType() == kFontFaceSrcClass) {
  //    return To<CSSFontFaceSrcValue>(this)->HasFailedOrCanceledSubresources();
  //  }
  //  if (GetClassType() == kImageClass) {
  //    return To<CSSImageValue>(this)->HasFailedOrCanceledSubresources();
  //  }
  //  if (GetClassType() == kCrossfadeClass) {
  //    return To<cssvalue::CSSCrossfadeValue>(this)
  //        ->HasFailedOrCanceledSubresources();
  //  }
  //  if (GetClassType() == kImageSetClass) {
  //    return To<CSSImageSetValue>(this)->HasFailedOrCanceledSubresources();
  //  }

  return false;
}

bool CSSValue::MayContainUrl() const {
  //  if (IsValueList()) {
  //    return To<CSSValueList>(*this).MayContainUrl();
  //  }
  //  return IsImageValue() || IsURIValue();
  return false;
}

void CSSValue::ReResolveUrl(const Document& document) const {
  // TODO(fs): Should handle all values that can contain URLs.
  //  if (IsImageValue()) {
  //    To<CSSImageValue>(*this).ReResolveURL(document);
  //    return;
  //  }
  //  if (IsURIValue()) {
  //    To<cssvalue::CSSURIValue>(*this).ReResolveUrl(document);
  //    return;
  //  }
  //  if (IsValueList()) {
  //    To<CSSValueList>(*this).ReResolveUrl(document);
  //    return;
  //  }
}

const char* CSSValue::GetClassTypeName() const {
  switch (GetClassType()) {
    case kNumericLiteralClass:
      return "NumericLiteral";
    case kMathFunctionClass:
      return "MathFunction";
    case kIdentifierClass:
      return "Identifier";
    case kColorClass:
      return "Color";
    case kColorMixClass:
      return "ColorMix";
    case kCounterClass:
      return "Counter";
    case kQuadClass:
      return "Quad";
    case kCustomIdentClass:
      return "CustomIdent";
    case kStringClass:
      return "String";
    case kRawClass:
      return "Raw";
    case kURIClass:
      return "URI";
    case kValuePairClass:
      return "ValuePair";
    case kLightDarkValuePairClass:
      return "LightDarkValuePair";
    case kAppearanceAutoBaseSelectValuePairClass:
      return "AppearanceAutoBaseSelectValuePair";
    case kScrollClass:
      return "Scroll";
    case kViewClass:
      return "View";
    case kRatioClass:
      return "Ratio";

    // Basic shapes
    case kBasicShapeCircleClass:
      return "BasicShapeCircle";
    case kBasicShapeEllipseClass:
      return "BasicShapeEllipse";
    case kBasicShapePolygonClass:
      return "BasicShapePolygon";
    case kBasicShapeInsetClass:
      return "BasicShapeInset";
    case kBasicShapeRectClass:
      return "BasicShapeRect";
    case kBasicShapeXYWHClass:
      return "BasicShapeXYWH";

    // Images
    case kImageClass:
      return "Image";
    case kCursorImageClass:
      return "CursorImage";

    // Image generators
    case kCrossfadeClass:
      return "Crossfade";
    case kPaintClass:
      return "Paint";
    case kLinearGradientClass:
      return "LinearGradient";
    case kRadialGradientClass:
      return "RadialGradient";
    case kConicGradientClass:
      return "ConicGradient";
    case kConstantGradientClass:
      return "ConstantGradient";

    // Timing functions
    case kLinearTimingFunctionClass:
      return "LinearTimingFunction";
    case kCubicBezierTimingFunctionClass:
      return "CubicBezierTimingFunction";
    case kStepsTimingFunctionClass:
      return "StepsTimingFunction";

    // Other
    case kBorderImageSliceClass:
      return "BorderImageSlice";
    case kDynamicRangeLimitMixClass:
      return "DynamicRangeLimitMix";
    case kFontFeatureClass:
      return "FontFeature";
    case kFontFaceSrcClass:
      return "FontFaceSrc";
    case kFontFamilyClass:
      return "FontFamily";
    case kFontStyleRangeClass:
      return "FontStyleRange";
    case kFontVariationClass:
      return "FontVariation";
    case kAlternateClass:
      return "Alternate";

    case kInheritedClass:
      return "Inherited";
    case kInitialClass:
      return "Initial";
    case kUnsetClass:
      return "Unset";
    case kRevertClass:
      return "Revert";
    case kRevertLayerClass:
      return "RevertLayer";

    case kReflectClass:
      return "Reflect";
    case kShadowClass:
      return "Shadow";
    case kUnicodeRangeClass:
      return "UnicodeRange";
    case kGridTemplateAreasClass:
      return "GridTemplateAreas";
    case kPaletteMixClass:
      return "PaletteMix";
    case kPathClass:
      return "Path";
    case kRayClass:
      return "Ray";
    case kUnparsedDeclarationClass:
      return "UnparsedDeclaration";
    case kPendingSubstitutionValueClass:
      return "PendingSubstitutionValue";
    case kPendingSystemFontValueClass:
      return "PendingSystemFontValue";
    case kInvalidVariableValueClass:
      return "InvalidVariableValue";
    case kCyclicVariableValueClass:
      return "CyclicVariableValue";
    case kFlipRevertClass:
      return "FlipRevert";
    case kLayoutFunctionClass:
      return "LayoutFunction";

    case kCSSContentDistributionClass:
      return "CSSContentDistribution";

    case kKeyframeShorthandClass:
      return "KeyframeShorthand";
    case kInitialColorValueClass:
      return "InitialColorValue";

    case kImageSetOptionClass:
      return "ImageSetOption";
    case kImageSetTypeClass:
      return "ImageSetType";

    case kRepeatStyleClass:
      return "RepeatStyle";

    case kValueListClass:
      return "ValueList";
    case kFunctionClass:
      return "Function";
    case kImageSetClass:
      return "ImageSet";
    case kGridLineNamesClass:
      return "GridLineNames";
    case kGridAutoRepeatClass:
      return "GridAutoRepeat";
    case kGridIntegerRepeatClass:
      return "GridIntegerRepeat";
    case kAxisClass:
      return "Axis";
  }
  return "UnknownCSSValue";
}

std::shared_ptr<const CSSValue> CSSValue::PopulateWithTreeScope(const webf::TreeScope* tree_scope) const {
  switch (GetClassType()) {
    case kCustomIdentClass:
      return To<CSSCustomIdentValue>(this)->PopulateWithTreeScope(tree_scope);
    case kMathFunctionClass:
      return To<CSSMathFunctionValue>(this)->PopulateWithTreeScope(tree_scope);
    case kValueListClass:
      return To<CSSValueList>(this)->PopulateWithTreeScope(tree_scope);
    default:
      assert(false);
      return shared_from_this();
  }
}

bool CSSValue::operator==(const webf::CSSValue&) const {
  return false;
}

}  // namespace webf
