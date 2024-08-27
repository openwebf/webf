// Copyright 2019 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "core/base/numerics/clamped_math.h"
#include "core/css/css_anchor_query_enums.h"
#include "core/css/css_axis_value.h"
#include "core/css/css_color.h"
#include "core/css/css_content_distribution_value.h"
#include "core/css/css_custom_ident_value.h"
#include "core/css/css_font_variation_value.h"
#include "core/css/css_function_value.h"
#include "core/css/css_grid_auto_repeat_value.h"
#include "core/css/css_grid_template_areas_value.h"
#include "core/css/css_identifier_value.h"
#include "core/css/css_initial_color_value.h"
#include "core/css/css_numeric_literal_value.h"
#include "core/css/css_primitive_value.h"
#include "core/platform/gfx/geometry/point_f.h"
#include "core/platform/gfx/geometry/size_f.h"
// #include "core/css/css_primitive_value_mappings.h"
#include "core/css/css_quad_value.h"
#include "core/css/css_ratio_value.h"
#include "core/css/css_reflect_value.h"
#include "core/css/css_resolution_units.h"
#include "core/css/css_string_value.h"
#include "core/css/css_uri_value.h"
#include "core/css/css_value.h"
#include "core/css/css_value_list.h"
#include "core/css/css_value_pair.h"
#include "core/css/parser/css_parser_context.h"
#include "core/css/parser/css_parser_fast_path.h"
#include "core/css/parser/css_parser_local_context.h"
#include "core/css/parser/css_parser_mode.h"
#include "core/css/parser/css_parser_save_point.h"
#include "core/css/parser/css_parser_token.h"
#include "core/css/parser/css_parser_token_range.h"
#include "core/css/parser/css_property_parser.h"
#include "core/css/parser/font_variant_alternates_parser.h"
#include "core/css/parser/font_variant_east_asian_parser.h"
#include "core/css/parser/font_variant_ligatures_parser.h"
#include "core/css/parser/font_variant_numeric_parser.h"
#include "core/platform/gfx/geometry/point.h"
// #include "core/css/properties/computed_style_utils.h"
#include "core/css/properties/css_parsing_utils.h"
#include "longhands.h"
// #include "core/css/resolver/style_builder_converter.h"
// #include "core/css/resolver/style_resolver.h"
#include "core/css/resolver/style_resolver_state.h"
#include "core/css/style_color.h"
#include "core/css/style_engine.h"
// #include "core/css/zoom_adjusted_pixel_value.h"
#include "css_value_keywords.h"
// #include "core/frame/deprecation/deprecation.h"
// #include "core/frame/settings.h"
// #include "core/frame/web_feature.h"
// #include "core/inspector/console_message.h"
// #include "core/keywords.h"
// #include "core/layout/layout_box.h"
// #include "core/layout/layout_object.h"
// #include "core/style/computed_style.h"
// #include "core/style/coord_box_offset_path_operation.h"
// #include "core/style/geometry_box_clip_path_operation.h"
// #include "core/style/grid_area.h"
// #include "core/style/paint_order_array.h"
// #include "core/style/reference_clip_path_operation.h"
// #include "core/style/reference_offset_path_operation.h"
// #include "core/style/shape_clip_path_operation.h"
// #include "core/style/shape_offset_path_operation.h"
// #include "core/style/style_overflow_clip_margin.h"
#include "core/platform/geometry/layout_unit.h"
#include "core/platform/geometry/length.h"
#include "core/platform/graphics/color.h"
#include "style_property_shorthand.h"

// Implementations of methods in Longhand subclasses that aren't generated.

