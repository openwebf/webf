// Copyright 2019 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Implementations of methods in Shorthand subclasses that aren't generated.

#include "core/css/css_initial_value.h"
#include "core/css/css_pending_system_font_value.h"
#include "core/css/css_value.h"
#include "core/css/css_value_pair.h"
#include "core/css/parser/css_parser_fast_path.h"
#include "core/css/parser/css_parser_save_point.h"
#include "core/css/parser/font_variant_alternates_parser.h"
#include "core/css/parser/font_variant_east_asian_parser.h"
#include "core/css/css_content_distribution_value.h"
#include "core/css/white_space.h"
#include "core/css/css_value_id_mappings.h"
#include "core/css/parser/font_variant_ligatures_parser.h"
#include "core/css/parser/font_variant_numeric_parser.h"
#include "core/css/properties/css_parsing_utils.h"
#include "css_property_names.h"
#include "css_value_keywords.h"
#include "longhands.h"
#include "shorthands.h"
#include "style_property_shorthand.h"

namespace webf {
namespace css_shorthand {

namespace {

// New animation-* properties are  "reset only":
// https://github.com/w3c/csswg-drafts/issues/6946#issuecomment-1233190360
bool IsResetOnlyAnimationProperty(CSSPropertyID property) {
  switch (property) {
//    case CSSPropertyID::kAnimationTimeline:
//    case CSSPropertyID::kAnimationRangeStart:
//    case CSSPropertyID::kAnimationRangeEnd:
//      return true;
    default:
      return false;
  }
}

// Legacy parsing allows <string>s for animation-name.
std::shared_ptr<const CSSValue> ConsumeAnimationValue(CSSPropertyID property,
                                                      CSSParserTokenStream& stream,
                                                      const CSSParserContext& context,
                                                      bool use_legacy_parsing) {
//  switch (property) {
//    case CSSPropertyID::kAnimationDelay:
//      return css_parsing_utils::ConsumeTime(stream, context, CSSPrimitiveValue::ValueRange::kAll);
//    case CSSPropertyID::kAnimationDirection:
//      return css_parsing_utils::ConsumeIdent<CSSValueID::kNormal, CSSValueID::kAlternate, CSSValueID::kReverse,
//                                             CSSValueID::kAlternateReverse>(stream);
//    case CSSPropertyID::kAnimationDuration:
//      return css_parsing_utils::ConsumeAnimationDuration(stream, context);
//    case CSSPropertyID::kAnimationFillMode:
//      return css_parsing_utils::ConsumeIdent<CSSValueID::kNone, CSSValueID::kForwards, CSSValueID::kBackwards,
//                                             CSSValueID::kBoth>(stream);
//    case CSSPropertyID::kAnimationIterationCount:
//      return css_parsing_utils::ConsumeAnimationIterationCount(stream, context);
//    case CSSPropertyID::kAnimationName:
//      return css_parsing_utils::ConsumeAnimationName(stream, context, use_legacy_parsing);
//    case CSSPropertyID::kAnimationPlayState:
//      return css_parsing_utils::ConsumeIdent<CSSValueID::kRunning, CSSValueID::kPaused>(stream);
//    case CSSPropertyID::kAnimationTimingFunction:
//      return css_parsing_utils::ConsumeAnimationTimingFunction(stream, context);
//    case CSSPropertyID::kAnimationTimeline:
//    case CSSPropertyID::kAnimationRangeStart:
//    case CSSPropertyID::kAnimationRangeEnd:
//      // New animation-* properties are  "reset only", see
//      // IsResetOnlyAnimationProperty.
//      return nullptr;
//    default:
//      NOTREACHED_IN_MIGRATION();
//      return nullptr;
//  }
  return nullptr;
}

bool ParseAnimationShorthand(const StylePropertyShorthand& shorthand,
                             bool important,
                             CSSParserTokenStream& stream,
                             const CSSParserContext& context,
                             const CSSParserLocalContext& local_context,
                             std::vector<CSSPropertyValue>& properties) {
  const unsigned longhand_count = shorthand.length();

  std::vector<std::shared_ptr<CSSValueList>> longhands(longhand_count);
  longhands.reserve(css_parsing_utils::kMaxNumAnimationLonghands);
  if (!css_parsing_utils::ConsumeAnimationShorthand(shorthand, longhands, ConsumeAnimationValue,
                                                    IsResetOnlyAnimationProperty, stream, context,
                                                    local_context.UseAliasParsing())) {
    return false;
  }

  for (unsigned i = 0; i < longhand_count; ++i) {
    css_parsing_utils::AddProperty(shorthand.properties()[i]->PropertyID(), shorthand.id(), longhands[i], important,
                                   css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  }
  return true;
}
//
// std::shared_ptr<const CSSValue> CSSValueFromComputedAnimation(
//    const StylePropertyShorthand& shorthand,
//    const CSSAnimationData* animation_data) {
//  if (animation_data) {
//    // The shorthand can not represent the following properties if they have
//    // non-initial values. This is because they are always reset to their
//    // initial value by the shorthand.
//    if (!animation_data->HasSingleInitialTimeline() ||
//        !animation_data->HasSingleInitialDelayEnd() ||
//        !animation_data->HasSingleInitialRangeStart() ||
//        !animation_data->HasSingleInitialRangeEnd()) {
//      return nullptr;
//    }
//
//    CSSValueList* animations_list = CSSValueList::CreateCommaSeparated();
//    for (wtf_size_t i = 0; i < animation_data->NameList().size(); ++i) {
//      CSSValueList* list = CSSValueList::CreateSpaceSeparated();
//      list->Append(*ComputedStyleUtils::ValueForAnimationDuration(
//          CSSTimingData::GetRepeated(animation_data->DurationList(), i),
//          /* resolve_auto_to_zero */ true));
//      list->Append(*ComputedStyleUtils::ValueForAnimationTimingFunction(
//          CSSTimingData::GetRepeated(animation_data->TimingFunctionList(), i)));
//      list->Append(*ComputedStyleUtils::ValueForAnimationDelay(
//          CSSTimingData::GetRepeated(animation_data->DelayStartList(), i)));
//      list->Append(*ComputedStyleUtils::ValueForAnimationIterationCount(
//          CSSTimingData::GetRepeated(animation_data->IterationCountList(), i)));
//      list->Append(*ComputedStyleUtils::ValueForAnimationDirection(
//          CSSTimingData::GetRepeated(animation_data->DirectionList(), i)));
//      list->Append(*ComputedStyleUtils::ValueForAnimationFillMode(
//          CSSTimingData::GetRepeated(animation_data->FillModeList(), i)));
//      list->Append(*ComputedStyleUtils::ValueForAnimationPlayState(
//          CSSTimingData::GetRepeated(animation_data->PlayStateList(), i)));
//      list->Append(*MakeGarbageCollected<CSSCustomIdentValue>(
//          animation_data->NameList()[i]));
//      animations_list->Append(*list);
//    }
//    return animations_list;
//  }
//
//  CSSValueList* list = CSSValueList::CreateSpaceSeparated();
//  // animation-name default value.
//  list->Append(*CSSIdentifierValue::Create(CSSValueID::kNone));
//  list->Append(*ComputedStyleUtils::ValueForAnimationDuration(
//      CSSAnimationData::InitialDuration(),
//      /* resolve_auto_to_zero */ true));
//  list->Append(*ComputedStyleUtils::ValueForAnimationTimingFunction(
//      CSSAnimationData::InitialTimingFunction()));
//  list->Append(*ComputedStyleUtils::ValueForAnimationDelay(
//      CSSAnimationData::InitialDelayStart()));
//  list->Append(*ComputedStyleUtils::ValueForAnimationIterationCount(
//      CSSAnimationData::InitialIterationCount()));
//  list->Append(*ComputedStyleUtils::ValueForAnimationDirection(
//      CSSAnimationData::InitialDirection()));
//  list->Append(*ComputedStyleUtils::ValueForAnimationFillMode(
//      CSSAnimationData::InitialFillMode()));
//  list->Append(*ComputedStyleUtils::ValueForAnimationPlayState(
//      CSSAnimationData::InitialPlayState()));
//  return list;
//}

bool ParseBackgroundOrMaskPosition(const StylePropertyShorthand& shorthand,
                                   bool important,
                                   CSSParserTokenStream& stream,
                                   const CSSParserContext& context,
                                   std::vector<CSSPropertyValue>& properties) {
  std::shared_ptr<const CSSValue> result_x = nullptr;
  std::shared_ptr<const CSSValue> result_y = nullptr;
  if (!css_parsing_utils::ConsumeBackgroundPosition(stream, context, css_parsing_utils::UnitlessQuirk::kAllow, result_x,
                                                    result_y)) {
    return false;
  }
  const StylePropertyShorthand::Properties& longhands = shorthand.properties();
  DCHECK_EQ(2u, longhands.size());
  css_parsing_utils::AddProperty(longhands[0]->PropertyID(), shorthand.id(), result_x, important,
                                 css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  css_parsing_utils::AddProperty(longhands[1]->PropertyID(), shorthand.id(), result_y, important,
                                 css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  return true;
}

}  // namespace
//
// bool Animation::ParseShorthand(
//    bool important,
//    CSSParserTokenStream& stream,
//    const CSSParserContext& context,
//    const CSSParserLocalContext& local_context,
//    std::vector<CSSPropertyValue>& properties) const {
//  return ParseAnimationShorthand(animationShorthand(), important, stream,
//                                 context, local_context, properties);
//}
//
// std::shared_ptr<const CSSValue> Animation::CSSValueFromComputedStyleInternal(
//    const ComputedStyle& style,
//    const LayoutObject*,
//    bool allow_visited_style,
//    CSSValuePhase value_phase) const {
//  return CSSValueFromComputedAnimation(animationShorthand(),
//                                       style.Animations());
//}
//
// bool AlternativeAnimationWithTimeline::ParseShorthand(
//    bool important,
//    CSSParserTokenStream& stream,
//    const CSSParserContext& context,
//    const CSSParserLocalContext& local_context,
//    std::vector<CSSPropertyValue>& properties) const {
//  return ParseAnimationShorthand(alternativeAnimationWithTimelineShorthand(),
//                                 important, stream, context, local_context,
//                                 properties);
//}
//
// std::shared_ptr<const CSSValue>
// AlternativeAnimationWithTimeline::CSSValueFromComputedStyleInternal(
//    const ComputedStyle& style,
//    const LayoutObject*,
//    bool allow_visited_style,
//    CSSValuePhase value_phase) const {
//  return CSSValueFromComputedAnimation(
//      alternativeAnimationWithTimelineShorthand(), style.Animations());
//}
//
// namespace {
//
//// Consume a single <animation-range-start> and a single
//// <animation-range-end>, and append the result to `start_list` and
//// `end_list` respectively.
// bool ConsumeAnimationRangeItemInto(CSSParserTokenStream& stream,
//                                    const CSSParserContext& context,
//                                    CSSValueList* start_list,
//                                    CSSValueList* end_list) {
//   using css_parsing_utils::ConsumeAnimationRange;
//   using css_parsing_utils::ConsumeTimelineRangeName;
//
//   std::shared_ptr<const CSSValue> start_range =
//       ConsumeAnimationRange(stream, context, /* default_offset_percent */ 0.0);
//   std::shared_ptr<const CSSValue> end_range = ConsumeAnimationRange(
//       stream, context, /* default_offset_percent */ 100.0);
//
//   // The form 'name X' must expand to 'name X name 100%'.
//   //
//   // https://github.com/w3c/csswg-drafts/issues/8438
//   if (start_range && start_range->IsValueList() && !end_range) {
//     CSSValueList* implied_end = CSSValueList::CreateSpaceSeparated();
//     const CSSValue& name = To<CSSValueList>(start_range)->First();
//     if (name.IsIdentifierValue()) {
//       implied_end->Append(name);
//       end_range = implied_end;
//     }
//   }
//
//   if (!start_range) {
//     return false;
//   }
//   if (!end_range) {
//     end_range = CSSIdentifierValue::Create(CSSValueID::kNormal);
//   }
//
//   DCHECK(start_range);
//   DCHECK(end_range);
//
//   start_list->Append(*start_range);
//   end_list->Append(*end_range);
//
//   return true;
// }
//
// }  // namespace
//
// bool AnimationRange::ParseShorthand(
//     bool important,
//     CSSParserTokenStream& stream,
//     const CSSParserContext& context,
//     const CSSParserLocalContext& local_context,
//     std::vector<CSSPropertyValue>& properties) const {
//   DCHECK(RuntimeEnabledFeatures::ScrollTimelineEnabled());
//
//   using css_parsing_utils::AddProperty;
//   using css_parsing_utils::ConsumeCommaIncludingWhitespace;
//   using css_parsing_utils::IsImplicitProperty;
//
//   const StylePropertyShorthand shorthand = animationRangeShorthand();
//   DCHECK_EQ(2u, shorthand.length());
//   DCHECK_EQ(&GetCSSPropertyAnimationRangeStart(), shorthand.properties()[0]);
//   DCHECK_EQ(&GetCSSPropertyAnimationRangeEnd(), shorthand.properties()[1]);
//
//   CSSValueList* start_list = CSSValueList::CreateCommaSeparated();
//   CSSValueList* end_list = CSSValueList::CreateCommaSeparated();
//
//   do {
//     if (!ConsumeAnimationRangeItemInto(stream, context, start_list, end_list)) {
//       return false;
//     }
//   } while (ConsumeCommaIncludingWhitespace(stream));
//
//   DCHECK(start_list->length());
//   DCHECK(end_list->length());
//   DCHECK_EQ(start_list->length(), end_list->length());
//
//   AddProperty(CSSPropertyID::kAnimationRangeStart,
//               CSSPropertyID::kAnimationRange, *start_list, important,
//               IsImplicitProperty::kNotImplicit, properties);
//   AddProperty(CSSPropertyID::kAnimationRangeEnd, CSSPropertyID::kAnimationRange,
//               *end_list, important, IsImplicitProperty::kNotImplicit,
//               properties);
//
//   return true;
// }
//
// std::shared_ptr<const CSSValue> AnimationRange::CSSValueFromComputedStyleInternal(
//     const ComputedStyle& style,
//     const LayoutObject*,
//     bool allow_visited_style,
//     CSSValuePhase value_phase) const {
//   const Vector<std::optional<TimelineOffset>>& range_start_list =
//       style.Animations() ? style.Animations()->RangeStartList()
//                          : Vector<std::optional<TimelineOffset>>{
//                                CSSAnimationData::InitialRangeStart()};
//   const Vector<std::optional<TimelineOffset>>& range_end_list =
//       style.Animations() ? style.Animations()->RangeEndList()
//                          : Vector<std::optional<TimelineOffset>>{
//                                CSSAnimationData::InitialRangeEnd()};
//
//   if (range_start_list.size() != range_end_list.size()) {
//     return nullptr;
//   }
//
//   TimelineOffset default_start(TimelineOffset::NamedRange::kNone,
//                                Length::Percent(0));
//   TimelineOffset default_end(TimelineOffset::NamedRange::kNone,
//                              Length::Percent(100));
//
//   auto* outer_list = CSSValueList::CreateCommaSeparated();
//
//   for (wtf_size_t i = 0; i < range_start_list.size(); ++i) {
//     const std::optional<TimelineOffset>& start = range_start_list[i];
//     const std::optional<TimelineOffset>& end = range_end_list[i];
//
//     auto* inner_list = CSSValueList::CreateSpaceSeparated();
//     inner_list->Append(
//         *ComputedStyleUtils::ValueForAnimationRangeStart(start, style));
//
//     // The form "name X name 100%" must contract to "name X".
//     //
//     // https://github.com/w3c/csswg-drafts/issues/8438
//     TimelineOffset omittable_end(start.value_or(default_start).name,
//                                  Length::Percent(100));
//     if (end.value_or(default_end) != omittable_end) {
//       inner_list->Append(
//           *ComputedStyleUtils::ValueForAnimationRangeEnd(end, style));
//     }
//     outer_list->Append(*inner_list);
//   }
//
//   return outer_list;
// }

bool Background::ParseShorthand(bool important,
                                CSSParserTokenStream& stream,
                                const CSSParserContext& context,
                                const CSSParserLocalContext& local_context,
                                std::vector<CSSPropertyValue>& properties) const {
  return css_parsing_utils::ParseBackgroundOrMask(important, stream, context, local_context, properties);
}

// std::shared_ptr<const CSSValue> Background::CSSValueFromComputedStyleInternal(
//     const ComputedStyle& style,
//     const LayoutObject* layout_object,
//     bool allow_visited_style,
//     CSSValuePhase value_phase) const {
//   return ComputedStyleUtils::ValuesForBackgroundShorthand(
//       style, layout_object, allow_visited_style, value_phase);
// }

bool BackgroundPosition::ParseShorthand(bool important,
                                        CSSParserTokenStream& stream,
                                        const CSSParserContext& context,
                                        const CSSParserLocalContext&,
                                        std::vector<CSSPropertyValue>& properties) const {
  return ParseBackgroundOrMaskPosition(backgroundPositionShorthand(), important, stream, context, properties);
}

// std::shared_ptr<const CSSValue> BackgroundPosition::CSSValueFromComputedStyleInternal(
//     const ComputedStyle& style,
//     const LayoutObject*,
//     bool allow_visited_style,
//     CSSValuePhase value_phase) const {
//   return ComputedStyleUtils::BackgroundPositionOrMaskPosition(
//       *this, style, &style.BackgroundLayers());
// }

bool BorderBlockColor::ParseShorthand(bool important,
                                      CSSParserTokenStream& stream,
                                      const CSSParserContext& context,
                                      const CSSParserLocalContext&,
                                      std::vector<CSSPropertyValue>& properties) const {
  return css_parsing_utils::ConsumeShorthandVia2Longhands(borderBlockColorShorthand(), important, context, stream,
                                                          properties);
}

// std::shared_ptr<const CSSValue> BorderBlockColor::CSSValueFromComputedStyleInternal(
//     const ComputedStyle& style,
//     const LayoutObject* layout_object,
//     bool allow_visited_style,
//     CSSValuePhase value_phase) const {
//   return ComputedStyleUtils::ValuesForInlineBlockShorthand(
//       borderBlockColorShorthand(), style, layout_object, allow_visited_style,
//       value_phase);
// }

bool BorderBlock::ParseShorthand(bool important,
                                 CSSParserTokenStream& stream,
                                 const CSSParserContext& context,
                                 const CSSParserLocalContext& local_context,
                                 std::vector<CSSPropertyValue>& properties) const {
  std::shared_ptr<const CSSValue> width = nullptr;
  std::shared_ptr<const CSSValue> style = nullptr;
  std::shared_ptr<const CSSValue> color = nullptr;

  if (!css_parsing_utils::ConsumeBorderShorthand(stream, context, local_context, width, style, color)) {
    return false;
  };

  css_parsing_utils::AddExpandedPropertyForValue(CSSPropertyID::kBorderBlockWidth, width, important, properties);
  css_parsing_utils::AddExpandedPropertyForValue(CSSPropertyID::kBorderBlockStyle, style, important, properties);
  css_parsing_utils::AddExpandedPropertyForValue(CSSPropertyID::kBorderBlockColor, color, important, properties);

  return true;
}
//
// std::shared_ptr<const CSSValue> BorderBlock::CSSValueFromComputedStyleInternal(
//    const ComputedStyle& style,
//    const LayoutObject* layout_object,
//    bool allow_visited_style,
//    CSSValuePhase value_phase) const {
//  std::shared_ptr<const CSSValue> value_start =
//      GetCSSPropertyBorderBlockStart().CSSValueFromComputedStyle(
//          style, layout_object, allow_visited_style, value_phase);
//  std::shared_ptr<const CSSValue> value_end =
//      GetCSSPropertyBorderBlockEnd().CSSValueFromComputedStyle(
//          style, layout_object, allow_visited_style, value_phase);
//  if (!base::ValuesEquivalent(value_start, value_end)) {
//    return nullptr;
//  }
//  return value_start;
//}

bool BorderBlockEnd::ParseShorthand(bool important,
                                    CSSParserTokenStream& stream,
                                    const CSSParserContext& context,
                                    const CSSParserLocalContext&,
                                    std::vector<CSSPropertyValue>& properties) const {
  return css_parsing_utils::ConsumeShorthandGreedilyViaLonghands(borderBlockEndShorthand(), important, context, stream,
                                                                 properties);
}

bool BorderBlockStart::ParseShorthand(bool important,
                                      CSSParserTokenStream& stream,
                                      const CSSParserContext& context,
                                      const CSSParserLocalContext&,
                                      std::vector<CSSPropertyValue>& properties) const {
  return css_parsing_utils::ConsumeShorthandGreedilyViaLonghands(borderBlockStartShorthand(), important, context,
                                                                 stream, properties);
}

bool BorderBlockStyle::ParseShorthand(bool important,
                                      CSSParserTokenStream& stream,
                                      const CSSParserContext& context,
                                      const CSSParserLocalContext&,
                                      std::vector<CSSPropertyValue>& properties) const {
  return css_parsing_utils::ConsumeShorthandVia2Longhands(borderBlockStyleShorthand(), important, context, stream,
                                                          properties);
}
//
// std::shared_ptr<const CSSValue> BorderBlockStyle::CSSValueFromComputedStyleInternal(
//    const ComputedStyle& style,
//    const LayoutObject* layout_object,
//    bool allow_visited_style,
//    CSSValuePhase value_phase) const {
//  return ComputedStyleUtils::ValuesForInlineBlockShorthand(
//      borderBlockStyleShorthand(), style, layout_object, allow_visited_style,
//      value_phase);
//}

bool BorderBlockWidth::ParseShorthand(bool important,
                                      CSSParserTokenStream& stream,
                                      const CSSParserContext& context,
                                      const CSSParserLocalContext&,
                                      std::vector<CSSPropertyValue>& properties) const {
  return css_parsing_utils::ConsumeShorthandVia2Longhands(borderBlockWidthShorthand(), important, context, stream,
                                                          properties);
}
//
// std::shared_ptr<const CSSValue> BorderBlockWidth::CSSValueFromComputedStyleInternal(
//    const ComputedStyle& style,
//    const LayoutObject* layout_object,
//    bool allow_visited_style,
//    CSSValuePhase value_phase) const {
//  return ComputedStyleUtils::ValuesForInlineBlockShorthand(
//      borderBlockWidthShorthand(), style, layout_object, allow_visited_style,
//      value_phase);
//}

bool BorderBottom::ParseShorthand(bool important,
                                  CSSParserTokenStream& stream,
                                  const CSSParserContext& context,
                                  const CSSParserLocalContext&,
                                  std::vector<CSSPropertyValue>& properties) const {
  return css_parsing_utils::ConsumeShorthandGreedilyViaLonghands(borderBottomShorthand(), important, context, stream,
                                                                 properties);
}

// std::shared_ptr<const CSSValue> BorderBottom::CSSValueFromComputedStyleInternal(
//     const ComputedStyle& style,
//     const LayoutObject* layout_object,
//     bool allow_visited_style,
//     CSSValuePhase value_phase) const {
//   return ComputedStyleUtils::ValuesForShorthandProperty(
//       borderBottomShorthand(), style, layout_object, allow_visited_style,
//       value_phase);
// }

bool BorderColor::ParseShorthand(bool important,
                                 CSSParserTokenStream& stream,
                                 const CSSParserContext& context,
                                 const CSSParserLocalContext&,
                                 std::vector<CSSPropertyValue>& properties) const {
  return css_parsing_utils::ConsumeShorthandVia4Longhands(borderColorShorthand(), important, context, stream,
                                                          properties);
}
//
// std::shared_ptr<const CSSValue> BorderColor::CSSValueFromComputedStyleInternal(
//    const ComputedStyle& style,
//    const LayoutObject* layout_object,
//    bool allow_visited_style,
//    CSSValuePhase value_phase) const {
//  return ComputedStyleUtils::ValuesForSidesShorthand(
//      borderColorShorthand(), style, layout_object, allow_visited_style,
//      value_phase);
//}

bool Border::ParseShorthand(bool important,
                            CSSParserTokenStream& stream,
                            const CSSParserContext& context,
                            const CSSParserLocalContext& local_context,
                            std::vector<CSSPropertyValue>& properties) const {
  std::shared_ptr<const CSSValue> width = nullptr;
  std::shared_ptr<const CSSValue> style = nullptr;
  std::shared_ptr<const CSSValue> color = nullptr;

  if (!css_parsing_utils::ConsumeBorderShorthand(stream, context, local_context, width, style, color)) {
    return false;
  };

  css_parsing_utils::AddExpandedPropertyForValue(CSSPropertyID::kBorderWidth, width, important, properties);
  css_parsing_utils::AddExpandedPropertyForValue(CSSPropertyID::kBorderStyle, style, important, properties);
  css_parsing_utils::AddExpandedPropertyForValue(CSSPropertyID::kBorderColor, color, important, properties);
  css_parsing_utils::AddExpandedPropertyForValue(CSSPropertyID::kBorderImage, CSSInitialValue::Create(), important,
                                                 properties);

  return true;
}
//
// std::shared_ptr<const CSSValue> Border::CSSValueFromComputedStyleInternal(
//    const ComputedStyle& style,
//    const LayoutObject* layout_object,
//    bool allow_visited_style,
//    CSSValuePhase value_phase) const {
//  std::shared_ptr<const CSSValue> value = GetCSSPropertyBorderTop().CSSValueFromComputedStyle(
//      style, layout_object, allow_visited_style, value_phase);
//  static const CSSProperty* kProperties[3] = {&GetCSSPropertyBorderRight(),
//                                              &GetCSSPropertyBorderBottom(),
//                                              &GetCSSPropertyBorderLeft()};
//  for (size_t i = 0; i < std::size(kProperties); ++i) {
//    std::shared_ptr<const CSSValue> value_for_side = kProperties[i]->CSSValueFromComputedStyle(
//        style, layout_object, allow_visited_style, value_phase);
//    if (!base::ValuesEquivalent(value, value_for_side)) {
//      return nullptr;
//    }
//  }
//  return value;
//}

bool BorderImage::ParseShorthand(bool important,
                                 CSSParserTokenStream& stream,
                                 const CSSParserContext& context,
                                 const CSSParserLocalContext&,
                                 std::vector<CSSPropertyValue>& properties) const {
  std::shared_ptr<const CSSValue> source = nullptr;
  std::shared_ptr<const CSSValue> slice = nullptr;
  std::shared_ptr<const CSSValue> width = nullptr;
  std::shared_ptr<const CSSValue> outset = nullptr;
  std::shared_ptr<const CSSValue> repeat = nullptr;

  if (!css_parsing_utils::ConsumeBorderImageComponents(stream, context, source, slice, width, outset, repeat,
                                                       css_parsing_utils::DefaultFill::kNoFill)) {
    return false;
  }

  css_parsing_utils::AddProperty(CSSPropertyID::kBorderImageSource, CSSPropertyID::kBorderImage,
                                 source ? source : GetCSSPropertyBorderImageSource().InitialValue(), important,
                                 css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  GetCSSPropertyBorderImageSlice();
  css_parsing_utils::AddProperty(CSSPropertyID::kBorderImageSlice, CSSPropertyID::kBorderImage,
                                 slice ? slice : GetCSSPropertyBorderImageSlice().InitialValue(), important,
                                 css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  css_parsing_utils::AddProperty(CSSPropertyID::kBorderImageWidth, CSSPropertyID::kBorderImage,
                                 width ? width : GetCSSPropertyBorderImageWidth().InitialValue(), important,
                                 css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  css_parsing_utils::AddProperty(CSSPropertyID::kBorderImageOutset, CSSPropertyID::kBorderImage,
                                 outset ? outset : GetCSSPropertyBorderImageOutset().InitialValue(), important,
                                 css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  css_parsing_utils::AddProperty(CSSPropertyID::kBorderImageRepeat, CSSPropertyID::kBorderImage,
                                 repeat ? repeat : GetCSSPropertyBorderImageRepeat().InitialValue(), important,
                                 css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);

  return true;
}

// std::shared_ptr<const CSSValue> BorderImage::CSSValueFromComputedStyleInternal(
//     const ComputedStyle& style,
//     const LayoutObject*,
//     bool allow_visited_style,
//     CSSValuePhase value_phase) const {
//   return ComputedStyleUtils::ValueForNinePieceImage(
//       style.BorderImage(), style, allow_visited_style, value_phase);
// }

bool BorderInlineColor::ParseShorthand(bool important,
                                       CSSParserTokenStream& stream,
                                       const CSSParserContext& context,
                                       const CSSParserLocalContext&,
                                       std::vector<CSSPropertyValue>& properties) const {
  return css_parsing_utils::ConsumeShorthandVia2Longhands(borderInlineColorShorthand(), important, context, stream,
                                                          properties);
}
//
// std::shared_ptr<const CSSValue> BorderInlineColor::CSSValueFromComputedStyleInternal(
//    const ComputedStyle& style,
//    const LayoutObject* layout_object,
//    bool allow_visited_style,
//    CSSValuePhase value_phase) const {
//  return ComputedStyleUtils::ValuesForInlineBlockShorthand(
//      borderInlineColorShorthand(), style, layout_object, allow_visited_style,
//      value_phase);
//}

bool BorderInline::ParseShorthand(bool important,
                                  CSSParserTokenStream& stream,
                                  const CSSParserContext& context,
                                  const CSSParserLocalContext& local_context,
                                  std::vector<CSSPropertyValue>& properties) const {
  std::shared_ptr<const CSSValue> width = nullptr;
  std::shared_ptr<const CSSValue> style = nullptr;
  std::shared_ptr<const CSSValue> color = nullptr;

  if (!css_parsing_utils::ConsumeBorderShorthand(stream, context, local_context, width, style, color)) {
    return false;
  };

  css_parsing_utils::AddExpandedPropertyForValue(CSSPropertyID::kBorderInlineWidth, width, important, properties);
  css_parsing_utils::AddExpandedPropertyForValue(CSSPropertyID::kBorderInlineStyle, style, important, properties);
  css_parsing_utils::AddExpandedPropertyForValue(CSSPropertyID::kBorderInlineColor, color, important, properties);

  return true;
}
//
// std::shared_ptr<const CSSValue> BorderInline::CSSValueFromComputedStyleInternal(
//    const ComputedStyle& style,
//    const LayoutObject* layout_object,
//    bool allow_visited_style,
//    CSSValuePhase value_phase) const {
//  std::shared_ptr<const CSSValue> value_start =
//      GetCSSPropertyBorderInlineStart().CSSValueFromComputedStyle(
//          style, layout_object, allow_visited_style, value_phase);
//  std::shared_ptr<const CSSValue> value_end =
//      GetCSSPropertyBorderInlineEnd().CSSValueFromComputedStyle(
//          style, layout_object, allow_visited_style, value_phase);
//  if (!ValuesEquivalent(value_start, value_end)) {
//    return nullptr;
//  }
//  return value_start;
//}

bool BorderInlineEnd::ParseShorthand(bool important,
                                     CSSParserTokenStream& stream,
                                     const CSSParserContext& context,
                                     const CSSParserLocalContext&,
                                     std::vector<CSSPropertyValue>& properties) const {
  return css_parsing_utils::ConsumeShorthandGreedilyViaLonghands(borderInlineEndShorthand(), important, context, stream,
                                                                 properties);
}

bool BorderInlineStart::ParseShorthand(bool important,
                                       CSSParserTokenStream& stream,
                                       const CSSParserContext& context,
                                       const CSSParserLocalContext&,
                                       std::vector<CSSPropertyValue>& properties) const {
  return css_parsing_utils::ConsumeShorthandGreedilyViaLonghands(borderInlineStartShorthand(), important, context,
                                                                 stream, properties);
}

bool BorderInlineStyle::ParseShorthand(bool important,
                                       CSSParserTokenStream& stream,
                                       const CSSParserContext& context,
                                       const CSSParserLocalContext&,
                                       std::vector<CSSPropertyValue>& properties) const {
  return css_parsing_utils::ConsumeShorthandVia2Longhands(borderInlineStyleShorthand(), important, context, stream,
                                                          properties);
}
//
// std::shared_ptr<const CSSValue> BorderInlineStyle::CSSValueFromComputedStyleInternal(
//    const ComputedStyle& style,
//    const LayoutObject* layout_object,
//    bool allow_visited_style,
//    CSSValuePhase value_phase) const {
//  return ComputedStyleUtils::ValuesForInlineBlockShorthand(
//      borderInlineStyleShorthand(), style, layout_object, allow_visited_style,
//      value_phase);
//}

bool BorderInlineWidth::ParseShorthand(bool important,
                                       CSSParserTokenStream& stream,
                                       const CSSParserContext& context,
                                       const CSSParserLocalContext&,
                                       std::vector<CSSPropertyValue>& properties) const {
  return css_parsing_utils::ConsumeShorthandVia2Longhands(borderInlineWidthShorthand(), important, context, stream,
                                                          properties);
}
//
// std::shared_ptr<const CSSValue> BorderInlineWidth::CSSValueFromComputedStyleInternal(
//    const ComputedStyle& style,
//    const LayoutObject* layout_object,
//    bool allow_visited_style,
//    CSSValuePhase value_phase) const {
//  return ComputedStyleUtils::ValuesForInlineBlockShorthand(
//      borderInlineWidthShorthand(), style, layout_object, allow_visited_style,
//      value_phase);
//}

bool BorderLeft::ParseShorthand(bool important,
                                CSSParserTokenStream& stream,
                                const CSSParserContext& context,
                                const CSSParserLocalContext&,
                                std::vector<CSSPropertyValue>& properties) const {
  return css_parsing_utils::ConsumeShorthandGreedilyViaLonghands(borderLeftShorthand(), important, context, stream,
                                                                 properties);
}
//
// std::shared_ptr<const CSSValue> BorderLeft::CSSValueFromComputedStyleInternal(
//    const ComputedStyle& style,
//    const LayoutObject* layout_object,
//    bool allow_visited_style,
//    CSSValuePhase value_phase) const {
//  return ComputedStyleUtils::ValuesForShorthandProperty(
//      borderLeftShorthand(), style, layout_object, allow_visited_style,
//      value_phase);
//}

bool BorderRadius::ParseShorthand(bool important,
                                  CSSParserTokenStream& stream,
                                  const CSSParserContext& context,
                                  const CSSParserLocalContext& local_context,
                                  std::vector<CSSPropertyValue>& properties) const {
  std::shared_ptr<const CSSValue> horizontal_radii[4] = {nullptr};
  std::shared_ptr<const CSSValue> vertical_radii[4] = {nullptr};

  if (!css_parsing_utils::ConsumeRadii(horizontal_radii, vertical_radii, stream, context,
                                       local_context.UseAliasParsing())) {
    return false;
  }

  css_parsing_utils::AddProperty(
      CSSPropertyID::kBorderTopLeftRadius, CSSPropertyID::kBorderRadius,
      std::make_shared<CSSValuePair>(horizontal_radii[0], vertical_radii[0], CSSValuePair::kDropIdenticalValues),
      important, css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  css_parsing_utils::AddProperty(
      CSSPropertyID::kBorderTopRightRadius, CSSPropertyID::kBorderRadius,
      std::make_shared<CSSValuePair>(horizontal_radii[1], vertical_radii[1], CSSValuePair::kDropIdenticalValues),
      important, css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  css_parsing_utils::AddProperty(
      CSSPropertyID::kBorderBottomRightRadius, CSSPropertyID::kBorderRadius,
      std::make_shared<CSSValuePair>(horizontal_radii[2], vertical_radii[2], CSSValuePair::kDropIdenticalValues),
      important, css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  css_parsing_utils::AddProperty(
      CSSPropertyID::kBorderBottomLeftRadius, CSSPropertyID::kBorderRadius,
      std::make_shared<CSSValuePair>(horizontal_radii[3], vertical_radii[3], CSSValuePair::kDropIdenticalValues),
      important, css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  return true;
}
//
// std::shared_ptr<const CSSValue> BorderRadius::CSSValueFromComputedStyleInternal(
//    const ComputedStyle& style,
//    const LayoutObject*,
//    bool allow_visited_style,
//    CSSValuePhase value_phase) const {
//  return ComputedStyleUtils::ValueForBorderRadiusShorthand(style);
//}

bool BorderRight::ParseShorthand(bool important,
                                 CSSParserTokenStream& stream,
                                 const CSSParserContext& context,
                                 const CSSParserLocalContext&,
                                 std::vector<CSSPropertyValue>& properties) const {
  return css_parsing_utils::ConsumeShorthandGreedilyViaLonghands(borderRightShorthand(), important, context, stream,
                                                                 properties);
}
//
// std::shared_ptr<const CSSValue> BorderRight::CSSValueFromComputedStyleInternal(
//    const ComputedStyle& style,
//    const LayoutObject* layout_object,
//    bool allow_visited_style,
//    CSSValuePhase value_phase) const {
//  return ComputedStyleUtils::ValuesForShorthandProperty(
//      borderRightShorthand(), style, layout_object, allow_visited_style,
//      value_phase);
//}

bool BorderSpacing::ParseShorthand(bool important,
                                   CSSParserTokenStream& stream,
                                   const CSSParserContext& context,
                                   const CSSParserLocalContext&,
                                   std::vector<CSSPropertyValue>& properties) const {
  std::shared_ptr<const CSSValue> horizontal_spacing = ConsumeLength(
      stream, context, CSSPrimitiveValue::ValueRange::kNonNegative, css_parsing_utils::UnitlessQuirk::kAllow);
  if (!horizontal_spacing) {
    return false;
  }
  std::shared_ptr<const CSSValue> vertical_spacing = ConsumeLength(
      stream, context, CSSPrimitiveValue::ValueRange::kNonNegative, css_parsing_utils::UnitlessQuirk::kAllow);
  if (!vertical_spacing) {
    vertical_spacing = horizontal_spacing;
  }
  return true;
}
//
// std::shared_ptr<const CSSValue> BorderSpacing::CSSValueFromComputedStyleInternal(
//    const ComputedStyle& style,
//    const LayoutObject*,
//    bool allow_visited_style,
//    CSSValuePhase value_phase) const {
//  CSSValueList* list = CSSValueList::CreateSpaceSeparated();
//  list->Append(*ZoomAdjustedPixelValue(style.HorizontalBorderSpacing(), style));
//  list->Append(*ZoomAdjustedPixelValue(style.VerticalBorderSpacing(), style));
//  return list;
//}

bool BorderStyle::ParseShorthand(bool important,
                                 CSSParserTokenStream& stream,
                                 const CSSParserContext& context,
                                 const CSSParserLocalContext&,
                                 std::vector<CSSPropertyValue>& properties) const {
  return css_parsing_utils::ConsumeShorthandVia4Longhands(borderStyleShorthand(), important, context, stream,
                                                          properties);
}
//
// std::shared_ptr<const CSSValue> BorderStyle::CSSValueFromComputedStyleInternal(
//    const ComputedStyle& style,
//    const LayoutObject* layout_object,
//    bool allow_visited_style,
//    CSSValuePhase value_phase) const {
//  return ComputedStyleUtils::ValuesForSidesShorthand(
//      borderStyleShorthand(), style, layout_object, allow_visited_style,
//      value_phase);
//}

bool BorderTop::ParseShorthand(bool important,
                               CSSParserTokenStream& stream,
                               const CSSParserContext& context,
                               const CSSParserLocalContext&,
                               std::vector<CSSPropertyValue>& properties) const {
  return css_parsing_utils::ConsumeShorthandGreedilyViaLonghands(borderTopShorthand(), important, context, stream,
                                                                 properties);
}
//
// std::shared_ptr<const CSSValue> BorderTop::CSSValueFromComputedStyleInternal(
//    const ComputedStyle& style,
//    const LayoutObject* layout_object,
//    bool allow_visited_style,
//    CSSValuePhase value_phase) const {
//  return ComputedStyleUtils::ValuesForShorthandProperty(
//      borderTopShorthand(), style, layout_object, allow_visited_style,
//      value_phase);
//}

bool BorderWidth::ParseShorthand(bool important,
                                 CSSParserTokenStream& stream,
                                 const CSSParserContext& context,
                                 const CSSParserLocalContext&,
                                 std::vector<CSSPropertyValue>& properties) const {
  return css_parsing_utils::ConsumeShorthandVia4Longhands(borderWidthShorthand(), important, context, stream,
                                                          properties);
}
//
// std::shared_ptr<const CSSValue> BorderWidth::CSSValueFromComputedStyleInternal(
//    const ComputedStyle& style,
//    const LayoutObject* layout_object,
//    bool allow_visited_style,
//    CSSValuePhase value_phase) const {
//  return ComputedStyleUtils::ValuesForSidesShorthand(
//      borderWidthShorthand(), style, layout_object, allow_visited_style,
//      value_phase);
//}

bool ColumnRule::ParseShorthand(bool important,
                                CSSParserTokenStream& stream,
                                const CSSParserContext& context,
                                const CSSParserLocalContext&,
                                std::vector<CSSPropertyValue>& properties) const {
  return css_parsing_utils::ConsumeShorthandGreedilyViaLonghands(columnRuleShorthand(), important, context, stream,
                                                                 properties);
}
//
// std::shared_ptr<const CSSValue> ColumnRule::CSSValueFromComputedStyleInternal(
//    const ComputedStyle& style,
//    const LayoutObject* layout_object,
//    bool allow_visited_style,
//    CSSValuePhase value_phase) const {
//  return ComputedStyleUtils::ValuesForShorthandProperty(
//      columnRuleShorthand(), style, layout_object, allow_visited_style,
//      value_phase);
//}

bool Columns::ParseShorthand(bool important,
                             CSSParserTokenStream& stream,
                             const CSSParserContext& context,
                             const CSSParserLocalContext&,
                             std::vector<CSSPropertyValue>& properties) const {
  std::shared_ptr<const CSSValue> column_width = nullptr;
  std::shared_ptr<const CSSValue> column_count = nullptr;
  if (!css_parsing_utils::ConsumeColumnWidthOrCount(stream, context, column_width, column_count)) {
    return false;
  }
  css_parsing_utils::ConsumeColumnWidthOrCount(stream, context, column_width, column_count);
  if (!column_width) {
    column_width = CSSIdentifierValue::Create(CSSValueID::kAuto);
  }
  if (!column_count) {
    column_count = CSSIdentifierValue::Create(CSSValueID::kAuto);
  }
  css_parsing_utils::AddProperty(CSSPropertyID::kColumnWidth, CSSPropertyID::kInvalid, column_width, important,
                                 css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  css_parsing_utils::AddProperty(CSSPropertyID::kColumnCount, CSSPropertyID::kInvalid, column_count, important,
                                 css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  return true;
}
//
// std::shared_ptr<const CSSValue> Columns::CSSValueFromComputedStyleInternal(
//    const ComputedStyle& style,
//    const LayoutObject* layout_object,
//    bool allow_visited_style,
//    CSSValuePhase value_phase) const {
//  return ComputedStyleUtils::ValuesForShorthandProperty(
//      columnsShorthand(), style, layout_object, allow_visited_style,
//      value_phase);
//}

//
// std::shared_ptr<const CSSValue> ContainIntrinsicSize::CSSValueFromComputedStyleInternal(
//    const ComputedStyle& style,
//    const LayoutObject* layout_object,
//    bool allow_visited_style,
//    CSSValuePhase value_phase) const {
//  const StylePropertyShorthand& shorthand = containIntrinsicSizeShorthand();
//  const auto& width = style.ContainIntrinsicWidth();
//  const auto& height = style.ContainIntrinsicHeight();
//  if (width != height) {
//    return ComputedStyleUtils::ValuesForShorthandProperty(
//        shorthand, style, layout_object, allow_visited_style, value_phase);
//  }
//  return shorthand.properties()[0]->CSSValueFromComputedStyle(
//      style, layout_object, allow_visited_style, value_phase);
//}

bool Container::ParseShorthand(bool important,
                               CSSParserTokenStream& stream,
                               const CSSParserContext& context,
                               const CSSParserLocalContext&,
                               std::vector<CSSPropertyValue>& properties) const {
  std::shared_ptr<const CSSValue> name = css_parsing_utils::ConsumeContainerName(stream, context);
  if (!name) {
    return false;
  }

  std::shared_ptr<const CSSValue> type = CSSIdentifierValue::Create(CSSValueID::kNormal);
  if (css_parsing_utils::ConsumeSlashIncludingWhitespace(stream)) {
    if (!(type = css_parsing_utils::ConsumeContainerType(stream))) {
      return false;
    }
  }

  css_parsing_utils::AddProperty(CSSPropertyID::kContainerName, CSSPropertyID::kContainer, name, important,
                                 css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);

  css_parsing_utils::AddProperty(CSSPropertyID::kContainerType, CSSPropertyID::kContainer, type, important,
                                 css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);

  return true;
}
//
// std::shared_ptr<const CSSValue> Container::CSSValueFromComputedStyleInternal(
//    const ComputedStyle& style,
//    const LayoutObject* layout_object,
//    bool allow_visited_style,
//    CSSValuePhase value_phase) const {
//  return ComputedStyleUtils::ValuesForContainerShorthand(
//      style, layout_object, allow_visited_style, value_phase);
//}

bool Flex::ParseShorthand(bool important,
                          CSSParserTokenStream& stream,
                          const CSSParserContext& context,
                          const CSSParserLocalContext&,
                          std::vector<CSSPropertyValue>& properties) const {
  static const double kUnsetValue = -1;
  double flex_grow = kUnsetValue;
  double flex_shrink = kUnsetValue;
  std::shared_ptr<const CSSValue> flex_basis = nullptr;

  if (stream.Peek().Id() == CSSValueID::kNone) {
    flex_grow = 0;
    flex_shrink = 0;
    flex_basis = CSSIdentifierValue::Create(CSSValueID::kAuto);
    stream.ConsumeIncludingWhitespace();
  } else {
    for (;;) {
      CSSParserSavePoint savepoint(stream);
      double num;
      if (css_parsing_utils::ConsumeNumberRaw(stream, context, num)) {
        if (num < 0) {
          break;
        }
        if (flex_grow == kUnsetValue) {
          flex_grow = num;
          savepoint.Release();
        } else if (flex_shrink == kUnsetValue) {
          flex_shrink = num;
          savepoint.Release();
        } else if (!num && !flex_basis) {
          // Unitless zero is a valid <'flex-basis'>. All other <length>s
          // must have some unit, and are handled by the other branch.
          flex_basis = CSSNumericLiteralValue::Create(0, CSSPrimitiveValue::UnitType::kPixels);
          savepoint.Release();
        } else {
          break;
        }
      } else if (!flex_basis) {
        if (css_parsing_utils::IdentMatches<CSSValueID::kAuto, CSSValueID::kContent, CSSValueID::kMinContent,
                                            CSSValueID::kMaxContent, CSSValueID::kFitContent>(stream.Peek().Id())) {
          flex_basis = css_parsing_utils::ConsumeIdent(stream);
        }
        if (!flex_basis) {
          flex_basis =
              css_parsing_utils::ConsumeLengthOrPercent(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative);
        }
        if (flex_basis) {
          // <'flex-basis'> may not appear between <'flex-grow'> and
          // <'flex-shrink'>. We therefore ensure that grow and shrink are
          // either both set, or both unset, once <'flex-basis'> is seen.
          if (flex_grow != kUnsetValue && flex_shrink == kUnsetValue) {
            flex_shrink = 1;
          }
          DCHECK_EQ(flex_grow == kUnsetValue, flex_shrink == kUnsetValue);
          savepoint.Release();
        } else {
          break;
        }
      } else {
        break;
      }
    }
    if (flex_grow == kUnsetValue && flex_shrink == kUnsetValue && !flex_basis) {
      return false;
    }
    if (flex_grow == kUnsetValue) {
      flex_grow = 1;
    }
    if (flex_shrink == kUnsetValue) {
      flex_shrink = 1;
    }
    if (!flex_basis) {
      flex_basis = CSSNumericLiteralValue::Create(0, CSSPrimitiveValue::UnitType::kPercentage);
    }
  }

  css_parsing_utils::AddProperty(
      CSSPropertyID::kFlexGrow, CSSPropertyID::kFlex,
      CSSNumericLiteralValue::Create(ClampTo<float>(flex_grow), CSSPrimitiveValue::UnitType::kNumber), important,
      css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  css_parsing_utils::AddProperty(
      CSSPropertyID::kFlexShrink, CSSPropertyID::kFlex,
      CSSNumericLiteralValue::Create(ClampTo<float>(flex_shrink), CSSPrimitiveValue::UnitType::kNumber), important,
      css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);

  css_parsing_utils::AddProperty(CSSPropertyID::kFlexBasis, CSSPropertyID::kFlex, flex_basis, important,
                                 css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);

  return true;
}

// std::shared_ptr<const CSSValue> Flex::CSSValueFromComputedStyleInternal(
//     const ComputedStyle& style,
//     const LayoutObject* layout_object,
//     bool allow_visited_style,
//     CSSValuePhase value_phase) const {
//   return ComputedStyleUtils::ValuesForShorthandProperty(
//       flexShorthand(), style, layout_object, allow_visited_style, value_phase);
// }

bool FlexFlow::ParseShorthand(bool important,
                              CSSParserTokenStream& stream,
                              const CSSParserContext& context,
                              const CSSParserLocalContext&,
                              std::vector<CSSPropertyValue>& properties) const {
  return css_parsing_utils::ConsumeShorthandGreedilyViaLonghands(flexFlowShorthand(), important, context, stream,
                                                                 properties,
                                                                 /* use_initial_value_function */ true);
}

// std::shared_ptr<const CSSValue> FlexFlow::CSSValueFromComputedStyleInternal(
//     const ComputedStyle& style,
//     const LayoutObject* layout_object,
//     bool allow_visited_style,
//     CSSValuePhase value_phase) const {
//   return ComputedStyleUtils::ValuesForShorthandProperty(
//       flexFlowShorthand(), style, layout_object, allow_visited_style,
//       value_phase);
// }

namespace {

bool ConsumeSystemFont(bool important, CSSParserTokenStream& stream, std::vector<CSSPropertyValue>& properties) {
  CSSValueID system_font_id = stream.ConsumeIncludingWhitespace().Id();
  DCHECK(CSSParserFastPaths::IsValidSystemFont(system_font_id));

  css_parsing_utils::AddExpandedPropertyForValue(
      CSSPropertyID::kFont, cssvalue::CSSPendingSystemFontValue::Create(system_font_id), important, properties);
  return true;
}

bool ConsumeFont(bool important,
                 CSSParserTokenStream& stream,
                 const CSSParserContext& context,
                 std::vector<CSSPropertyValue>& properties) {
  // Optional font-style, font-variant, font-stretch and font-weight.
  // Each may be normal.
  std::shared_ptr<const CSSValue> font_style = nullptr;
  std::shared_ptr<const CSSIdentifierValue> font_variant_caps = nullptr;
  std::shared_ptr<const CSSValue> font_weight = nullptr;
  std::shared_ptr<const CSSValue> font_stretch = nullptr;
  const int kNumReorderableFontProperties = 4;
  for (int i = 0; i < kNumReorderableFontProperties && !stream.AtEnd(); ++i) {
    CSSValueID id = stream.Peek().Id();
    if (id == CSSValueID::kNormal) {
      css_parsing_utils::ConsumeIdent(stream);
      continue;
    }
    if (!font_style && (id == CSSValueID::kItalic || id == CSSValueID::kOblique)) {
      font_style = css_parsing_utils::ConsumeFontStyle(stream, context);
      if (!font_style) {
        // NOTE: Strictly speaking, perhaps we should rewind the stream here
        // and return true instead, but given that this rule exists solely
        // for accepting !important, we can just as well give a parse error.
        return false;
      }
      continue;
    }
    if (!font_variant_caps && id == CSSValueID::kSmallCaps) {
      // Font variant in the shorthand is particular, it only accepts normal
      // or small-caps. See https://drafts.csswg.org/css-fonts/#propdef-font
      font_variant_caps = css_parsing_utils::ConsumeFontVariantCSS21(stream);
      if (font_variant_caps) {
        continue;
      }
    }
    if (!font_weight) {
      font_weight = css_parsing_utils::ConsumeFontWeight(stream, context);
      if (font_weight) {
        continue;
      }
    }
    // Stretch in the font shorthand can only take the CSS Fonts Level 3
    // keywords, not arbitrary values, compare
    // https://drafts.csswg.org/css-fonts-4/#font-prop
    // Bail out if the last possible property of the set in this loop could
    // not be parsed, this closes the first block of optional values of the
    // font shorthand, compare: [ [ <‘font-style’> || <font-variant-css21> ||
    // <‘font-weight’> || <font-stretch-css3> ]?
    if (font_stretch || !(font_stretch = css_parsing_utils::ConsumeFontStretchKeywordOnly(stream, context))) {
      break;
    }
  }

  if (stream.AtEnd()) {
    return false;
  }

  css_parsing_utils::AddProperty(CSSPropertyID::kFontStyle, CSSPropertyID::kFont,
                                 font_style ? font_style : CSSIdentifierValue::Create(CSSValueID::kNormal), important,
                                 css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  css_parsing_utils::AddProperty(
      CSSPropertyID::kFontVariantCaps, CSSPropertyID::kFont,
      font_variant_caps ? font_variant_caps : CSSIdentifierValue::Create(CSSValueID::kNormal), important,
      css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);

  // All subproperties of the font, i.e. font-size-adjust, font-kerning, all
  // subproperties of font-variant, font-feature-settings,
  // font-language-override, font-optical-sizing and font-variation-settings
  // property should be reset to their initial values, compare
  // https://drafts.csswg.org/css-fonts-4/#font-prop
  css_parsing_utils::AddProperty(CSSPropertyID::kFontVariantLigatures, CSSPropertyID::kFont,
                                 CSSIdentifierValue::Create(CSSValueID::kNormal), important,
                                 css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  css_parsing_utils::AddProperty(CSSPropertyID::kFontVariantNumeric, CSSPropertyID::kFont,
                                 CSSIdentifierValue::Create(CSSValueID::kNormal), important,
                                 css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  css_parsing_utils::AddProperty(CSSPropertyID::kFontVariantEastAsian, CSSPropertyID::kFont,
                                 CSSIdentifierValue::Create(CSSValueID::kNormal), important,
                                 css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  css_parsing_utils::AddProperty(CSSPropertyID::kFontVariantAlternates, CSSPropertyID::kFont,
                                 CSSIdentifierValue::Create(CSSValueID::kNormal), important,
                                 css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  css_parsing_utils::AddProperty(CSSPropertyID::kFontSizeAdjust, CSSPropertyID::kFont,
                                 CSSIdentifierValue::Create(CSSValueID::kNone), important,
                                 css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  css_parsing_utils::AddProperty(CSSPropertyID::kFontKerning, CSSPropertyID::kFont,
                                 CSSIdentifierValue::Create(CSSValueID::kAuto), important,
                                 css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  css_parsing_utils::AddProperty(CSSPropertyID::kFontOpticalSizing, CSSPropertyID::kFont,
                                 CSSIdentifierValue::Create(CSSValueID::kAuto), important,
                                 css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  css_parsing_utils::AddProperty(CSSPropertyID::kFontFeatureSettings, CSSPropertyID::kFont,
                                 CSSIdentifierValue::Create(CSSValueID::kNormal), important,
                                 css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  css_parsing_utils::AddProperty(CSSPropertyID::kFontVariationSettings, CSSPropertyID::kFont,
                                 CSSIdentifierValue::Create(CSSValueID::kNormal), important,
                                 css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  css_parsing_utils::AddProperty(CSSPropertyID::kFontVariantPosition, CSSPropertyID::kFont,
                                 CSSIdentifierValue::Create(CSSValueID::kNormal), important,
                                 css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);

  css_parsing_utils::AddProperty(CSSPropertyID::kFontVariantEmoji, CSSPropertyID::kFont,
                                 CSSIdentifierValue::Create(CSSValueID::kNormal), important,
                                 css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);

  css_parsing_utils::AddProperty(CSSPropertyID::kFontWeight, CSSPropertyID::kFont,
                                 font_weight ? font_weight : CSSIdentifierValue::Create(CSSValueID::kNormal), important,
                                 css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  css_parsing_utils::AddProperty(CSSPropertyID::kFontStretch, CSSPropertyID::kFont,
                                 font_stretch ? font_stretch : CSSIdentifierValue::Create(CSSValueID::kNormal),
                                 important, css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);

  // Now a font size _must_ come.
  std::shared_ptr<const CSSValue> font_size = css_parsing_utils::ConsumeFontSize(stream, context);
  if (!font_size || stream.AtEnd()) {
    return false;
  }

  css_parsing_utils::AddProperty(CSSPropertyID::kFontSize, CSSPropertyID::kFont, font_size, important,
                                 css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);

  if (css_parsing_utils::ConsumeSlashIncludingWhitespace(stream)) {
    std::shared_ptr<const CSSValue> line_height = css_parsing_utils::ConsumeLineHeight(stream, context);
    if (!line_height) {
      return false;
    }
    css_parsing_utils::AddProperty(CSSPropertyID::kLineHeight, CSSPropertyID::kFont, line_height, important,
                                   css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  } else {
    css_parsing_utils::AddProperty(CSSPropertyID::kLineHeight, CSSPropertyID::kFont,
                                   CSSIdentifierValue::Create(CSSValueID::kNormal), important,
                                   css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  }

  // Font family must come now.
  std::shared_ptr<const CSSValue> parsed_family_value = css_parsing_utils::ConsumeFontFamily(stream);
  if (!parsed_family_value) {
    return false;
  }

  css_parsing_utils::AddProperty(CSSPropertyID::kFontFamily, CSSPropertyID::kFont, parsed_family_value, important,
                                 css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);

  return true;
}

}  // namespace

bool Font::ParseShorthand(bool important,
                          CSSParserTokenStream& stream,
                          const CSSParserContext& context,
                          const CSSParserLocalContext&,
                          std::vector<CSSPropertyValue>& properties) const {
  const CSSParserToken& token = stream.Peek();
  if (CSSParserFastPaths::IsValidSystemFont(token.Id())) {
    return ConsumeSystemFont(important, stream, properties);
  }
  return ConsumeFont(important, stream, context, properties);
}
//
// std::shared_ptr<const CSSValue> Font::CSSValueFromComputedStyleInternal(
//    const ComputedStyle& style,
//    const LayoutObject*,
//    bool allow_visited_style,
//    CSSValuePhase value_phase) const {
//  return ComputedStyleUtils::ValueForFont(style);
//}

bool FontVariant::ParseShorthand(bool important,
                                 CSSParserTokenStream& stream,
                                 const CSSParserContext& context,
                                 const CSSParserLocalContext&,
                                 std::vector<CSSPropertyValue>& properties) const {
  if (css_parsing_utils::IdentMatches<CSSValueID::kNormal, CSSValueID::kNone>(stream.Peek().Id())) {
    css_parsing_utils::AddProperty(CSSPropertyID::kFontVariantLigatures, CSSPropertyID::kFontVariant,
                                   css_parsing_utils::ConsumeIdent(stream), important,
                                   css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
    css_parsing_utils::AddProperty(CSSPropertyID::kFontVariantCaps, CSSPropertyID::kFontVariant,
                                   CSSIdentifierValue::Create(CSSValueID::kNormal), important,
                                   css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
    css_parsing_utils::AddProperty(CSSPropertyID::kFontVariantNumeric, CSSPropertyID::kFontVariant,
                                   CSSIdentifierValue::Create(CSSValueID::kNormal), important,
                                   css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
    css_parsing_utils::AddProperty(CSSPropertyID::kFontVariantEastAsian, CSSPropertyID::kFontVariant,
                                   CSSIdentifierValue::Create(CSSValueID::kNormal), important,
                                   css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
    css_parsing_utils::AddProperty(CSSPropertyID::kFontVariantAlternates, CSSPropertyID::kFontVariant,
                                   CSSIdentifierValue::Create(CSSValueID::kNormal), important,
                                   css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
    css_parsing_utils::AddProperty(CSSPropertyID::kFontVariantPosition, CSSPropertyID::kFontVariant,
                                   CSSIdentifierValue::Create(CSSValueID::kNormal), important,
                                   css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
    css_parsing_utils::AddProperty(CSSPropertyID::kFontVariantEmoji, CSSPropertyID::kFontVariant,
                                   CSSIdentifierValue::Create(CSSValueID::kNormal), important,
                                   css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
    return true;
  }

  std::shared_ptr<const CSSIdentifierValue> caps_value = nullptr;
  FontVariantLigaturesParser ligatures_parser;
  FontVariantNumericParser numeric_parser;
  FontVariantEastAsianParser east_asian_parser;
  FontVariantAlternatesParser alternates_parser;
  std::shared_ptr<const CSSIdentifierValue> position_value = nullptr;
  std::shared_ptr<const CSSIdentifierValue> emoji_value = nullptr;
  bool first_value = true;
  do {
    FontVariantLigaturesParser::ParseResult ligatures_parse_result = ligatures_parser.ConsumeLigature(stream);
    FontVariantNumericParser::ParseResult numeric_parse_result = numeric_parser.ConsumeNumeric(stream);
    FontVariantEastAsianParser::ParseResult east_asian_parse_result = east_asian_parser.ConsumeEastAsian(stream);
    FontVariantAlternatesParser::ParseResult alternates_parse_result =
        alternates_parser.ConsumeAlternates(stream, context);
    if (ligatures_parse_result == FontVariantLigaturesParser::ParseResult::kConsumedValue ||
        numeric_parse_result == FontVariantNumericParser::ParseResult::kConsumedValue ||
        east_asian_parse_result == FontVariantEastAsianParser::ParseResult::kConsumedValue ||
        alternates_parse_result == FontVariantAlternatesParser::ParseResult::kConsumedValue) {
      first_value = false;
      continue;
    }

    if (ligatures_parse_result == FontVariantLigaturesParser::ParseResult::kDisallowedValue ||
        numeric_parse_result == FontVariantNumericParser::ParseResult::kDisallowedValue ||
        east_asian_parse_result == FontVariantEastAsianParser::ParseResult::kDisallowedValue ||
        alternates_parse_result == FontVariantAlternatesParser::ParseResult::kDisallowedValue) {
      return false;
    }

    CSSValueID id = stream.Peek().Id();
    bool fail = false;
    switch (id) {
      case CSSValueID::kSmallCaps:
      case CSSValueID::kAllSmallCaps:
      case CSSValueID::kPetiteCaps:
      case CSSValueID::kAllPetiteCaps:
      case CSSValueID::kUnicase:
      case CSSValueID::kTitlingCaps:
        // Only one caps value permitted in font-variant grammar.
        if (caps_value) {
          return false;
        }
        caps_value = css_parsing_utils::ConsumeIdent(stream);
        break;
      case CSSValueID::kSub:
      case CSSValueID::kSuper:
        // Only one position value permitted in font-variant grammar.
        if (position_value) {
          return false;
        }
        position_value = css_parsing_utils::ConsumeIdent(stream);
        break;
      case CSSValueID::kText:
      case CSSValueID::kEmoji:
      case CSSValueID::kUnicode:
        // Only one emoji value permitted in font-variant grammar.
        if (emoji_value) {
          return false;
        }
        emoji_value = css_parsing_utils::ConsumeIdent(stream);
        break;
      default:
        // Random junk at the end is allowed (could be “!important”,
        // and if it's not, the caller will reject the value for us).
        fail = true;
        break;
    }
    if (fail) {
      if (first_value) {
        // Need at least one good value.
        return false;
      }
      break;
    }
    first_value = false;
  } while (!stream.AtEnd());

  css_parsing_utils::AddProperty(CSSPropertyID::kFontVariantLigatures, CSSPropertyID::kFontVariant,
                                 ligatures_parser.FinalizeValue(), important,
                                 css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  css_parsing_utils::AddProperty(CSSPropertyID::kFontVariantNumeric, CSSPropertyID::kFontVariant,
                                 numeric_parser.FinalizeValue(), important,
                                 css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  css_parsing_utils::AddProperty(CSSPropertyID::kFontVariantEastAsian, CSSPropertyID::kFontVariant,
                                 east_asian_parser.FinalizeValue(), important,
                                 css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  css_parsing_utils::AddProperty(CSSPropertyID::kFontVariantCaps, CSSPropertyID::kFontVariant,
                                 caps_value ? caps_value : CSSIdentifierValue::Create(CSSValueID::kNormal), important,
                                 css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  css_parsing_utils::AddProperty(CSSPropertyID::kFontVariantAlternates, CSSPropertyID::kFontVariant,
                                 alternates_parser.FinalizeValue(), important,
                                 css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  css_parsing_utils::AddProperty(CSSPropertyID::kFontVariantPosition, CSSPropertyID::kFontVariant,
                                 position_value ? position_value : CSSIdentifierValue::Create(CSSValueID::kNormal),
                                 important, css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  css_parsing_utils::AddProperty(CSSPropertyID::kFontVariantEmoji, CSSPropertyID::kFontVariant,
                                 emoji_value ? emoji_value : CSSIdentifierValue::Create(CSSValueID::kNormal), important,
                                 css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  return true;
}

// std::shared_ptr<const CSSValue> FontVariant::CSSValueFromComputedStyleInternal(
//     const ComputedStyle& style,
//     const LayoutObject* layout_object,
//     bool allow_visited_style,
//     CSSValuePhase value_phase) const {
//   return ComputedStyleUtils::ValuesForFontVariantProperty(
//       style, layout_object, allow_visited_style, value_phase);
// }

bool FontSynthesis::ParseShorthand(bool important,
                                   CSSParserTokenStream& stream,
                                   const CSSParserContext&,
                                   const CSSParserLocalContext&,
                                   std::vector<CSSPropertyValue>& properties) const {
  if (stream.Peek().Id() == CSSValueID::kNone) {
    stream.ConsumeIncludingWhitespace();
    css_parsing_utils::AddProperty(CSSPropertyID::kFontSynthesisWeight, CSSPropertyID::kFontSynthesis,
                                   CSSIdentifierValue::Create(CSSValueID::kNone), important,
                                   css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
    css_parsing_utils::AddProperty(CSSPropertyID::kFontSynthesisStyle, CSSPropertyID::kFontSynthesis,
                                   CSSIdentifierValue::Create(CSSValueID::kNone), important,
                                   css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
    css_parsing_utils::AddProperty(CSSPropertyID::kFontSynthesisSmallCaps, CSSPropertyID::kFontSynthesis,
                                   CSSIdentifierValue::Create(CSSValueID::kNone), important,
                                   css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
    return true;
  }

  std::shared_ptr<const CSSValue> font_synthesis_weight = nullptr;
  std::shared_ptr<const CSSValue> font_synthesis_style = nullptr;
  std::shared_ptr<const CSSValue> font_synthesis_small_caps = nullptr;
  do {
    if (stream.Peek().GetType() != kIdentToken) {
      break;
    }
    CSSParserSavePoint savepoint(stream);
    bool fail = false;
    CSSValueID id = stream.ConsumeIncludingWhitespace().Id();
    switch (id) {
      case CSSValueID::kWeight:
        if (font_synthesis_weight) {
          return false;
        }
        font_synthesis_weight = CSSIdentifierValue::Create(CSSValueID::kAuto);
        savepoint.Release();
        break;
      case CSSValueID::kStyle:
        if (font_synthesis_style) {
          return false;
        }
        font_synthesis_style = CSSIdentifierValue::Create(CSSValueID::kAuto);
        savepoint.Release();
        break;
      case CSSValueID::kSmallCaps:
        if (font_synthesis_small_caps) {
          return false;
        }
        font_synthesis_small_caps = CSSIdentifierValue::Create(CSSValueID::kAuto);
        savepoint.Release();
        break;
      default:
        // Random junk at the end is allowed (could be “!important”,
        // and if it's not, the caller will reject the value for us).
        fail = true;
        break;
    }
    if (fail) {
      break;
    }
  } while (!stream.AtEnd());

  if (!font_synthesis_weight && !font_synthesis_style && !font_synthesis_small_caps) {
    return false;
  }

  css_parsing_utils::AddProperty(
      CSSPropertyID::kFontSynthesisWeight, CSSPropertyID::kFontSynthesis,
      font_synthesis_weight ? font_synthesis_weight : CSSIdentifierValue::Create(CSSValueID::kNone), important,
      css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  css_parsing_utils::AddProperty(
      CSSPropertyID::kFontSynthesisStyle, CSSPropertyID::kFontSynthesis,
      font_synthesis_style ? font_synthesis_style : CSSIdentifierValue::Create(CSSValueID::kNone), important,
      css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  css_parsing_utils::AddProperty(
      CSSPropertyID::kFontSynthesisSmallCaps, CSSPropertyID::kFontSynthesis,
      font_synthesis_small_caps ? font_synthesis_small_caps : CSSIdentifierValue::Create(CSSValueID::kNone), important,
      css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  return true;
}

// std::shared_ptr<const CSSValue> FontSynthesis::CSSValueFromComputedStyleInternal(
//     const ComputedStyle& style,
//     const LayoutObject* layout_object,
//     bool allow_visited_style,
//     CSSValuePhase value_phase) const {
//   return ComputedStyleUtils::ValuesForFontSynthesisProperty(
//       style, layout_object, allow_visited_style, value_phase);
// }

bool Gap::ParseShorthand(bool important,
                         CSSParserTokenStream& stream,
                         const CSSParserContext& context,
                         const CSSParserLocalContext&,
                         std::vector<CSSPropertyValue>& properties) const {
  DCHECK_EQ(shorthandForProperty(CSSPropertyID::kGap).length(), 2u);
  std::shared_ptr<const CSSValue> row_gap = css_parsing_utils::ConsumeGapLength(stream, context);
  std::shared_ptr<const CSSValue> column_gap = css_parsing_utils::ConsumeGapLength(stream, context);
  if (!row_gap) {
    return false;
  }
  if (!column_gap) {
    column_gap = row_gap;
  }
  css_parsing_utils::AddProperty(CSSPropertyID::kRowGap, CSSPropertyID::kGap, row_gap, important,
                                 css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  css_parsing_utils::AddProperty(CSSPropertyID::kColumnGap, CSSPropertyID::kGap, column_gap, important,
                                 css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  return true;
}
//
// std::shared_ptr<const CSSValue> Gap::CSSValueFromComputedStyleInternal(
//    const ComputedStyle& style,
//    const LayoutObject* layout_object,
//    bool allow_visited_style,
//    CSSValuePhase value_phase) const {
//  return ComputedStyleUtils::ValuesForGapShorthand(
//      gapShorthand(), style, layout_object, allow_visited_style, value_phase);
//}

bool GridArea::ParseShorthand(bool important,
                              CSSParserTokenStream& stream,
                              const CSSParserContext& context,
                              const CSSParserLocalContext&,
                              std::vector<CSSPropertyValue>& properties) const {
  DCHECK_EQ(gridAreaShorthand().length(), 4u);

  std::shared_ptr<const CSSValue> row_start_value = css_parsing_utils::ConsumeGridLine(stream, context);
  if (!row_start_value) {
    return false;
  }
  std::shared_ptr<const CSSValue> column_start_value = nullptr;
  std::shared_ptr<const CSSValue> row_end_value = nullptr;
  std::shared_ptr<const CSSValue> column_end_value = nullptr;
  if (css_parsing_utils::ConsumeSlashIncludingWhitespace(stream)) {
    column_start_value = css_parsing_utils::ConsumeGridLine(stream, context);
    if (!column_start_value) {
      return false;
    }
    if (css_parsing_utils::ConsumeSlashIncludingWhitespace(stream)) {
      row_end_value = css_parsing_utils::ConsumeGridLine(stream, context);
      if (!row_end_value) {
        return false;
      }
      if (css_parsing_utils::ConsumeSlashIncludingWhitespace(stream)) {
        column_end_value = css_parsing_utils::ConsumeGridLine(stream, context);
        if (!column_end_value) {
          return false;
        }
      }
    }
  }
  if (!column_start_value) {
    column_start_value =
        row_start_value->IsCustomIdentValue() ? row_start_value : CSSIdentifierValue::Create(CSSValueID::kAuto);
  }
  if (!row_end_value) {
    row_end_value =
        row_start_value->IsCustomIdentValue() ? row_start_value : CSSIdentifierValue::Create(CSSValueID::kAuto);
  }
  if (!column_end_value) {
    column_end_value =
        column_start_value->IsCustomIdentValue() ? column_start_value : CSSIdentifierValue::Create(CSSValueID::kAuto);
  }

  css_parsing_utils::AddProperty(CSSPropertyID::kGridRowStart, CSSPropertyID::kGridArea, row_start_value, important,
                                 css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  css_parsing_utils::AddProperty(CSSPropertyID::kGridColumnStart, CSSPropertyID::kGridArea, column_start_value,
                                 important, css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  css_parsing_utils::AddProperty(CSSPropertyID::kGridRowEnd, CSSPropertyID::kGridArea, row_end_value, important,
                                 css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  css_parsing_utils::AddProperty(CSSPropertyID::kGridColumnEnd, CSSPropertyID::kGridArea, column_end_value, important,
                                 css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  return true;
}
//
// std::shared_ptr<const CSSValue> GridArea::CSSValueFromComputedStyleInternal(
//    const ComputedStyle& style,
//    const LayoutObject* layout_object,
//    bool allow_visited_style,
//    CSSValuePhase value_phase) const {
//  return ComputedStyleUtils::ValuesForGridAreaShorthand(
//      gridAreaShorthand(), style, layout_object, allow_visited_style,
//      value_phase);
//}

bool GridColumn::ParseShorthand(bool important,
                                CSSParserTokenStream& stream,
                                const CSSParserContext& context,
                                const CSSParserLocalContext&,
                                std::vector<CSSPropertyValue>& properties) const {
  const StylePropertyShorthand& shorthand = shorthandForProperty(CSSPropertyID::kGridColumn);
  DCHECK_EQ(shorthand.length(), 2u);

  std::shared_ptr<const CSSValue> start_value = nullptr;
  std::shared_ptr<const CSSValue> end_value = nullptr;
  if (!css_parsing_utils::ConsumeGridItemPositionShorthand(important, stream, context, start_value, end_value)) {
    return false;
  }

  css_parsing_utils::AddProperty(shorthand.properties()[0]->PropertyID(), CSSPropertyID::kGridColumn, start_value,
                                 important, css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  css_parsing_utils::AddProperty(shorthand.properties()[1]->PropertyID(), CSSPropertyID::kGridColumn, end_value,
                                 important, css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);

  return true;
}
//
// std::shared_ptr<const CSSValue> GridColumn::CSSValueFromComputedStyleInternal(
//    const ComputedStyle& style,
//    const LayoutObject* layout_object,
//    bool allow_visited_style,
//    CSSValuePhase value_phase) const {
//  return ComputedStyleUtils::ValuesForGridLineShorthand(
//      gridColumnShorthand(), style, layout_object, allow_visited_style,
//      value_phase);
//}

namespace {

std::shared_ptr<const CSSValueList> ConsumeImplicitAutoFlow(CSSParserTokenStream& stream,
                                                            std::shared_ptr<const CSSIdentifierValue> flow_direction) {
  // [ auto-flow && dense? ]
  std::shared_ptr<const CSSValue> dense_algorithm = nullptr;
  if (css_parsing_utils::ConsumeIdent<CSSValueID::kAutoFlow>(stream)) {
    dense_algorithm = css_parsing_utils::ConsumeIdent<CSSValueID::kDense>(stream);
  } else {
    dense_algorithm = css_parsing_utils::ConsumeIdent<CSSValueID::kDense>(stream);
    if (!dense_algorithm) {
      return nullptr;
    }
    if (!css_parsing_utils::ConsumeIdent<CSSValueID::kAutoFlow>(stream)) {
      return nullptr;
    }
  }
  std::shared_ptr<CSSValueList> list = CSSValueList::CreateSpaceSeparated();
  if (flow_direction->GetValueID() == CSSValueID::kColumn || !dense_algorithm) {
    list->Append(flow_direction);
  }
  if (dense_algorithm) {
    list->Append(dense_algorithm);
  }
  return list;
}

}  // namespace

bool Grid::ParseShorthand(bool important,
                          CSSParserTokenStream& stream,
                          const CSSParserContext& context,
                          const CSSParserLocalContext&,
                          std::vector<CSSPropertyValue>& properties) const {
  DCHECK_EQ(shorthandForProperty(CSSPropertyID::kGrid).length(), 6u);

  CSSParserTokenStream::State savepoint = stream.Save();

  std::shared_ptr<const CSSValue> template_rows = nullptr;
  std::shared_ptr<const CSSValue> template_columns = nullptr;
  std::shared_ptr<const CSSValue> template_areas = nullptr;

  // NOTE: The test for stream.AtEnd() here is a practical concession;
  // we should accept any arbitrary junk afterwards, but for cases like
  // “none / auto-flow 100px”, ConsumeGridTemplateShorthand() will consume
  // the “none” alone and return success, which is not what we want
  // (we want to fall back to the part below). So we make a quick fix
  // to check for either end _or_ !important.
  const bool ok = css_parsing_utils::ConsumeGridTemplateShorthand(important, stream, context, template_rows,
                                                                  template_columns, template_areas);
  stream.ConsumeWhitespace();
  if (ok && (stream.AtEnd() || (stream.Peek().GetType() == kDelimiterToken && stream.Peek().Delimiter() == '!'))) {
    DCHECK(template_rows);
    DCHECK(template_columns);
    DCHECK(template_areas);

    css_parsing_utils::AddProperty(CSSPropertyID::kGridTemplateRows, CSSPropertyID::kGrid, template_rows, important,
                                   css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
    css_parsing_utils::AddProperty(CSSPropertyID::kGridTemplateColumns, CSSPropertyID::kGrid, template_columns,
                                   important, css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
    css_parsing_utils::AddProperty(CSSPropertyID::kGridTemplateAreas, CSSPropertyID::kGrid, template_areas, important,
                                   css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);

    // It can only be specified the explicit or the implicit grid properties
    // in a single grid declaration. The sub-properties not specified are set
    // to their initial value, as normal for shorthands.
    css_parsing_utils::AddProperty(CSSPropertyID::kGridAutoFlow, CSSPropertyID::kGrid,
                                   GetCSSPropertyGridAutoFlow().InitialValue(), important,
                                   css_parsing_utils::IsImplicitProperty::kImplicit, properties);
    css_parsing_utils::AddProperty(CSSPropertyID::kGridAutoColumns, CSSPropertyID::kGrid,
                                   GetCSSPropertyGridAutoColumns().InitialValue(), important,
                                   css_parsing_utils::IsImplicitProperty::kImplicit, properties);
    css_parsing_utils::AddProperty(CSSPropertyID::kGridAutoRows, CSSPropertyID::kGrid,
                                   GetCSSPropertyGridAutoRows().InitialValue(), important,
                                   css_parsing_utils::IsImplicitProperty::kImplicit, properties);
    return true;
  }

  stream.Restore(savepoint);

  std::shared_ptr<const CSSValue> auto_columns_value = nullptr;
  std::shared_ptr<const CSSValue> auto_rows_value = nullptr;
  std::shared_ptr<const CSSValueList> grid_auto_flow = nullptr;
  template_rows = nullptr;
  template_columns = nullptr;

  if (css_parsing_utils::IdentMatches<CSSValueID::kDense, CSSValueID::kAutoFlow>(stream.Peek().Id())) {
    // 2- [ auto-flow && dense? ] <grid-auto-rows>? / <grid-template-columns>
    grid_auto_flow = ConsumeImplicitAutoFlow(stream, CSSIdentifierValue::Create(CSSValueID::kRow));
    if (!grid_auto_flow) {
      return false;
    }
    if (css_parsing_utils::ConsumeSlashIncludingWhitespace(stream)) {
      auto_rows_value = GetCSSPropertyGridAutoRows().InitialValue();
    } else {
      auto_rows_value =
          css_parsing_utils::ConsumeGridTrackList(stream, context, css_parsing_utils::TrackListType::kGridAuto);
      if (!auto_rows_value) {
        return false;
      }
      if (!css_parsing_utils::ConsumeSlashIncludingWhitespace(stream)) {
        return false;
      }
    }
    if (!(template_columns = css_parsing_utils::ConsumeGridTemplatesRowsOrColumns(stream, context))) {
      return false;
    }
    template_rows = GetCSSPropertyGridTemplateRows().InitialValue();
    auto_columns_value = GetCSSPropertyGridAutoColumns().InitialValue();
  } else {
    // 3- <grid-template-rows> / [ auto-flow && dense? ] <grid-auto-columns>?
    template_rows = css_parsing_utils::ConsumeGridTemplatesRowsOrColumns(stream, context);
    if (!template_rows) {
      return false;
    }
    if (!css_parsing_utils::ConsumeSlashIncludingWhitespace(stream)) {
      return false;
    }
    grid_auto_flow = ConsumeImplicitAutoFlow(stream, CSSIdentifierValue::Create(CSSValueID::kColumn));
    if (!grid_auto_flow) {
      return false;
    }
    auto_columns_value =
        css_parsing_utils::ConsumeGridTrackList(stream, context, css_parsing_utils::TrackListType::kGridAuto);
    if (!auto_columns_value) {
      // End of stream or parse error; in the latter case,
      // the caller will clean up since we're not at the end.
      auto_columns_value = GetCSSPropertyGridAutoColumns().InitialValue();
    }
    template_columns = GetCSSPropertyGridTemplateColumns().InitialValue();
    auto_rows_value = GetCSSPropertyGridAutoRows().InitialValue();
  }

  // It can only be specified the explicit or the implicit grid properties in
  // a single grid declaration. The sub-properties not specified are set to
  // their initial value, as normal for shorthands.
  css_parsing_utils::AddProperty(CSSPropertyID::kGridTemplateColumns, CSSPropertyID::kGrid, template_columns,
                                 important, css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  css_parsing_utils::AddProperty(CSSPropertyID::kGridTemplateRows, CSSPropertyID::kGrid, template_rows, important,
                                 css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  css_parsing_utils::AddProperty(CSSPropertyID::kGridTemplateAreas, CSSPropertyID::kGrid,
                                 GetCSSPropertyGridTemplateAreas().InitialValue(), important,
                                 css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  css_parsing_utils::AddProperty(CSSPropertyID::kGridAutoFlow, CSSPropertyID::kGrid, grid_auto_flow, important,
                                 css_parsing_utils::IsImplicitProperty::kImplicit, properties);
  css_parsing_utils::AddProperty(CSSPropertyID::kGridAutoColumns, CSSPropertyID::kGrid, auto_columns_value, important,
                                 css_parsing_utils::IsImplicitProperty::kImplicit, properties);
  css_parsing_utils::AddProperty(CSSPropertyID::kGridAutoRows, CSSPropertyID::kGrid, auto_rows_value, important,
                                 css_parsing_utils::IsImplicitProperty::kImplicit, properties);
  return true;
}
//
//std::shared_ptr<const CSSValue> Grid::CSSValueFromComputedStyleInternal(const ComputedStyle& style,
//                                                                        const LayoutObject* layout_object,
//                                                                        bool allow_visited_style,
//                                                                        CSSValuePhase value_phase) const {
//  return ComputedStyleUtils::ValuesForGridShorthand(gridShorthand(), style, layout_object, allow_visited_style,
//                                                    value_phase);
//}

bool GridRow::ParseShorthand(bool important,
                             CSSParserTokenStream& stream,
                             const CSSParserContext& context,
                             const CSSParserLocalContext&,
                             std::vector<CSSPropertyValue>& properties) const {
  const StylePropertyShorthand& shorthand = shorthandForProperty(CSSPropertyID::kGridRow);
  DCHECK_EQ(shorthand.length(), 2u);

  std::shared_ptr<const CSSValue> start_value = nullptr;
  std::shared_ptr<const CSSValue> end_value = nullptr;
  if (!css_parsing_utils::ConsumeGridItemPositionShorthand(important, stream, context, start_value, end_value)) {
    return false;
  }

  css_parsing_utils::AddProperty(shorthand.properties()[0]->PropertyID(), CSSPropertyID::kGridRow, start_value,
                                 important, css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  css_parsing_utils::AddProperty(shorthand.properties()[1]->PropertyID(), CSSPropertyID::kGridRow, end_value,
                                 important, css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);

  return true;
}

//std::shared_ptr<const CSSValue> GridRow::CSSValueFromComputedStyleInternal(const ComputedStyle& style,
//                                                                           const LayoutObject* layout_object,
//                                                                           bool allow_visited_style,
//                                                                           CSSValuePhase value_phase) const {
//  return ComputedStyleUtils::ValuesForGridLineShorthand(gridRowShorthand(), style, layout_object, allow_visited_style,
//                                                        value_phase);
//}

bool GridTemplate::ParseShorthand(bool important,
                                  CSSParserTokenStream& stream,
                                  const CSSParserContext& context,
                                  const CSSParserLocalContext&,
                                  std::vector<CSSPropertyValue>& properties) const {
  std::shared_ptr<const CSSValue> template_rows = nullptr;
  std::shared_ptr<const CSSValue> template_columns = nullptr;
  std::shared_ptr<const CSSValue> template_areas = nullptr;
  if (!css_parsing_utils::ConsumeGridTemplateShorthand(important, stream, context, template_rows, template_columns,
                                                       template_areas)) {
    return false;
  }

  DCHECK(template_rows);
  DCHECK(template_columns);
  DCHECK(template_areas);

  css_parsing_utils::AddProperty(CSSPropertyID::kGridTemplateRows, CSSPropertyID::kGridTemplate, template_rows,
                                 important, css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  css_parsing_utils::AddProperty(CSSPropertyID::kGridTemplateColumns, CSSPropertyID::kGridTemplate, template_columns,
                                 important, css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  css_parsing_utils::AddProperty(CSSPropertyID::kGridTemplateAreas, CSSPropertyID::kGridTemplate, template_areas,
                                 important, css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);

  return true;
}
//
//bool GridTemplate::IsLayoutDependent(const ComputedStyle* style, LayoutObject* layout_object) const {
//  return layout_object && layout_object->IsLayoutGrid();
//}
//
//std::shared_ptr<const CSSValue> GridTemplate::CSSValueFromComputedStyleInternal(const ComputedStyle& style,
//                                                                                const LayoutObject* layout_object,
//                                                                                bool allow_visited_style,
//                                                                                CSSValuePhase value_phase) const {
//  return ComputedStyleUtils::ValuesForGridTemplateShorthand(gridTemplateShorthand(), style, layout_object,
//                                                            allow_visited_style, value_phase);
//}

bool InsetBlock::ParseShorthand(bool important,
                                CSSParserTokenStream& stream,
                                const CSSParserContext& context,
                                const CSSParserLocalContext&,
                                std::vector<CSSPropertyValue>& properties) const {
  return css_parsing_utils::ConsumeShorthandVia2Longhands(insetBlockShorthand(), important, context, stream,
                                                          properties);
}

//std::shared_ptr<const CSSValue> InsetBlock::CSSValueFromComputedStyleInternal(const ComputedStyle& style,
//                                                                              const LayoutObject* layout_object,
//                                                                              bool allow_visited_style,
//                                                                              CSSValuePhase value_phase) const {
//  return ComputedStyleUtils::ValuesForInlineBlockShorthand(insetBlockShorthand(), style, layout_object,
//                                                           allow_visited_style, value_phase);
//}

//bool InsetBlock::IsLayoutDependent(const ComputedStyle* style, LayoutObject* layout_object) const {
//  return layout_object && layout_object->IsBox();
//}

bool Inset::ParseShorthand(bool important,
                           CSSParserTokenStream& stream,
                           const CSSParserContext& context,
                           const CSSParserLocalContext&,
                           std::vector<CSSPropertyValue>& properties) const {
  return css_parsing_utils::ConsumeShorthandVia4Longhands(insetShorthand(), important, context, stream, properties);
}
//
//std::shared_ptr<const CSSValue> Inset::CSSValueFromComputedStyleInternal(const ComputedStyle& style,
//                                                                         const LayoutObject* layout_object,
//                                                                         bool allow_visited_style,
//                                                                         CSSValuePhase value_phase) const {
//  return ComputedStyleUtils::ValuesForSidesShorthand(insetShorthand(), style, layout_object, allow_visited_style,
//                                                     value_phase);
//}

//bool Inset::IsLayoutDependent(const ComputedStyle* style, LayoutObject* layout_object) const {
//  return layout_object && layout_object->IsBox();
//}

bool InsetInline::ParseShorthand(bool important,
                                 CSSParserTokenStream& stream,
                                 const CSSParserContext& context,
                                 const CSSParserLocalContext&,
                                 std::vector<CSSPropertyValue>& properties) const {
  return css_parsing_utils::ConsumeShorthandVia2Longhands(insetInlineShorthand(), important, context, stream,
                                                          properties);
}

//std::shared_ptr<const CSSValue> InsetInline::CSSValueFromComputedStyleInternal(const ComputedStyle& style,
//                                                                               const LayoutObject* layout_object,
//                                                                               bool allow_visited_style,
//                                                                               CSSValuePhase value_phase) const {
//  return ComputedStyleUtils::ValuesForInlineBlockShorthand(insetInlineShorthand(), style, layout_object,
//                                                           allow_visited_style, value_phase);
//}

//bool InsetInline::IsLayoutDependent(const ComputedStyle* style, LayoutObject* layout_object) const {
//  return layout_object && layout_object->IsBox();
//}

bool MarginBlock::ParseShorthand(bool important,
                                 CSSParserTokenStream& stream,
                                 const CSSParserContext& context,
                                 const CSSParserLocalContext&,
                                 std::vector<CSSPropertyValue>& properties) const {
  return css_parsing_utils::ConsumeShorthandVia2Longhands(marginBlockShorthand(), important, context, stream,
                                                          properties);
}

//bool MarginBlock::IsLayoutDependent(const ComputedStyle* style, LayoutObject* layout_object) const {
//  return layout_object && layout_object->IsBox();
//}

//std::shared_ptr<const CSSValue> MarginBlock::CSSValueFromComputedStyleInternal(const ComputedStyle& style,
//                                                                               const LayoutObject* layout_object,
//                                                                               bool allow_visited_style,
//                                                                               CSSValuePhase value_phase) const {
//  return ComputedStyleUtils::ValuesForInlineBlockShorthand(marginBlockShorthand(), style, layout_object,
//                                                           allow_visited_style, value_phase);
//}

bool Margin::ParseShorthand(bool important,
                            CSSParserTokenStream& stream,
                            const CSSParserContext& context,
                            const CSSParserLocalContext&,
                            std::vector<CSSPropertyValue>& properties) const {
  return css_parsing_utils::ConsumeShorthandVia4Longhands(marginShorthand(), important, context, stream, properties);
}

//bool Margin::IsLayoutDependent(const ComputedStyle* style, LayoutObject* layout_object) const {
//  return layout_object && layout_object->IsBox() &&
//         (!style || !style->MarginBottom().IsFixed() || !style->MarginTop().IsFixed() ||
//          !style->MarginLeft().IsFixed() || !style->MarginRight().IsFixed());
//}

//std::shared_ptr<const CSSValue> Margin::CSSValueFromComputedStyleInternal(const ComputedStyle& style,
//                                                                          const LayoutObject* layout_object,
//                                                                          bool allow_visited_style,
//                                                                          CSSValuePhase value_phase) const {
//  return ComputedStyleUtils::ValuesForSidesShorthand(marginShorthand(), style, layout_object, allow_visited_style,
//                                                     value_phase);
//}

bool MarginInline::ParseShorthand(bool important,
                                  CSSParserTokenStream& stream,
                                  const CSSParserContext& context,
                                  const CSSParserLocalContext&,
                                  std::vector<CSSPropertyValue>& properties) const {
  return css_parsing_utils::ConsumeShorthandVia2Longhands(marginInlineShorthand(), important, context, stream,
                                                          properties);
}

//bool MarginInline::IsLayoutDependent(const ComputedStyle* style, LayoutObject* layout_object) const {
//  return layout_object && layout_object->IsBox();
//}

//std::shared_ptr<const CSSValue> MarginInline::CSSValueFromComputedStyleInternal(const ComputedStyle& style,
//                                                                                const LayoutObject* layout_object,
//                                                                                bool allow_visited_style,
//                                                                                CSSValuePhase value_phase) const {
//  return ComputedStyleUtils::ValuesForInlineBlockShorthand(marginInlineShorthand(), style, layout_object,
//                                                           allow_visited_style, value_phase);
//}

bool Marker::ParseShorthand(bool important,
                            CSSParserTokenStream& stream,
                            const CSSParserContext& context,
                            const CSSParserLocalContext&,
                            std::vector<CSSPropertyValue>& properties) const {
  std::shared_ptr<const CSSValue> marker =
      css_parsing_utils::ParseLonghand(CSSPropertyID::kMarkerStart, CSSPropertyID::kMarker, context, stream);
  if (!marker) {
    return false;
  }

  css_parsing_utils::AddProperty(CSSPropertyID::kMarkerStart, CSSPropertyID::kMarker, marker, important,
                                 css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  css_parsing_utils::AddProperty(CSSPropertyID::kMarkerMid, CSSPropertyID::kMarker, marker, important,
                                 css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  css_parsing_utils::AddProperty(CSSPropertyID::kMarkerEnd, CSSPropertyID::kMarker, marker, important,
                                 css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  return true;
}

//std::shared_ptr<const CSSValue> Marker::CSSValueFromComputedStyleInternal(const ComputedStyle& style,
//                                                                          const LayoutObject* layout_object,
//                                                                          bool allow_visited_style,
//                                                                          CSSValuePhase value_phase) const {
//  std::shared_ptr<const CSSValue> marker_start = ComputedStyleUtils::ValueForSVGResource(style.MarkerStartResource());
//  if (*marker_start == *ComputedStyleUtils::ValueForSVGResource(style.MarkerMidResource()) &&
//      *marker_start == *ComputedStyleUtils::ValueForSVGResource(style.MarkerEndResource())) {
//    return marker_start;
//  }
//  return nullptr;
//}

bool Offset::ParseShorthand(bool important,
                            CSSParserTokenStream& stream,
                            const CSSParserContext& context,
                            const CSSParserLocalContext&,
                            std::vector<CSSPropertyValue>& properties) const {
  // TODO(meade): The propertyID parameter isn't used - it can be removed
  // once all of the ParseSingleValue implementations have been moved to the
  // CSSPropertys, and the base CSSProperty::ParseSingleValue contains
  // no functionality.

  std::shared_ptr<const CSSValue> offset_position =
      GetCSSPropertyOffsetPosition().ParseSingleValue(stream, context, CSSParserLocalContext());
  std::shared_ptr<const CSSValue> offset_path = css_parsing_utils::ConsumeOffsetPath(stream, context);
  std::shared_ptr<const CSSValue> offset_distance = nullptr;
  std::shared_ptr<const CSSValue> offset_rotate = nullptr;
  if (offset_path) {
    offset_distance = css_parsing_utils::ConsumeLengthOrPercent(stream, context, CSSPrimitiveValue::ValueRange::kAll);
    offset_rotate = css_parsing_utils::ConsumeOffsetRotate(stream, context);
    if (offset_rotate && !offset_distance) {
      offset_distance = css_parsing_utils::ConsumeLengthOrPercent(stream, context, CSSPrimitiveValue::ValueRange::kAll);
    }
  }
  std::shared_ptr<const CSSValue> offset_anchor = nullptr;
  if (css_parsing_utils::ConsumeSlashIncludingWhitespace(stream)) {
    offset_anchor = GetCSSPropertyOffsetAnchor().ParseSingleValue(stream, context, CSSParserLocalContext());
    if (!offset_anchor) {
      return false;
    }
  }
  if (!offset_position && !offset_path) {
    return false;
  }

  if (!offset_position) {
    offset_position = CSSIdentifierValue::Create(CSSValueID::kNormal);
  }
  css_parsing_utils::AddProperty(CSSPropertyID::kOffsetPosition, CSSPropertyID::kOffset, offset_position, important,
                                 css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);

  if (!offset_path) {
    offset_path = CSSIdentifierValue::Create(CSSValueID::kNone);
  }
  css_parsing_utils::AddProperty(CSSPropertyID::kOffsetPath, CSSPropertyID::kOffset, offset_path, important,
                                 css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);

  if (!offset_distance) {
    offset_distance = CSSNumericLiteralValue::Create(0, CSSPrimitiveValue::UnitType::kPixels);
  }
  css_parsing_utils::AddProperty(CSSPropertyID::kOffsetDistance, CSSPropertyID::kOffset, offset_distance, important,
                                 css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);

  if (!offset_rotate) {
    offset_rotate = CSSIdentifierValue::Create(CSSValueID::kAuto);
  }
  css_parsing_utils::AddProperty(CSSPropertyID::kOffsetRotate, CSSPropertyID::kOffset, offset_rotate, important,
                                 css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);

  if (!offset_anchor) {
    offset_anchor = CSSIdentifierValue::Create(CSSValueID::kAuto);
  }
  css_parsing_utils::AddProperty(CSSPropertyID::kOffsetAnchor, CSSPropertyID::kOffset, offset_anchor, important,
                                 css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);

  return true;
}

//std::shared_ptr<const CSSValue> Offset::CSSValueFromComputedStyleInternal(const ComputedStyle& style,
//                                                                          const LayoutObject* layout_object,
//                                                                          bool allow_visited_style,
//                                                                          CSSValuePhase value_phase) const {
//  return ComputedStyleUtils::ValueForOffset(style, layout_object, allow_visited_style, value_phase);
//}

bool Outline::ParseShorthand(bool important,
                             CSSParserTokenStream& stream,
                             const CSSParserContext& context,
                             const CSSParserLocalContext&,
                             std::vector<CSSPropertyValue>& properties) const {
  return css_parsing_utils::ConsumeShorthandGreedilyViaLonghands(outlineShorthand(), important, context, stream,
                                                                 properties);
}

//std::shared_ptr<const CSSValue> Outline::CSSValueFromComputedStyleInternal(const ComputedStyle& style,
//                                                                           const LayoutObject* layout_object,
//                                                                           bool allow_visited_style,
//                                                                           CSSValuePhase value_phase) const {
//  return ComputedStyleUtils::ValuesForShorthandProperty(outlineShorthand(), style, layout_object, allow_visited_style,
//                                                        value_phase);
//}

bool Overflow::ParseShorthand(bool important,
                              CSSParserTokenStream& stream,
                              const CSSParserContext& context,
                              const CSSParserLocalContext&,
                              std::vector<CSSPropertyValue>& properties) const {
  return css_parsing_utils::ConsumeShorthandVia2Longhands(overflowShorthand(), important, context, stream, properties);
}

//std::shared_ptr<const CSSValue> Overflow::CSSValueFromComputedStyleInternal(const ComputedStyle& style,
//                                                                            const LayoutObject*,
//                                                                            bool allow_visited_style,
//                                                                            CSSValuePhase value_phase) const {
//  CSSValueList* list = CSSValueList::CreateSpaceSeparated();
//  list->Append(*CSSIdentifierValue::Create(style.OverflowX()));
//  if (style.OverflowX() != style.OverflowY()) {
//    list->Append(*CSSIdentifierValue::Create(style.OverflowY()));
//  }
//
//  return list;
//}

//std::shared_ptr<const CSSValue> OverscrollBehavior::CSSValueFromComputedStyleInternal(const ComputedStyle& style,
//                                                                                      const LayoutObject*,
//                                                                                      bool allow_visited_style,
//                                                                                      CSSValuePhase value_phase) const {
//  CSSValueList* list = CSSValueList::CreateSpaceSeparated();
//  list->Append(*CSSIdentifierValue::Create(style.OverscrollBehaviorX()));
//  if (style.OverscrollBehaviorX() != style.OverscrollBehaviorY()) {
//    list->Append(*CSSIdentifierValue::Create(style.OverscrollBehaviorY()));
//  }
//
//  return list;
//}

bool PaddingBlock::ParseShorthand(bool important,
                                  CSSParserTokenStream& stream,
                                  const CSSParserContext& context,
                                  const CSSParserLocalContext&,
                                  std::vector<CSSPropertyValue>& properties) const {
  return css_parsing_utils::ConsumeShorthandVia2Longhands(paddingBlockShorthand(), important, context, stream,
                                                          properties);
}

//std::shared_ptr<const CSSValue> PaddingBlock::CSSValueFromComputedStyleInternal(const ComputedStyle& style,
//                                                                                const LayoutObject* layout_object,
//                                                                                bool allow_visited_style,
//                                                                                CSSValuePhase value_phase) const {
//  return ComputedStyleUtils::ValuesForInlineBlockShorthand(paddingBlockShorthand(), style, layout_object,
//                                                           allow_visited_style, value_phase);
//}

bool Padding::ParseShorthand(bool important,
                             CSSParserTokenStream& stream,
                             const CSSParserContext& context,
                             const CSSParserLocalContext&,
                             std::vector<CSSPropertyValue>& properties) const {
  return css_parsing_utils::ConsumeShorthandVia4Longhands(paddingShorthand(), important, context, stream, properties);
}

//bool Padding::IsLayoutDependent(const ComputedStyle* style, LayoutObject* layout_object) const {
//  return layout_object && layout_object->IsBox() &&
//         (!style || !style->PaddingBottom().IsFixed() || !style->PaddingTop().IsFixed() ||
//          !style->PaddingLeft().IsFixed() || !style->PaddingRight().IsFixed());
//}

//std::shared_ptr<const CSSValue> Padding::CSSValueFromComputedStyleInternal(const ComputedStyle& style,
//                                                                           const LayoutObject* layout_object,
//                                                                           bool allow_visited_style,
//                                                                           CSSValuePhase value_phase) const {
//  return ComputedStyleUtils::ValuesForSidesShorthand(paddingShorthand(), style, layout_object, allow_visited_style,
//                                                     value_phase);
//}

bool PaddingInline::ParseShorthand(bool important,
                                   CSSParserTokenStream& stream,
                                   const CSSParserContext& context,
                                   const CSSParserLocalContext&,
                                   std::vector<CSSPropertyValue>& properties) const {
  return css_parsing_utils::ConsumeShorthandVia2Longhands(paddingInlineShorthand(), important, context, stream,
                                                          properties);
}

//std::shared_ptr<const CSSValue> PaddingInline::CSSValueFromComputedStyleInternal(const ComputedStyle& style,
//                                                                                 const LayoutObject* layout_object,
//                                                                                 bool allow_visited_style,
//                                                                                 CSSValuePhase value_phase) const {
//  return ComputedStyleUtils::ValuesForInlineBlockShorthand(paddingInlineShorthand(), style, layout_object,
//                                                           allow_visited_style, value_phase);
//}

bool PageBreakAfter::ParseShorthand(bool important,
                                    CSSParserTokenStream& stream,
                                    const CSSParserContext&,
                                    const CSSParserLocalContext&,
                                    std::vector<CSSPropertyValue>& properties) const {
  CSSValueID value;
  if (!css_parsing_utils::ConsumeFromPageBreakBetween(stream, value)) {
    return false;
  }

  DCHECK(IsValidCSSValueID(value));
  css_parsing_utils::AddProperty(CSSPropertyID::kBreakAfter, CSSPropertyID::kPageBreakAfter,
                                 CSSIdentifierValue::Create(value), important,
                                 css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  return true;
}

//std::shared_ptr<const CSSValue> PageBreakAfter::CSSValueFromComputedStyleInternal(const ComputedStyle& style,
//                                                                                  const LayoutObject*,
//                                                                                  bool allow_visited_style,
//                                                                                  CSSValuePhase value_phase) const {
//  return ComputedStyleUtils::ValueForPageBreakBetween(style.BreakAfter());
//}

bool PageBreakBefore::ParseShorthand(bool important,
                                     CSSParserTokenStream& stream,
                                     const CSSParserContext&,
                                     const CSSParserLocalContext&,
                                     std::vector<CSSPropertyValue>& properties) const {
  CSSValueID value;
  if (!css_parsing_utils::ConsumeFromPageBreakBetween(stream, value)) {
    return false;
  }

  DCHECK(IsValidCSSValueID(value));
  css_parsing_utils::AddProperty(CSSPropertyID::kBreakBefore, CSSPropertyID::kPageBreakBefore,
                                 CSSIdentifierValue::Create(value), important,
                                 css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  return true;
}

//std::shared_ptr<const CSSValue> PageBreakBefore::CSSValueFromComputedStyleInternal(const ComputedStyle& style,
//                                                                                   const LayoutObject*,
//                                                                                   bool allow_visited_style,
//                                                                                   CSSValuePhase value_phase) const {
//  return ComputedStyleUtils::ValueForPageBreakBetween(style.BreakBefore());
//}

bool PageBreakInside::ParseShorthand(bool important,
                                     CSSParserTokenStream& stream,
                                     const CSSParserContext&,
                                     const CSSParserLocalContext&,
                                     std::vector<CSSPropertyValue>& properties) const {
  CSSValueID value;
  if (!css_parsing_utils::ConsumeFromColumnOrPageBreakInside(stream, value)) {
    return false;
  }

  css_parsing_utils::AddProperty(CSSPropertyID::kBreakInside, CSSPropertyID::kPageBreakInside,
                                 CSSIdentifierValue::Create(value), important,
                                 css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  return true;
}

//std::shared_ptr<const CSSValue> PageBreakInside::CSSValueFromComputedStyleInternal(const ComputedStyle& style,
//                                                                                   const LayoutObject*,
//                                                                                   bool allow_visited_style,
//                                                                                   CSSValuePhase value_phase) const {
//  return ComputedStyleUtils::ValueForPageBreakInside(style.BreakInside());
//}

bool PlaceContent::ParseShorthand(bool important,
                                  CSSParserTokenStream& stream,
                                  const CSSParserContext& context,
                                  const CSSParserLocalContext& local_context,
                                  std::vector<CSSPropertyValue>& properties) const {
  DCHECK_EQ(shorthandForProperty(CSSPropertyID::kPlaceContent).length(), 2u);

  stream.EnsureLookAhead();

  CSSParserTokenStream::State savepoint = stream.Save();
  bool is_baseline = css_parsing_utils::IsBaselineKeyword(stream.Peek().Id());
  std::shared_ptr<const CSSValue> align_content_value =
      GetCSSPropertyAlignContent().ParseSingleValue(stream, context, local_context);
  if (!align_content_value) {
    return false;
  }

  std::shared_ptr<const CSSValue> justify_content_value =
      GetCSSPropertyJustifyContent().ParseSingleValue(stream, context, local_context);
  if (!justify_content_value) {
    if (is_baseline) {
      justify_content_value = std::make_shared<cssvalue::CSSContentDistributionValue>(
          CSSValueID::kInvalid, CSSValueID::kStart, CSSValueID::kInvalid);
    } else {
      // Rewind the parser and use the value we just parsed as align-content,
      // as justify-content, too.
      stream.Restore(savepoint);
      justify_content_value = GetCSSPropertyJustifyContent().ParseSingleValue(stream, context, local_context);
    }
  }
  if (!justify_content_value) {
    return false;
  }

  DCHECK(align_content_value);
  DCHECK(justify_content_value);

  css_parsing_utils::AddProperty(CSSPropertyID::kAlignContent, CSSPropertyID::kPlaceContent, align_content_value,
                                 important, css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  css_parsing_utils::AddProperty(CSSPropertyID::kJustifyContent, CSSPropertyID::kPlaceContent, justify_content_value,
                                 important, css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);

  return true;
}

//std::shared_ptr<const CSSValue> PlaceContent::CSSValueFromComputedStyleInternal(const ComputedStyle& style,
//                                                                                const LayoutObject* layout_object,
//                                                                                bool allow_visited_style,
//                                                                                CSSValuePhase value_phase) const {
//  return ComputedStyleUtils::ValuesForPlaceShorthand(placeContentShorthand(), style, layout_object, allow_visited_style,
//                                                     value_phase);
//}

bool PlaceItems::ParseShorthand(bool important,
                                CSSParserTokenStream& stream,
                                const CSSParserContext& context,
                                const CSSParserLocalContext& local_context,
                                std::vector<CSSPropertyValue>& properties) const {
  DCHECK_EQ(shorthandForProperty(CSSPropertyID::kPlaceItems).length(), 2u);

  stream.EnsureLookAhead();
  CSSParserTokenStream::State savepoint = stream.Save();
  std::shared_ptr<const CSSValue> align_items_value =
      GetCSSPropertyAlignItems().ParseSingleValue(stream, context, local_context);
  if (!align_items_value) {
    return false;
  }

  std::shared_ptr<const CSSValue> justify_items_value =
      GetCSSPropertyJustifyItems().ParseSingleValue(stream, context, local_context);
  if (!justify_items_value) {
    // End-of-stream or parse error. If it's the former,
    // we try to to parse what we already parsed as align-items again,
    // just as justify-items. If it's the latter, the caller will
    // clean up for us (as we won't end on end-of-stream).
    size_t align_items_end = stream.Offset();
    stream.Restore(savepoint);
    justify_items_value = GetCSSPropertyJustifyItems().ParseSingleValue(stream, context, local_context);
    if (!justify_items_value || stream.Offset() != align_items_end) {
      return false;
    }
  }

  DCHECK(align_items_value);
  DCHECK(justify_items_value);

  css_parsing_utils::AddProperty(CSSPropertyID::kAlignItems, CSSPropertyID::kPlaceItems, align_items_value, important,
                                 css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  css_parsing_utils::AddProperty(CSSPropertyID::kJustifyItems, CSSPropertyID::kPlaceItems, justify_items_value,
                                 important, css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);

  return true;
}

//std::shared_ptr<const CSSValue> PlaceItems::CSSValueFromComputedStyleInternal(const ComputedStyle& style,
//                                                                              const LayoutObject* layout_object,
//                                                                              bool allow_visited_style,
//                                                                              CSSValuePhase value_phase) const {
//  return ComputedStyleUtils::ValuesForPlaceShorthand(placeItemsShorthand(), style, layout_object, allow_visited_style,
//                                                     value_phase);
//}

bool PlaceSelf::ParseShorthand(bool important,
                               CSSParserTokenStream& stream,
                               const CSSParserContext& context,
                               const CSSParserLocalContext& local_context,
                               std::vector<CSSPropertyValue>& properties) const {
  DCHECK_EQ(shorthandForProperty(CSSPropertyID::kPlaceSelf).length(), 2u);

  stream.EnsureLookAhead();
  CSSParserTokenStream::State savepoint = stream.Save();

  std::shared_ptr<const CSSValue> align_self_value =
      GetCSSPropertyAlignSelf().ParseSingleValue(stream, context, local_context);
  if (!align_self_value) {
    return false;
  }

  std::shared_ptr<const CSSValue> justify_self_value =
      GetCSSPropertyJustifySelf().ParseSingleValue(stream, context, local_context);
  if (!justify_self_value) {
    // End-of-stream or parse error. If it's the former,
    // we try to to parse what we already parsed as align-items again,
    // just as justify-items. If it's the latter, the caller will
    // clean up for us (as we won't end on end-of-stream).
    size_t align_items_end = stream.Offset();
    stream.Restore(savepoint);
    justify_self_value = GetCSSPropertyJustifySelf().ParseSingleValue(stream, context, local_context);
    if (!justify_self_value || stream.Offset() != align_items_end) {
      return false;
    }
  }

  DCHECK(align_self_value);
  DCHECK(justify_self_value);

  css_parsing_utils::AddProperty(CSSPropertyID::kAlignSelf, CSSPropertyID::kPlaceSelf, align_self_value, important,
                                 css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  css_parsing_utils::AddProperty(CSSPropertyID::kJustifySelf, CSSPropertyID::kPlaceSelf, justify_self_value, important,
                                 css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);

  return true;
}


namespace {

// Consume a single name, axis, and optionally inset, then append the result
// to `name_list`, `axis_list`, and `inset_list` respectively.
//
// Insets are only relevant for the view-timeline shorthand, and not for
// the scroll-timeline shorthand, hence `inset_list` may be nullptr.
//
// https://drafts.csswg.org/scroll-animations-1/#view-timeline-shorthand
// https://drafts.csswg.org/scroll-animations-1/#scroll-timeline-shorthand
bool ConsumeTimelineItemInto(CSSParserTokenStream& stream,
                             const CSSParserContext& context,
                             const std::shared_ptr<CSSValueList>& name_list,
                             const std::shared_ptr<CSSValueList>& axis_list,
                             const std::shared_ptr<CSSValueList>& inset_list) {
  using css_parsing_utils::ConsumeSingleTimelineAxis;
  using css_parsing_utils::ConsumeSingleTimelineInset;
  using css_parsing_utils::ConsumeSingleTimelineName;

  std::shared_ptr<const CSSValue> name = ConsumeSingleTimelineName(stream, context);

  if (!name) {
    return false;
  }

  std::shared_ptr<const CSSValue> axis = nullptr;
  std::shared_ptr<const CSSValue> inset = nullptr;

  // [ <'view-timeline-axis'> || <'view-timeline-inset'> ]
  while (true) {
    if (!axis && (axis = ConsumeSingleTimelineAxis(stream))) {
      continue;
    }
    if (inset_list && !inset && (inset = ConsumeSingleTimelineInset(stream, context))) {
      continue;
    }
    break;
  }

  if (!axis) {
    axis = CSSIdentifierValue::Create(CSSValueID::kBlock);
  }
  if (inset_list && !inset) {
    inset = std::make_shared<CSSValuePair>(CSSIdentifierValue::Create(CSSValueID::kAuto),
                                               CSSIdentifierValue::Create(CSSValueID::kAuto),
                                               CSSValuePair::kDropIdenticalValues);
  }

  DCHECK(name_list);
  DCHECK(axis_list);
  name_list->Append(name);
  axis_list->Append(axis);
  if (inset) {
    DCHECK(inset_list);
    inset_list->Append(inset);
  }

  return true;
}

bool ParseTimelineShorthand(CSSPropertyID shorthand_id,
                            const StylePropertyShorthand& shorthand,
                            bool important,
                            CSSParserTokenStream& stream,
                            const CSSParserContext& context,
                            const CSSParserLocalContext&,
                            std::vector<CSSPropertyValue>& properties) {
  using css_parsing_utils::AddProperty;
  using css_parsing_utils::ConsumeCommaIncludingWhitespace;
  using css_parsing_utils::IsImplicitProperty;

  std::shared_ptr<CSSValueList> name_list = CSSValueList::CreateCommaSeparated();
  std::shared_ptr<CSSValueList> axis_list = CSSValueList::CreateCommaSeparated();
  std::shared_ptr<CSSValueList> inset_list = shorthand.length() == 3u ? CSSValueList::CreateCommaSeparated() : nullptr;

  do {
    if (!ConsumeTimelineItemInto(stream, context, name_list, axis_list, inset_list)) {
      return false;
    }
  } while (ConsumeCommaIncludingWhitespace(stream));

  DCHECK(name_list->length());
  DCHECK(axis_list->length());
  DCHECK(!inset_list || inset_list->length());
  DCHECK_EQ(name_list->length(), axis_list->length());
  DCHECK_EQ(inset_list ? name_list->length() : 0, inset_list ? inset_list->length() : 0);

  DCHECK_GE(shorthand.length(), 2u);
  DCHECK_LE(shorthand.length(), 3u);
  AddProperty(shorthand.properties()[0]->PropertyID(), shorthand_id, name_list, important,
              IsImplicitProperty::kNotImplicit, properties);
  AddProperty(shorthand.properties()[1]->PropertyID(), shorthand_id, axis_list, important,
              IsImplicitProperty::kNotImplicit, properties);
  if (inset_list) {
    DCHECK_EQ(shorthand.length(), 3u);
    AddProperty(shorthand.properties()[2]->PropertyID(), shorthand_id, inset_list, important,
                IsImplicitProperty::kNotImplicit, properties);
  }

  return true;
}
}  // namespace


bool TextDecoration::ParseShorthand(bool important,
                                    CSSParserTokenStream& stream,
                                    const CSSParserContext& context,
                                    const CSSParserLocalContext&,
                                    std::vector<CSSPropertyValue>& properties) const {
  // Use RuntimeEnabledFeature-aware shorthandForProperty() method until
  // text-decoration-thickness ships, see style_property_shorthand.cc.tmpl.
  return css_parsing_utils::ConsumeShorthandGreedilyViaLonghands(shorthandForProperty(CSSPropertyID::kTextDecoration),
                                                                 important, context, stream, properties);
}

namespace {

std::shared_ptr<const CSSValue> ConsumeTransitionValue(CSSPropertyID property,
                                 CSSParserTokenStream& stream,
                                 const CSSParserContext& context,
                                 bool use_legacy_parsing) {
  switch (property) {
    case CSSPropertyID::kTransitionDelay:
      return css_parsing_utils::ConsumeTime(stream, context, CSSPrimitiveValue::ValueRange::kAll);
    case CSSPropertyID::kTransitionDuration:
      return css_parsing_utils::ConsumeTime(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative);
    case CSSPropertyID::kTransitionProperty:
      return css_parsing_utils::ConsumeTransitionProperty(stream, context);
    case CSSPropertyID::kTransitionTimingFunction:
      return css_parsing_utils::ConsumeAnimationTimingFunction(stream, context);
    case CSSPropertyID::kTransitionBehavior:
      if (css_parsing_utils::IsValidTransitionBehavior(stream.Peek().Id())) {
        return CSSIdentifierValue::Create(stream.ConsumeIncludingWhitespace().Id());
      }
      return nullptr;
    default:
      NOTREACHED_IN_MIGRATION();
      return nullptr;
  }
}

}  // namespace

bool Transition::ParseShorthand(bool important,
                                CSSParserTokenStream& stream,
                                const CSSParserContext& context,
                                const CSSParserLocalContext& local_context,
                                std::vector<CSSPropertyValue>& properties) const {
  const StylePropertyShorthand shorthand = transitionShorthandForParsing();
  const unsigned longhand_count = shorthand.length();

  // Only relevant for 'animation'.
  auto is_reset_only_function = [](CSSPropertyID) { return false; };

  std::vector<std::shared_ptr<CSSValueList>> longhands(longhand_count);
  longhands.reserve(css_parsing_utils::kMaxNumAnimationLonghands);
  if (!css_parsing_utils::ConsumeAnimationShorthand(shorthand, longhands, ConsumeTransitionValue,
                                                    is_reset_only_function, stream, context,
                                                    local_context.UseAliasParsing())) {
    return false;
  }

  for (unsigned i = 0; i < longhand_count; ++i) {
    if (shorthand.properties()[i]->IDEquals(CSSPropertyID::kTransitionProperty) &&
        !css_parsing_utils::IsValidPropertyList(*longhands[i])) {
      return false;
    }
  }

  for (unsigned i = 0; i < longhand_count; ++i) {
    css_parsing_utils::AddProperty(shorthand.properties()[i]->PropertyID(), shorthand.id(), longhands[i], important,
                                   css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  }

  return true;
}


bool WebkitColumnBreakAfter::ParseShorthand(bool important,
                                            CSSParserTokenStream& stream,
                                            const CSSParserContext&,
                                            const CSSParserLocalContext&,
                                            std::vector<CSSPropertyValue>& properties) const {
  CSSValueID value;
  if (!css_parsing_utils::ConsumeFromColumnBreakBetween(stream, value)) {
    return false;
  }

  css_parsing_utils::AddProperty(CSSPropertyID::kBreakAfter, CSSPropertyID::kWebkitColumnBreakAfter,
                                 CSSIdentifierValue::Create(value), important,
                                 css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  return true;
}

bool WebkitColumnBreakBefore::ParseShorthand(bool important,
                                             CSSParserTokenStream& stream,
                                             const CSSParserContext&,
                                             const CSSParserLocalContext&,
                                             std::vector<CSSPropertyValue>& properties) const {
  CSSValueID value;
  if (!css_parsing_utils::ConsumeFromColumnBreakBetween(stream, value)) {
    return false;
  }

  css_parsing_utils::AddProperty(CSSPropertyID::kBreakBefore, CSSPropertyID::kWebkitColumnBreakBefore,
                                 CSSIdentifierValue::Create(value), important,
                                 css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  return true;
}

bool WebkitColumnBreakInside::ParseShorthand(bool important,
                                             CSSParserTokenStream& stream,
                                             const CSSParserContext&,
                                             const CSSParserLocalContext&,
                                             std::vector<CSSPropertyValue>& properties) const {
  CSSValueID value;
  if (!css_parsing_utils::ConsumeFromColumnOrPageBreakInside(stream, value)) {
    return false;
  }

  css_parsing_utils::AddProperty(CSSPropertyID::kBreakInside, CSSPropertyID::kWebkitColumnBreakInside,
                                 CSSIdentifierValue::Create(value), important,
                                 css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
  return true;
}

//std::shared_ptr<const CSSValue> WebkitMaskBoxImage::CSSValueFromComputedStyleInternal(const ComputedStyle& style,
//                                                                                      const LayoutObject*,
//                                                                                      bool allow_visited_style,
//                                                                                      CSSValuePhase value_phase) const {
//  return ComputedStyleUtils::ValueForNinePieceImage(style.MaskBoxImage(), style, allow_visited_style, value_phase);
//}

bool TextEmphasis::ParseShorthand(bool important,
                                  CSSParserTokenStream& stream,
                                  const CSSParserContext& context,
                                  const CSSParserLocalContext&,
                                  std::vector<CSSPropertyValue>& properties) const {
  return css_parsing_utils::ConsumeShorthandGreedilyViaLonghands(textEmphasisShorthand(), important, context, stream,
                                                                 properties);
}

bool WhiteSpace::ParseShorthand(bool important,
                                CSSParserTokenStream& stream,
                                const CSSParserContext& context,
                                const CSSParserLocalContext&,
                                std::vector<CSSPropertyValue>& properties) const {
  CSSParserTokenStream::State savepoint = stream.Save();

  // Try to parse as a pre-defined keyword. The `white-space` has pre-defined
  // keywords in addition to the multi-values shorthand, for the backward
  // compatibility with when it was a longhand.
  if (std::shared_ptr<const CSSIdentifierValue> value =
          css_parsing_utils::ConsumeIdent<CSSValueID::kBreakSpaces, CSSValueID::kNormal, CSSValueID::kNowrap,
                                          CSSValueID::kPre, CSSValueID::kPreLine, CSSValueID::kPreWrap>(stream)) {
    // Parse as a pre-defined keyword only if it is at the end. Some keywords
    // can be both a pre-defined keyword or a longhand value.
    //
    // TODO(sesse): Figure out some less hacky way of figuring out
    // whether we are at the end or not. In theory, we are supposed to
    // accept arbitrary junk after our input, but we are being saved
    // by the fact that shorthands only need to worry about !important
    // (and none of our longhands accept anything involving the ! delimiter).
    bool at_end = stream.AtEnd();
    if (!at_end) {
      stream.ConsumeWhitespace();
      at_end = stream.Peek().GetType() == kDelimiterToken && stream.Peek().Delimiter() == '!';
    }
    if (at_end) {
      const EWhiteSpace whitespace = CssValueIDToPlatformEnum<EWhiteSpace>(value->GetValueID());
      DCHECK(IsValidWhiteSpace(whitespace));
      AddProperty(CSSPropertyID::kWhiteSpaceCollapse, CSSPropertyID::kWhiteSpace,
                  CSSIdentifierValue::Create(ToWhiteSpaceCollapse(whitespace)), important,
                  css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
      AddProperty(CSSPropertyID::kTextWrap, CSSPropertyID::kWhiteSpace,
                  CSSIdentifierValue::Create(ToTextWrap(whitespace)), important,
                  css_parsing_utils::IsImplicitProperty::kNotImplicit, properties);
      return true;
    }

    // If `stream` is not at end, the keyword is for longhands. Restore
    // `stream`.
    stream.Restore(savepoint);
  }

  // Consume multi-value syntax if the first identifier is not pre-defined.
  return css_parsing_utils::ConsumeShorthandGreedilyViaLonghands(whiteSpaceShorthand(), important, context, stream,
                                                                 properties);
}
//
//std::shared_ptr<const CSSValue> WhiteSpace::CSSValueFromComputedStyleInternal(const ComputedStyle& style,
//                                                                              const LayoutObject* layout_object,
//                                                                              bool allow_visited_style,
//                                                                              CSSValuePhase value_phase) const {
//  const EWhiteSpace whitespace = style.WhiteSpace();
//  if (IsValidWhiteSpace(whitespace)) {
//    const CSSValueID value = PlatformEnumToCSSValueID(whitespace);
//    DCHECK_NE(value, CSSValueID::kNone);
//    return CSSIdentifierValue::Create(value);
//  }
//
//  CSSValueList* list = CSSValueList::CreateSpaceSeparated();
//  const WhiteSpaceCollapse collapse = style.GetWhiteSpaceCollapse();
//  if (collapse != ComputedStyleInitialValues::InitialWhiteSpaceCollapse()) {
//    list->Append(*CSSIdentifierValue::Create(collapse));
//  }
//  const TextWrap wrap = style.GetTextWrap();
//  if (wrap != ComputedStyleInitialValues::InitialTextWrap()) {
//    list->Append(*CSSIdentifierValue::Create(wrap));
//  }
//  // When all longhands are initial values, it should be `normal`, covered by
//  // `IsValidWhiteSpace()` above.
//  DCHECK(list->length());
//  return list;
//}

}  // namespace css_shorthand
}  // namespace webf