namespace webf {

namespace {

void AppendIntegerOrAutoIfZero(unsigned value, CSSValueList* list) {
  if (!value) {
    list->Append(CSSIdentifierValue::Create(CSSValueID::kAuto));
    return;
  }
  list->Append(CSSNumericLiteralValue::Create(value, CSSPrimitiveValue::UnitType::kInteger));
}

std::shared_ptr<const CSSCustomIdentValue> ConsumeCustomIdentExcludingNone(CSSParserTokenStream& stream,
                                                                           const CSSParserContext& context) {
  if (stream.Peek().Id() == CSSValueID::kNone) {
    return nullptr;
  }
  return css_parsing_utils::ConsumeCustomIdent(stream, context);
}

}  // namespace

namespace css_longhand {

std::shared_ptr<const CSSValue> AlignContent::ParseSingleValue(CSSParserTokenStream& stream,
                                                               const CSSParserContext& context,
                                                               const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeContentDistributionOverflowPosition(stream,
                                                                       css_parsing_utils::IsContentPositionKeyword);
}

std::shared_ptr<const CSSValue> AlignItems::ParseSingleValue(CSSParserTokenStream& stream,
                                                             const CSSParserContext& context,
                                                             const CSSParserLocalContext&) const {
  // align-items property does not allow the 'auto' value.
  if (css_parsing_utils::IdentMatches<CSSValueID::kAuto>(stream.Peek().Id())) {
    return nullptr;
  }
  return css_parsing_utils::ConsumeSelfPositionOverflowPosition(stream, css_parsing_utils::IsSelfPositionKeyword);
}

std::shared_ptr<const CSSValue> AlignSelf::ParseSingleValue(CSSParserTokenStream& stream,
                                                            const CSSParserContext& context,
                                                            const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeSelfPositionOverflowPosition(stream, css_parsing_utils::IsSelfPositionKeyword);
}

// anchor-name: none | <dashed-ident>#
std::shared_ptr<const CSSValue> AnchorName::ParseSingleValue(CSSParserTokenStream& stream,
                                                             const CSSParserContext& context,
                                                             const CSSParserLocalContext&) const {
  if (std::shared_ptr<const CSSValue> value = css_parsing_utils::ConsumeIdent<CSSValueID::kNone>(stream)) {
    return value;
  }
  return css_parsing_utils::ConsumeCommaSeparatedList(css_parsing_utils::ConsumeDashedIdent<CSSParserTokenStream>,
                                                      stream, context);
}

std::shared_ptr<const CSSValue> AnchorScope::ParseSingleValue(CSSParserTokenStream& stream,
                                                              const CSSParserContext& context,
                                                              const CSSParserLocalContext&) const {
  if (std::shared_ptr<const CSSValue> value =
          css_parsing_utils::ConsumeIdent<CSSValueID::kNone, CSSValueID::kAll>(stream)) {
    return value;
  }
  return css_parsing_utils::ConsumeCommaSeparatedList(css_parsing_utils::ConsumeDashedIdent<CSSParserTokenStream>,
                                                      stream, context);
}
//
//std::shared_ptr<const CSSValue> AnimationComposition::ParseSingleValue(CSSParserTokenStream& stream,
//                                                                       const CSSParserContext& context,
//                                                                       const CSSParserLocalContext&) const {
//  return css_parsing_utils::ConsumeCommaSeparatedList<std::shared_ptr<const CSSIdentifierValue>(CSSParserTokenStream&)>(
//      css_parsing_utils::ConsumeIdent<CSSValueID::kReplace, CSSValueID::kAdd, CSSValueID::kAccumulate>, stream);
//}
//
//std::shared_ptr<const CSSValue> AnimationDelay::ParseSingleValue(CSSParserTokenStream& stream,
//                                                                 const CSSParserContext& context,
//                                                                 const CSSParserLocalContext&) const {
//  return css_parsing_utils::ConsumeCommaSeparatedList(
//      static_cast<std::shared_ptr<const CSSPrimitiveValue> (*)(CSSParserTokenStream&, const CSSParserContext&,
//                                                               CSSPrimitiveValue::ValueRange)>(
//          css_parsing_utils::ConsumeTime),
//      stream, context, CSSPrimitiveValue::ValueRange::kAll);
//}
//
//std::shared_ptr<const CSSValue> AnimationDirection::ParseSingleValue(CSSParserTokenStream& stream,
//                                                                     const CSSParserContext&,
//                                                                     const CSSParserLocalContext&) const {
//  return css_parsing_utils::ConsumeCommaSeparatedList<std::shared_ptr<const CSSIdentifierValue>(CSSParserTokenStream&)>(
//      css_parsing_utils::ConsumeIdent<CSSValueID::kNormal, CSSValueID::kAlternate, CSSValueID::kReverse,
//                                      CSSValueID::kAlternateReverse>,
//      stream);
//}
//
//std::shared_ptr<const CSSValue> AnimationDirection::InitialValue() const {
//  return CSSIdentifierValue::Create(CSSValueID::kNormal);
//}
//
//std::shared_ptr<const CSSValue> AnimationDuration::ParseSingleValue(CSSParserTokenStream& stream,
//                                                                    const CSSParserContext& context,
//                                                                    const CSSParserLocalContext&) const {
//  return css_parsing_utils::ConsumeCommaSeparatedList(css_parsing_utils::ConsumeAnimationDuration, stream, context);
//}
//
//std::shared_ptr<const CSSValue> AnimationFillMode::ParseSingleValue(CSSParserTokenStream& stream,
//                                                                    const CSSParserContext&,
//                                                                    const CSSParserLocalContext&) const {
//  return css_parsing_utils::ConsumeCommaSeparatedList<std::shared_ptr<const CSSIdentifierValue>(CSSParserTokenStream&)>(
//      css_parsing_utils::ConsumeIdent<CSSValueID::kNone, CSSValueID::kForwards, CSSValueID::kBackwards,
//                                      CSSValueID::kBoth>,
//      stream);
//}
//
//std::shared_ptr<const CSSValue> AnimationFillMode::InitialValue() const {
//  return CSSIdentifierValue::Create(CSSValueID::kNone);
//}
//
//std::shared_ptr<const CSSValue> AnimationIterationCount::ParseSingleValue(CSSParserTokenStream& stream,
//                                                                          const CSSParserContext& context,
//                                                                          const CSSParserLocalContext&) const {
//  return css_parsing_utils::ConsumeCommaSeparatedList(css_parsing_utils::ConsumeAnimationIterationCount, stream,
//                                                      context);
//}
//
//std::shared_ptr<const CSSValue> AnimationName::ParseSingleValue(CSSParserTokenStream& stream,
//                                                                const CSSParserContext& context,
//                                                                const CSSParserLocalContext& local_context) const {
//  // Allow quoted name if this is an alias property.
//  return css_parsing_utils::ConsumeCommaSeparatedList(css_parsing_utils::ConsumeAnimationName, stream, context,
//                                                      local_context.UseAliasParsing());
//}
//
//std::shared_ptr<const CSSValue> AnimationName::InitialValue() const {
//  return CSSIdentifierValue::Create(CSSValueID::kNone);
//}
//
//std::shared_ptr<const CSSValue> AnimationPlayState::ParseSingleValue(CSSParserTokenStream& stream,
//                                                                     const CSSParserContext&,
//                                                                     const CSSParserLocalContext&) const {
//  return css_parsing_utils::ConsumeCommaSeparatedList<std::shared_ptr<const CSSIdentifierValue>(CSSParserTokenStream&)>(
//      css_parsing_utils::ConsumeIdent<CSSValueID::kRunning, CSSValueID::kPaused>, stream);
//}
//
//std::shared_ptr<const CSSValue> AnimationPlayState::InitialValue() const {
//  return CSSIdentifierValue::Create(CSSValueID::kRunning);
//}
//
//std::shared_ptr<const CSSValue> AnimationRangeStart::ParseSingleValue(CSSParserTokenStream& stream,
//                                                                      const CSSParserContext& context,
//                                                                      const CSSParserLocalContext&) const {
//  return css_parsing_utils::ConsumeCommaSeparatedList(css_parsing_utils::ConsumeAnimationRange, stream, context,
//                                                      /* default_offset_percent */ 0.0);
//}
//
//std::shared_ptr<const CSSValue> AnimationRangeStart::InitialValue() const {
//  return CSSIdentifierValue::Create(CSSValueID::kNormal);
//}
//
//std::shared_ptr<const CSSValue> AnimationRangeEnd::ParseSingleValue(CSSParserTokenStream& stream,
//                                                                    const CSSParserContext& context,
//                                                                    const CSSParserLocalContext&) const {
//  return css_parsing_utils::ConsumeCommaSeparatedList(css_parsing_utils::ConsumeAnimationRange, stream, context,
//                                                      /* default_offset_percent */ 100.0);
//}
//
//std::shared_ptr<const CSSValue> AnimationRangeEnd::InitialValue() const {
//  return CSSIdentifierValue::Create(CSSValueID::kNormal);
//}
//
//std::shared_ptr<const CSSValue> AnimationTimeline::ParseSingleValue(CSSParserTokenStream& stream,
//                                                                    const CSSParserContext& context,
//                                                                    const CSSParserLocalContext& local_context) const {
//  return css_parsing_utils::ConsumeCommaSeparatedList(css_parsing_utils::ConsumeAnimationTimeline, stream, context);
//}
//
//std::shared_ptr<const CSSValue> AnimationTimeline::InitialValue() const {
//  return CSSIdentifierValue::Create(CSSValueID::kAuto);
//}
//
//std::shared_ptr<const CSSValue> AnimationTimingFunction::ParseSingleValue(CSSParserTokenStream& stream,
//                                                                          const CSSParserContext& context,
//                                                                          const CSSParserLocalContext&) const {
//  return css_parsing_utils::ConsumeCommaSeparatedList(css_parsing_utils::ConsumeAnimationTimingFunction, stream,
//                                                      context);
//}
//
//std::shared_ptr<const CSSValue> AnimationTimingFunction::InitialValue() const {
//  return CSSIdentifierValue::Create(CSSValueID::kEase);
//}

std::shared_ptr<const CSSValue> AspectRatio::ParseSingleValue(CSSParserTokenStream& stream,
                                                              const CSSParserContext& context,
                                                              const CSSParserLocalContext&) const {
  // Syntax: auto | auto 1/2 | 1/2 auto | 1/2
  std::shared_ptr<const CSSValue> auto_value = nullptr;
  if (stream.Peek().Id() == CSSValueID::kAuto) {
    auto_value = css_parsing_utils::ConsumeIdent(stream);
  }

  std::shared_ptr<const CSSValue> ratio = css_parsing_utils::ConsumeRatio(stream, context);
  if (!ratio) {
    return auto_value;  // Either auto alone, or failure.
  }

  if (!auto_value && stream.Peek().Id() == CSSValueID::kAuto) {
    auto_value = css_parsing_utils::ConsumeIdent(stream);
  }

  std::shared_ptr<CSSValueList> list = CSSValueList::CreateSpaceSeparated();
  if (auto_value) {
    list->Append(auto_value);
  }
  list->Append(ratio);
  return list;
}

std::shared_ptr<const CSSValue> BackdropFilter::ParseSingleValue(CSSParserTokenStream& stream,
                                                                 const CSSParserContext& context,
                                                                 const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeFilterFunctionList(stream, context);
}

void BackdropFilter::ApplyValue(StyleResolverState& state, const CSSValue& value, ValueMode) const {}

std::shared_ptr<const CSSValue> BackgroundAttachment::ParseSingleValue(CSSParserTokenStream& stream,
                                                                       const CSSParserContext&,
                                                                       const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeCommaSeparatedList(css_parsing_utils::ConsumeBackgroundAttachment, stream);
}

std::shared_ptr<const CSSValue> BackgroundBlendMode::ParseSingleValue(CSSParserTokenStream& stream,
                                                                      const CSSParserContext&,
                                                                      const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeCommaSeparatedList(css_parsing_utils::ConsumeBackgroundBlendMode, stream);
}

std::shared_ptr<const CSSValue> BackgroundClip::ParseSingleValue(CSSParserTokenStream& stream,
                                                                 const CSSParserContext&,
                                                                 const CSSParserLocalContext& local_context) const {
  return css_parsing_utils::ConsumeCommaSeparatedList(css_parsing_utils::ConsumeBackgroundBoxOrText, stream);
}

std::shared_ptr<const CSSValue> BackgroundColor::ParseSingleValue(CSSParserTokenStream& stream,
                                                                  const CSSParserContext& context,
                                                                  const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeColorMaybeQuirky(stream, context);
}

std::shared_ptr<const CSSValue> BackgroundImage::ParseSingleValue(CSSParserTokenStream& stream,
                                                                  const CSSParserContext& context,
                                                                  const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeCommaSeparatedList(css_parsing_utils::ConsumeImageOrNone, stream, context);
}

std::shared_ptr<const CSSValue> BackgroundOrigin::ParseSingleValue(CSSParserTokenStream& stream,
                                                                   const CSSParserContext&,
                                                                   const CSSParserLocalContext& local_context) const {
  return css_parsing_utils::ParseBackgroundBox(stream, local_context, css_parsing_utils::AllowTextValue::kForbid);
}

std::shared_ptr<const CSSValue> BackgroundPositionX::ParseSingleValue(CSSParserTokenStream& stream,
                                                                      const CSSParserContext& context,
                                                                      const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeCommaSeparatedList(
      css_parsing_utils::ConsumePositionLonghand<CSSValueID::kLeft, CSSValueID::kRight>, stream, context);
}

std::shared_ptr<const CSSValue> BackgroundPositionY::ParseSingleValue(CSSParserTokenStream& stream,
                                                                      const CSSParserContext& context,
                                                                      const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeCommaSeparatedList(
      css_parsing_utils::ConsumePositionLonghand<CSSValueID::kTop, CSSValueID::kBottom>, stream, context);
}

std::shared_ptr<const CSSValue> BackgroundSize::ParseSingleValue(CSSParserTokenStream& stream,
                                                                 const CSSParserContext& context,
                                                                 const CSSParserLocalContext& local_context) const {
  return css_parsing_utils::ParseBackgroundSize(stream, context, local_context);
}

std::shared_ptr<const CSSValue> BackgroundRepeat::ParseSingleValue(CSSParserTokenStream& stream,
                                                                   const CSSParserContext& context,
                                                                   const CSSParserLocalContext& local_context) const {
  return css_parsing_utils::ParseRepeatStyle(stream);
}

std::shared_ptr<const CSSValue> BaselineShift::ParseSingleValue(CSSParserTokenStream& stream,
                                                                const CSSParserContext& context,
                                                                const CSSParserLocalContext&) const {
  CSSValueID id = stream.Peek().Id();
  if (id == CSSValueID::kBaseline || id == CSSValueID::kSub || id == CSSValueID::kSuper) {
    return css_parsing_utils::ConsumeIdent(stream);
  }
  CSSParserContext::ParserModeOverridingScope scope(context, kSVGAttributeMode);
  return css_parsing_utils::ConsumeLengthOrPercent(stream, context, CSSPrimitiveValue::ValueRange::kAll);
}

std::shared_ptr<const CSSValue> BlockSize::ParseSingleValue(CSSParserTokenStream& stream,
                                                            const CSSParserContext& context,
                                                            const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeWidthOrHeight(stream, context);
}

std::shared_ptr<const CSSValue> BorderBlockEndColor::ParseSingleValue(CSSParserTokenStream& stream,
                                                                      const CSSParserContext& context,
                                                                      const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeColor(stream, context);
}

std::shared_ptr<const CSSValue> BorderBlockEndWidth::ParseSingleValue(CSSParserTokenStream& stream,
                                                                      const CSSParserContext& context,
                                                                      const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeBorderWidth(stream, context, css_parsing_utils::UnitlessQuirk::kForbid);
}

std::shared_ptr<const CSSValue> BorderBlockStartColor::ParseSingleValue(CSSParserTokenStream& stream,
                                                                        const CSSParserContext& context,
                                                                        const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeColor(stream, context);
}

std::shared_ptr<const CSSValue> BorderBlockStartWidth::ParseSingleValue(CSSParserTokenStream& stream,
                                                                        const CSSParserContext& context,
                                                                        const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeBorderWidth(stream, context, css_parsing_utils::UnitlessQuirk::kForbid);
}

std::shared_ptr<const CSSValue> BorderBottomColor::ParseSingleValue(CSSParserTokenStream& stream,
                                                                    const CSSParserContext& context,
                                                                    const CSSParserLocalContext& local_context) const {
  return css_parsing_utils::ConsumeBorderColorSide(stream, context, local_context);
}

std::shared_ptr<const CSSValue> BorderBottomLeftRadius::ParseSingleValue(CSSParserTokenStream& stream,
                                                                         const CSSParserContext& context,
                                                                         const CSSParserLocalContext&) const {
  return css_parsing_utils::ParseBorderRadiusCorner(stream, context);
}

std::shared_ptr<const CSSValue> BorderBottomRightRadius::ParseSingleValue(CSSParserTokenStream& stream,
                                                                          const CSSParserContext& context,
                                                                          const CSSParserLocalContext&) const {
  return css_parsing_utils::ParseBorderRadiusCorner(stream, context);
}

std::shared_ptr<const CSSValue> BorderBottomStyle::ParseSingleValue(CSSParserTokenStream& stream,
                                                                    const CSSParserContext& context,
                                                                    const CSSParserLocalContext& local_context) const {
  return css_parsing_utils::ParseBorderStyleSide(stream, context);
}

std::shared_ptr<const CSSValue> BorderBottomWidth::ParseSingleValue(CSSParserTokenStream& stream,
                                                                    const CSSParserContext& context,
                                                                    const CSSParserLocalContext& local_context) const {
  return css_parsing_utils::ParseBorderWidthSide(stream, context, local_context);
}

std::shared_ptr<const CSSValue> BorderEndEndRadius::ParseSingleValue(CSSParserTokenStream& stream,
                                                                     const CSSParserContext& context,
                                                                     const CSSParserLocalContext&) const {
  return css_parsing_utils::ParseBorderRadiusCorner(stream, context);
}

std::shared_ptr<const CSSValue> BorderEndStartRadius::ParseSingleValue(CSSParserTokenStream& stream,
                                                                       const CSSParserContext& context,
                                                                       const CSSParserLocalContext&) const {
  return css_parsing_utils::ParseBorderRadiusCorner(stream, context);
}

std::shared_ptr<const CSSValue> BorderImageOutset::ParseSingleValue(CSSParserTokenStream& stream,
                                                                    const CSSParserContext& context,
                                                                    const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeBorderImageOutset(stream, context);
}

std::shared_ptr<const CSSValue> BorderImageOutset::InitialValue() const {
  thread_local static std::shared_ptr<const CSSQuadValue> value = std::make_shared<CSSQuadValue>(
      CSSNumericLiteralValue::Create(0, CSSPrimitiveValue::UnitType::kInteger), CSSQuadValue::kSerializeAsQuad);
  return value;
}

std::shared_ptr<const CSSValue> BorderImageRepeat::ParseSingleValue(CSSParserTokenStream& stream,
                                                                    const CSSParserContext&,
                                                                    const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeBorderImageRepeat(stream);
}

std::shared_ptr<const CSSValue> BorderImageRepeat::InitialValue() const {
  return CSSIdentifierValue::Create(CSSValueID::kStretch);
}

std::shared_ptr<const CSSValue> BorderImageSlice::ParseSingleValue(CSSParserTokenStream& stream,
                                                                   const CSSParserContext& context,
                                                                   const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeBorderImageSlice(stream, context, css_parsing_utils::DefaultFill::kNoFill);
}

std::shared_ptr<const CSSValue> BorderImageSlice::InitialValue() const {
  thread_local static std::shared_ptr<const CSSValue> value = std::make_shared<CSSQuadValue>(
      CSSNumericLiteralValue::Create(100, CSSPrimitiveValue::UnitType::kPercentage), CSSQuadValue::kSerializeAsQuad);
  return value;
}

std::shared_ptr<const CSSValue> BorderImageSource::ParseSingleValue(CSSParserTokenStream& stream,
                                                                    const CSSParserContext& context,
                                                                    const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeImageOrNone(stream, context);
}

std::shared_ptr<const CSSValue> BorderImageSource::InitialValue() const {
  return CSSIdentifierValue::Create(CSSValueID::kNone);
}

std::shared_ptr<const CSSValue> BorderImageWidth::ParseSingleValue(CSSParserTokenStream& stream,
                                                                   const CSSParserContext& context,
                                                                   const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeBorderImageWidth(stream, context);
}

std::shared_ptr<const CSSValue> BorderImageWidth::InitialValue() const {
  thread_local static std::shared_ptr<const CSSQuadValue> value = std::make_shared<const CSSQuadValue>(
      CSSNumericLiteralValue::Create(1, CSSPrimitiveValue::UnitType::kInteger), CSSQuadValue::kSerializeAsQuad);
  return value;
}

std::shared_ptr<const CSSValue> BorderInlineEndColor::ParseSingleValue(CSSParserTokenStream& stream,
                                                                       const CSSParserContext& context,
                                                                       const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeColor(stream, context);
}

std::shared_ptr<const CSSValue> BorderInlineEndWidth::ParseSingleValue(CSSParserTokenStream& stream,
                                                                       const CSSParserContext& context,
                                                                       const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeBorderWidth(stream, context, css_parsing_utils::UnitlessQuirk::kForbid);
}

std::shared_ptr<const CSSValue> BorderInlineStartColor::ParseSingleValue(CSSParserTokenStream& stream,
                                                                         const CSSParserContext& context,
                                                                         const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeColor(stream, context);
}

std::shared_ptr<const CSSValue> BorderInlineStartWidth::ParseSingleValue(CSSParserTokenStream& stream,
                                                                         const CSSParserContext& context,
                                                                         const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeBorderWidth(stream, context, css_parsing_utils::UnitlessQuirk::kForbid);
}

std::shared_ptr<const CSSValue> BorderLeftColor::ParseSingleValue(CSSParserTokenStream& stream,
                                                                  const CSSParserContext& context,
                                                                  const CSSParserLocalContext& local_context) const {
  return css_parsing_utils::ConsumeBorderColorSide(stream, context, local_context);
}

std::shared_ptr<const CSSValue> BorderLeftStyle::ParseSingleValue(CSSParserTokenStream& stream,
                                                                  const CSSParserContext& context,
                                                                  const CSSParserLocalContext& local_context) const {
  return css_parsing_utils::ParseBorderStyleSide(stream, context);
}

std::shared_ptr<const CSSValue> BorderLeftWidth::ParseSingleValue(CSSParserTokenStream& stream,
                                                                  const CSSParserContext& context,
                                                                  const CSSParserLocalContext& local_context) const {
  return css_parsing_utils::ParseBorderWidthSide(stream, context, local_context);
}

std::shared_ptr<const CSSValue> BorderRightColor::ParseSingleValue(CSSParserTokenStream& stream,
                                                                   const CSSParserContext& context,
                                                                   const CSSParserLocalContext& local_context) const {
  return css_parsing_utils::ConsumeBorderColorSide(stream, context, local_context);
}

std::shared_ptr<const CSSValue> BorderRightStyle::ParseSingleValue(CSSParserTokenStream& stream,
                                                                   const CSSParserContext& context,
                                                                   const CSSParserLocalContext& local_context) const {
  return css_parsing_utils::ParseBorderStyleSide(stream, context);
}

std::shared_ptr<const CSSValue> BorderRightWidth::ParseSingleValue(CSSParserTokenStream& stream,
                                                                   const CSSParserContext& context,
                                                                   const CSSParserLocalContext& local_context) const {
  return css_parsing_utils::ParseBorderWidthSide(stream, context, local_context);
}

std::shared_ptr<const CSSValue> BorderStartStartRadius::ParseSingleValue(CSSParserTokenStream& stream,
                                                                         const CSSParserContext& context,
                                                                         const CSSParserLocalContext&) const {
  return css_parsing_utils::ParseBorderRadiusCorner(stream, context);
}

std::shared_ptr<const CSSValue> BorderStartEndRadius::ParseSingleValue(CSSParserTokenStream& stream,
                                                                       const CSSParserContext& context,
                                                                       const CSSParserLocalContext&) const {
  return css_parsing_utils::ParseBorderRadiusCorner(stream, context);
}

std::shared_ptr<const CSSValue> BorderTopColor::ParseSingleValue(CSSParserTokenStream& stream,
                                                                 const CSSParserContext& context,
                                                                 const CSSParserLocalContext& local_context) const {
  return css_parsing_utils::ConsumeBorderColorSide(stream, context, local_context);
}

std::shared_ptr<const CSSValue> BorderTopLeftRadius::ParseSingleValue(CSSParserTokenStream& stream,
                                                                      const CSSParserContext& context,
                                                                      const CSSParserLocalContext&) const {
  return css_parsing_utils::ParseBorderRadiusCorner(stream, context);
}

std::shared_ptr<const CSSValue> BorderTopRightRadius::ParseSingleValue(CSSParserTokenStream& stream,
                                                                       const CSSParserContext& context,
                                                                       const CSSParserLocalContext&) const {
  return css_parsing_utils::ParseBorderRadiusCorner(stream, context);
}

std::shared_ptr<const CSSValue> BorderTopStyle::ParseSingleValue(CSSParserTokenStream& stream,
                                                                 const CSSParserContext& context,
                                                                 const CSSParserLocalContext& local_context) const {
  return css_parsing_utils::ParseBorderStyleSide(stream, context);
}

std::shared_ptr<const CSSValue> BorderTopWidth::ParseSingleValue(CSSParserTokenStream& stream,
                                                                 const CSSParserContext& context,
                                                                 const CSSParserLocalContext& local_context) const {
  return css_parsing_utils::ParseBorderWidthSide(stream, context, local_context);
}

std::shared_ptr<const CSSValue> Bottom::ParseSingleValue(CSSParserTokenStream& stream,
                                                         const CSSParserContext& context,
                                                         const CSSParserLocalContext& local_context) const {
  return css_parsing_utils::ConsumeMarginOrOffset(stream, context,
                                                  css_parsing_utils::UnitlessUnlessShorthand(local_context),
                                                  static_cast<CSSAnchorQueryTypes>(CSSAnchorQueryType::kAnchor));
}

std::shared_ptr<const CSSValue> BoxShadow::ParseSingleValue(CSSParserTokenStream& stream,
                                                            const CSSParserContext& context,
                                                            const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeShadow(stream, context, css_parsing_utils::AllowInsetAndSpread::kAllow);
}

std::shared_ptr<const CSSValue> CaretColor::ParseSingleValue(CSSParserTokenStream& stream,
                                                             const CSSParserContext& context,
                                                             const CSSParserLocalContext&) const {
  if (stream.Peek().Id() == CSSValueID::kAuto) {
    return css_parsing_utils::ConsumeIdent(stream);
  }
  return css_parsing_utils::ConsumeColor(stream, context);
}

namespace {

std::shared_ptr<const CSSValue> ConsumeClipComponent(CSSParserTokenStream& stream, const CSSParserContext& context) {
  if (stream.Peek().Id() == CSSValueID::kAuto) {
    return css_parsing_utils::ConsumeIdent(stream);
  }
  return css_parsing_utils::ConsumeLength(stream, context, CSSPrimitiveValue::ValueRange::kAll,
                                          css_parsing_utils::UnitlessQuirk::kAllow);
}

}  // namespace

std::shared_ptr<const CSSValue> Clip::ParseSingleValue(CSSParserTokenStream& stream,
                                                       const CSSParserContext& context,
                                                       const CSSParserLocalContext&) const {
  if (stream.Peek().Id() == CSSValueID::kAuto) {
    return css_parsing_utils::ConsumeIdent(stream);
  }

  if (stream.Peek().FunctionId() != CSSValueID::kRect) {
    return nullptr;
  }

  CSSParserTokenStream::RestoringBlockGuard guard(stream);
  stream.ConsumeWhitespace();
  // rect(t, r, b, l) || rect(t r b l)
  std::shared_ptr<const CSSValue> top = ConsumeClipComponent(stream, context);
  if (!top) {
    return nullptr;
  }
  bool needs_comma = css_parsing_utils::ConsumeCommaIncludingWhitespace(stream);
  std::shared_ptr<const CSSValue> right = ConsumeClipComponent(stream, context);
  if (!right || (needs_comma && !css_parsing_utils::ConsumeCommaIncludingWhitespace(stream))) {
    return nullptr;
  }
  std::shared_ptr<const CSSValue> bottom = ConsumeClipComponent(stream, context);
  if (!bottom || (needs_comma && !css_parsing_utils::ConsumeCommaIncludingWhitespace(stream))) {
    return nullptr;
  }
  std::shared_ptr<const CSSValue> left = ConsumeClipComponent(stream, context);
  if (!left || !stream.AtEnd()) {
    // NOTE: This AtEnd() is fine, because we test within the
    // RestoringBlockGuard. But we need the stream to rewind in that case.
    return nullptr;
  }
  guard.Release();
  return std::make_shared<CSSQuadValue>(top, right, bottom, left, CSSQuadValue::kSerializeAsRect);
}

std::shared_ptr<const CSSValue> ClipPath::ParseSingleValue(CSSParserTokenStream& stream,
                                                           const CSSParserContext& context,
                                                           const CSSParserLocalContext&) const {
  if (stream.Peek().Id() == CSSValueID::kNone) {
    return css_parsing_utils::ConsumeIdent(stream);
  }

  if (std::shared_ptr<cssvalue::CSSURIValue> url = css_parsing_utils::ConsumeUrl(stream, context)) {
    return url;
  }

  std::shared_ptr<const CSSValue> geometry_box = css_parsing_utils::ConsumeGeometryBox(stream);
  std::shared_ptr<const CSSValue> basic_shape = css_parsing_utils::ConsumeBasicShape(stream, context);
  if (basic_shape && !geometry_box) {
    geometry_box = css_parsing_utils::ConsumeGeometryBox(stream);
  }
  if (basic_shape || geometry_box) {
    std::shared_ptr<CSSValueList> list = CSSValueList::CreateSpaceSeparated();
    if (basic_shape) {
      list->Append(basic_shape);
    }
    if (geometry_box) {
      if (list->length() == 0 || To<CSSIdentifierValue>(geometry_box.get())->GetValueID() != CSSValueID::kBorderBox) {
        list->Append(geometry_box);
      }
    }
    return list;
  }

  return nullptr;
}

std::shared_ptr<const CSSValue> Color::ParseSingleValue(CSSParserTokenStream& stream,
                                                        const CSSParserContext& context,
                                                        const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeColorMaybeQuirky(stream, context);
}

std::shared_ptr<const CSSValue> ColorScheme::ParseSingleValue(CSSParserTokenStream& stream,
                                                              const CSSParserContext& context,
                                                              const CSSParserLocalContext&) const {
  if (stream.Peek().Id() == CSSValueID::kNormal) {
    return css_parsing_utils::ConsumeIdent(stream);
  }

  std::shared_ptr<const CSSValue> only = nullptr;
  std::shared_ptr<CSSValueList> values = CSSValueList::CreateSpaceSeparated();
  do {
    CSSValueID id = stream.Peek().Id();
    // 'normal' is handled above, and needs to be excluded from
    // ConsumeCustomIdent below.
    if (id == CSSValueID::kNormal) {
      return nullptr;
    }
    std::shared_ptr<const CSSValue> value =
        css_parsing_utils::ConsumeIdent<CSSValueID::kDark, CSSValueID::kLight, CSSValueID::kOnly>(stream);
    if (id == CSSValueID::kOnly) {
      if (only) {
        return nullptr;
      }
      if (values->length()) {
        values->Append(value);
        return values;
      }
      only = value;
      continue;
    }
    if (!value) {
      value = css_parsing_utils::ConsumeCustomIdent(stream, context);
    }
    if (!value) {
      break;
    }
    values->Append(value);
  } while (!stream.AtEnd());
  if (!values->length()) {
    return nullptr;
  }
  if (only) {
    values->Append(only);
  }
  return values;
}

std::shared_ptr<const CSSValue> ColorScheme::InitialValue() const {
  return CSSIdentifierValue::Create(CSSValueID::kNormal);
}

std::shared_ptr<const CSSValue> ColumnCount::ParseSingleValue(CSSParserTokenStream& stream,
                                                              const CSSParserContext& context,
                                                              const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeColumnCount(stream, context);
}

std::shared_ptr<const CSSValue> ColumnGap::ParseSingleValue(CSSParserTokenStream& stream,
                                                            const CSSParserContext& context,
                                                            const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeGapLength(stream, context);
}

std::shared_ptr<const CSSValue> ColumnRuleColor::ParseSingleValue(CSSParserTokenStream& stream,
                                                                  const CSSParserContext& context,
                                                                  const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeColor(stream, context);
}

std::shared_ptr<const CSSValue> ColumnRuleWidth::ParseSingleValue(CSSParserTokenStream& stream,
                                                                  const CSSParserContext& context,
                                                                  const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeLineWidth(stream, context, css_parsing_utils::UnitlessQuirk::kForbid);
}

std::shared_ptr<const CSSValue> ColumnSpan::ParseSingleValue(CSSParserTokenStream& stream,
                                                             const CSSParserContext& context,
                                                             const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeIdent<CSSValueID::kAll, CSSValueID::kNone>(stream);
}

std::shared_ptr<const CSSValue> ColumnWidth::ParseSingleValue(CSSParserTokenStream& stream,
                                                              const CSSParserContext& context,
                                                              const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeColumnWidth(stream, context);
}

// none | strict | content | [ size || layout || style || paint ]
std::shared_ptr<const CSSValue> Contain::ParseSingleValue(CSSParserTokenStream& stream,
                                                          const CSSParserContext& context,
                                                          const CSSParserLocalContext&) const {
  CSSValueID id = stream.Peek().Id();
  if (id == CSSValueID::kNone) {
    return css_parsing_utils::ConsumeIdent(stream);
  }

  std::shared_ptr<CSSValueList> list = CSSValueList::CreateSpaceSeparated();
  if (id == CSSValueID::kStrict || id == CSSValueID::kContent) {
    list->Append(css_parsing_utils::ConsumeIdent(stream));
    return list;
  }

  std::shared_ptr<const CSSIdentifierValue> size = nullptr;
  std::shared_ptr<const CSSIdentifierValue> layout = nullptr;
  std::shared_ptr<const CSSIdentifierValue> style = nullptr;
  std::shared_ptr<const CSSIdentifierValue> paint = nullptr;
  while (true) {
    id = stream.Peek().Id();
    if ((id == CSSValueID::kSize ||

         id == CSSValueID::kInlineSize) &&
        !size) {
      size = css_parsing_utils::ConsumeIdent(stream);
    } else if (id == CSSValueID::kLayout && !layout) {
      layout = css_parsing_utils::ConsumeIdent(stream);
    } else if (id == CSSValueID::kStyle && !style) {
      style = css_parsing_utils::ConsumeIdent(stream);
    } else if (id == CSSValueID::kPaint && !paint) {
      paint = css_parsing_utils::ConsumeIdent(stream);
    } else {
      break;
    }
  }
  if (size) {
    list->Append(size);
  }
  if (layout) {
    list->Append(layout);
  }
  if (style) {
    list->Append(style);
  }
  if (paint) {
    list->Append(paint);
  }
  if (!list->length()) {
    return nullptr;
  }
  return list;
}

std::shared_ptr<const CSSValue> ContainIntrinsicWidth::ParseSingleValue(CSSParserTokenStream& stream,
                                                                        const CSSParserContext& context,
                                                                        const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeIntrinsicSizeLonghand(stream, context);
}

std::shared_ptr<const CSSValue> ContainIntrinsicHeight::ParseSingleValue(CSSParserTokenStream& stream,
                                                                         const CSSParserContext& context,
                                                                         const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeIntrinsicSizeLonghand(stream, context);
}

std::shared_ptr<const CSSValue> ContainIntrinsicInlineSize::ParseSingleValue(CSSParserTokenStream& stream,
                                                                             const CSSParserContext& context,
                                                                             const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeIntrinsicSizeLonghand(stream, context);
}

std::shared_ptr<const CSSValue> ContainIntrinsicBlockSize::ParseSingleValue(CSSParserTokenStream& stream,
                                                                            const CSSParserContext& context,
                                                                            const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeIntrinsicSizeLonghand(stream, context);
}

std::shared_ptr<const CSSValue> ContainerName::ParseSingleValue(CSSParserTokenStream& stream,
                                                                const CSSParserContext& context,
                                                                const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeContainerName(stream, context);
}

std::shared_ptr<const CSSValue> ContainerType::ParseSingleValue(CSSParserTokenStream& stream,
                                                                const CSSParserContext& context,
                                                                const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeContainerType(stream);
}

namespace {

std::shared_ptr<const CSSValue> ConsumeAttr(CSSParserTokenStream& stream, const CSSParserContext& context) {
  std::string attr_name;
  {
    CSSParserTokenStream::BlockGuard guard(stream);
    stream.ConsumeWhitespace();
    if (stream.Peek().GetType() != kIdentToken) {
      return nullptr;
    }

    attr_name = stream.ConsumeIncludingWhitespace().Value();
    if (!stream.AtEnd()) {
      // NOTE: This AtEnd() is fine, because we are inside a function block
      // (i.e., inside a BlockGuard).
      return nullptr;
    }
  }

  stream.ConsumeWhitespace();

  std::shared_ptr<CSSFunctionValue> attr_value = std::make_shared<CSSFunctionValue>(CSSValueID::kAttr);
  attr_value->Append(std::make_shared<const CSSCustomIdentValue>(attr_name));
  return attr_value;
}

}  // namespace

std::shared_ptr<const CSSValue> Content::ParseSingleValue(CSSParserTokenStream& stream,
                                                          const CSSParserContext& context,
                                                          const CSSParserLocalContext&) const {
  if (css_parsing_utils::IdentMatches<CSSValueID::kNone, CSSValueID::kNormal>(stream.Peek().Id())) {
    return css_parsing_utils::ConsumeIdent(stream);
  }

  std::shared_ptr<CSSValueList> values = CSSValueList::CreateSpaceSeparated();
  std::shared_ptr<CSSValueList> outer_list = CSSValueList::CreateSlashSeparated();
  bool alt_text_present = false;
  do {
    CSSParserSavePoint savepoint(stream);
    std::shared_ptr<const CSSValue> parsed_value = css_parsing_utils::ConsumeImage(stream, context);
    if (!parsed_value) {
      parsed_value = css_parsing_utils::ConsumeIdent<CSSValueID::kOpenQuote, CSSValueID::kCloseQuote,
                                                     CSSValueID::kNoOpenQuote, CSSValueID::kNoCloseQuote>(stream);
    }
    if (!parsed_value) {
      parsed_value = css_parsing_utils::ConsumeString(stream);
    }
    if (!parsed_value) {
      if (stream.Peek().FunctionId() == CSSValueID::kAttr) {
        parsed_value = ConsumeAttr(stream, context);
      }
    }
    if (!parsed_value) {
      if (css_parsing_utils::ConsumeSlashIncludingWhitespace(stream)) {
        // No values were parsed before the slash, so nothing to apply the
        // alternative text to.
        if (!values->length()) {
          return nullptr;
        }
        alt_text_present = true;
      } else {
        break;
      }
    } else {
      values->Append(parsed_value);
    }
    savepoint.Release();
  } while (!stream.AtEnd() && !alt_text_present);
  if (!values->length()) {
    return nullptr;
  }
  outer_list->Append(values);
  if (alt_text_present) {
    std::shared_ptr<CSSValueList> alt_text_values = CSSValueList::CreateSpaceSeparated();
    std::shared_ptr<const CSSValue> alt_text = nullptr;
    alt_text = css_parsing_utils::ConsumeString(stream);
    if (!alt_text) {
      return nullptr;
    }
    alt_text_values->Append(alt_text);

    outer_list->Append(alt_text_values);
  }
  return outer_list;
}

const int kCounterIncrementDefaultValue = 1;

std::shared_ptr<const CSSValue> CounterIncrement::ParseSingleValue(CSSParserTokenStream& stream,
                                                                   const CSSParserContext& context,
                                                                   const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeCounter(stream, context, kCounterIncrementDefaultValue);
}

const int kCounterResetDefaultValue = 0;

std::shared_ptr<const CSSValue> CounterReset::ParseSingleValue(CSSParserTokenStream& stream,
                                                               const CSSParserContext& context,
                                                               const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeCounter(stream, context, kCounterResetDefaultValue);
}

const int kCounterSetDefaultValue = 0;

std::shared_ptr<const CSSValue> CounterSet::ParseSingleValue(CSSParserTokenStream& stream,
                                                             const CSSParserContext& context,
                                                             const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeCounter(stream, context, kCounterSetDefaultValue);
}

// std::shared_ptr<const CSSValue> Cursor::ParseSingleValue(CSSParserTokenStream& stream,
//                                                          const CSSParserContext& context,
//                                                          const CSSParserLocalContext&) const {
//   bool in_quirks_mode = IsQuirksModeBehavior(context.Mode());
//   std::shared_ptr<CSSValueList> list = nullptr;
//   while (std::shared_ptr<const CSSValue> image = css_parsing_utils::ConsumeImage(stream, context,
//                                                            css_parsing_utils::ConsumeGeneratedImagePolicy::kForbid))
//                                                            {
//     double num;
//     gfx::Point hot_spot(-1, -1);
//     bool hot_spot_specified = false;
//     if (css_parsing_utils::ConsumeNumberRaw(stream, context, num)) {
//       hot_spot.set_x(ClampTo<int>(num));
//       if (!css_parsing_utils::ConsumeNumberRaw(stream, context, num)) {
//         return nullptr;
//       }
//       hot_spot.set_y(ClampTo<int>(num));
//       hot_spot_specified = true;
//     }
//
//     if (!list) {
//       list = CSSValueList::CreateCommaSeparated();
//     }
//
//     list->Append(*std::make_shared<cssvalue::CSSCursorImageValue>(*image, hot_spot_specified, hot_spot));
//     if (!css_parsing_utils::ConsumeCommaIncludingWhitespace(stream)) {
//       return nullptr;
//     }
//   }
//
//   CSSValueID id = stream.Peek().Id();
//   std::shared_ptr<const CSSIdentifierValue> cursor_type = nullptr;
//   if (id == CSSValueID::kHand) {
//     if (!in_quirks_mode) {  // Non-standard behavior
//       return nullptr;
//     }
//     cursor_type = std::make_shared<CSSIdentifierValue>(CSSValueID::kPointer,
//                                                            /*was_quirky=*/true);  // Cannot use the identifier value
//                                                                                   // pool due to was_quirky.
//     stream.ConsumeIncludingWhitespace();
//   } else if ((id >= CSSValueID::kAuto && id <= CSSValueID::kWebkitZoomOut) || id == CSSValueID::kCopy ||
//              id == CSSValueID::kNone) {
//     cursor_type = css_parsing_utils::ConsumeIdent(stream);
//   } else {
//     return nullptr;
//   }
//
//   if (!list) {
//     return cursor_type;
//   }
//   list->Append(cursor_type);
//   return list;
// }
//

namespace {

static bool IsDisplayOutside(CSSValueID id) {
  return id >= CSSValueID::kInline && id <= CSSValueID::kBlock;
}

static bool IsDisplayInside(CSSValueID id) {
  return (id >= CSSValueID::kFlowRoot && id <= CSSValueID::kGrid) || id == CSSValueID::kMath || id == CSSValueID::kRuby;
}

static bool IsDisplayBox(CSSValueID id) {
  return css_parsing_utils::IdentMatches<CSSValueID::kNone, CSSValueID::kContents>(id);
}

static bool IsDisplayInternal(CSSValueID id) {
  return id >= CSSValueID::kTableRowGroup && id <= CSSValueID::kRubyText;
}

static bool IsDisplayLegacy(CSSValueID id) {
  return id >= CSSValueID::kInlineBlock && id <= CSSValueID::kWebkitInlineFlex;
}

bool IsDisplayListItem(CSSValueID id) {
  return id == CSSValueID::kListItem;
}

struct DisplayValidationResult {
  WEBF_STACK_ALLOCATED();

 public:
  std::shared_ptr<const CSSIdentifierValue> outside;
  std::shared_ptr<const CSSIdentifierValue> inside;
  std::shared_ptr<const CSSIdentifierValue> list_item;
};

// Find <display-outside>, <display-inside>, and `list-item` in the unordered
// keyword list `values`.  Returns nullopt if `values` contains an invalid
// combination of keywords.
std::optional<DisplayValidationResult> ValidateDisplayKeywords(const CSSValueList& values) {
  std::shared_ptr<const CSSIdentifierValue> outside = nullptr;
  std::shared_ptr<const CSSIdentifierValue> inside = nullptr;
  std::shared_ptr<const CSSIdentifierValue> list_item = nullptr;
  for (const auto& item : values) {
    std::shared_ptr<const CSSIdentifierValue> value = std::static_pointer_cast<const CSSIdentifierValue>(item);
    CSSValueID value_id = value->GetValueID();
    if (!outside && IsDisplayOutside(value_id)) {
      outside = value;
    } else if (!inside && IsDisplayInside(value_id)) {
      inside = value;
    } else if (!list_item && IsDisplayListItem(value_id)) {
      list_item = value;
    } else {
      return std::nullopt;
    }
  }
  DisplayValidationResult result{outside, inside, list_item};
  return result;
}

// Drop redundant keywords, and update to backward-compatible keywords.
// e.g. {outside:"block", inside:"flow"} ==> {outside:"block", inside:null}
//      {outside:"inline", inside:"flow-root"} ==>
//          {outside:null, inside:"inline-block"}
void AdjustDisplayKeywords(DisplayValidationResult& result) {
  CSSValueID outside = result.outside ? result.outside->GetValueID() : CSSValueID::kInvalid;
  CSSValueID inside = result.inside ? result.inside->GetValueID() : CSSValueID::kInvalid;
  switch (inside) {
    case CSSValueID::kFlow:
      if (result.outside) {
        result.inside = nullptr;
      }
      break;
    case CSSValueID::kFlex:
    case CSSValueID::kFlowRoot:
    case CSSValueID::kGrid:
    case CSSValueID::kTable:
      if (outside == CSSValueID::kBlock) {
        result.outside = nullptr;
      } else if (outside == CSSValueID::kInline && !result.list_item) {
        CSSValueID new_id = CSSValueID::kInvalid;
        if (inside == CSSValueID::kFlex) {
          new_id = CSSValueID::kInlineFlex;
        } else if (inside == CSSValueID::kFlowRoot) {
          new_id = CSSValueID::kInlineBlock;
        } else if (inside == CSSValueID::kGrid) {
          new_id = CSSValueID::kInlineGrid;
        } else if (inside == CSSValueID::kTable) {
          new_id = CSSValueID::kInlineTable;
        }
        assert(new_id != CSSValueID::kInvalid);
        result.outside = nullptr;
        result.inside = CSSIdentifierValue::Create(new_id);
      }
      break;
    case CSSValueID::kMath:
    case CSSValueID::kRuby:
      if (outside == CSSValueID::kInline) {
        result.outside = nullptr;
      }
      break;
    default:
      break;
  }

  if (result.list_item) {
    if (outside == CSSValueID::kBlock) {
      result.outside = nullptr;
    }
    if (inside == CSSValueID::kFlow) {
      result.inside = nullptr;
    }
  }
}

std::shared_ptr<const CSSValue> ParseDisplayMultipleKeywords(
    CSSParserTokenStream& stream,
    const std::shared_ptr<const CSSIdentifierValue>& first_value) {
  std::shared_ptr<CSSValueList> values = CSSValueList::CreateSpaceSeparated();
  values->Append(first_value);
  values->Append(css_parsing_utils::ConsumeIdent(stream));
  if (stream.Peek().Id() != CSSValueID::kInvalid) {
    values->Append(css_parsing_utils::ConsumeIdent(stream));
  }
  // `values` now has two or three CSSIdentifierValue pointers.

  auto result = ValidateDisplayKeywords(*values);
  if (!result) {
    return nullptr;
  }

  if (result->list_item && result->inside) {
    CSSValueID inside = result->inside->GetValueID();
    if (inside != CSSValueID::kFlow && inside != CSSValueID::kFlowRoot) {
      return nullptr;
    }
  }

  AdjustDisplayKeywords(*result);
  std::shared_ptr<CSSValueList> result_list = CSSValueList::CreateSpaceSeparated();
  if (result->outside) {
    result_list->Append(result->outside);
  }
  if (result->inside) {
    result_list->Append(result->inside);
  }
  if (result->list_item) {
    result_list->Append(result->list_item);
  }
  return result_list->length() == 1u ? result_list->Item(0) : result_list;
}

}  // namespace

// https://drafts.csswg.org/css-display/#the-display-properties
//   [<display-outside> || <display-inside>] |
//   [<display-outside>? && [ flow | flow-root ]? && list-item] |
//   <display-internal> | <display-box> | <display-legacy>
std::shared_ptr<const CSSValue> Display::ParseSingleValue(CSSParserTokenStream& stream,
                                                          const CSSParserContext& context,
                                                          const CSSParserLocalContext&) const {
  CSSValueID id = stream.Peek().Id();
  if (id != CSSValueID::kInvalid) {
    std::shared_ptr<const CSSIdentifierValue> value = css_parsing_utils::ConsumeIdent(stream);
    if (stream.Peek().Id() != CSSValueID::kInvalid) {
      return ParseDisplayMultipleKeywords(stream, value);
    }

    // The property has only one keyword (or one keyword and then junk,
    // in which case the caller will abort for us).
    if (id == CSSValueID::kFlow) {
      return CSSIdentifierValue::Create(CSSValueID::kBlock);
    } else if (id == CSSValueID::kListItem || IsDisplayBox(id) || IsDisplayInternal(id) || IsDisplayLegacy(id) ||
               IsDisplayInside(id) || IsDisplayOutside(id)) {
      return value;
    } else {
      return nullptr;
    }
  }
  return nullptr;
}

void Display::ApplyInitial(StyleResolverState& state) const {
  //  ComputedStyleBuilder& builder = state.StyleBuilder();
  //  builder.SetDisplay(ComputedStyleInitialValues::InitialDisplay());
  //  builder.SetDisplayLayoutCustomName(ComputedStyleInitialValues::InitialDisplayLayoutCustomName());
}

void Display::ApplyInherit(StyleResolverState& state) const {
  //  ComputedStyleBuilder& builder = state.StyleBuilder();
  //  builder.SetDisplay(state.ParentStyle()->Display());
  //  builder.SetDisplayLayoutCustomName(state.ParentStyle()->DisplayLayoutCustomName());
}

void Display::ApplyValue(StyleResolverState& state, const CSSValue& value, ValueMode) const {
  //  ComputedStyleBuilder& builder = state.StyleBuilder();
  //  if (auto* identifier_value = DynamicTo<CSSIdentifierValue>(value)) {
  //    builder.SetDisplay(identifier_value->ConvertTo<EDisplay>());
  //    builder.SetDisplayLayoutCustomName(ComputedStyleInitialValues::InitialDisplayLayoutCustomName());
  //    return;
  //  }
  //
  //  if (value.IsValueList()) {
  //    builder.SetDisplayLayoutCustomName(ComputedStyleInitialValues::InitialDisplayLayoutCustomName());
  //    const CSSValueList& list = To<CSSValueList>(value);
  //    DCHECK(list.length() == 2u || (list.length() == 3u && list.Item(2).IsIdentifierValue()));
  //    DCHECK(list.Item(0).IsIdentifierValue());
  //    DCHECK(list.Item(1).IsIdentifierValue());
  //    auto result = ValidateDisplayKeywords(list);
  //    DCHECK(result);
  //    CSSValueID outside = result->outside ? result->outside->GetValueID() : CSSValueID::kInvalid;
  //    CSSValueID inside = result->inside ? result->inside->GetValueID() : CSSValueID::kInvalid;
  //
  //    if (result->list_item) {
  //      const bool is_block = outside == CSSValueID::kBlock || !IsValidCSSValueID(outside);
  //      if (inside != CSSValueID::kFlowRoot) {
  //        builder.SetDisplay(is_block ? EDisplay::kListItem : EDisplay::kInlineListItem);
  //      } else {
  //        builder.SetDisplay(is_block ? EDisplay::kFlowRootListItem : EDisplay::kInlineFlowRootListItem);
  //      }
  //      return;
  //    }
  //
  //    DCHECK(IsDisplayOutside(outside));
  //    DCHECK(IsDisplayInside(inside));
  //    const bool is_block = outside == CSSValueID::kBlock;
  //    if (inside == CSSValueID::kFlowRoot) {
  //      builder.SetDisplay(is_block ? EDisplay::kFlowRoot : EDisplay::kInlineBlock);
  //    } else if (inside == CSSValueID::kFlow) {
  //      builder.SetDisplay(is_block ? EDisplay::kBlock : EDisplay::kInline);
  //    } else if (inside == CSSValueID::kTable) {
  //      builder.SetDisplay(is_block ? EDisplay::kTable : EDisplay::kInlineTable);
  //    } else if (inside == CSSValueID::kFlex) {
  //      builder.SetDisplay(is_block ? EDisplay::kFlex : EDisplay::kInlineFlex);
  //    } else if (inside == CSSValueID::kGrid) {
  //      builder.SetDisplay(is_block ? EDisplay::kGrid : EDisplay::kInlineGrid);
  //    } else if (inside == CSSValueID::kMath) {
  //      builder.SetDisplay(is_block ? EDisplay::kBlockMath : EDisplay::kMath);
  //    } else if (inside == CSSValueID::kRuby) {
  //      builder.SetDisplay(is_block ? EDisplay::kBlockRuby : EDisplay::kRuby);
  //    }
  //    return;
  //  }
  //
  //  const auto& layout_function_value = To<cssvalue::CSSLayoutFunctionValue>(value);
  //
  //  EDisplay display = layout_function_value.IsInline() ? EDisplay::kInlineLayoutCustom : EDisplay::kLayoutCustom;
  //  builder.SetDisplay(display);
  //  builder.SetDisplayLayoutCustomName(layout_function_value.GetName());
}

std::shared_ptr<const CSSValue> FillOpacity::ParseSingleValue(CSSParserTokenStream& stream,
                                                              const CSSParserContext& context,
                                                              const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeAlphaValue(stream, context);
}

std::shared_ptr<const CSSValue> Filter::ParseSingleValue(CSSParserTokenStream& stream,
                                                         const CSSParserContext& context,
                                                         const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeFilterFunctionList(stream, context);
}

std::shared_ptr<const CSSValue> FlexBasis::ParseSingleValue(CSSParserTokenStream& stream,
                                                            const CSSParserContext& context,
                                                            const CSSParserLocalContext&) const {
  // TODO(https://crbug.com/353538495): This should really use
  // css_parsing_utils::ValidWidthOrHeightKeyword.
  if (css_parsing_utils::IdentMatches<CSSValueID::kAuto, CSSValueID::kContent, CSSValueID::kMinContent,
                                      CSSValueID::kMaxContent, CSSValueID::kFitContent>(stream.Peek().Id())) {
    return css_parsing_utils::ConsumeIdent(stream);
  }
  return css_parsing_utils::ConsumeLengthOrPercent(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative,
                                                   css_parsing_utils::UnitlessQuirk::kForbid, kCSSAnchorQueryTypesNone,
                                                   css_parsing_utils::AllowCalcSize::kAllowWithAutoAndContent);
}

std::shared_ptr<const CSSValue> FlexDirection::InitialValue() const {
  return CSSIdentifierValue::Create(CSSValueID::kRow);
}

std::shared_ptr<const CSSValue> FlexGrow::ParseSingleValue(CSSParserTokenStream& stream,
                                                           const CSSParserContext& context,
                                                           const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeNumber(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative);
}

std::shared_ptr<const CSSValue> FlexShrink::ParseSingleValue(CSSParserTokenStream& stream,
                                                             const CSSParserContext& context,
                                                             const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeNumber(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative);
}

std::shared_ptr<const CSSValue> FlexWrap::InitialValue() const {
  return CSSIdentifierValue::Create(CSSValueID::kNowrap);
}

std::shared_ptr<const CSSValue> FloodColor::ParseSingleValue(CSSParserTokenStream& stream,
                                                             const CSSParserContext& context,
                                                             const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeColor(stream, context);
}

std::shared_ptr<const CSSValue> FloodOpacity::ParseSingleValue(CSSParserTokenStream& stream,
                                                               const CSSParserContext& context,
                                                               const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeAlphaValue(stream, context);
}

std::shared_ptr<const CSSValue> FontFamily::ParseSingleValue(CSSParserTokenStream& stream,
                                                             const CSSParserContext&,
                                                             const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeFontFamily(stream);
}

std::shared_ptr<const CSSValue> FontFeatureSettings::ParseSingleValue(CSSParserTokenStream& stream,
                                                                      const CSSParserContext& context,
                                                                      const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeFontFeatureSettings(stream, context);
}

std::shared_ptr<const CSSValue> FontPalette::ParseSingleValue(CSSParserTokenStream& stream,
                                                              const CSSParserContext& context,
                                                              const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeFontPalette(stream, context);
}

std::shared_ptr<const CSSValue> FontSizeAdjust::ParseSingleValue(CSSParserTokenStream& stream,
                                                                 const CSSParserContext& context,
                                                                 const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeFontSizeAdjust(stream, context);
}

std::shared_ptr<const CSSValue> FontSize::ParseSingleValue(CSSParserTokenStream& stream,
                                                           const CSSParserContext& context,
                                                           const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeFontSize(stream, context, css_parsing_utils::UnitlessQuirk::kAllow);
}

std::shared_ptr<const CSSValue> FontStretch::ParseSingleValue(CSSParserTokenStream& stream,
                                                              const CSSParserContext& context,
                                                              const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeFontStretch(stream, context);
}

std::shared_ptr<const CSSValue> FontStyle::ParseSingleValue(CSSParserTokenStream& stream,
                                                            const CSSParserContext& context,
                                                            const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeFontStyle(stream, context);
}

std::shared_ptr<const CSSValue> FontVariantCaps::ParseSingleValue(CSSParserTokenStream& stream,
                                                                  const CSSParserContext& context,
                                                                  const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeIdent<CSSValueID::kNormal, CSSValueID::kSmallCaps, CSSValueID::kAllSmallCaps,
                                         CSSValueID::kPetiteCaps, CSSValueID::kAllPetiteCaps, CSSValueID::kUnicase,
                                         CSSValueID::kTitlingCaps>(stream);
}

std::shared_ptr<const CSSValue> FontVariantEastAsian::ParseSingleValue(CSSParserTokenStream& stream,
                                                                       const CSSParserContext& context,
                                                                       const CSSParserLocalContext&) const {
  if (stream.Peek().Id() == CSSValueID::kNormal) {
    return css_parsing_utils::ConsumeIdent(stream);
  }

  bool found_any = false;

  FontVariantEastAsianParser east_asian_parser;
  do {
    if (east_asian_parser.ConsumeEastAsian(stream) != FontVariantEastAsianParser::ParseResult::kConsumedValue) {
      break;
    }
    found_any = true;
  } while (!stream.AtEnd());

  if (!found_any) {
    return nullptr;
  }

  return east_asian_parser.FinalizeValue();
}

std::shared_ptr<const CSSValue> FontVariantLigatures::ParseSingleValue(CSSParserTokenStream& stream,
                                                                       const CSSParserContext& context,
                                                                       const CSSParserLocalContext&) const {
  if (stream.Peek().Id() == CSSValueID::kNormal || stream.Peek().Id() == CSSValueID::kNone) {
    return css_parsing_utils::ConsumeIdent(stream);
  }

  bool found_any = false;

  FontVariantLigaturesParser ligatures_parser;
  do {
    if (ligatures_parser.ConsumeLigature(stream) != FontVariantLigaturesParser::ParseResult::kConsumedValue) {
      break;
    }
    found_any = true;
  } while (!stream.AtEnd());

  if (!found_any) {
    return nullptr;
  }

  return ligatures_parser.FinalizeValue();
}

std::shared_ptr<const CSSValue> FontVariantNumeric::ParseSingleValue(CSSParserTokenStream& stream,
                                                                     const CSSParserContext& context,
                                                                     const CSSParserLocalContext&) const {
  if (stream.Peek().Id() == CSSValueID::kNormal) {
    return css_parsing_utils::ConsumeIdent(stream);
  }

  bool found_any = false;

  FontVariantNumericParser numeric_parser;
  do {
    if (numeric_parser.ConsumeNumeric(stream) != FontVariantNumericParser::ParseResult::kConsumedValue) {
      break;
    }
    found_any = true;
  } while (!stream.AtEnd());

  if (!found_any) {
    return nullptr;
  }

  return numeric_parser.FinalizeValue();
}

std::shared_ptr<const CSSValue> FontVariantAlternates::ParseSingleValue(CSSParserTokenStream& stream,
                                                                        const CSSParserContext& context,
                                                                        const CSSParserLocalContext&) const {
  if (stream.Peek().Id() == CSSValueID::kNormal) {
    return css_parsing_utils::ConsumeIdent(stream);
  }

  bool found_any = false;

  FontVariantAlternatesParser alternates_parser;
  do {
    if (alternates_parser.ConsumeAlternates(stream, context) !=
        FontVariantAlternatesParser::ParseResult::kConsumedValue) {
      break;
    }
    found_any = true;
  } while (!stream.AtEnd());

  if (!found_any) {
    return nullptr;
  }

  return alternates_parser.FinalizeValue();
}

namespace {

std::shared_ptr<const cssvalue::CSSFontVariationValue> ConsumeFontVariationTag(CSSParserTokenStream& stream,
                                                                               const CSSParserContext& context) {
  // Feature tag name consists of 4-letter characters.
  static const size_t kTagNameLength = 4;

  const CSSParserToken& token = stream.Peek();
  // Feature tag name comes first
  if (token.GetType() != kStringToken) {
    return nullptr;
  }
  if (token.Value().length() != kTagNameLength) {
    return nullptr;
  }
  std::string tag = token.Value();
  stream.ConsumeIncludingWhitespace();
  for (size_t i = 0; i < kTagNameLength; ++i) {
    // Limits the range of characters to 0x20-0x7E, following the tag name
    // rules defined in the OpenType specification.
    uint8_t character = tag[i];
    if (character < 0x20 || character > 0x7E) {
      return nullptr;
    }
  }

  double tag_value = 0;
  if (!css_parsing_utils::ConsumeNumberRaw(stream, context, tag_value)) {
    return nullptr;
  }
  return std::make_shared<cssvalue::CSSFontVariationValue>(tag, ClampTo<float>(tag_value));
}

}  // namespace

std::shared_ptr<const CSSValue> FontVariationSettings::ParseSingleValue(CSSParserTokenStream& stream,
                                                                        const CSSParserContext& context,
                                                                        const CSSParserLocalContext&) const {
  if (stream.Peek().Id() == CSSValueID::kNormal) {
    return css_parsing_utils::ConsumeIdent(stream);
  }
  std::shared_ptr<CSSValueList> variation_settings = CSSValueList::CreateCommaSeparated();
  do {
    std::shared_ptr<const cssvalue::CSSFontVariationValue> font_variation_value =
        ConsumeFontVariationTag(stream, context);
    if (!font_variation_value) {
      return nullptr;
    }
    variation_settings->Append(font_variation_value);
  } while (css_parsing_utils::ConsumeCommaIncludingWhitespace(stream));
  return variation_settings;
}

std::shared_ptr<const CSSValue> FontWeight::ParseSingleValue(CSSParserTokenStream& stream,
                                                             const CSSParserContext& context,
                                                             const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeFontWeight(stream, context);
}

std::shared_ptr<const CSSValue> GridAutoColumns::ParseSingleValue(CSSParserTokenStream& stream,
                                                                  const CSSParserContext& context,
                                                                  const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeGridTrackList(stream, context, css_parsing_utils::TrackListType::kGridAuto);
}

std::shared_ptr<const CSSValue> GridAutoColumns::InitialValue() const {
  return CSSIdentifierValue::Create(CSSValueID::kAuto);
}

std::shared_ptr<const CSSValue> GridAutoFlow::ParseSingleValue(CSSParserTokenStream& stream,
                                                               const CSSParserContext& context,
                                                               const CSSParserLocalContext&) const {
  std::shared_ptr<const CSSIdentifierValue> row_or_column_value =
      css_parsing_utils::ConsumeIdent<CSSValueID::kRow, CSSValueID::kColumn>(stream);
  std::shared_ptr<const CSSIdentifierValue> dense_algorithm =
      css_parsing_utils::ConsumeIdent<CSSValueID::kDense>(stream);
  if (!row_or_column_value) {
    row_or_column_value = css_parsing_utils::ConsumeIdent<CSSValueID::kRow, CSSValueID::kColumn>(stream);
    if (!row_or_column_value && !dense_algorithm) {
      return nullptr;
    }
  }
  std::shared_ptr<CSSValueList> parsed_values = CSSValueList::CreateSpaceSeparated();
  if (row_or_column_value) {
    CSSValueID value = row_or_column_value->GetValueID();
    if (value == CSSValueID::kColumn || (value == CSSValueID::kRow && !dense_algorithm)) {
      parsed_values->Append(row_or_column_value);
    }
  }
  if (dense_algorithm) {
    parsed_values->Append(dense_algorithm);
  }
  return parsed_values;
}

std::shared_ptr<const CSSValue> GridAutoFlow::InitialValue() const {
  return CSSIdentifierValue::Create(CSSValueID::kRow);
}

std::shared_ptr<const CSSValue> GridAutoRows::ParseSingleValue(CSSParserTokenStream& stream,
                                                               const CSSParserContext& context,
                                                               const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeGridTrackList(stream, context, css_parsing_utils::TrackListType::kGridAuto);
}

std::shared_ptr<const CSSValue> GridAutoRows::InitialValue() const {
  return CSSIdentifierValue::Create(CSSValueID::kAuto);
}

std::shared_ptr<const CSSValue> GridColumnEnd::ParseSingleValue(CSSParserTokenStream& stream,
                                                                const CSSParserContext& context,
                                                                const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeGridLine(stream, context);
}

std::shared_ptr<const CSSValue> GridColumnStart::ParseSingleValue(CSSParserTokenStream& stream,
                                                                  const CSSParserContext& context,
                                                                  const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeGridLine(stream, context);
}

std::shared_ptr<const CSSValue> GridRowEnd::ParseSingleValue(CSSParserTokenStream& stream,
                                                             const CSSParserContext& context,
                                                             const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeGridLine(stream, context);
}

std::shared_ptr<const CSSValue> GridRowStart::ParseSingleValue(CSSParserTokenStream& stream,
                                                               const CSSParserContext& context,
                                                               const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeGridLine(stream, context);
}

std::shared_ptr<const CSSValue> GridTemplateAreas::ParseSingleValue(CSSParserTokenStream& stream,
                                                                    const CSSParserContext&,
                                                                    const CSSParserLocalContext&) const {
  if (stream.Peek().Id() == CSSValueID::kNone) {
    return css_parsing_utils::ConsumeIdent(stream);
  }

  NamedGridAreaMap grid_area_map;
  size_t row_count = 0;
  size_t column_count = 0;

  while (stream.Peek().GetType() == kStringToken) {
    if (!css_parsing_utils::ParseGridTemplateAreasRow(stream.ConsumeIncludingWhitespace().Value(), grid_area_map,
                                                      row_count, column_count)) {
      return nullptr;
    }
    ++row_count;
  }

  if (row_count == 0) {
    return nullptr;
  }
  DCHECK(column_count);
  return std::make_shared<cssvalue::CSSGridTemplateAreasValue>(grid_area_map, row_count, column_count);
}

std::shared_ptr<const CSSValue> GridTemplateAreas::InitialValue() const {
  return CSSIdentifierValue::Create(CSSValueID::kNone);
}

std::shared_ptr<const CSSValue> GridTemplateColumns::ParseSingleValue(CSSParserTokenStream& stream,
                                                                      const CSSParserContext& context,
                                                                      const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeGridTemplatesRowsOrColumns(stream, context);
}

std::shared_ptr<const CSSValue> GridTemplateColumns::InitialValue() const {
  return CSSIdentifierValue::Create(CSSValueID::kNone);
}

std::shared_ptr<const CSSValue> GridTemplateRows::ParseSingleValue(CSSParserTokenStream& stream,
                                                                   const CSSParserContext& context,
                                                                   const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeGridTemplatesRowsOrColumns(stream, context);
}

std::shared_ptr<const CSSValue> GridTemplateRows::InitialValue() const {
  return CSSIdentifierValue::Create(CSSValueID::kNone);
}

std::shared_ptr<const CSSValue> Height::ParseSingleValue(CSSParserTokenStream& stream,
                                                         const CSSParserContext& context,
                                                         const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeWidthOrHeight(stream, context, css_parsing_utils::UnitlessQuirk::kAllow);
}

std::shared_ptr<const CSSValue> PopoverShowDelay::ParseSingleValue(CSSParserTokenStream& stream,
                                                                   const CSSParserContext& context,
                                                                   const CSSParserLocalContext& local_context) const {
  return css_parsing_utils::ConsumeTime(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative);
}

std::shared_ptr<const CSSValue> PopoverHideDelay::ParseSingleValue(CSSParserTokenStream& stream,
                                                                   const CSSParserContext& context,
                                                                   const CSSParserLocalContext& local_context) const {
  return css_parsing_utils::ConsumeTime(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative);
}

std::shared_ptr<const CSSValue> ImageOrientation::ParseSingleValue(CSSParserTokenStream& stream,
                                                                   const CSSParserContext& context,
                                                                   const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeIdent<CSSValueID::kFromImage, CSSValueID::kNone>(stream);
}

std::shared_ptr<const CSSValue> InitialLetter::ParseSingleValue(CSSParserTokenStream& stream,
                                                                const CSSParserContext& context,
                                                                const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeInitialLetter(stream, context);
}

std::shared_ptr<const CSSValue> InlineSize::ParseSingleValue(CSSParserTokenStream& stream,
                                                             const CSSParserContext& context,
                                                             const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeWidthOrHeight(stream, context);
}

std::shared_ptr<const CSSValue> InsetBlockEnd::ParseSingleValue(CSSParserTokenStream& stream,
                                                                const CSSParserContext& context,
                                                                const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeMarginOrOffset(stream, context, css_parsing_utils::UnitlessQuirk::kForbid,
                                                  static_cast<CSSAnchorQueryTypes>(CSSAnchorQueryType::kAnchor));
}

std::shared_ptr<const CSSValue> InsetBlockStart::ParseSingleValue(CSSParserTokenStream& stream,
                                                                  const CSSParserContext& context,
                                                                  const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeMarginOrOffset(stream, context, css_parsing_utils::UnitlessQuirk::kForbid,
                                                  static_cast<CSSAnchorQueryTypes>(CSSAnchorQueryType::kAnchor));
}

std::shared_ptr<const CSSValue> InsetInlineEnd::ParseSingleValue(CSSParserTokenStream& stream,
                                                                 const CSSParserContext& context,
                                                                 const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeMarginOrOffset(stream, context, css_parsing_utils::UnitlessQuirk::kForbid,
                                                  static_cast<CSSAnchorQueryTypes>(CSSAnchorQueryType::kAnchor));
}

std::shared_ptr<const CSSValue> InsetInlineStart::ParseSingleValue(CSSParserTokenStream& stream,
                                                                   const CSSParserContext& context,
                                                                   const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeMarginOrOffset(stream, context, css_parsing_utils::UnitlessQuirk::kForbid,
                                                  static_cast<CSSAnchorQueryTypes>(CSSAnchorQueryType::kAnchor));
}

std::shared_ptr<const CSSValue> JustifyContent::ParseSingleValue(CSSParserTokenStream& stream,
                                                                 const CSSParserContext& context,
                                                                 const CSSParserLocalContext&) const {
  // justify-content property does not allow the <baseline-position> values.
  if (css_parsing_utils::IdentMatches<CSSValueID::kFirst, CSSValueID::kLast, CSSValueID::kBaseline>(
          stream.Peek().Id())) {
    return nullptr;
  }
  return css_parsing_utils::ConsumeContentDistributionOverflowPosition(
      stream, css_parsing_utils::IsContentPositionOrLeftOrRightKeyword);
}

std::shared_ptr<const CSSValue> JustifyItems::ParseSingleValue(CSSParserTokenStream& stream,
                                                               const CSSParserContext& context,
                                                               const CSSParserLocalContext&) const {
  CSSParserTokenStream::State savepoint = stream.Save();
  // justify-items property does not allow the 'auto' value.
  if (css_parsing_utils::IdentMatches<CSSValueID::kAuto>(stream.Peek().Id())) {
    return nullptr;
  }
  std::shared_ptr<const CSSIdentifierValue> legacy = css_parsing_utils::ConsumeIdent<CSSValueID::kLegacy>(stream);
  std::shared_ptr<const CSSIdentifierValue> position_keyword =
      css_parsing_utils::ConsumeIdent<CSSValueID::kCenter, CSSValueID::kLeft, CSSValueID::kRight>(stream);
  if (!legacy) {
    legacy = css_parsing_utils::ConsumeIdent<CSSValueID::kLegacy>(stream);
  }
  if (!legacy) {
    stream.Restore(savepoint);
  }
  if (legacy) {
    if (position_keyword) {
      return std::make_shared<CSSValuePair>(legacy, position_keyword, CSSValuePair::kDropIdenticalValues);
    }
    return legacy;
  }

  return css_parsing_utils::ConsumeSelfPositionOverflowPosition(stream,
                                                                css_parsing_utils::IsSelfPositionOrLeftOrRightKeyword);
}

std::shared_ptr<const CSSValue> JustifySelf::ParseSingleValue(CSSParserTokenStream& stream,
                                                              const CSSParserContext& context,
                                                              const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeSelfPositionOverflowPosition(stream,
                                                                css_parsing_utils::IsSelfPositionOrLeftOrRightKeyword);
}

std::shared_ptr<const CSSValue> Left::ParseSingleValue(CSSParserTokenStream& stream,
                                                       const CSSParserContext& context,
                                                       const CSSParserLocalContext& local_context) const {
  return css_parsing_utils::ConsumeMarginOrOffset(stream, context,
                                                  css_parsing_utils::UnitlessUnlessShorthand(local_context),
                                                  static_cast<CSSAnchorQueryTypes>(CSSAnchorQueryType::kAnchor));
}

std::shared_ptr<const CSSValue> LetterSpacing::ParseSingleValue(CSSParserTokenStream& stream,
                                                                const CSSParserContext& context,
                                                                const CSSParserLocalContext&) const {
  return css_parsing_utils::ParseSpacing(stream, context);
}

std::shared_ptr<const CSSValue> LightingColor::ParseSingleValue(CSSParserTokenStream& stream,
                                                                const CSSParserContext& context,
                                                                const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeColor(stream, context);
}

std::shared_ptr<const CSSValue> LineClamp::ParseSingleValue(CSSParserTokenStream& stream,
                                                            const CSSParserContext& context,
                                                            const CSSParserLocalContext&) const {
  if (stream.Peek().Id() == CSSValueID::kNone || stream.Peek().Id() == CSSValueID::kAuto) {
    return css_parsing_utils::ConsumeIdent(stream);
  } else {
    return css_parsing_utils::ConsumePositiveInteger(stream, context);
  }
}

std::shared_ptr<const CSSValue> LineHeight::ParseSingleValue(CSSParserTokenStream& stream,
                                                             const CSSParserContext& context,
                                                             const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeLineHeight(stream, context);
}

std::shared_ptr<const CSSValue> ListStyleImage::ParseSingleValue(CSSParserTokenStream& stream,
                                                                 const CSSParserContext& context,
                                                                 const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeImageOrNone(stream, context);
}

std::shared_ptr<const CSSValue> ListStyleType::ParseSingleValue(CSSParserTokenStream& stream,
                                                                const CSSParserContext& context,
                                                                const CSSParserLocalContext&) const {
  if (auto none = css_parsing_utils::ConsumeIdent<CSSValueID::kNone>(stream)) {
    return none;
  }

  return css_parsing_utils::ConsumeString(stream);
}

std::shared_ptr<const CSSValue> MarginBlockEnd::ParseSingleValue(CSSParserTokenStream& stream,
                                                                 const CSSParserContext& context,
                                                                 const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeMarginOrOffset(stream, context, css_parsing_utils::UnitlessQuirk::kForbid);
}

std::shared_ptr<const CSSValue> MarginBlockStart::ParseSingleValue(CSSParserTokenStream& stream,
                                                                   const CSSParserContext& context,
                                                                   const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeMarginOrOffset(stream, context, css_parsing_utils::UnitlessQuirk::kForbid);
}

std::shared_ptr<const CSSValue> MarginBottom::ParseSingleValue(CSSParserTokenStream& stream,
                                                               const CSSParserContext& context,
                                                               const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeMarginOrOffset(stream, context, css_parsing_utils::UnitlessQuirk::kAllow);
}

std::shared_ptr<const CSSValue> MarginInlineEnd::ParseSingleValue(CSSParserTokenStream& stream,
                                                                  const CSSParserContext& context,
                                                                  const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeMarginOrOffset(stream, context, css_parsing_utils::UnitlessQuirk::kForbid);
}

std::shared_ptr<const CSSValue> MarginInlineStart::ParseSingleValue(CSSParserTokenStream& stream,
                                                                    const CSSParserContext& context,
                                                                    const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeMarginOrOffset(stream, context, css_parsing_utils::UnitlessQuirk::kForbid);
}

std::shared_ptr<const CSSValue> MarginLeft::ParseSingleValue(CSSParserTokenStream& stream,
                                                             const CSSParserContext& context,
                                                             const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeMarginOrOffset(stream, context, css_parsing_utils::UnitlessQuirk::kAllow);
}

std::shared_ptr<const CSSValue> MarginRight::ParseSingleValue(CSSParserTokenStream& stream,
                                                              const CSSParserContext& context,
                                                              const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeMarginOrOffset(stream, context, css_parsing_utils::UnitlessQuirk::kAllow);
}

std::shared_ptr<const CSSValue> MarginTop::ParseSingleValue(CSSParserTokenStream& stream,
                                                            const CSSParserContext& context,
                                                            const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeMarginOrOffset(stream, context, css_parsing_utils::UnitlessQuirk::kAllow);
}

std::shared_ptr<const CSSValue> MarkerEnd::ParseSingleValue(CSSParserTokenStream& stream,
                                                            const CSSParserContext& context,
                                                            const CSSParserLocalContext&) const {
  if (stream.Peek().Id() == CSSValueID::kNone) {
    return css_parsing_utils::ConsumeIdent(stream);
  }
  return css_parsing_utils::ConsumeUrl(stream, context);
}

std::shared_ptr<const CSSValue> MarkerMid::ParseSingleValue(CSSParserTokenStream& stream,
                                                            const CSSParserContext& context,
                                                            const CSSParserLocalContext&) const {
  if (stream.Peek().Id() == CSSValueID::kNone) {
    return css_parsing_utils::ConsumeIdent(stream);
  }
  return css_parsing_utils::ConsumeUrl(stream, context);
}

std::shared_ptr<const CSSValue> MarkerStart::ParseSingleValue(CSSParserTokenStream& stream,
                                                              const CSSParserContext& context,
                                                              const CSSParserLocalContext&) const {
  if (stream.Peek().Id() == CSSValueID::kNone) {
    return css_parsing_utils::ConsumeIdent(stream);
  }
  return css_parsing_utils::ConsumeUrl(stream, context);
}

std::shared_ptr<const CSSValue> MaxBlockSize::ParseSingleValue(CSSParserTokenStream& stream,
                                                               const CSSParserContext& context,
                                                               const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeMaxWidthOrHeight(stream, context);
}

std::shared_ptr<const CSSValue> MaxHeight::ParseSingleValue(CSSParserTokenStream& stream,
                                                            const CSSParserContext& context,
                                                            const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeMaxWidthOrHeight(stream, context, css_parsing_utils::UnitlessQuirk::kAllow);
}

std::shared_ptr<const CSSValue> MaxInlineSize::ParseSingleValue(CSSParserTokenStream& stream,
                                                                const CSSParserContext& context,
                                                                const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeMaxWidthOrHeight(stream, context);
}

std::shared_ptr<const CSSValue> MaxWidth::ParseSingleValue(CSSParserTokenStream& stream,
                                                           const CSSParserContext& context,
                                                           const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeMaxWidthOrHeight(stream, context, css_parsing_utils::UnitlessQuirk::kAllow);
}

std::shared_ptr<const CSSValue> MinBlockSize::ParseSingleValue(CSSParserTokenStream& stream,
                                                               const CSSParserContext& context,
                                                               const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeWidthOrHeight(stream, context);
}

std::shared_ptr<const CSSValue> MinHeight::ParseSingleValue(CSSParserTokenStream& stream,
                                                            const CSSParserContext& context,
                                                            const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeWidthOrHeight(stream, context, css_parsing_utils::UnitlessQuirk::kAllow);
}

std::shared_ptr<const CSSValue> MinInlineSize::ParseSingleValue(CSSParserTokenStream& stream,
                                                                const CSSParserContext& context,
                                                                const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeWidthOrHeight(stream, context);
}

std::shared_ptr<const CSSValue> MinWidth::ParseSingleValue(CSSParserTokenStream& stream,
                                                           const CSSParserContext& context,
                                                           const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeWidthOrHeight(stream, context, css_parsing_utils::UnitlessQuirk::kAllow);
}

std::shared_ptr<const CSSValue> ObjectPosition::ParseSingleValue(CSSParserTokenStream& stream,
                                                                 const CSSParserContext& context,
                                                                 const CSSParserLocalContext&) const {
  return ConsumePosition(stream, context, css_parsing_utils::UnitlessQuirk::kForbid);
}

std::shared_ptr<const CSSValue> ObjectViewBox::ParseSingleValue(CSSParserTokenStream& stream,
                                                                const CSSParserContext& context,
                                                                const CSSParserLocalContext&) const {
  if (stream.Peek().Id() == CSSValueID::kNone) {
    return css_parsing_utils::ConsumeIdent(stream);
  }
  auto css_value = css_parsing_utils::ConsumeBasicShape(stream, context, css_parsing_utils::AllowPathValue::kForbid);

  if (!css_value || css_value->IsBasicShapeInsetValue() || css_value->IsBasicShapeRectValue() ||
      css_value->IsBasicShapeXYWHValue()) {
    return css_value;
  }

  return nullptr;
}

std::shared_ptr<const CSSValue> OffsetAnchor::ParseSingleValue(CSSParserTokenStream& stream,
                                                               const CSSParserContext& context,
                                                               const CSSParserLocalContext&) const {
  CSSValueID id = stream.Peek().Id();
  if (id == CSSValueID::kAuto) {
    return css_parsing_utils::ConsumeIdent(stream);
  }
  return css_parsing_utils::ConsumePosition(stream, context, css_parsing_utils::UnitlessQuirk::kForbid);
}

std::shared_ptr<const CSSValue> OffsetDistance::ParseSingleValue(CSSParserTokenStream& stream,
                                                                 const CSSParserContext& context,
                                                                 const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeLengthOrPercent(stream, context, CSSPrimitiveValue::ValueRange::kAll);
}

std::shared_ptr<const CSSValue> OffsetPath::ParseSingleValue(CSSParserTokenStream& stream,
                                                             const CSSParserContext& context,
                                                             const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeOffsetPath(stream, context);
}

std::shared_ptr<const CSSValue> OffsetPosition::ParseSingleValue(CSSParserTokenStream& stream,
                                                                 const CSSParserContext& context,
                                                                 const CSSParserLocalContext&) const {
  CSSValueID id = stream.Peek().Id();
  if (id == CSSValueID::kAuto) {
    return css_parsing_utils::ConsumeIdent(stream);
  }
  if (id == CSSValueID::kNormal) {
    return css_parsing_utils::ConsumeIdent(stream);
  }
  auto value = css_parsing_utils::ConsumePosition(stream, context, css_parsing_utils::UnitlessQuirk::kForbid);
  return value;
}

std::shared_ptr<const CSSValue> OffsetRotate::ParseSingleValue(CSSParserTokenStream& stream,
                                                               const CSSParserContext& context,
                                                               const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeOffsetRotate(stream, context);
}

std::shared_ptr<const CSSValue> Opacity::ParseSingleValue(CSSParserTokenStream& stream,
                                                          const CSSParserContext& context,
                                                          const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeAlphaValue(stream, context);
}

std::shared_ptr<const CSSValue> Order::ParseSingleValue(CSSParserTokenStream& stream,
                                                        const CSSParserContext& context,
                                                        const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeInteger(stream, context);
}

std::shared_ptr<const CSSValue> Orphans::ParseSingleValue(CSSParserTokenStream& stream,
                                                          const CSSParserContext& context,
                                                          const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumePositiveInteger(stream, context);
}

std::shared_ptr<const CSSValue> OutlineColor::ParseSingleValue(CSSParserTokenStream& stream,
                                                               const CSSParserContext& context,
                                                               const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeColor(stream, context);
}

std::shared_ptr<const CSSValue> AccentColor::ParseSingleValue(CSSParserTokenStream& stream,
                                                              const CSSParserContext& context,
                                                              const CSSParserLocalContext&) const {
  if (stream.Peek().Id() == CSSValueID::kAuto) {
    return css_parsing_utils::ConsumeIdent(stream);
  }
  return css_parsing_utils::ConsumeColor(stream, context);
}

std::shared_ptr<const CSSValue> OutlineOffset::ParseSingleValue(CSSParserTokenStream& stream,
                                                                const CSSParserContext& context,
                                                                const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeLength(stream, context, CSSPrimitiveValue::ValueRange::kAll);
}

std::shared_ptr<const CSSValue> OutlineWidth::ParseSingleValue(CSSParserTokenStream& stream,
                                                               const CSSParserContext& context,
                                                               const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeLineWidth(stream, context, css_parsing_utils::UnitlessQuirk::kForbid);
}

std::shared_ptr<const CSSValue> OverflowClipMargin::ParseSingleValue(CSSParserTokenStream& stream,
                                                                     const CSSParserContext& context,
                                                                     const CSSParserLocalContext&) const {
  std::shared_ptr<const CSSPrimitiveValue> length;
  std::shared_ptr<const CSSIdentifierValue> reference_box;

  if (stream.Peek().GetType() != kIdentToken && stream.Peek().GetType() != kDimensionToken) {
    return nullptr;
  }

  if (stream.Peek().GetType() == kIdentToken) {
    reference_box = css_parsing_utils::ConsumeVisualBox(stream);
    length = css_parsing_utils::ConsumeLength(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative);
  } else {
    length = css_parsing_utils::ConsumeLength(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative);
    reference_box = css_parsing_utils::ConsumeVisualBox(stream);
  }

  // At least one of |reference_box| and |length| must be provided.
  if (!reference_box && !length) {
    return nullptr;
  }

  if (reference_box && reference_box->GetValueID() == CSSValueID::kPaddingBox) {
    reference_box = nullptr;
    if (!length) {
      length = CSSPrimitiveValue::CreateFromLength(Length::Fixed(0), 1.f);
    }
  } else if (reference_box && length && length->IsZero() == CSSPrimitiveValue::BoolStatus::kTrue) {
    length = nullptr;
  }

  auto css_value_list = CSSValueList::CreateSpaceSeparated();
  if (reference_box) {
    css_value_list->Append(reference_box);
  }
  if (length) {
    css_value_list->Append(length);
  }
  return css_value_list;
}

std::shared_ptr<const CSSValue> PaddingBlockEnd::ParseSingleValue(CSSParserTokenStream& stream,
                                                                  const CSSParserContext& context,
                                                                  const CSSParserLocalContext&) const {
  return ConsumeLengthOrPercent(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative,
                                css_parsing_utils::UnitlessQuirk::kForbid);
}

std::shared_ptr<const CSSValue> PaddingBlockStart::ParseSingleValue(CSSParserTokenStream& stream,
                                                                    const CSSParserContext& context,
                                                                    const CSSParserLocalContext&) const {
  return ConsumeLengthOrPercent(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative,
                                css_parsing_utils::UnitlessQuirk::kForbid);
}

std::shared_ptr<const CSSValue> PaddingBottom::ParseSingleValue(CSSParserTokenStream& stream,
                                                                const CSSParserContext& context,
                                                                const CSSParserLocalContext&) const {
  return ConsumeLengthOrPercent(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative,
                                css_parsing_utils::UnitlessQuirk::kAllow);
}

std::shared_ptr<const CSSValue> PaddingInlineEnd::ParseSingleValue(CSSParserTokenStream& stream,
                                                                   const CSSParserContext& context,
                                                                   const CSSParserLocalContext&) const {
  return ConsumeLengthOrPercent(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative,
                                css_parsing_utils::UnitlessQuirk::kForbid);
}

std::shared_ptr<const CSSValue> PaddingInlineStart::ParseSingleValue(CSSParserTokenStream& stream,
                                                                     const CSSParserContext& context,
                                                                     const CSSParserLocalContext&) const {
  return ConsumeLengthOrPercent(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative,
                                css_parsing_utils::UnitlessQuirk::kForbid);
}

std::shared_ptr<const CSSValue> PaddingLeft::ParseSingleValue(CSSParserTokenStream& stream,
                                                              const CSSParserContext& context,
                                                              const CSSParserLocalContext&) const {
  return ConsumeLengthOrPercent(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative,
                                css_parsing_utils::UnitlessQuirk::kAllow);
}

std::shared_ptr<const CSSValue> PaddingRight::ParseSingleValue(CSSParserTokenStream& stream,
                                                               const CSSParserContext& context,
                                                               const CSSParserLocalContext&) const {
  return ConsumeLengthOrPercent(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative,
                                css_parsing_utils::UnitlessQuirk::kAllow);
}

std::shared_ptr<const CSSValue> PaddingTop::ParseSingleValue(CSSParserTokenStream& stream,
                                                             const CSSParserContext& context,
                                                             const CSSParserLocalContext&) const {
  return ConsumeLengthOrPercent(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative,
                                css_parsing_utils::UnitlessQuirk::kAllow);
}

std::shared_ptr<const CSSValue> Page::ParseSingleValue(CSSParserTokenStream& stream,
                                                       const CSSParserContext& context,
                                                       const CSSParserLocalContext&) const {
  if (stream.Peek().Id() == CSSValueID::kAuto) {
    return css_parsing_utils::ConsumeIdent(stream);
  }
  return css_parsing_utils::ConsumeCustomIdent(stream, context);
}

std::shared_ptr<const CSSValue> Perspective::ParseSingleValue(CSSParserTokenStream& stream,
                                                              const CSSParserContext& context,
                                                              const CSSParserLocalContext& localContext) const {
  if (stream.Peek().Id() == CSSValueID::kNone) {
    return css_parsing_utils::ConsumeIdent(stream);
  }
  std::shared_ptr<const CSSPrimitiveValue> parsed_value =
      css_parsing_utils::ConsumeLength(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative);
  bool use_legacy_parsing = localContext.UseAliasParsing();
  if (!parsed_value && use_legacy_parsing) {
    double perspective;
    if (!css_parsing_utils::ConsumeNumberRaw(stream, context, perspective) || perspective < 0.0) {
      return nullptr;
    }
    parsed_value = CSSNumericLiteralValue::Create(perspective, CSSPrimitiveValue::UnitType::kPixels);
  }
  return parsed_value;
}

std::shared_ptr<const CSSValue> PerspectiveOrigin::ParseSingleValue(CSSParserTokenStream& stream,
                                                                    const CSSParserContext& context,
                                                                    const CSSParserLocalContext&) const {
  return ConsumePosition(stream, context, css_parsing_utils::UnitlessQuirk::kForbid);
}

std::shared_ptr<const CSSValue> Quotes::ParseSingleValue(CSSParserTokenStream& stream,
                                                         const CSSParserContext& context,
                                                         const CSSParserLocalContext&) const {
  if (auto value = css_parsing_utils::ConsumeIdent<CSSValueID::kAuto, CSSValueID::kNone>(stream)) {
    return value;
  }
  std::shared_ptr<CSSValueList> values = CSSValueList::CreateSpaceSeparated();
  while (!stream.AtEnd()) {
    std::shared_ptr<const CSSStringValue> parsed_value = css_parsing_utils::ConsumeString(stream);
    if (!parsed_value) {
      // NOTE: Technically, if we consumed an odd number of strings,
      // we should have returned success here but un-consumed
      // the last string (since we should allow any arbitrary junk).
      // However, in practice, the only thing we need to care about
      // is !important, since we're not part of a shorthand,
      // so we let it slip.
      break;
    }
    values->Append(parsed_value);
  }
  if (values->length() && values->length() % 2 == 0) {
    return values;
  }
  return nullptr;
}

std::shared_ptr<const CSSValue> Right::ParseSingleValue(CSSParserTokenStream& stream,
                                                        const CSSParserContext& context,
                                                        const CSSParserLocalContext& local_context) const {
  return css_parsing_utils::ConsumeMarginOrOffset(stream, context,
                                                  css_parsing_utils::UnitlessUnlessShorthand(local_context),
                                                  static_cast<CSSAnchorQueryTypes>(CSSAnchorQueryType::kAnchor));
}

std::shared_ptr<const CSSValue> Rotate::ParseSingleValue(CSSParserTokenStream& stream,
                                                         const CSSParserContext& context,
                                                         const CSSParserLocalContext&) const {
  CSSValueID id = stream.Peek().Id();
  if (id == CSSValueID::kNone) {
    return css_parsing_utils::ConsumeIdent(stream);
  }

  std::shared_ptr<CSSValueList> list = CSSValueList::CreateSpaceSeparated();

  std::shared_ptr<const CSSValue> rotation = css_parsing_utils::ConsumeAngle(stream, context);

  std::shared_ptr<const CSSValue> axis = css_parsing_utils::ConsumeAxis(stream, context);
  if (axis) {
    if (To<cssvalue::CSSAxisValue>(axis.get())->AxisName() != CSSValueID::kZ) {
      // The z axis should be normalized away and stored as a 2D rotate.
      list->Append(axis);
    }
  } else if (!rotation) {
    return nullptr;
  }

  if (!rotation) {
    rotation = css_parsing_utils::ConsumeAngle(stream, context);
    if (!rotation) {
      return nullptr;
    }
  }
  list->Append(rotation);

  return list;
}

std::shared_ptr<const CSSValue> RowGap::ParseSingleValue(CSSParserTokenStream& stream,
                                                         const CSSParserContext& context,
                                                         const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeGapLength(stream, context);
}

std::shared_ptr<const CSSValue> Scale::ParseSingleValue(CSSParserTokenStream& stream,
                                                        const CSSParserContext& context,
                                                        const CSSParserLocalContext&) const {
  CSSValueID id = stream.Peek().Id();
  if (id == CSSValueID::kNone) {
    return css_parsing_utils::ConsumeIdent(stream);
  }

  std::shared_ptr<const CSSPrimitiveValue> x_scale =
      css_parsing_utils::ConsumeNumberOrPercent(stream, context, CSSPrimitiveValue::ValueRange::kAll);
  if (!x_scale) {
    return nullptr;
  }

  std::shared_ptr<CSSValueList> list = CSSValueList::CreateSpaceSeparated();
  list->Append(x_scale);

  std::shared_ptr<const CSSPrimitiveValue> y_scale =
      css_parsing_utils::ConsumeNumberOrPercent(stream, context, CSSPrimitiveValue::ValueRange::kAll);
  if (y_scale) {
    std::shared_ptr<const CSSPrimitiveValue> z_scale =
        css_parsing_utils::ConsumeNumberOrPercent(stream, context, CSSPrimitiveValue::ValueRange::kAll);
    if (z_scale &&
        (!z_scale->IsNumericLiteralValue() || To<CSSNumericLiteralValue>(z_scale.get())->DoubleValue() != 1.0)) {
      list->Append(y_scale);
      list->Append(z_scale);
    } else if (!x_scale->IsNumericLiteralValue() || !y_scale->IsNumericLiteralValue() ||
               To<CSSNumericLiteralValue>(x_scale.get())->DoubleValue() !=
                   To<CSSNumericLiteralValue>(y_scale.get())->DoubleValue()) {
      list->Append(y_scale);
    }
  }

  return list;
}


static std::shared_ptr<const CSSValue> ConsumePageSize(CSSParserTokenStream& stream) {
  return css_parsing_utils::ConsumeIdent<CSSValueID::kA3, CSSValueID::kA4, CSSValueID::kA5, CSSValueID::kB4,
                                         CSSValueID::kB5, CSSValueID::kJisB5, CSSValueID::kJisB4, CSSValueID::kLedger,
                                         CSSValueID::kLegal, CSSValueID::kLetter>(stream);
}

static float MmToPx(float mm) {
  return mm * kCssPixelsPerMillimeter;
}
static float InchToPx(float inch) {
  return inch * kCssPixelsPerInch;
}
static gfx::SizeF GetPageSizeFromName(const CSSIdentifierValue& page_size_name) {
  switch (page_size_name.GetValueID()) {
    case CSSValueID::kA5:
      return gfx::SizeF(MmToPx(148), MmToPx(210));
    case CSSValueID::kA4:
      return gfx::SizeF(MmToPx(210), MmToPx(297));
    case CSSValueID::kA3:
      return gfx::SizeF(MmToPx(297), MmToPx(420));
    case CSSValueID::kB5:
      return gfx::SizeF(MmToPx(176), MmToPx(250));
    case CSSValueID::kB4:
      return gfx::SizeF(MmToPx(250), MmToPx(353));
    case CSSValueID::kJisB5:
      return gfx::SizeF(MmToPx(182), MmToPx(257));
    case CSSValueID::kJisB4:
      return gfx::SizeF(MmToPx(257), MmToPx(364));
    case CSSValueID::kLetter:
      return gfx::SizeF(InchToPx(8.5), InchToPx(11));
    case CSSValueID::kLegal:
      return gfx::SizeF(InchToPx(8.5), InchToPx(14));
    case CSSValueID::kLedger:
      return gfx::SizeF(InchToPx(11), InchToPx(17));
    default:
      NOTREACHED_IN_MIGRATION();
      return gfx::SizeF(0, 0);
  }
}

std::shared_ptr<const CSSValue> Size::ParseSingleValue(CSSParserTokenStream& stream,
                                                       const CSSParserContext& context,
                                                       const CSSParserLocalContext&) const {
  std::shared_ptr<CSSValueList> result = CSSValueList::CreateSpaceSeparated();

  if (stream.Peek().Id() == CSSValueID::kAuto) {
    result->Append(css_parsing_utils::ConsumeIdent(stream));
    return result;
  }

  if (std::shared_ptr<const CSSValue> width =
          css_parsing_utils::ConsumeLength(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative)) {
    std::shared_ptr<const CSSValue> height = css_parsing_utils::ConsumeLength(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative);
    result->Append(width);
    if (height) {
      result->Append(height);
    }
    return result;
  }

  std::shared_ptr<const CSSValue> page_size = ConsumePageSize(stream);
  std::shared_ptr<const CSSValue> orientation = css_parsing_utils::ConsumeIdent<CSSValueID::kPortrait, CSSValueID::kLandscape>(stream);
  if (!page_size) {
    page_size = ConsumePageSize(stream);
  }

  if (!orientation && !page_size) {
    return nullptr;
  }
  if (page_size) {
    result->Append(page_size);
  }
  if (orientation) {
    result->Append(orientation);
  }
  return result;
}

void Size::ApplyInitial(StyleResolverState& state) const {}

void Size::ApplyInherit(StyleResolverState& state) const {}

std::shared_ptr<const CSSValue> StopColor::ParseSingleValue(CSSParserTokenStream& stream,
                                                            const CSSParserContext& context,
                                                            const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeColor(stream, context);
}

std::shared_ptr<const CSSValue> StopOpacity::ParseSingleValue(CSSParserTokenStream& stream,
                                                              const CSSParserContext& context,
                                                              const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeAlphaValue(stream, context);
}

std::shared_ptr<const CSSValue> ContentVisibility::ParseSingleValue(CSSParserTokenStream& stream,
                                                                    const CSSParserContext& context,
                                                                    const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeIdent<CSSValueID::kVisible, CSSValueID::kAuto, CSSValueID::kHidden>(stream);
}

std::shared_ptr<const CSSValue> TabSize::ParseSingleValue(CSSParserTokenStream& stream,
                                                          const CSSParserContext& context,
                                                          const CSSParserLocalContext&) const {
  std::shared_ptr<const CSSPrimitiveValue> parsed_value =
      css_parsing_utils::ConsumeNumber(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative);
  if (parsed_value) {
    return parsed_value;
  }
  return css_parsing_utils::ConsumeLength(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative);
}

std::shared_ptr<const CSSValue> TextBoxEdge::ParseSingleValue(CSSParserTokenStream& stream,
                                                              const CSSParserContext& context,
                                                              const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeTextBoxEdge(stream);
}

std::shared_ptr<const CSSValue> TextDecorationColor::ParseSingleValue(CSSParserTokenStream& stream,
                                                                      const CSSParserContext& context,
                                                                      const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeColor(stream, context);
}

std::shared_ptr<const CSSValue> TextDecorationLine::ParseSingleValue(CSSParserTokenStream& stream,
                                                                     const CSSParserContext&,
                                                                     const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeTextDecorationLine(stream);
}

std::shared_ptr<const CSSValue> TextDecorationThickness::ParseSingleValue(CSSParserTokenStream& stream,
                                                                          const CSSParserContext& context,
                                                                          const CSSParserLocalContext&) const {
  if (auto ident = css_parsing_utils::ConsumeIdent<CSSValueID::kFromFont, CSSValueID::kAuto>(stream)) {
    return ident;
  }
  return css_parsing_utils::ConsumeLengthOrPercent(stream, context, CSSPrimitiveValue::ValueRange::kAll);
}

std::shared_ptr<const CSSValue> TextIndent::ParseSingleValue(CSSParserTokenStream& stream,
                                                             const CSSParserContext& context,
                                                             const CSSParserLocalContext&) const {
  // [ <length> | <percentage> ]
  auto length_percentage = css_parsing_utils::ConsumeLengthOrPercent(
      stream, context, CSSPrimitiveValue::ValueRange::kAll, css_parsing_utils::UnitlessQuirk::kAllow);
  if (!length_percentage) {
    return nullptr;
  }
  std::shared_ptr<CSSValueList> list = CSSValueList::CreateSpaceSeparated();
  list->Append(length_percentage);

  return list;
}

std::shared_ptr<const CSSValue> TextShadow::ParseSingleValue(CSSParserTokenStream& stream,
                                                             const CSSParserContext& context,
                                                             const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeShadow(stream, context, css_parsing_utils::AllowInsetAndSpread::kForbid);
}

std::shared_ptr<const CSSValue> TextSizeAdjust::ParseSingleValue(CSSParserTokenStream& stream,
                                                                 const CSSParserContext& context,
                                                                 const CSSParserLocalContext&) const {
  if (stream.Peek().Id() == CSSValueID::kAuto) {
    return css_parsing_utils::ConsumeIdent(stream);
  }
  if (stream.Peek().Id() == CSSValueID::kNone) {
    return css_parsing_utils::ConsumeIdent(stream);
  }
  return css_parsing_utils::ConsumePercent(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative);
}

// https://drafts.csswg.org/css-text-decor-4/#text-underline-position-property
// auto | [ from-font | under ] || [ left | right ] - default: auto
std::shared_ptr<const CSSValue> TextUnderlinePosition::ParseSingleValue(CSSParserTokenStream& stream,
                                                                        const CSSParserContext& context,
                                                                        const CSSParserLocalContext&) const {
  if (stream.Peek().Id() == CSSValueID::kAuto) {
    return css_parsing_utils::ConsumeIdent(stream);
  }

  std::shared_ptr<const CSSIdentifierValue> from_font_or_under_value =
      css_parsing_utils::ConsumeIdent<CSSValueID::kFromFont, CSSValueID::kUnder>(stream);
  std::shared_ptr<const CSSIdentifierValue> left_or_right_value =
      css_parsing_utils::ConsumeIdent<CSSValueID::kLeft, CSSValueID::kRight>(stream);
  if (left_or_right_value && !from_font_or_under_value) {
    from_font_or_under_value = css_parsing_utils::ConsumeIdent<CSSValueID::kFromFont, CSSValueID::kUnder>(stream);
  }
  if (!from_font_or_under_value && !left_or_right_value) {
    return nullptr;
  }
  std::shared_ptr<CSSValueList> list = CSSValueList::CreateSpaceSeparated();
  if (from_font_or_under_value) {
    list->Append(from_font_or_under_value);
  }
  if (left_or_right_value) {
    list->Append(left_or_right_value);
  }
  return list;
}

std::shared_ptr<const CSSValue> TextUnderlineOffset::ParseSingleValue(CSSParserTokenStream& stream,
                                                                      const CSSParserContext& context,
                                                                      const CSSParserLocalContext&) const {
  if (stream.Peek().Id() == CSSValueID::kAuto) {
    return css_parsing_utils::ConsumeIdent(stream);
  }
  return css_parsing_utils::ConsumeLengthOrPercent(stream, context, CSSPrimitiveValue::ValueRange::kAll);
}

std::shared_ptr<const CSSValue> Top::ParseSingleValue(CSSParserTokenStream& stream,
                                                      const CSSParserContext& context,
                                                      const CSSParserLocalContext& local_context) const {
  return css_parsing_utils::ConsumeMarginOrOffset(stream, context,
                                                  css_parsing_utils::UnitlessUnlessShorthand(local_context),
                                                  static_cast<CSSAnchorQueryTypes>(CSSAnchorQueryType::kAnchor));
}

namespace {

static bool ConsumePan(CSSParserTokenStream& stream,
                       std::shared_ptr<const CSSValue>& pan_x,
                       std::shared_ptr<const CSSValue>& pan_y,
                       std::shared_ptr<const CSSValue>& pinch_zoom) {
  CSSValueID id = stream.Peek().Id();
  if ((id == CSSValueID::kPanX || id == CSSValueID::kPanRight || id == CSSValueID::kPanLeft) && !pan_x) {
    pan_x = css_parsing_utils::ConsumeIdent(stream);
  } else if ((id == CSSValueID::kPanY || id == CSSValueID::kPanDown || id == CSSValueID::kPanUp) && !pan_y) {
    pan_y = css_parsing_utils::ConsumeIdent(stream);
  } else if (id == CSSValueID::kPinchZoom && !pinch_zoom) {
    pinch_zoom = css_parsing_utils::ConsumeIdent(stream);
  } else {
    return false;
  }
  return true;
}

}  // namespace

std::shared_ptr<const CSSValue> TouchAction::ParseSingleValue(CSSParserTokenStream& stream,
                                                              const CSSParserContext& context,
                                                              const CSSParserLocalContext&) const {
  std::shared_ptr<CSSValueList> list = CSSValueList::CreateSpaceSeparated();
  CSSValueID id = stream.Peek().Id();
  if (id == CSSValueID::kAuto || id == CSSValueID::kNone || id == CSSValueID::kManipulation) {
    list->Append(css_parsing_utils::ConsumeIdent(stream));
    return list;
  }

  std::shared_ptr<const CSSValue> pan_x = nullptr;
  std::shared_ptr<const CSSValue> pan_y = nullptr;
  std::shared_ptr<const CSSValue> pinch_zoom = nullptr;
  if (!ConsumePan(stream, pan_x, pan_y, pinch_zoom)) {
    return nullptr;
  }
  ConsumePan(stream, pan_x, pan_y, pinch_zoom);  // May fail.
  ConsumePan(stream, pan_x, pan_y, pinch_zoom);  // May fail.

  if (pan_x) {
    list->Append(pan_x);
  }
  if (pan_y) {
    list->Append(pan_y);
  }
  if (pinch_zoom) {
    list->Append(pinch_zoom);
  }
  return list;
}

std::shared_ptr<const CSSValue> Transform::ParseSingleValue(CSSParserTokenStream& stream,
                                                            const CSSParserContext& context,
                                                            const CSSParserLocalContext& local_context) const {
  return css_parsing_utils::ConsumeTransformList(stream, context, local_context);
}

std::shared_ptr<const CSSValue> TransformOrigin::ParseSingleValue(CSSParserTokenStream& stream,
                                                                  const CSSParserContext& context,
                                                                  const CSSParserLocalContext&) const {
  std::shared_ptr<const CSSValue> result_x = nullptr;
  std::shared_ptr<const CSSValue> result_y = nullptr;
  if (css_parsing_utils::ConsumeOneOrTwoValuedPosition(stream, context, css_parsing_utils::UnitlessQuirk::kForbid,
                                                       result_x, result_y)) {
    std::shared_ptr<CSSValueList> list = CSSValueList::CreateSpaceSeparated();
    list->Append(result_x);
    list->Append(result_y);
    std::shared_ptr<const CSSValue> result_z =
        css_parsing_utils::ConsumeLength(stream, context, CSSPrimitiveValue::ValueRange::kAll);
    if (result_z) {
      list->Append(result_z);
    }
    return list;
  }
  return nullptr;
}

std::shared_ptr<const CSSValue> TransitionDelay::ParseSingleValue(CSSParserTokenStream& stream,
                                                                  const CSSParserContext& context,
                                                                  const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeCommaSeparatedList(
      static_cast<std::shared_ptr<const CSSPrimitiveValue> (*)(CSSParserTokenStream&, const CSSParserContext&,
                                                               CSSPrimitiveValue::ValueRange)>(
          css_parsing_utils::ConsumeTime),
      stream, context, CSSPrimitiveValue::ValueRange::kAll);
}

std::shared_ptr<const CSSValue> TransitionDuration::ParseSingleValue(CSSParserTokenStream& stream,
                                                                     const CSSParserContext& context,
                                                                     const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeCommaSeparatedList(
      static_cast<std::shared_ptr<const CSSPrimitiveValue> (*)(CSSParserTokenStream&, const CSSParserContext&,
                                                               CSSPrimitiveValue::ValueRange)>(
          css_parsing_utils::ConsumeTime),
      stream, context, CSSPrimitiveValue::ValueRange::kNonNegative);
}

std::shared_ptr<const CSSValue> TransitionProperty::ParseSingleValue(CSSParserTokenStream& stream,
                                                                     const CSSParserContext& context,
                                                                     const CSSParserLocalContext&) const {
  std::shared_ptr<const CSSValueList> list =
      css_parsing_utils::ConsumeCommaSeparatedList(css_parsing_utils::ConsumeTransitionProperty, stream, context);
  if (!list || !css_parsing_utils::IsValidPropertyList(*list)) {
    return nullptr;
  }
  return list;
}

std::shared_ptr<const CSSValue> TransitionProperty::InitialValue() const {
  return CSSIdentifierValue::Create(CSSValueID::kAll);
}

namespace {
std::shared_ptr<const CSSIdentifierValue> ConsumeIdentNoTemplate(CSSParserTokenStream& stream, const CSSParserContext&) {
  return css_parsing_utils::ConsumeIdent(stream);
}
}  // namespace

std::shared_ptr<const CSSValue> TransitionBehavior::ParseSingleValue(CSSParserTokenStream& stream,
                                                                     const CSSParserContext& context,
                                                                     const CSSParserLocalContext&) const {
  std::shared_ptr<const CSSValueList> list = css_parsing_utils::ConsumeCommaSeparatedList(ConsumeIdentNoTemplate, stream, context);
  if (!list || !css_parsing_utils::IsValidTransitionBehaviorList(*list)) {
    return nullptr;
  }
  return list;
}

std::shared_ptr<const CSSValue> TransitionBehavior::InitialValue() const {
  return CSSIdentifierValue::Create(CSSValueID::kNormal);
}

std::shared_ptr<const CSSValue> TransitionTimingFunction::ParseSingleValue(CSSParserTokenStream& stream,
                                                                           const CSSParserContext& context,
                                                                           const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeCommaSeparatedList(css_parsing_utils::ConsumeAnimationTimingFunction, stream,
                                                      context);
}

std::shared_ptr<const CSSValue> TransitionTimingFunction::InitialValue() const {
  return CSSIdentifierValue::Create(CSSValueID::kEase);
}

//std::shared_ptr<const CSSValue> Translate::ParseSingleValue(CSSParserTokenStream& stream,
//                                                            const CSSParserContext& context,
//                                                            const CSSParserLocalContext&) const {
//  CSSValueID id = stream.Peek().Id();
//  if (id == CSSValueID::kNone) {
//    return css_parsing_utils::ConsumeIdent(stream);
//  }
//
//  std::shared_ptr<const CSSValue> translate_x =
//      css_parsing_utils::ConsumeLengthOrPercent(stream, context, CSSPrimitiveValue::ValueRange::kAll);
//  if (!translate_x) {
//    return nullptr;
//  }
//  std::shared_ptr<CSSValueList> list = CSSValueList::CreateSpaceSeparated();
//  list->Append(translate_x);
//  std::shared_ptr<const CSSPrimitiveValue> translate_y =
//      css_parsing_utils::ConsumeLengthOrPercent(stream, context, CSSPrimitiveValue::ValueRange::kAll);
//  if (translate_y) {
//    std::shared_ptr<const CSSPrimitiveValue> translate_z =
//        css_parsing_utils::ConsumeLength(stream, context, CSSPrimitiveValue::ValueRange::kAll);
//
//    if (translate_z && translate_z->IsZero() == CSSPrimitiveValue::BoolStatus::kTrue) {
//      translate_z = nullptr;
//    }
//    if (translate_y->IsZero() == CSSPrimitiveValue::BoolStatus::kTrue && !translate_y->HasPercentage() &&
//        !translate_z) {
//      return list;
//    }
//
//    list->Append(translate_y);
//    if (translate_z) {
//      list->Append(translate_z);
//    }
//  }
//
//  return list;
//}

std::shared_ptr<const CSSValue> VerticalAlign::ParseSingleValue(CSSParserTokenStream& stream,
                                                                const CSSParserContext& context,
                                                                const CSSParserLocalContext&) const {
  std::shared_ptr<const CSSValue> parsed_value =
      css_parsing_utils::ConsumeIdentRange(stream, CSSValueID::kBaseline, CSSValueID::kWebkitBaselineMiddle);
  if (!parsed_value) {
    parsed_value = css_parsing_utils::ConsumeLengthOrPercent(stream, context, CSSPrimitiveValue::ValueRange::kAll,
                                                             css_parsing_utils::UnitlessQuirk::kAllow);
  }
  return parsed_value;
}

void AppRegion::ApplyInitial(StyleResolverState& state) const {}

void AppRegion::ApplyInherit(StyleResolverState& state) const {}

std::shared_ptr<const CSSValue> Appearance::ParseSingleValue(CSSParserTokenStream& stream,
                                                             const CSSParserContext& context,
                                                             const CSSParserLocalContext& local_context) const {
  CSSValueID id = stream.Peek().Id();
  CSSPropertyID property = CSSPropertyID::kAppearance;
  if (local_context.UseAliasParsing()) {
    property = CSSPropertyID::kAliasWebkitAppearance;
  }
  if (CSSParserFastPaths::IsValidKeywordPropertyAndValue(property, id, context.Mode())) {
    css_parsing_utils::CountKeywordOnlyPropertyUsage(property, context, id);
    return css_parsing_utils::ConsumeIdent(stream);
  }
  css_parsing_utils::WarnInvalidKeywordPropertyUsage(property, context, id);
  return nullptr;
}

std::shared_ptr<const CSSValue> WebkitBorderHorizontalSpacing::ParseSingleValue(CSSParserTokenStream& stream,
                                                                                const CSSParserContext& context,
                                                                                const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeLength(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative);
}

std::shared_ptr<const CSSValue> WebkitBorderImage::ParseSingleValue(CSSParserTokenStream& stream,
                                                                    const CSSParserContext& context,
                                                                    const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeWebkitBorderImage(stream, context);
}

std::shared_ptr<const CSSValue> WebkitBorderVerticalSpacing::ParseSingleValue(CSSParserTokenStream& stream,
                                                                              const CSSParserContext& context,
                                                                              const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeLength(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative);
}

std::shared_ptr<const CSSValue> WebkitBoxFlex::ParseSingleValue(CSSParserTokenStream& stream,
                                                                const CSSParserContext& context,
                                                                const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeNumber(stream, context, CSSPrimitiveValue::ValueRange::kAll);
}

std::shared_ptr<const CSSValue> WebkitBoxOrdinalGroup::ParseSingleValue(CSSParserTokenStream& stream,
                                                                        const CSSParserContext& context,
                                                                        const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumePositiveInteger(stream, context);
}

namespace {

std::shared_ptr<const CSSValue> ConsumeReflect(CSSParserTokenStream& stream, const CSSParserContext& context) {
  std::shared_ptr<const CSSIdentifierValue> direction =
      css_parsing_utils::ConsumeIdent<CSSValueID::kAbove, CSSValueID::kBelow, CSSValueID::kLeft, CSSValueID::kRight>(
          stream);
  if (!direction) {
    return nullptr;
  }

  std::shared_ptr<const CSSPrimitiveValue> offset = ConsumeLengthOrPercent(
      stream, context, CSSPrimitiveValue::ValueRange::kAll, css_parsing_utils::UnitlessQuirk::kForbid);
  if (!offset) {
    // End of stream or parse error; in the latter case,
    // the caller will clean up since we're not at the end.
    offset = CSSNumericLiteralValue::Create(0, CSSPrimitiveValue::UnitType::kPixels);
    return std::make_shared<cssvalue::CSSReflectValue>(direction, offset,
                                                       /*mask=*/nullptr);
  }

  std::shared_ptr<const CSSValue> mask_or_null = css_parsing_utils::ConsumeWebkitBorderImage(stream, context);
  return std::make_shared<cssvalue::CSSReflectValue>(direction, offset, mask_or_null);
}

}  // namespace

std::shared_ptr<const CSSValue> WebkitBoxReflect::ParseSingleValue(CSSParserTokenStream& stream,
                                                                   const CSSParserContext& context,
                                                                   const CSSParserLocalContext&) const {
  return ConsumeReflect(stream, context);
}

std::shared_ptr<const CSSValue> WebkitLineClamp::ParseSingleValue(CSSParserTokenStream& stream,
                                                                  const CSSParserContext& context,
                                                                  const CSSParserLocalContext&) const {
  // When specifying number of lines, don't allow 0 as a valid value.
  return css_parsing_utils::ConsumePositiveInteger(stream, context);
}

std::shared_ptr<const CSSValue> WebkitLocale::ParseSingleValue(CSSParserTokenStream& stream,
                                                               const CSSParserContext&,
                                                               const CSSParserLocalContext&) const {
  if (stream.Peek().Id() == CSSValueID::kAuto) {
    return css_parsing_utils::ConsumeIdent(stream);
  }
  return css_parsing_utils::ConsumeString(stream);
}

std::shared_ptr<const CSSValue> WebkitMaskBoxImageOutset::ParseSingleValue(CSSParserTokenStream& stream,
                                                                           const CSSParserContext& context,
                                                                           const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeBorderImageOutset(stream, context);
}

std::shared_ptr<const CSSValue> WebkitMaskBoxImageRepeat::ParseSingleValue(CSSParserTokenStream& stream,
                                                                           const CSSParserContext&,
                                                                           const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeBorderImageRepeat(stream);
}

std::shared_ptr<const CSSValue> WebkitMaskBoxImageSlice::ParseSingleValue(CSSParserTokenStream& stream,
                                                                          const CSSParserContext& context,
                                                                          const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeBorderImageSlice(stream, context, css_parsing_utils::DefaultFill::kNoFill);
}

std::shared_ptr<const CSSValue> WebkitMaskBoxImageSource::ParseSingleValue(CSSParserTokenStream& stream,
                                                                           const CSSParserContext& context,
                                                                           const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeImageOrNone(stream, context);
}

// void WebkitMaskBoxImageSource::ApplyValue(StyleResolverState& state, const CSSValue& value, ValueMode) const {
//   state.StyleBuilder().SetMaskBoxImageSource(state.GetStyleImage(CSSPropertyID::kWebkitMaskBoxImageSource, value));
// }

std::shared_ptr<const CSSValue> WebkitMaskBoxImageWidth::ParseSingleValue(CSSParserTokenStream& stream,
                                                                          const CSSParserContext& context,
                                                                          const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeBorderImageWidth(stream, context);
}

std::shared_ptr<const CSSValue> MaskClip::ParseSingleValue(CSSParserTokenStream& stream,
                                                           const CSSParserContext&,
                                                           const CSSParserLocalContext& local_context) const {
  if (local_context.UseAliasParsing()) {
    return css_parsing_utils::ConsumeCommaSeparatedList(css_parsing_utils::ConsumePrefixedBackgroundBox, stream,
                                                        css_parsing_utils::AllowTextValue::kAllow);
  }
  return css_parsing_utils::ConsumeCommaSeparatedList(css_parsing_utils::ConsumeCoordBoxOrNoClip, stream);
}

std::shared_ptr<const CSSValue> MaskClip::InitialValue() const {
  return CSSIdentifierValue::Create(CSSValueID::kBorderBox);
}

std::shared_ptr<const CSSValue> MaskComposite::ParseSingleValue(CSSParserTokenStream& stream,
                                                                const CSSParserContext&,
                                                                const CSSParserLocalContext& local_context) const {
  if (local_context.UseAliasParsing()) {
    return css_parsing_utils::ConsumeCommaSeparatedList(css_parsing_utils::ConsumePrefixedMaskComposite, stream);
  }
  return css_parsing_utils::ConsumeCommaSeparatedList(css_parsing_utils::ConsumeMaskComposite, stream);
}

std::shared_ptr<const CSSValue> MaskComposite::InitialValue() const {
  return CSSIdentifierValue::Create(CSSValueID::kAdd);
}

std::shared_ptr<const CSSValue> MaskImage::ParseSingleValue(CSSParserTokenStream& stream,
                                                            const CSSParserContext& context,
                                                            const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeCommaSeparatedList(css_parsing_utils::ConsumeImageOrNone, stream, context);
}

std::shared_ptr<const CSSValue> MaskMode::ParseSingleValue(CSSParserTokenStream& stream,
                                                           const CSSParserContext&,
                                                           const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeCommaSeparatedList(css_parsing_utils::ConsumeMaskMode, stream);
}

std::shared_ptr<const CSSValue> MaskMode::InitialValue() const {
  return CSSIdentifierValue::Create(CSSValueID::kMatchSource);
}

std::shared_ptr<const CSSValue> MaskOrigin::ParseSingleValue(CSSParserTokenStream& stream,
                                                             const CSSParserContext&,
                                                             const CSSParserLocalContext& local_context) const {
  if (local_context.UseAliasParsing()) {
    return css_parsing_utils::ConsumeCommaSeparatedList(css_parsing_utils::ConsumePrefixedBackgroundBox, stream,
                                                        css_parsing_utils::AllowTextValue::kForbid);
  }
  return css_parsing_utils::ConsumeCommaSeparatedList(css_parsing_utils::ConsumeCoordBox, stream);
}

std::shared_ptr<const CSSValue> MaskOrigin::InitialValue() const {
  return CSSIdentifierValue::Create(CSSValueID::kBorderBox);
}

std::shared_ptr<const CSSValue> WebkitMaskPositionX::ParseSingleValue(CSSParserTokenStream& Stream,
                                                                      const CSSParserContext& context,
                                                                      const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeCommaSeparatedList(
      css_parsing_utils::ConsumePositionLonghand<CSSValueID::kLeft, CSSValueID::kRight>, Stream, context);
}

std::shared_ptr<const CSSValue> WebkitMaskPositionX::InitialValue() const {
  return CSSNumericLiteralValue::Create(0, CSSPrimitiveValue::UnitType::kPercentage);
}

std::shared_ptr<const CSSValue> WebkitMaskPositionY::ParseSingleValue(CSSParserTokenStream& stream,
                                                                      const CSSParserContext& context,
                                                                      const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeCommaSeparatedList(
      css_parsing_utils::ConsumePositionLonghand<CSSValueID::kTop, CSSValueID::kBottom>, stream, context);
}

std::shared_ptr<const CSSValue> WebkitMaskPositionY::InitialValue() const {
  return CSSNumericLiteralValue::Create(0, CSSPrimitiveValue::UnitType::kPercentage);
}

std::shared_ptr<const CSSValue> MaskRepeat::ParseSingleValue(CSSParserTokenStream& stream,
                                                             const CSSParserContext& context,
                                                             const CSSParserLocalContext& local_context) const {
  return css_parsing_utils::ParseRepeatStyle(stream);
}

std::shared_ptr<const CSSValue> MaskRepeat::InitialValue() const {
  return std::make_shared<CSSRepeatStyleValue>(CSSIdentifierValue::Create(CSSValueID::kRepeat));
}

std::shared_ptr<const CSSValue> MaskSize::ParseSingleValue(CSSParserTokenStream& stream,
                                                           const CSSParserContext& context,
                                                           const CSSParserLocalContext& local_context) const {
  return css_parsing_utils::ParseMaskSize(stream, context, local_context);
}

std::shared_ptr<const CSSValue> MaskSize::InitialValue() const {
  return CSSIdentifierValue::Create(CSSValueID::kAuto);
}

std::shared_ptr<const CSSValue> WebkitPerspectiveOriginX::ParseSingleValue(CSSParserTokenStream& stream,
                                                                           const CSSParserContext& context,
                                                                           const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumePositionLonghand<CSSValueID::kLeft, CSSValueID::kRight>(stream, context);
}

// void WebkitPerspectiveOriginX::ApplyInherit(StyleResolverState& state) const {
//   state.StyleBuilder().SetPerspectiveOriginX(state.ParentStyle()->PerspectiveOrigin().X());
// }

std::shared_ptr<const CSSValue> WebkitPerspectiveOriginY::ParseSingleValue(CSSParserTokenStream& stream,
                                                                           const CSSParserContext& context,
                                                                           const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumePositionLonghand<CSSValueID::kTop, CSSValueID::kBottom>(stream, context);
}

std::shared_ptr<const CSSValue> RubyPosition::ParseSingleValue(CSSParserTokenStream& stream,
                                                               const CSSParserContext& context,
                                                               const CSSParserLocalContext&) const {
  CSSValueID value_id = stream.Peek().Id();
  if (css_parsing_utils::IdentMatches<CSSValueID::kOver, CSSValueID::kUnder>(value_id)) {
    return css_parsing_utils::ConsumeIdent(stream);
  }
  return nullptr;
}

std::shared_ptr<const CSSValue> WebkitTapHighlightColor::ParseSingleValue(CSSParserTokenStream& stream,
                                                                          const CSSParserContext& context,
                                                                          const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeColor(stream, context);
}

std::shared_ptr<const CSSValue> TextEmphasisColor::ParseSingleValue(CSSParserTokenStream& stream,
                                                                    const CSSParserContext& context,
                                                                    const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeColor(stream, context);
}

// [ over | under ] && [ right | left ]?
// If [ right | left ] is omitted, it defaults to right.
std::shared_ptr<const CSSValue> TextEmphasisPosition::ParseSingleValue(CSSParserTokenStream& stream,
                                                                       const CSSParserContext& context,
                                                                       const CSSParserLocalContext&) const {
  std::shared_ptr<const CSSIdentifierValue> values[2] = {
      css_parsing_utils::ConsumeIdent<CSSValueID::kOver, CSSValueID::kUnder, CSSValueID::kRight, CSSValueID::kLeft>(
          stream),
      nullptr};
  if (!values[0]) {
    return nullptr;
  }
  values[1] =
      css_parsing_utils::ConsumeIdent<CSSValueID::kOver, CSSValueID::kUnder, CSSValueID::kRight, CSSValueID::kLeft>(
          stream);
  std::shared_ptr<const CSSIdentifierValue> over_under = nullptr;
  std::shared_ptr<const CSSIdentifierValue> left_right = nullptr;

  for (auto value : values) {
    if (!value) {
      break;
    }
    switch (value->GetValueID()) {
      case CSSValueID::kOver:
      case CSSValueID::kUnder:
        if (over_under) {
          return nullptr;
        }
        over_under = value;
        break;
      case CSSValueID::kLeft:
      case CSSValueID::kRight:
        if (left_right) {
          return nullptr;
        }
        left_right = value;
        break;
      default:
        NOTREACHED_IN_MIGRATION();
        break;
    }
  }
  if (!over_under) {
    return nullptr;
  }
  std::shared_ptr<CSSValueList> list = CSSValueList::CreateSpaceSeparated();
  list->Append(over_under);
  if (left_right) {
    list->Append(left_right);
  }
  return list;
}

std::shared_ptr<const CSSValue> TextEmphasisStyle::ParseSingleValue(CSSParserTokenStream& stream,
                                                                    const CSSParserContext& context,
                                                                    const CSSParserLocalContext&) const {
  CSSValueID id = stream.Peek().Id();
  if (id == CSSValueID::kNone) {
    return css_parsing_utils::ConsumeIdent(stream);
  }

  if (std::shared_ptr<const CSSValue> text_emphasis_style = css_parsing_utils::ConsumeString(stream)) {
    return text_emphasis_style;
  }

  std::shared_ptr<const CSSIdentifierValue> fill =
      css_parsing_utils::ConsumeIdent<CSSValueID::kFilled, CSSValueID::kOpen>(stream);
  std::shared_ptr<const CSSIdentifierValue> shape =
      css_parsing_utils::ConsumeIdent<CSSValueID::kDot, CSSValueID::kCircle, CSSValueID::kDoubleCircle,
                                      CSSValueID::kTriangle, CSSValueID::kSesame>(stream);
  if (!fill) {
    fill = css_parsing_utils::ConsumeIdent<CSSValueID::kFilled, CSSValueID::kOpen>(stream);
  }
  if (fill && shape) {
    std::shared_ptr<CSSValueList> parsed_values = CSSValueList::CreateSpaceSeparated();
    parsed_values->Append(fill);
    parsed_values->Append(shape);
    return parsed_values;
  }
  if (fill) {
    return fill;
  }
  if (shape) {
    return shape;
  }
  return nullptr;
}

std::shared_ptr<const CSSValue> WebkitTextFillColor::ParseSingleValue(CSSParserTokenStream& stream,
                                                                      const CSSParserContext& context,
                                                                      const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeColor(stream, context);
}

std::shared_ptr<const CSSValue> WebkitTextStrokeColor::ParseSingleValue(CSSParserTokenStream& stream,
                                                                        const CSSParserContext& context,
                                                                        const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeColor(stream, context);
}

std::shared_ptr<const CSSValue> WebkitTextStrokeWidth::ParseSingleValue(CSSParserTokenStream& stream,
                                                                        const CSSParserContext& context,
                                                                        const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeLineWidth(stream, context, css_parsing_utils::UnitlessQuirk::kForbid);
}

std::shared_ptr<const CSSValue> TimelineScope::ParseSingleValue(CSSParserTokenStream& stream,
                                                                const CSSParserContext& context,
                                                                const CSSParserLocalContext&) const {
  if (stream.Peek().Id() == CSSValueID::kNone) {
    return css_parsing_utils::ConsumeIdent(stream);
  }
  using css_parsing_utils::ConsumeCommaSeparatedList;
  using css_parsing_utils::ConsumeCustomIdent;
  return ConsumeCommaSeparatedList<std::shared_ptr<const CSSCustomIdentValue>(
      CSSParserTokenStream&, const CSSParserContext&)>(ConsumeCustomIdent, stream, context);
}

std::shared_ptr<const CSSValue> WebkitTransformOriginX::ParseSingleValue(CSSParserTokenStream& stream,
                                                                         const CSSParserContext& context,
                                                                         const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumePositionLonghand<CSSValueID::kLeft, CSSValueID::kRight>(stream, context);
}

std::shared_ptr<const CSSValue> WebkitTransformOriginY::ParseSingleValue(CSSParserTokenStream& stream,
                                                                         const CSSParserContext& context,
                                                                         const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumePositionLonghand<CSSValueID::kTop, CSSValueID::kBottom>(stream, context);
}

// void WebkitTransformOriginY::ApplyInherit(StyleResolverState& state) const {
//   state.StyleBuilder().SetTransformOriginY(state.ParentStyle()->GetTransformOrigin().Y());
// }

std::shared_ptr<const CSSValue> WebkitTransformOriginZ::ParseSingleValue(CSSParserTokenStream& stream,
                                                                         const CSSParserContext& context,
                                                                         const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeLength(stream, context, CSSPrimitiveValue::ValueRange::kAll);
}

std::shared_ptr<const CSSValue> Widows::ParseSingleValue(CSSParserTokenStream& stream,
                                                         const CSSParserContext& context,
                                                         const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumePositiveInteger(stream, context);
}

std::shared_ptr<const CSSValue> Width::ParseSingleValue(CSSParserTokenStream& stream,
                                                        const CSSParserContext& context,
                                                        const CSSParserLocalContext&) const {
  return css_parsing_utils::ConsumeWidthOrHeight(stream, context, css_parsing_utils::UnitlessQuirk::kAllow);
}

std::shared_ptr<const CSSValue> WillChange::ParseSingleValue(CSSParserTokenStream& stream,
                                                             const CSSParserContext& context,
                                                             const CSSParserLocalContext&) const {
  if (stream.Peek().Id() == CSSValueID::kAuto) {
    return css_parsing_utils::ConsumeIdent(stream);
  }

  std::shared_ptr<CSSValueList> values = CSSValueList::CreateCommaSeparated();
  // Every comma-separated list of identifiers is a valid will-change value,
  // unless the list includes an explicitly disallowed identifier.
  while (true) {
    if (stream.Peek().GetType() != kIdentToken) {
      return nullptr;
    }
    CSSPropertyID unresolved_property = UnresolvedCSSPropertyID(context.GetExecutingContext(), stream.Peek().Value());
    if (unresolved_property != CSSPropertyID::kInvalid && unresolved_property != CSSPropertyID::kVariable) {
#if DCHECK_IS_ON()
      DCHECK(CSSProperty::Get(ResolveCSSPropertyID(unresolved_property)).IsWebExposed(context.GetExecutingContext()));
#endif
      // Now "all" is used by both CSSValue and CSSPropertyValue.
      // Need to return nullptr when currentValue is CSSPropertyID::kAll.
      if (unresolved_property == CSSPropertyID::kWillChange || unresolved_property == CSSPropertyID::kAll) {
        return nullptr;
      }
      values->Append(std::make_shared<CSSCustomIdentValue>(unresolved_property));
      stream.ConsumeIncludingWhitespace();
    } else {
      switch (stream.Peek().Id()) {
        case CSSValueID::kNone:
        case CSSValueID::kAll:
        case CSSValueID::kAuto:
        case CSSValueID::kDefault:
        case CSSValueID::kInitial:
        case CSSValueID::kInherit:
        case CSSValueID::kRevert:
          return nullptr;
        case CSSValueID::kContents:
        case CSSValueID::kScrollPosition:
          values->Append(css_parsing_utils::ConsumeIdent(stream));
          break;
        default:
          stream.ConsumeIncludingWhitespace();
          break;
      }
    }

    if (!css_parsing_utils::ConsumeCommaIncludingWhitespace(stream)) {
      break;
    }
  }

  return values;
}

void WillChange::ApplyInitial(StyleResolverState& state) const {
  //  ComputedStyleBuilder& builder = state.StyleBuilder();
  //  builder.SetWillChangeContents(false);
  //  builder.SetWillChangeScrollPosition(false);
  //  builder.SetWillChangeProperties(Vector<CSSPropertyID>());
}

void WillChange::ApplyInherit(StyleResolverState& state) const {
  //  ComputedStyleBuilder& builder = state.StyleBuilder();
  //  builder.SetWillChangeContents(state.ParentStyle()->WillChangeContents());
  //  builder.SetWillChangeScrollPosition(state.ParentStyle()->WillChangeScrollPosition());
  //  builder.SetWillChangeProperties(state.ParentStyle()->WillChangeProperties());
}

void WillChange::ApplyValue(StyleResolverState& state, const CSSValue& value, ValueMode) const {
  //  bool will_change_contents = false;
  //  bool will_change_scroll_position = false;
  //  Vector<CSSPropertyID> will_change_properties;
  //
  //  if (auto* identifier_value = DynamicTo<CSSIdentifierValue>(value)) {
  //    DCHECK_EQ(identifier_value->GetValueID(), CSSValueID::kAuto);
  //  } else {
  //    for (auto& will_change_value : To<CSSValueList>(value)) {
  //      if (auto* ident_value = DynamicTo<CSSCustomIdentValue>(will_change_value.Get())) {
  //        will_change_properties.push_back(ident_value->ValueAsPropertyID());
  //      } else if (To<CSSIdentifierValue>(*will_change_value).GetValueID() == CSSValueID::kContents) {
  //        will_change_contents = true;
  //      } else if (To<CSSIdentifierValue>(*will_change_value).GetValueID() == CSSValueID::kScrollPosition) {
  //        will_change_scroll_position = true;
  //      } else {
  //        NOTREACHED_IN_MIGRATION();
  //      }
  //    }
  //  }
  //  ComputedStyleBuilder& builder = state.StyleBuilder();
  //  builder.SetWillChangeContents(will_change_contents);
  //  builder.SetWillChangeScrollPosition(will_change_scroll_position);
  //  builder.SetWillChangeProperties(will_change_properties);
  //  builder.SetSubtreeWillChangeContents(will_change_contents || state.ParentStyle()->SubtreeWillChangeContents());
}

std::shared_ptr<const CSSValue> WordSpacing::ParseSingleValue(CSSParserTokenStream& stream,
                                                              const CSSParserContext& context,
                                                              const CSSParserLocalContext&) const {
  return css_parsing_utils::ParseSpacing(stream, context);
}

void WritingMode::ApplyInitial(StyleResolverState& state) const {
  //  state.SetWritingMode(ComputedStyleInitialValues::InitialWritingMode());
}

void WritingMode::ApplyValue(StyleResolverState& state, const CSSValue& value, ValueMode) const {
  //  state.SetWritingMode(To<CSSIdentifierValue>(value).ConvertTo<blink::WritingMode>());
}

void TextSizeAdjust::ApplyInitial(StyleResolverState& state) const {
  //  state.SetTextSizeAdjust(ComputedStyleInitialValues::InitialTextSizeAdjust());
}

void TextSizeAdjust::ApplyInherit(StyleResolverState& state) const {
  //  state.SetTextSizeAdjust(state.ParentStyle()->GetTextSizeAdjust());
}

void TextSizeAdjust::ApplyValue(StyleResolverState& state, const CSSValue& value, ValueMode) const {
  //  state.SetTextSizeAdjust(StyleBuilderConverter::ConvertTextSizeAdjust(state, value));
}

std::shared_ptr<const CSSValue> ZIndex::ParseSingleValue(CSSParserTokenStream& stream,
                                                         const CSSParserContext& context,
                                                         const CSSParserLocalContext&) const {
  if (stream.Peek().Id() == CSSValueID::kAuto) {
    return css_parsing_utils::ConsumeIdent(stream);
  }
  return css_parsing_utils::ConsumeInteger(stream, context, /* minimum_value */ -std::numeric_limits<double>::max(),
                                           /* is_percentage_allowed */ false);
}

std::shared_ptr<const CSSValue> Zoom::ParseSingleValue(CSSParserTokenStream& stream,
                                                       const CSSParserContext& context,
                                                       const CSSParserLocalContext&) const {
  const CSSParserToken token = stream.Peek();
  std::shared_ptr<const CSSValue> zoom = nullptr;
  if (token.GetType() == kIdentToken) {
    zoom = css_parsing_utils::ConsumeIdent<CSSValueID::kNormal>(stream);
  } else {
    zoom = css_parsing_utils::ConsumePercent(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative);
    if (!zoom) {
      zoom = css_parsing_utils::ConsumeNumber(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative);
    }
  }
  if (zoom) {
    if (!(token.Id() == CSSValueID::kNormal ||
          (token.GetType() == kNumberToken &&
           To<CSSPrimitiveValue>(zoom.get())->IsOne() == CSSPrimitiveValue::BoolStatus::kTrue) ||
          (token.GetType() == kPercentageToken &&
           To<CSSPrimitiveValue>(zoom.get())->IsHundred() == CSSPrimitiveValue::BoolStatus::kTrue))) {
    }
  }
  return zoom;
}

void Zoom::ApplyInitial(StyleResolverState& state) const {
  //  state.SetZoom(ComputedStyleInitialValues::InitialZoom());
}

void Zoom::ApplyInherit(StyleResolverState& state) const {
  //  state.SetZoom(state.ParentStyle()->Zoom());
}

void Zoom::ApplyValue(StyleResolverState& state, const CSSValue& value, ValueMode) const {
  //  state.SetZoom(StyleBuilderConverter::ConvertZoom(state, value));
}

}  // namespace css_longhand
}  // namespace webf