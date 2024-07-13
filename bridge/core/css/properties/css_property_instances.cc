// Copyright 2019 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "css_property_instances.h"
//#include "core/css/css_property_names.h"

#include "core/css/properties/longhands.h"
#include "core/css/properties/longhands/variable.h"

namespace webf {


// NOTE: Everything in here must be reinterpret_cast-able
// to CSSUnresolvedProperty! In particular, this means that
// multiple inheritance is forbidden. We enforce this through
// asserts as much as we can; this also checks (compile-time)
// that everything inherits from CSSUnresolvedProperty.
union alignas(kCSSPropertyUnionBytes) CSSPropertyUnion {
  constexpr CSSPropertyUnion() {}  // For kInvalid.
//  constexpr CSSPropertyUnion(::webf::css_longhand::ColorScheme property)
//      : csspropertycolorscheme_(std::move(property)) {
//    assert(reinterpret_cast<const CSSUnresolvedProperty *>(this) ==
//           static_cast<const CSSUnresolvedProperty *>(&csspropertycolorscheme_));
//  }
};

const CSSPropertyUnion kCssProperties[] = {
    {},  // kInvalid.
//    Variable(),
//    ::webf::css_longhand::ColorScheme(),
//    ::webf::css_longhand::ForcedColorAdjust(),
//    ::webf::css_longhand::MaskImage(),
//    ::webf::css_longhand::MathDepth(),
//    ::webf::css_longhand::Position(),
//    ::webf::css_longhand::PositionAnchor(),
//    ::webf::css_longhand::TextSizeAdjust(),
//    ::webf::css_longhand::Appearance(),
//    ::webf::css_longhand::Color(),
//    ::webf::css_longhand::Direction(),
//    ::webf::css_longhand::FontFamily(),
//    ::webf::css_longhand::FontFeatureSettings(),
//    ::webf::css_longhand::FontKerning(),
//    ::webf::css_longhand::FontOpticalSizing(),
//    ::webf::css_longhand::FontPalette(),
//    ::webf::css_longhand::FontSize(),
//    ::webf::css_longhand::FontSizeAdjust(),
//    ::webf::css_longhand::FontStretch(),
//    ::webf::css_longhand::FontStyle(),
//    ::webf::css_longhand::FontSynthesisSmallCaps(),
//    ::webf::css_longhand::FontSynthesisStyle(),
//    ::webf::css_longhand::FontSynthesisWeight(),
//    ::webf::css_longhand::FontVariantAlternates(),
//    ::webf::css_longhand::FontVariantCaps(),
//    ::webf::css_longhand::FontVariantEastAsian(),
//    ::webf::css_longhand::FontVariantEmoji(),
//    ::webf::css_longhand::FontVariantLigatures(),
//    ::webf::css_longhand::FontVariantNumeric(),
//    ::webf::css_longhand::FontVariantPosition(),
//    ::webf::css_longhand::FontVariationSettings(),
//    ::webf::css_longhand::FontWeight(),
//    ::webf::css_longhand::InsetArea(),
//    ::webf::css_longhand::InternalVisitedColor(),
//    ::webf::css_longhand::TextOrientation(),
//    ::webf::css_longhand::TextRendering(),
//    ::webf::css_longhand::TextSpacingTrim(),
//    ::webf::css_longhand::WebkitFontSmoothing(),
//    ::webf::css_longhand::WebkitLocale(),
//    ::webf::css_longhand::WebkitTextOrientation(),
//    ::webf::css_longhand::WebkitWritingMode(),
//    ::webf::css_longhand::WritingMode(),
//    ::webf::css_longhand::Zoom(),
//    ::webf::css_longhand::AccentColor(),
//    ::webf::css_longhand::AdditiveSymbols(),
//    ::webf::css_longhand::AlignContent(),
//    ::webf::css_longhand::AlignItems(),
//    ::webf::css_longhand::AlignSelf(),
//    ::webf::css_longhand::AlignmentBaseline(),
//    ::webf::css_longhand::All(),
//    ::webf::css_longhand::AnchorName(),
//    ::webf::css_longhand::AnchorScope(),
//    ::webf::css_longhand::AnimationComposition(),
//    ::webf::css_longhand::AnimationDelay(),
//    ::webf::css_longhand::AnimationDirection(),
//    ::webf::css_longhand::AnimationDuration(),
//    ::webf::css_longhand::AnimationFillMode(),
//    ::webf::css_longhand::AnimationIterationCount(),
//    ::webf::css_longhand::AnimationName(),
//    ::webf::css_longhand::AnimationPlayState(),
//    ::webf::css_longhand::AnimationRangeEnd(),
//    ::webf::css_longhand::AnimationRangeStart(),
//    ::webf::css_longhand::AnimationTimeline(),
//    ::webf::css_longhand::AnimationTimingFunction(),
//    ::webf::css_longhand::AppRegion(),
//    ::webf::css_longhand::AscentOverride(),
//    ::webf::css_longhand::AspectRatio(),
//    ::webf::css_longhand::BackdropFilter(),
//    ::webf::css_longhand::BackfaceVisibility(),
//    ::webf::css_longhand::BackgroundAttachment(),
//    ::webf::css_longhand::BackgroundBlendMode(),
//    ::webf::css_longhand::BackgroundClip(),
//    ::webf::css_longhand::BackgroundColor(),
//    ::webf::css_longhand::BackgroundImage(),
//    ::webf::css_longhand::BackgroundOrigin(),
//    ::webf::css_longhand::BackgroundPositionX(),
//    ::webf::css_longhand::BackgroundPositionY(),
//    ::webf::css_longhand::BackgroundRepeat(),
//    ::webf::css_longhand::BackgroundSize(),
//    ::webf::css_longhand::BasePalette(),
//    ::webf::css_longhand::BaselineShift(),
//    ::webf::css_longhand::BaselineSource(),
//    ::webf::css_longhand::BlockSize(),
//    ::webf::css_longhand::BorderBlockEndColor(),
//    ::webf::css_longhand::BorderBlockEndStyle(),
//    ::webf::css_longhand::BorderBlockEndWidth(),
//    ::webf::css_longhand::BorderBlockStartColor(),
//    ::webf::css_longhand::BorderBlockStartStyle(),
//    ::webf::css_longhand::BorderBlockStartWidth(),
//    ::webf::css_longhand::BorderBottomColor(),
//    ::webf::css_longhand::BorderBottomLeftRadius(),
//    ::webf::css_longhand::BorderBottomRightRadius(),
//    ::webf::css_longhand::BorderBottomStyle(),
//    ::webf::css_longhand::BorderBottomWidth(),
//    ::webf::css_longhand::BorderCollapse(),
//    ::webf::css_longhand::BorderEndEndRadius(),
//    ::webf::css_longhand::BorderEndStartRadius(),
//    ::webf::css_longhand::BorderImageOutset(),
//    ::webf::css_longhand::BorderImageRepeat(),
//    ::webf::css_longhand::BorderImageSlice(),
//    ::webf::css_longhand::BorderImageSource(),
//    ::webf::css_longhand::BorderImageWidth(),
//    ::webf::css_longhand::BorderInlineEndColor(),
//    ::webf::css_longhand::BorderInlineEndStyle(),
//    ::webf::css_longhand::BorderInlineEndWidth(),
//    ::webf::css_longhand::BorderInlineStartColor(),
//    ::webf::css_longhand::BorderInlineStartStyle(),
//    ::webf::css_longhand::BorderInlineStartWidth(),
//    ::webf::css_longhand::BorderLeftColor(),
//    ::webf::css_longhand::BorderLeftStyle(),
//    ::webf::css_longhand::BorderLeftWidth(),
//    ::webf::css_longhand::BorderRightColor(),
//    ::webf::css_longhand::BorderRightStyle(),
//    ::webf::css_longhand::BorderRightWidth(),
//    ::webf::css_longhand::BorderStartEndRadius(),
//    ::webf::css_longhand::BorderStartStartRadius(),
//    ::webf::css_longhand::BorderTopColor(),
//    ::webf::css_longhand::BorderTopLeftRadius(),
//    ::webf::css_longhand::BorderTopRightRadius(),
//    ::webf::css_longhand::BorderTopStyle(),
//    ::webf::css_longhand::BorderTopWidth(),
//    ::webf::css_longhand::Bottom(),
//    ::webf::css_longhand::BoxShadow(),
//    ::webf::css_longhand::BoxSizing(),
//    ::webf::css_longhand::BreakAfter(),
//    ::webf::css_longhand::BreakBefore(),
//    ::webf::css_longhand::BreakInside(),
//    ::webf::css_longhand::BufferedRendering(),
//    ::webf::css_longhand::CaptionSide(),
//    ::webf::css_longhand::CaretColor(),
//    ::webf::css_longhand::Clear(),
//    ::webf::css_longhand::Clip(),
//    ::webf::css_longhand::ClipPath(),
//    ::webf::css_longhand::ClipRule(),
//    ::webf::css_longhand::ColorInterpolation(),
//    ::webf::css_longhand::ColorInterpolationFilters(),
//    ::webf::css_longhand::ColorRendering(),
//    ::webf::css_longhand::ColumnCount(),
//    ::webf::css_longhand::ColumnFill(),
//    ::webf::css_longhand::ColumnGap(),
//    ::webf::css_longhand::ColumnRuleColor(),
//    ::webf::css_longhand::ColumnRuleStyle(),
//    ::webf::css_longhand::ColumnRuleWidth(),
//    ::webf::css_longhand::ColumnSpan(),
//    ::webf::css_longhand::ColumnWidth(),
//    ::webf::css_longhand::Contain(),
//    ::webf::css_longhand::ContainIntrinsicBlockSize(),
//    ::webf::css_longhand::ContainIntrinsicHeight(),
//    ::webf::css_longhand::ContainIntrinsicInlineSize(),
//    ::webf::css_longhand::ContainIntrinsicWidth(),
//    ::webf::css_longhand::ContainerName(),
//    ::webf::css_longhand::ContainerType(),
//    ::webf::css_longhand::Content(),
//    ::webf::css_longhand::ContentVisibility(),
//    ::webf::css_longhand::CounterIncrement(),
//    ::webf::css_longhand::CounterReset(),
//    ::webf::css_longhand::CounterSet(),
//    ::webf::css_longhand::Cursor(),
//    ::webf::css_longhand::Cx(),
//    ::webf::css_longhand::Cy(),
//    ::webf::css_longhand::D(),
//    ::webf::css_longhand::DescentOverride(),
//    ::webf::css_longhand::Display(),
//    ::webf::css_longhand::DominantBaseline(),
//    ::webf::css_longhand::DynamicRangeLimit(),
//    ::webf::css_longhand::EmptyCells(),
//    ::webf::css_longhand::Fallback(),
//    ::webf::css_longhand::FieldSizing(),
//    ::webf::css_longhand::Fill(),
//    ::webf::css_longhand::FillOpacity(),
//    ::webf::css_longhand::FillRule(),
//    ::webf::css_longhand::Filter(),
//    ::webf::css_longhand::FlexBasis(),
//    ::webf::css_longhand::FlexDirection(),
//    ::webf::css_longhand::FlexGrow(),
//    ::webf::css_longhand::FlexShrink(),
//    ::webf::css_longhand::FlexWrap(),
//    ::webf::css_longhand::Float(),
//    ::webf::css_longhand::FloodColor(),
//    ::webf::css_longhand::FloodOpacity(),
//    ::webf::css_longhand::FontDisplay(),
//    ::webf::css_longhand::GridAutoColumns(),
//    ::webf::css_longhand::GridAutoFlow(),
//    ::webf::css_longhand::GridAutoRows(),
//    ::webf::css_longhand::GridColumnEnd(),
//    ::webf::css_longhand::GridColumnStart(),
//    ::webf::css_longhand::GridRowEnd(),
//    ::webf::css_longhand::GridRowStart(),
//    ::webf::css_longhand::GridTemplateAreas(),
//    ::webf::css_longhand::GridTemplateColumns(),
//    ::webf::css_longhand::GridTemplateRows(),
//    ::webf::css_longhand::Height(),
//    ::webf::css_longhand::HyphenateCharacter(),
//    ::webf::css_longhand::HyphenateLimitChars(),
//    ::webf::css_longhand::Hyphens(),
//    ::webf::css_longhand::ImageOrientation(),
//    ::webf::css_longhand::ImageRendering(),
//    ::webf::css_longhand::Inherits(),
//    ::webf::css_longhand::InitialLetter(),
//    ::webf::css_longhand::InitialValue(),
//    ::webf::css_longhand::InlineSize(),
//    ::webf::css_longhand::InsetBlockEnd(),
//    ::webf::css_longhand::InsetBlockStart(),
//    ::webf::css_longhand::InsetInlineEnd(),
//    ::webf::css_longhand::InsetInlineStart(),
//    ::webf::css_longhand::InternalAlignContentBlock(),
//    ::webf::css_longhand::InternalEmptyLineHeight(),
//    ::webf::css_longhand::InternalFontSizeDelta(),
//    ::webf::css_longhand::InternalForcedBackgroundColor(),
//    ::webf::css_longhand::InternalForcedBorderColor(),
//    ::webf::css_longhand::InternalForcedColor(),
//    ::webf::css_longhand::InternalForcedOutlineColor(),
//    ::webf::css_longhand::InternalForcedVisitedColor(),
//    ::webf::css_longhand::InternalOverflowBlock(),
//    ::webf::css_longhand::InternalOverflowInline(),
//    ::webf::css_longhand::InternalVisitedBackgroundColor(),
//    ::webf::css_longhand::InternalVisitedBorderBlockEndColor(),
//    ::webf::css_longhand::InternalVisitedBorderBlockStartColor(),
//    ::webf::css_longhand::InternalVisitedBorderBottomColor(),
//    ::webf::css_longhand::InternalVisitedBorderInlineEndColor(),
//    ::webf::css_longhand::InternalVisitedBorderInlineStartColor(),
//    ::webf::css_longhand::InternalVisitedBorderLeftColor(),
//    ::webf::css_longhand::InternalVisitedBorderRightColor(),
//    ::webf::css_longhand::InternalVisitedBorderTopColor(),
//    ::webf::css_longhand::InternalVisitedCaretColor(),
//    ::webf::css_longhand::InternalVisitedColumnRuleColor(),
//    ::webf::css_longhand::InternalVisitedFill(),
//    ::webf::css_longhand::InternalVisitedOutlineColor(),
//    ::webf::css_longhand::InternalVisitedStroke(),
//    ::webf::css_longhand::InternalVisitedTextDecorationColor(),
//    ::webf::css_longhand::InternalVisitedTextEmphasisColor(),
//    ::webf::css_longhand::InternalVisitedTextFillColor(),
//    ::webf::css_longhand::InternalVisitedTextStrokeColor(),
//    ::webf::css_longhand::Isolation(),
//    ::webf::css_longhand::JustifyContent(),
//    ::webf::css_longhand::JustifyItems(),
//    ::webf::css_longhand::JustifySelf(),
//    ::webf::css_longhand::Left(),
//    ::webf::css_longhand::LetterSpacing(),
//    ::webf::css_longhand::LightingColor(),
//    ::webf::css_longhand::LineBreak(),
//    ::webf::css_longhand::LineClamp(),
//    ::webf::css_longhand::LineGapOverride(),
//    ::webf::css_longhand::LineHeight(),
//    ::webf::css_longhand::ListStyleImage(),
//    ::webf::css_longhand::ListStylePosition(),
//    ::webf::css_longhand::ListStyleType(),
//    ::webf::css_longhand::MarginBlockEnd(),
//    ::webf::css_longhand::MarginBlockStart(),
//    ::webf::css_longhand::MarginBottom(),
//    ::webf::css_longhand::MarginInlineEnd(),
//    ::webf::css_longhand::MarginInlineStart(),
//    ::webf::css_longhand::MarginLeft(),
//    ::webf::css_longhand::MarginRight(),
//    ::webf::css_longhand::MarginTop(),
//    ::webf::css_longhand::MarkerEnd(),
//    ::webf::css_longhand::MarkerMid(),
//    ::webf::css_longhand::MarkerStart(),
//    ::webf::css_longhand::MaskClip(),
//    ::webf::css_longhand::MaskComposite(),
//    ::webf::css_longhand::MaskMode(),
//    ::webf::css_longhand::MaskOrigin(),
//    ::webf::css_longhand::MaskRepeat(),
//    ::webf::css_longhand::MaskSize(),
//    ::webf::css_longhand::MaskType(),
//    ::webf::css_longhand::MathShift(),
//    ::webf::css_longhand::MathStyle(),
//    ::webf::css_longhand::MaxBlockSize(),
//    ::webf::css_longhand::MaxHeight(),
//    ::webf::css_longhand::MaxInlineSize(),
//    ::webf::css_longhand::MaxWidth(),
//    ::webf::css_longhand::MinBlockSize(),
//    ::webf::css_longhand::MinHeight(),
//    ::webf::css_longhand::MinInlineSize(),
//    ::webf::css_longhand::MinWidth(),
//    ::webf::css_longhand::MixBlendMode(),
//    ::webf::css_longhand::Navigation(),
//    ::webf::css_longhand::Negative(),
//    ::webf::css_longhand::ObjectFit(),
//    ::webf::css_longhand::ObjectPosition(),
//    ::webf::css_longhand::ObjectViewBox(),
//    ::webf::css_longhand::OffsetAnchor(),
//    ::webf::css_longhand::OffsetDistance(),
//    ::webf::css_longhand::OffsetPath(),
//    ::webf::css_longhand::OffsetPosition(),
//    ::webf::css_longhand::OffsetRotate(),
//    ::webf::css_longhand::Opacity(),
//    ::webf::css_longhand::Order(),
//    ::webf::css_longhand::OriginTrialTestProperty(),
//    ::webf::css_longhand::Orphans(),
//    ::webf::css_longhand::OutlineColor(),
//    ::webf::css_longhand::OutlineOffset(),
//    ::webf::css_longhand::OutlineStyle(),
//    ::webf::css_longhand::OutlineWidth(),
//    ::webf::css_longhand::OverflowAnchor(),
//    ::webf::css_longhand::OverflowBlock(),
//    ::webf::css_longhand::OverflowClipMargin(),
//    ::webf::css_longhand::OverflowInline(),
//    ::webf::css_longhand::OverflowWrap(),
//    ::webf::css_longhand::OverflowX(),
//    ::webf::css_longhand::OverflowY(),
//    ::webf::css_longhand::Overlay(),
//    ::webf::css_longhand::OverrideColors(),
//    ::webf::css_longhand::OverscrollBehaviorBlock(),
//    ::webf::css_longhand::OverscrollBehaviorInline(),
//    ::webf::css_longhand::OverscrollBehaviorX(),
//    ::webf::css_longhand::OverscrollBehaviorY(),
//    ::webf::css_longhand::Pad(),
//    ::webf::css_longhand::PaddingBlockEnd(),
//    ::webf::css_longhand::PaddingBlockStart(),
//    ::webf::css_longhand::PaddingBottom(),
//    ::webf::css_longhand::PaddingInlineEnd(),
//    ::webf::css_longhand::PaddingInlineStart(),
//    ::webf::css_longhand::PaddingLeft(),
//    ::webf::css_longhand::PaddingRight(),
//    ::webf::css_longhand::PaddingTop(),
//    ::webf::css_longhand::Page(),
//    ::webf::css_longhand::PageOrientation(),
//    ::webf::css_longhand::PaintOrder(),
//    ::webf::css_longhand::Perspective(),
//    ::webf::css_longhand::PerspectiveOrigin(),
//    ::webf::css_longhand::PointerEvents(),
//    ::webf::css_longhand::PopoverHideDelay(),
//    ::webf::css_longhand::PopoverShowDelay(),
//    ::webf::css_longhand::PositionTryOptions(),
//    ::webf::css_longhand::PositionTryOrder(),
//    ::webf::css_longhand::PositionVisibility(),
//    ::webf::css_longhand::Prefix(),
//    ::webf::css_longhand::Quotes(),
//    ::webf::css_longhand::R(),
//    ::webf::css_longhand::Range(),
//    ::webf::css_longhand::ReadingFlow(),
//    ::webf::css_longhand::Resize(),
//    ::webf::css_longhand::Right(),
//    ::webf::css_longhand::Rotate(),
//    ::webf::css_longhand::RowGap(),
//    ::webf::css_longhand::RubyAlign(),
//    ::webf::css_longhand::RubyPosition(),
//    ::webf::css_longhand::Rx(),
//    ::webf::css_longhand::Ry(),
//    ::webf::css_longhand::Scale(),
//    ::webf::css_longhand::ScrollBehavior(),
//    ::webf::css_longhand::ScrollMarginBlockEnd(),
//    ::webf::css_longhand::ScrollMarginBlockStart(),
//    ::webf::css_longhand::ScrollMarginBottom(),
//    ::webf::css_longhand::ScrollMarginInlineEnd(),
//    ::webf::css_longhand::ScrollMarginInlineStart(),
//    ::webf::css_longhand::ScrollMarginLeft(),
//    ::webf::css_longhand::ScrollMarginRight(),
//    ::webf::css_longhand::ScrollMarginTop(),
//    ::webf::css_longhand::ScrollMarkers(),
//    ::webf::css_longhand::ScrollPaddingBlockEnd(),
//    ::webf::css_longhand::ScrollPaddingBlockStart(),
//    ::webf::css_longhand::ScrollPaddingBottom(),
//    ::webf::css_longhand::ScrollPaddingInlineEnd(),
//    ::webf::css_longhand::ScrollPaddingInlineStart(),
//    ::webf::css_longhand::ScrollPaddingLeft(),
//    ::webf::css_longhand::ScrollPaddingRight(),
//    ::webf::css_longhand::ScrollPaddingTop(),
//    ::webf::css_longhand::ScrollSnapAlign(),
//    ::webf::css_longhand::ScrollSnapStop(),
//    ::webf::css_longhand::ScrollSnapType(),
//    ::webf::css_longhand::ScrollStartBlock(),
//    ::webf::css_longhand::ScrollStartInline(),
//    ::webf::css_longhand::ScrollStartTargetBlock(),
//    ::webf::css_longhand::ScrollStartTargetInline(),
//    ::webf::css_longhand::ScrollStartTargetX(),
//    ::webf::css_longhand::ScrollStartTargetY(),
//    ::webf::css_longhand::ScrollStartX(),
//    ::webf::css_longhand::ScrollStartY(),
//    ::webf::css_longhand::ScrollTimelineAxis(),
//    ::webf::css_longhand::ScrollTimelineName(),
//    ::webf::css_longhand::ScrollbarColor(),
//    ::webf::css_longhand::ScrollbarGutter(),
//    ::webf::css_longhand::ScrollbarWidth(),
//    ::webf::css_longhand::ShapeImageThreshold(),
//    ::webf::css_longhand::ShapeMargin(),
//    ::webf::css_longhand::ShapeOutside(),
//    ::webf::css_longhand::ShapeRendering(),
//    ::webf::css_longhand::Size(),
//    ::webf::css_longhand::SizeAdjust(),
//    ::webf::css_longhand::Speak(),
//    ::webf::css_longhand::SpeakAs(),
//    ::webf::css_longhand::Src(),
//    ::webf::css_longhand::StopColor(),
//    ::webf::css_longhand::StopOpacity(),
//    ::webf::css_longhand::Stroke(),
//    ::webf::css_longhand::StrokeDasharray(),
//    ::webf::css_longhand::StrokeDashoffset(),
//    ::webf::css_longhand::StrokeLinecap(),
//    ::webf::css_longhand::StrokeLinejoin(),
//    ::webf::css_longhand::StrokeMiterlimit(),
//    ::webf::css_longhand::StrokeOpacity(),
//    ::webf::css_longhand::StrokeWidth(),
//    ::webf::css_longhand::Suffix(),
//    ::webf::css_longhand::Symbols(),
//    ::webf::css_longhand::Syntax(),
//    ::webf::css_longhand::System(),
//    ::webf::css_longhand::TabSize(),
//    ::webf::css_longhand::TableLayout(),
//    ::webf::css_longhand::TextAlign(),
//    ::webf::css_longhand::TextAlignLast(),
//    ::webf::css_longhand::TextAnchor(),
//    ::webf::css_longhand::TextAutospace(),
//    ::webf::css_longhand::TextBoxEdge(),
//    ::webf::css_longhand::TextBoxTrim(),
//    ::webf::css_longhand::TextCombineUpright(),
//    ::webf::css_longhand::TextDecorationColor(),
//    ::webf::css_longhand::TextDecorationLine(),
//    ::webf::css_longhand::TextDecorationSkipInk(),
//    ::webf::css_longhand::TextDecorationStyle(),
//    ::webf::css_longhand::TextDecorationThickness(),
//    ::webf::css_longhand::TextEmphasisColor(),
//    ::webf::css_longhand::TextEmphasisPosition(),
//    ::webf::css_longhand::TextEmphasisStyle(),
//    ::webf::css_longhand::TextIndent(),
//    ::webf::css_longhand::TextOverflow(),
//    ::webf::css_longhand::TextShadow(),
//    ::webf::css_longhand::TextTransform(),
//    ::webf::css_longhand::TextUnderlineOffset(),
//    ::webf::css_longhand::TextUnderlinePosition(),
//    ::webf::css_longhand::TextWrap(),
//    ::webf::css_longhand::TimelineScope(),
//    ::webf::css_longhand::Top(),
//    ::webf::css_longhand::TouchAction(),
//    ::webf::css_longhand::Transform(),
//    ::webf::css_longhand::TransformBox(),
//    ::webf::css_longhand::TransformOrigin(),
//    ::webf::css_longhand::TransformStyle(),
//    ::webf::css_longhand::TransitionBehavior(),
//    ::webf::css_longhand::TransitionDelay(),
//    ::webf::css_longhand::TransitionDuration(),
//    ::webf::css_longhand::TransitionProperty(),
//    ::webf::css_longhand::TransitionTimingFunction(),
//    ::webf::css_longhand::Translate(),
//    ::webf::css_longhand::Types(),
//    ::webf::css_longhand::UnicodeBidi(),
//    ::webf::css_longhand::UnicodeRange(),
//    ::webf::css_longhand::UserSelect(),
//    ::webf::css_longhand::VectorEffect(),
//    ::webf::css_longhand::VerticalAlign(),
//    ::webf::css_longhand::ViewTimelineAxis(),
//    ::webf::css_longhand::ViewTimelineInset(),
//    ::webf::css_longhand::ViewTimelineName(),
//    ::webf::css_longhand::ViewTransitionClass(),
//    ::webf::css_longhand::ViewTransitionName(),
//    ::webf::css_longhand::Visibility(),
//    ::webf::css_longhand::WebkitBorderHorizontalSpacing(),
//    ::webf::css_longhand::WebkitBorderImage(),
//    ::webf::css_longhand::WebkitBorderVerticalSpacing(),
//    ::webf::css_longhand::WebkitBoxAlign(),
//    ::webf::css_longhand::WebkitBoxDecorationBreak(),
//    ::webf::css_longhand::WebkitBoxDirection(),
//    ::webf::css_longhand::WebkitBoxFlex(),
//    ::webf::css_longhand::WebkitBoxOrdinalGroup(),
//    ::webf::css_longhand::WebkitBoxOrient(),
//    ::webf::css_longhand::WebkitBoxPack(),
//    ::webf::css_longhand::WebkitBoxReflect(),
//    ::webf::css_longhand::WebkitLineBreak(),
//    ::webf::css_longhand::WebkitLineClamp(),
//    ::webf::css_longhand::WebkitMaskBoxImageOutset(),
//    ::webf::css_longhand::WebkitMaskBoxImageRepeat(),
//    ::webf::css_longhand::WebkitMaskBoxImageSlice(),
//    ::webf::css_longhand::WebkitMaskBoxImageSource(),
//    ::webf::css_longhand::WebkitMaskBoxImageWidth(),
//    ::webf::css_longhand::WebkitMaskPositionX(),
//    ::webf::css_longhand::WebkitMaskPositionY(),
//    ::webf::css_longhand::WebkitPerspectiveOriginX(),
//    ::webf::css_longhand::WebkitPerspectiveOriginY(),
//    ::webf::css_longhand::WebkitPrintColorAdjust(),
//    ::webf::css_longhand::WebkitRtlOrdering(),
//    ::webf::css_longhand::WebkitRubyPosition(),
//    ::webf::css_longhand::WebkitTapHighlightColor(),
//    ::webf::css_longhand::WebkitTextCombine(),
//    ::webf::css_longhand::WebkitTextDecorationsInEffect(),
//    ::webf::css_longhand::WebkitTextFillColor(),
//    ::webf::css_longhand::WebkitTextSecurity(),
//    ::webf::css_longhand::WebkitTextStrokeColor(),
//    ::webf::css_longhand::WebkitTextStrokeWidth(),
//    ::webf::css_longhand::WebkitTransformOriginX(),
//    ::webf::css_longhand::WebkitTransformOriginY(),
//    ::webf::css_longhand::WebkitTransformOriginZ(),
//    ::webf::css_longhand::WebkitUserDrag(),
//    ::webf::css_longhand::WebkitUserModify(),
//    ::webf::css_longhand::WhiteSpaceCollapse(),
//    ::webf::css_longhand::Widows(),
//    ::webf::css_longhand::Width(),
//    ::webf::css_longhand::WillChange(),
//    ::webf::css_longhand::WordBreak(),
//    ::webf::css_longhand::WordSpacing(),
//    ::webf::css_longhand::X(),
//    ::webf::css_longhand::Y(),
//    ::webf::css_longhand::ZIndex(),
//    ::webf::css_longhand::WebkitAppearance(),
//    ::webf::css_longhand::WebkitAppRegion(),
//    ::webf::css_longhand::WebkitMaskClip(),
//    ::webf::css_longhand::WebkitMaskComposite(),
//    ::webf::css_longhand::WebkitMaskImage(),
//    ::webf::css_longhand::WebkitMaskOrigin(),
//    ::webf::css_longhand::WebkitMaskRepeat(),
//    ::webf::css_longhand::WebkitMaskSize(),
//    ::webf::css_longhand::WebkitBorderEndColor(),
//    ::webf::css_longhand::WebkitBorderEndStyle(),
//    ::webf::css_longhand::WebkitBorderEndWidth(),
//    ::webf::css_longhand::WebkitBorderStartColor(),
//    ::webf::css_longhand::WebkitBorderStartStyle(),
//    ::webf::css_longhand::WebkitBorderStartWidth(),
//    ::webf::css_longhand::WebkitBorderBeforeColor(),
//    ::webf::css_longhand::WebkitBorderBeforeStyle(),
//    ::webf::css_longhand::WebkitBorderBeforeWidth(),
//    ::webf::css_longhand::WebkitBorderAfterColor(),
//    ::webf::css_longhand::WebkitBorderAfterStyle(),
//    ::webf::css_longhand::WebkitBorderAfterWidth(),
//    ::webf::css_longhand::WebkitMarginEnd(),
//    ::webf::css_longhand::WebkitMarginStart(),
//    ::webf::css_longhand::WebkitMarginBefore(),
//    ::webf::css_longhand::WebkitMarginAfter(),
//    ::webf::css_longhand::WebkitPaddingEnd(),
//    ::webf::css_longhand::WebkitPaddingStart(),
//    ::webf::css_longhand::WebkitPaddingBefore(),
//    ::webf::css_longhand::WebkitPaddingAfter(),
//    ::webf::css_longhand::WebkitLogicalWidth(),
//    ::webf::css_longhand::WebkitLogicalHeight(),
//    ::webf::css_longhand::WebkitMinLogicalWidth(),
//    ::webf::css_longhand::WebkitMinLogicalHeight(),
//    ::webf::css_longhand::WebkitMaxLogicalWidth(),
//    ::webf::css_longhand::WebkitMaxLogicalHeight(),
////    ::webf::css_shorthand::WebkitBorderAfter(),
////    ::webf::css_shorthand::WebkitBorderBefore(),
////    ::webf::css_shorthand::WebkitBorderEnd(),
////    ::webf::css_shorthand::WebkitBorderStart(),
////    ::webf::css_shorthand::WebkitMask(),
////    ::webf::css_shorthand::WebkitMaskPosition(),
//    ::webf::css_longhand::EpubCaptionSide(),
//    ::webf::css_longhand::EpubTextCombine(),
////    ::webf::css_shorthand::EpubTextEmphasis(),
//    ::webf::css_longhand::EpubTextEmphasisColor(),
//    ::webf::css_longhand::EpubTextEmphasisStyle(),
//    ::webf::css_longhand::EpubTextOrientation(),
//    ::webf::css_longhand::EpubTextTransform(),
//    ::webf::css_longhand::EpubWordBreak(),
//    ::webf::css_longhand::EpubWritingMode(),
//    ::webf::css_longhand::WebkitAlignContent(),
//    ::webf::css_longhand::WebkitAlignItems(),
//    ::webf::css_longhand::WebkitAlignSelf(),
////    ::webf::css_shorthand::WebkitAnimation(),
////    ::webf::css_shorthand::WebkitAlternativeAnimationWithTimeline(),
//    ::webf::css_longhand::WebkitAnimationDelay(),
//    ::webf::css_longhand::WebkitAnimationDirection(),
//    ::webf::css_longhand::WebkitAnimationDuration(),
//    ::webf::css_longhand::WebkitAnimationFillMode(),
//    ::webf::css_longhand::WebkitAnimationIterationCount(),
//    ::webf::css_longhand::WebkitAnimationName(),
//    ::webf::css_longhand::WebkitAnimationPlayState(),
//    ::webf::css_longhand::WebkitAnimationTimingFunction(),
//    ::webf::css_longhand::WebkitBackfaceVisibility(),
//    ::webf::css_longhand::WebkitBackgroundClip(),
//    ::webf::css_longhand::WebkitBackgroundOrigin(),
//    ::webf::css_longhand::WebkitBackgroundSize(),
//    ::webf::css_longhand::WebkitBorderBottomLeftRadius(),
//    ::webf::css_longhand::WebkitBorderBottomRightRadius(),
////    ::webf::css_shorthand::WebkitBorderRadius(),
//    ::webf::css_longhand::WebkitBorderTopLeftRadius(),
//    ::webf::css_longhand::WebkitBorderTopRightRadius(),
//    ::webf::css_longhand::WebkitBoxShadow(),
//    ::webf::css_longhand::WebkitBoxSizing(),
//    ::webf::css_longhand::WebkitClipPath(),
//    ::webf::css_longhand::WebkitColumnCount(),
//    ::webf::css_longhand::WebkitColumnGap(),
////    ::webf::css_shorthand::WebkitColumnRule(),
//    ::webf::css_longhand::WebkitColumnRuleColor(),
//    ::webf::css_longhand::WebkitColumnRuleStyle(),
//    ::webf::css_longhand::WebkitColumnRuleWidth(),
//    ::webf::css_longhand::WebkitColumnSpan(),
//    ::webf::css_longhand::WebkitColumnWidth(),
////    ::webf::css_shorthand::WebkitColumns(),
//    ::webf::css_longhand::WebkitFilter(),
////    ::webf::css_shorthand::WebkitFlex(),
//    ::webf::css_longhand::WebkitFlexBasis(),
//    ::webf::css_longhand::WebkitFlexDirection(),
////    ::webf::css_shorthand::WebkitFlexFlow(),
//    ::webf::css_longhand::WebkitFlexGrow(),
//    ::webf::css_longhand::WebkitFlexShrink(),
//    ::webf::css_longhand::WebkitFlexWrap(),
//    ::webf::css_longhand::WebkitFontFeatureSettings(),
//    ::webf::css_longhand::WebkitHyphenateCharacter(),
//    ::webf::css_longhand::WebkitJustifyContent(),
//    ::webf::css_longhand::WebkitOpacity(),
//    ::webf::css_longhand::WebkitOrder(),
//    ::webf::css_longhand::WebkitPerspective(),
//    ::webf::css_longhand::WebkitPerspectiveOrigin(),
//    ::webf::css_longhand::WebkitShapeImageThreshold(),
//    ::webf::css_longhand::WebkitShapeMargin(),
//    ::webf::css_longhand::WebkitShapeOutside(),
////    ::webf::css_shorthand::WebkitTextEmphasis(),
//    ::webf::css_longhand::WebkitTextEmphasisColor(),
//    ::webf::css_longhand::WebkitTextEmphasisPosition(),
//    ::webf::css_longhand::WebkitTextEmphasisStyle(),
//    ::webf::css_longhand::WebkitTextSizeAdjust(),
//    ::webf::css_longhand::WebkitTransform(),
//    ::webf::css_longhand::WebkitTransformOrigin(),
//    ::webf::css_longhand::WebkitTransformStyle(),
////    ::webf::css_shorthand::WebkitTransition(),
//    ::webf::css_longhand::WebkitTransitionDelay(),
//    ::webf::css_longhand::WebkitTransitionDuration(),
//    ::webf::css_longhand::WebkitTransitionProperty(),
//    ::webf::css_longhand::WebkitTransitionTimingFunction(),
//    ::webf::css_longhand::WebkitUserSelect(),
//    ::webf::css_longhand::WordWrap(),
//    ::webf::css_longhand::GridColumnGap(),
//    ::webf::css_longhand::GridRowGap(),
//    ::webf::css_shorthand::GridGap(),
};

// Mapping from a property's ID to that of its visited counterpart,
// or kInvalid if it has none.
const uint8_t kPropertyVisitedIDs[] = {
    static_cast<uint8_t>(CSSPropertyID::kInvalid),
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kVariable.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kColorScheme.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kForcedColorAdjust.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kMaskImage.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kMathDepth.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kPosition.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kPositionAnchor.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kTextSizeAdjust.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAppearance.
    static_cast<uint8_t>(CSSPropertyID::kInternalVisitedColor),  // kColor.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kDirection.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kFontFamily.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kFontFeatureSettings.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kFontKerning.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kFontOpticalSizing.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kFontPalette.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kFontSize.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kFontSizeAdjust.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kFontStretch.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kFontStyle.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kFontSynthesisSmallCaps.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kFontSynthesisStyle.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kFontSynthesisWeight.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kFontVariantAlternates.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kFontVariantCaps.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kFontVariantEastAsian.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kFontVariantEmoji.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kFontVariantLigatures.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kFontVariantNumeric.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kFontVariantPosition.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kFontVariationSettings.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kFontWeight.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kInsetArea.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kInternalVisitedColor.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kTextOrientation.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kTextRendering.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kTextSpacingTrim.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kWebkitFontSmoothing.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kWebkitLocale.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kWebkitTextOrientation.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kWebkitWritingMode.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kWritingMode.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kZoom.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAccentColor.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAdditiveSymbols.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAlignContent.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAlignItems.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAlignSelf.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAlignmentBaseline.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAll.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAnchorName.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAnchorScope.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAnimationComposition.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAnimationDelay.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAnimationDirection.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAnimationDuration.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAnimationFillMode.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAnimationIterationCount.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAnimationName.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAnimationPlayState.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAnimationRangeEnd.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAnimationRangeStart.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAnimationTimeline.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAnimationTimingFunction.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAppRegion.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAscentOverride.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAspectRatio.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBackdropFilter.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBackfaceVisibility.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBackgroundAttachment.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBackgroundBlendMode.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBackgroundClip.
    static_cast<uint8_t>(CSSPropertyID::kInternalVisitedBackgroundColor),  // kBackgroundColor.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBackgroundImage.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBackgroundOrigin.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBackgroundPositionX.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBackgroundPositionY.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBackgroundRepeat.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBackgroundSize.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBasePalette.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBaselineShift.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBaselineSource.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBlockSize.
    static_cast<uint8_t>(CSSPropertyID::kInternalVisitedBorderBlockEndColor),  // kBorderBlockEndColor.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBorderBlockEndStyle.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBorderBlockEndWidth.
    static_cast<uint8_t>(CSSPropertyID::kInternalVisitedBorderBlockStartColor),  // kBorderBlockStartColor.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBorderBlockStartStyle.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBorderBlockStartWidth.
    static_cast<uint8_t>(CSSPropertyID::kInternalVisitedBorderBottomColor),  // kBorderBottomColor.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBorderBottomLeftRadius.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBorderBottomRightRadius.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBorderBottomStyle.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBorderBottomWidth.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBorderCollapse.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBorderEndEndRadius.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBorderEndStartRadius.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBorderImageOutset.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBorderImageRepeat.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBorderImageSlice.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBorderImageSource.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBorderImageWidth.
    static_cast<uint8_t>(CSSPropertyID::kInternalVisitedBorderInlineEndColor),  // kBorderInlineEndColor.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBorderInlineEndStyle.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBorderInlineEndWidth.
    static_cast<uint8_t>(CSSPropertyID::kInternalVisitedBorderInlineStartColor),  // kBorderInlineStartColor.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBorderInlineStartStyle.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBorderInlineStartWidth.
    static_cast<uint8_t>(CSSPropertyID::kInternalVisitedBorderLeftColor),  // kBorderLeftColor.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBorderLeftStyle.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBorderLeftWidth.
    static_cast<uint8_t>(CSSPropertyID::kInternalVisitedBorderRightColor),  // kBorderRightColor.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBorderRightStyle.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBorderRightWidth.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBorderStartEndRadius.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBorderStartStartRadius.
    static_cast<uint8_t>(CSSPropertyID::kInternalVisitedBorderTopColor),  // kBorderTopColor.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBorderTopLeftRadius.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBorderTopRightRadius.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBorderTopStyle.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBorderTopWidth.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBottom.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBoxShadow.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBoxSizing.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBreakAfter.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBreakBefore.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBreakInside.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBufferedRendering.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kCaptionSide.
    static_cast<uint8_t>(CSSPropertyID::kInternalVisitedCaretColor),  // kCaretColor.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kClear.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kClip.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kClipPath.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kClipRule.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kColorInterpolation.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kColorInterpolationFilters.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kColorRendering.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kColumnCount.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kColumnFill.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kColumnGap.
    static_cast<uint8_t>(CSSPropertyID::kInternalVisitedColumnRuleColor),  // kColumnRuleColor.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kColumnRuleStyle.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kColumnRuleWidth.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kColumnSpan.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kColumnWidth.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kContain.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kContainIntrinsicBlockSize.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kContainIntrinsicHeight.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kContainIntrinsicInlineSize.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kContainIntrinsicWidth.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kContainerName.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kContainerType.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kContent.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kContentVisibility.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kCounterIncrement.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kCounterReset.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kCounterSet.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kCursor.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kCx.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kCy.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kD.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kDescentOverride.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kDisplay.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kDominantBaseline.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kDynamicRangeLimit.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kEmptyCells.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kFallback.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kFieldSizing.
    static_cast<uint8_t>(CSSPropertyID::kInternalVisitedFill),  // kFill.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kFillOpacity.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kFillRule.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kFilter.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kFlexBasis.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kFlexDirection.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kFlexGrow.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kFlexShrink.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kFlexWrap.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kFloat.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kFloodColor.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kFloodOpacity.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kFontDisplay.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kGridAutoColumns.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kGridAutoFlow.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kGridAutoRows.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kGridColumnEnd.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kGridColumnStart.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kGridRowEnd.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kGridRowStart.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kGridTemplateAreas.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kGridTemplateColumns.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kGridTemplateRows.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kHeight.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kHyphenateCharacter.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kHyphenateLimitChars.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kHyphens.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kImageOrientation.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kImageRendering.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kInherits.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kInitialLetter.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kInitialValue.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kInlineSize.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kInsetBlockEnd.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kInsetBlockStart.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kInsetInlineEnd.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kInsetInlineStart.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kInternalAlignContentBlock.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kInternalEmptyLineHeight.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kInternalFontSizeDelta.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kInternalForcedBackgroundColor.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kInternalForcedBorderColor.
    static_cast<uint8_t>(CSSPropertyID::kInternalForcedVisitedColor),  // kInternalForcedColor.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kInternalForcedOutlineColor.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kInternalForcedVisitedColor.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kInternalOverflowBlock.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kInternalOverflowInline.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kInternalVisitedBackgroundColor.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kInternalVisitedBorderBlockEndColor.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kInternalVisitedBorderBlockStartColor.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kInternalVisitedBorderBottomColor.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kInternalVisitedBorderInlineEndColor.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kInternalVisitedBorderInlineStartColor.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kInternalVisitedBorderLeftColor.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kInternalVisitedBorderRightColor.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kInternalVisitedBorderTopColor.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kInternalVisitedCaretColor.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kInternalVisitedColumnRuleColor.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kInternalVisitedFill.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kInternalVisitedOutlineColor.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kInternalVisitedStroke.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kInternalVisitedTextDecorationColor.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kInternalVisitedTextEmphasisColor.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kInternalVisitedTextFillColor.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kInternalVisitedTextStrokeColor.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kIsolation.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kJustifyContent.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kJustifyItems.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kJustifySelf.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kLeft.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kLetterSpacing.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kLightingColor.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kLineBreak.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kLineClamp.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kLineGapOverride.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kLineHeight.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kListStyleImage.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kListStylePosition.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kListStyleType.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kMarginBlockEnd.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kMarginBlockStart.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kMarginBottom.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kMarginInlineEnd.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kMarginInlineStart.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kMarginLeft.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kMarginRight.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kMarginTop.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kMarkerEnd.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kMarkerMid.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kMarkerStart.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kMaskClip.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kMaskComposite.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kMaskMode.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kMaskOrigin.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kMaskRepeat.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kMaskSize.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kMaskType.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kMathShift.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kMathStyle.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kMaxBlockSize.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kMaxHeight.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kMaxInlineSize.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kMaxWidth.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kMinBlockSize.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kMinHeight.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kMinInlineSize.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kMinWidth.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kMixBlendMode.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kNavigation.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kNegative.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kObjectFit.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kObjectPosition.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kObjectViewBox.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kOffsetAnchor.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kOffsetDistance.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kOffsetPath.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kOffsetPosition.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kOffsetRotate.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kOpacity.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kOrder.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kOriginTrialTestProperty.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kOrphans.
    static_cast<uint8_t>(CSSPropertyID::kInternalVisitedOutlineColor),  // kOutlineColor.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kOutlineOffset.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kOutlineStyle.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kOutlineWidth.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kOverflowAnchor.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kOverflowBlock.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kOverflowClipMargin.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kOverflowInline.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kOverflowWrap.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kOverflowX.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kOverflowY.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kOverlay.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kOverrideColors.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kOverscrollBehaviorBlock.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kOverscrollBehaviorInline.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kOverscrollBehaviorX.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kOverscrollBehaviorY.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kPad.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kPaddingBlockEnd.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kPaddingBlockStart.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kPaddingBottom.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kPaddingInlineEnd.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kPaddingInlineStart.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kPaddingLeft.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kPaddingRight.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kPaddingTop.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kPage.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kPageOrientation.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kPaintOrder.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kPerspective.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kPerspectiveOrigin.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kPointerEvents.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kPopoverHideDelay.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kPopoverShowDelay.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kPositionTryOptions.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kPositionTryOrder.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kPositionVisibility.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kPrefix.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kQuotes.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kR.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kRange.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kReadingFlow.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kResize.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kRight.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kRotate.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kRowGap.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kRubyAlign.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kRubyPosition.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kRx.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kRy.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kScale.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kScrollBehavior.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kScrollMarginBlockEnd.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kScrollMarginBlockStart.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kScrollMarginBottom.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kScrollMarginInlineEnd.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kScrollMarginInlineStart.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kScrollMarginLeft.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kScrollMarginRight.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kScrollMarginTop.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kScrollMarkers.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kScrollPaddingBlockEnd.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kScrollPaddingBlockStart.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kScrollPaddingBottom.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kScrollPaddingInlineEnd.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kScrollPaddingInlineStart.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kScrollPaddingLeft.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kScrollPaddingRight.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kScrollPaddingTop.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kScrollSnapAlign.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kScrollSnapStop.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kScrollSnapType.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kScrollStartBlock.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kScrollStartInline.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kScrollStartTargetBlock.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kScrollStartTargetInline.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kScrollStartTargetX.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kScrollStartTargetY.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kScrollStartX.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kScrollStartY.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kScrollTimelineAxis.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kScrollTimelineName.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kScrollbarColor.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kScrollbarGutter.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kScrollbarWidth.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kShapeImageThreshold.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kShapeMargin.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kShapeOutside.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kShapeRendering.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kSize.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kSizeAdjust.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kSpeak.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kSpeakAs.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kSrc.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kStopColor.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kStopOpacity.
    static_cast<uint8_t>(CSSPropertyID::kInternalVisitedStroke),  // kStroke.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kStrokeDasharray.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kStrokeDashoffset.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kStrokeLinecap.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kStrokeLinejoin.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kStrokeMiterlimit.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kStrokeOpacity.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kStrokeWidth.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kSuffix.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kSymbols.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kSyntax.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kSystem.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kTabSize.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kTableLayout.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kTextAlign.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kTextAlignLast.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kTextAnchor.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kTextAutospace.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kTextBoxEdge.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kTextBoxTrim.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kTextCombineUpright.
    static_cast<uint8_t>(CSSPropertyID::kInternalVisitedTextDecorationColor),  // kTextDecorationColor.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kTextDecorationLine.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kTextDecorationSkipInk.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kTextDecorationStyle.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kTextDecorationThickness.
    static_cast<uint8_t>(CSSPropertyID::kInternalVisitedTextEmphasisColor),  // kTextEmphasisColor.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kTextEmphasisPosition.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kTextEmphasisStyle.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kTextIndent.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kTextOverflow.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kTextShadow.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kTextTransform.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kTextUnderlineOffset.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kTextUnderlinePosition.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kTextWrap.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kTimelineScope.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kTop.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kTouchAction.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kTransform.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kTransformBox.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kTransformOrigin.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kTransformStyle.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kTransitionBehavior.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kTransitionDelay.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kTransitionDuration.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kTransitionProperty.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kTransitionTimingFunction.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kTranslate.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kTypes.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kUnicodeBidi.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kUnicodeRange.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kUserSelect.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kVectorEffect.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kVerticalAlign.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kViewTimelineAxis.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kViewTimelineInset.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kViewTimelineName.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kViewTransitionClass.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kViewTransitionName.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kVisibility.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kWebkitBorderHorizontalSpacing.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kWebkitBorderImage.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kWebkitBorderVerticalSpacing.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kWebkitBoxAlign.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kWebkitBoxDecorationBreak.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kWebkitBoxDirection.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kWebkitBoxFlex.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kWebkitBoxOrdinalGroup.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kWebkitBoxOrient.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kWebkitBoxPack.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kWebkitBoxReflect.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kWebkitLineBreak.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kWebkitLineClamp.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kWebkitMaskBoxImageOutset.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kWebkitMaskBoxImageRepeat.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kWebkitMaskBoxImageSlice.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kWebkitMaskBoxImageSource.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kWebkitMaskBoxImageWidth.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kWebkitMaskPositionX.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kWebkitMaskPositionY.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kWebkitPerspectiveOriginX.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kWebkitPerspectiveOriginY.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kWebkitPrintColorAdjust.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kWebkitRtlOrdering.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kWebkitRubyPosition.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kWebkitTapHighlightColor.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kWebkitTextCombine.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kWebkitTextDecorationsInEffect.
    static_cast<uint8_t>(CSSPropertyID::kInternalVisitedTextFillColor),  // kWebkitTextFillColor.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kWebkitTextSecurity.
    static_cast<uint8_t>(CSSPropertyID::kInternalVisitedTextStrokeColor),  // kWebkitTextStrokeColor.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kWebkitTextStrokeWidth.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kWebkitTransformOriginX.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kWebkitTransformOriginY.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kWebkitTransformOriginZ.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kWebkitUserDrag.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kWebkitUserModify.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kWhiteSpaceCollapse.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kWidows.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kWidth.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kWillChange.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kWordBreak.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kWordSpacing.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kX.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kY.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kZIndex.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAlternativeAnimationWithTimeline.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAnimation.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAnimationRange.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBackground.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBackgroundPosition.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBorder.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBorderBlock.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBorderBlockColor.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBorderBlockEnd.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBorderBlockStart.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBorderBlockStyle.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBorderBlockWidth.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBorderBottom.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBorderColor.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBorderImage.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBorderInline.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBorderInlineColor.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBorderInlineEnd.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBorderInlineStart.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBorderInlineStyle.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBorderInlineWidth.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBorderLeft.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBorderRadius.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBorderRight.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBorderSpacing.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBorderStyle.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBorderTop.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kBorderWidth.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kColumnRule.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kColumns.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kContainIntrinsicSize.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kContainer.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kFlex.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kFlexFlow.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kFont.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kFontSynthesis.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kFontVariant.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kGap.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kGrid.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kGridArea.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kGridColumn.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kGridRow.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kGridTemplate.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kInset.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kInsetBlock.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kInsetInline.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kListStyle.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kMargin.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kMarginBlock.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kMarginInline.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kMarker.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kMask.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kMaskPosition.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kOffset.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kOutline.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kOverflow.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kOverscrollBehavior.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kPadding.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kPaddingBlock.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kPaddingInline.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kPageBreakAfter.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kPageBreakBefore.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kPageBreakInside.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kPlaceContent.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kPlaceItems.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kPlaceSelf.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kPositionTry.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kScrollMargin.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kScrollMarginBlock.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kScrollMarginInline.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kScrollPadding.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kScrollPaddingBlock.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kScrollPaddingInline.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kScrollStart.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kScrollStartTarget.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kScrollTimeline.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kTextDecoration.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kTextEmphasis.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kTextSpacing.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kTransition.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kViewTimeline.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kWebkitColumnBreakAfter.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kWebkitColumnBreakBefore.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kWebkitColumnBreakInside.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kWebkitMaskBoxImage.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kWebkitTextStroke.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kWhiteSpace.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitAppearance.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitAppRegion.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitMaskClip.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitMaskComposite.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitMaskImage.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitMaskOrigin.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitMaskRepeat.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitMaskSize.
    static_cast<uint8_t>(CSSPropertyID::kInternalVisitedBorderInlineEndColor),  // kAliasWebkitBorderEndColor.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitBorderEndStyle.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitBorderEndWidth.
    static_cast<uint8_t>(CSSPropertyID::kInternalVisitedBorderInlineStartColor),  // kAliasWebkitBorderStartColor.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitBorderStartStyle.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitBorderStartWidth.
    static_cast<uint8_t>(CSSPropertyID::kInternalVisitedBorderBlockStartColor),  // kAliasWebkitBorderBeforeColor.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitBorderBeforeStyle.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitBorderBeforeWidth.
    static_cast<uint8_t>(CSSPropertyID::kInternalVisitedBorderBlockEndColor),  // kAliasWebkitBorderAfterColor.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitBorderAfterStyle.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitBorderAfterWidth.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitMarginEnd.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitMarginStart.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitMarginBefore.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitMarginAfter.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitPaddingEnd.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitPaddingStart.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitPaddingBefore.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitPaddingAfter.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitLogicalWidth.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitLogicalHeight.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitMinLogicalWidth.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitMinLogicalHeight.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitMaxLogicalWidth.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitMaxLogicalHeight.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitBorderAfter.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitBorderBefore.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitBorderEnd.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitBorderStart.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitMask.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitMaskPosition.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasEpubCaptionSide.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasEpubTextCombine.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasEpubTextEmphasis.
    static_cast<uint8_t>(CSSPropertyID::kInternalVisitedTextEmphasisColor),  // kAliasEpubTextEmphasisColor.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasEpubTextEmphasisStyle.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasEpubTextOrientation.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasEpubTextTransform.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasEpubWordBreak.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasEpubWritingMode.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitAlignContent.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitAlignItems.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitAlignSelf.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitAnimation.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitAlternativeAnimationWithTimeline.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitAnimationDelay.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitAnimationDirection.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitAnimationDuration.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitAnimationFillMode.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitAnimationIterationCount.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitAnimationName.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitAnimationPlayState.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitAnimationTimingFunction.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitBackfaceVisibility.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitBackgroundClip.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitBackgroundOrigin.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitBackgroundSize.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitBorderBottomLeftRadius.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitBorderBottomRightRadius.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitBorderRadius.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitBorderTopLeftRadius.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitBorderTopRightRadius.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitBoxShadow.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitBoxSizing.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitClipPath.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitColumnCount.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitColumnGap.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitColumnRule.
    static_cast<uint8_t>(CSSPropertyID::kInternalVisitedColumnRuleColor),  // kAliasWebkitColumnRuleColor.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitColumnRuleStyle.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitColumnRuleWidth.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitColumnSpan.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitColumnWidth.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitColumns.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitFilter.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitFlex.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitFlexBasis.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitFlexDirection.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitFlexFlow.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitFlexGrow.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitFlexShrink.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitFlexWrap.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitFontFeatureSettings.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitHyphenateCharacter.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitJustifyContent.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitOpacity.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitOrder.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitPerspective.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitPerspectiveOrigin.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitShapeImageThreshold.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitShapeMargin.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitShapeOutside.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitTextEmphasis.
    static_cast<uint8_t>(CSSPropertyID::kInternalVisitedTextEmphasisColor),  // kAliasWebkitTextEmphasisColor.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitTextEmphasisPosition.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitTextEmphasisStyle.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitTextSizeAdjust.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitTransform.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitTransformOrigin.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitTransformStyle.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitTransition.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitTransitionDelay.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitTransitionDuration.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitTransitionProperty.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitTransitionTimingFunction.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWebkitUserSelect.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasWordWrap.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasGridColumnGap.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasGridRowGap.
    static_cast<uint8_t>(CSSPropertyID::kInvalid),  // kAliasGridGap.
};

// Verify that all properties (used in the array) fit into a uint8_t.
// If this stops holding, we'll either need to switch types of
// kPropertyVisitedIDs, or reorganize the ordering of the enum
// so that the kInternalVisited* ones are earlier.
static_assert(static_cast<size_t>(CSSPropertyID::kInvalid) < 256);
static_assert(static_cast<size_t>(CSSPropertyID::kInternalVisitedColor) < 256);
static_assert(static_cast<size_t>(CSSPropertyID::kInternalVisitedBackgroundColor) < 256);
static_assert(static_cast<size_t>(CSSPropertyID::kInternalVisitedBorderBlockEndColor) < 256);
static_assert(static_cast<size_t>(CSSPropertyID::kInternalVisitedBorderBlockStartColor) < 256);
static_assert(static_cast<size_t>(CSSPropertyID::kInternalVisitedBorderBottomColor) < 256);
static_assert(static_cast<size_t>(CSSPropertyID::kInternalVisitedBorderInlineEndColor) < 256);
static_assert(static_cast<size_t>(CSSPropertyID::kInternalVisitedBorderInlineStartColor) < 256);
static_assert(static_cast<size_t>(CSSPropertyID::kInternalVisitedBorderLeftColor) < 256);
static_assert(static_cast<size_t>(CSSPropertyID::kInternalVisitedBorderRightColor) < 256);
static_assert(static_cast<size_t>(CSSPropertyID::kInternalVisitedBorderTopColor) < 256);
static_assert(static_cast<size_t>(CSSPropertyID::kInternalVisitedCaretColor) < 256);
static_assert(static_cast<size_t>(CSSPropertyID::kInternalVisitedColumnRuleColor) < 256);
static_assert(static_cast<size_t>(CSSPropertyID::kInternalVisitedFill) < 256);
static_assert(static_cast<size_t>(CSSPropertyID::kInternalForcedVisitedColor) < 256);
static_assert(static_cast<size_t>(CSSPropertyID::kInternalVisitedOutlineColor) < 256);
static_assert(static_cast<size_t>(CSSPropertyID::kInternalVisitedStroke) < 256);
static_assert(static_cast<size_t>(CSSPropertyID::kInternalVisitedTextDecorationColor) < 256);
static_assert(static_cast<size_t>(CSSPropertyID::kInternalVisitedTextEmphasisColor) < 256);
static_assert(static_cast<size_t>(CSSPropertyID::kInternalVisitedTextFillColor) < 256);
static_assert(static_cast<size_t>(CSSPropertyID::kInternalVisitedTextStrokeColor) < 256);
static_assert(static_cast<size_t>(CSSPropertyID::kInternalVisitedBorderInlineEndColor) < 256);
static_assert(static_cast<size_t>(CSSPropertyID::kInternalVisitedBorderInlineStartColor) < 256);
static_assert(static_cast<size_t>(CSSPropertyID::kInternalVisitedBorderBlockStartColor) < 256);
static_assert(static_cast<size_t>(CSSPropertyID::kInternalVisitedBorderBlockEndColor) < 256);
static_assert(static_cast<size_t>(CSSPropertyID::kInternalVisitedTextEmphasisColor) < 256);
static_assert(static_cast<size_t>(CSSPropertyID::kInternalVisitedColumnRuleColor) < 256);
static_assert(static_cast<size_t>(CSSPropertyID::kInternalVisitedTextEmphasisColor) < 256);

// Similar, for unvisited IDs. Note that this array is much less
// hot than kPropertyVisitedIDs, so it's definitely fine that it's uint16_t.
const uint16_t kPropertyUnvisitedIDs[] = {
    static_cast<uint16_t>(CSSPropertyID::kInvalid),
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kVariable.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kColorScheme.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kForcedColorAdjust.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kMaskImage.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kMathDepth.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kPosition.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kPositionAnchor.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kTextSizeAdjust.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAppearance.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kColor.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kDirection.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kFontFamily.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kFontFeatureSettings.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kFontKerning.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kFontOpticalSizing.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kFontPalette.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kFontSize.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kFontSizeAdjust.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kFontStretch.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kFontStyle.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kFontSynthesisSmallCaps.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kFontSynthesisStyle.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kFontSynthesisWeight.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kFontVariantAlternates.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kFontVariantCaps.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kFontVariantEastAsian.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kFontVariantEmoji.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kFontVariantLigatures.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kFontVariantNumeric.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kFontVariantPosition.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kFontVariationSettings.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kFontWeight.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kInsetArea.
    static_cast<uint16_t>(CSSPropertyID::kColor),  // kInternalVisitedColor.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kTextOrientation.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kTextRendering.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kTextSpacingTrim.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kWebkitFontSmoothing.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kWebkitLocale.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kWebkitTextOrientation.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kWebkitWritingMode.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kWritingMode.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kZoom.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAccentColor.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAdditiveSymbols.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAlignContent.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAlignItems.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAlignSelf.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAlignmentBaseline.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAll.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAnchorName.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAnchorScope.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAnimationComposition.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAnimationDelay.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAnimationDirection.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAnimationDuration.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAnimationFillMode.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAnimationIterationCount.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAnimationName.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAnimationPlayState.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAnimationRangeEnd.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAnimationRangeStart.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAnimationTimeline.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAnimationTimingFunction.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAppRegion.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAscentOverride.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAspectRatio.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBackdropFilter.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBackfaceVisibility.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBackgroundAttachment.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBackgroundBlendMode.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBackgroundClip.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBackgroundColor.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBackgroundImage.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBackgroundOrigin.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBackgroundPositionX.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBackgroundPositionY.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBackgroundRepeat.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBackgroundSize.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBasePalette.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBaselineShift.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBaselineSource.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBlockSize.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBorderBlockEndColor.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBorderBlockEndStyle.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBorderBlockEndWidth.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBorderBlockStartColor.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBorderBlockStartStyle.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBorderBlockStartWidth.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBorderBottomColor.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBorderBottomLeftRadius.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBorderBottomRightRadius.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBorderBottomStyle.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBorderBottomWidth.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBorderCollapse.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBorderEndEndRadius.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBorderEndStartRadius.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBorderImageOutset.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBorderImageRepeat.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBorderImageSlice.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBorderImageSource.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBorderImageWidth.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBorderInlineEndColor.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBorderInlineEndStyle.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBorderInlineEndWidth.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBorderInlineStartColor.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBorderInlineStartStyle.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBorderInlineStartWidth.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBorderLeftColor.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBorderLeftStyle.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBorderLeftWidth.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBorderRightColor.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBorderRightStyle.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBorderRightWidth.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBorderStartEndRadius.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBorderStartStartRadius.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBorderTopColor.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBorderTopLeftRadius.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBorderTopRightRadius.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBorderTopStyle.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBorderTopWidth.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBottom.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBoxShadow.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBoxSizing.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBreakAfter.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBreakBefore.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBreakInside.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBufferedRendering.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kCaptionSide.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kCaretColor.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kClear.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kClip.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kClipPath.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kClipRule.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kColorInterpolation.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kColorInterpolationFilters.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kColorRendering.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kColumnCount.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kColumnFill.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kColumnGap.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kColumnRuleColor.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kColumnRuleStyle.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kColumnRuleWidth.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kColumnSpan.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kColumnWidth.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kContain.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kContainIntrinsicBlockSize.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kContainIntrinsicHeight.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kContainIntrinsicInlineSize.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kContainIntrinsicWidth.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kContainerName.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kContainerType.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kContent.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kContentVisibility.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kCounterIncrement.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kCounterReset.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kCounterSet.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kCursor.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kCx.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kCy.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kD.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kDescentOverride.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kDisplay.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kDominantBaseline.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kDynamicRangeLimit.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kEmptyCells.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kFallback.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kFieldSizing.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kFill.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kFillOpacity.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kFillRule.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kFilter.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kFlexBasis.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kFlexDirection.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kFlexGrow.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kFlexShrink.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kFlexWrap.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kFloat.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kFloodColor.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kFloodOpacity.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kFontDisplay.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kGridAutoColumns.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kGridAutoFlow.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kGridAutoRows.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kGridColumnEnd.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kGridColumnStart.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kGridRowEnd.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kGridRowStart.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kGridTemplateAreas.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kGridTemplateColumns.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kGridTemplateRows.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kHeight.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kHyphenateCharacter.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kHyphenateLimitChars.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kHyphens.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kImageOrientation.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kImageRendering.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kInherits.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kInitialLetter.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kInitialValue.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kInlineSize.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kInsetBlockEnd.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kInsetBlockStart.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kInsetInlineEnd.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kInsetInlineStart.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kInternalAlignContentBlock.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kInternalEmptyLineHeight.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kInternalFontSizeDelta.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kInternalForcedBackgroundColor.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kInternalForcedBorderColor.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kInternalForcedColor.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kInternalForcedOutlineColor.
    static_cast<uint16_t>(CSSPropertyID::kInternalForcedColor),  // kInternalForcedVisitedColor.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kInternalOverflowBlock.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kInternalOverflowInline.
    static_cast<uint16_t>(CSSPropertyID::kBackgroundColor),  // kInternalVisitedBackgroundColor.
    static_cast<uint16_t>(CSSPropertyID::kBorderBlockEndColor),  // kInternalVisitedBorderBlockEndColor.
    static_cast<uint16_t>(CSSPropertyID::kBorderBlockStartColor),  // kInternalVisitedBorderBlockStartColor.
    static_cast<uint16_t>(CSSPropertyID::kBorderBottomColor),  // kInternalVisitedBorderBottomColor.
    static_cast<uint16_t>(CSSPropertyID::kBorderInlineEndColor),  // kInternalVisitedBorderInlineEndColor.
    static_cast<uint16_t>(CSSPropertyID::kBorderInlineStartColor),  // kInternalVisitedBorderInlineStartColor.
    static_cast<uint16_t>(CSSPropertyID::kBorderLeftColor),  // kInternalVisitedBorderLeftColor.
    static_cast<uint16_t>(CSSPropertyID::kBorderRightColor),  // kInternalVisitedBorderRightColor.
    static_cast<uint16_t>(CSSPropertyID::kBorderTopColor),  // kInternalVisitedBorderTopColor.
    static_cast<uint16_t>(CSSPropertyID::kCaretColor),  // kInternalVisitedCaretColor.
    static_cast<uint16_t>(CSSPropertyID::kColumnRuleColor),  // kInternalVisitedColumnRuleColor.
    static_cast<uint16_t>(CSSPropertyID::kFill),  // kInternalVisitedFill.
    static_cast<uint16_t>(CSSPropertyID::kOutlineColor),  // kInternalVisitedOutlineColor.
    static_cast<uint16_t>(CSSPropertyID::kStroke),  // kInternalVisitedStroke.
    static_cast<uint16_t>(CSSPropertyID::kTextDecorationColor),  // kInternalVisitedTextDecorationColor.
    static_cast<uint16_t>(CSSPropertyID::kTextEmphasisColor),  // kInternalVisitedTextEmphasisColor.
    static_cast<uint16_t>(CSSPropertyID::kWebkitTextFillColor),  // kInternalVisitedTextFillColor.
    static_cast<uint16_t>(CSSPropertyID::kWebkitTextStrokeColor),  // kInternalVisitedTextStrokeColor.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kIsolation.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kJustifyContent.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kJustifyItems.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kJustifySelf.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kLeft.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kLetterSpacing.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kLightingColor.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kLineBreak.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kLineClamp.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kLineGapOverride.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kLineHeight.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kListStyleImage.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kListStylePosition.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kListStyleType.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kMarginBlockEnd.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kMarginBlockStart.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kMarginBottom.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kMarginInlineEnd.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kMarginInlineStart.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kMarginLeft.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kMarginRight.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kMarginTop.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kMarkerEnd.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kMarkerMid.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kMarkerStart.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kMaskClip.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kMaskComposite.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kMaskMode.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kMaskOrigin.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kMaskRepeat.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kMaskSize.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kMaskType.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kMathShift.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kMathStyle.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kMaxBlockSize.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kMaxHeight.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kMaxInlineSize.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kMaxWidth.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kMinBlockSize.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kMinHeight.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kMinInlineSize.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kMinWidth.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kMixBlendMode.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kNavigation.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kNegative.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kObjectFit.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kObjectPosition.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kObjectViewBox.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kOffsetAnchor.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kOffsetDistance.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kOffsetPath.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kOffsetPosition.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kOffsetRotate.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kOpacity.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kOrder.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kOriginTrialTestProperty.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kOrphans.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kOutlineColor.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kOutlineOffset.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kOutlineStyle.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kOutlineWidth.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kOverflowAnchor.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kOverflowBlock.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kOverflowClipMargin.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kOverflowInline.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kOverflowWrap.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kOverflowX.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kOverflowY.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kOverlay.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kOverrideColors.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kOverscrollBehaviorBlock.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kOverscrollBehaviorInline.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kOverscrollBehaviorX.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kOverscrollBehaviorY.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kPad.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kPaddingBlockEnd.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kPaddingBlockStart.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kPaddingBottom.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kPaddingInlineEnd.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kPaddingInlineStart.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kPaddingLeft.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kPaddingRight.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kPaddingTop.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kPage.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kPageOrientation.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kPaintOrder.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kPerspective.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kPerspectiveOrigin.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kPointerEvents.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kPopoverHideDelay.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kPopoverShowDelay.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kPositionTryOptions.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kPositionTryOrder.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kPositionVisibility.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kPrefix.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kQuotes.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kR.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kRange.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kReadingFlow.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kResize.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kRight.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kRotate.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kRowGap.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kRubyAlign.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kRubyPosition.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kRx.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kRy.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kScale.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kScrollBehavior.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kScrollMarginBlockEnd.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kScrollMarginBlockStart.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kScrollMarginBottom.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kScrollMarginInlineEnd.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kScrollMarginInlineStart.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kScrollMarginLeft.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kScrollMarginRight.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kScrollMarginTop.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kScrollMarkers.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kScrollPaddingBlockEnd.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kScrollPaddingBlockStart.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kScrollPaddingBottom.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kScrollPaddingInlineEnd.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kScrollPaddingInlineStart.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kScrollPaddingLeft.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kScrollPaddingRight.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kScrollPaddingTop.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kScrollSnapAlign.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kScrollSnapStop.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kScrollSnapType.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kScrollStartBlock.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kScrollStartInline.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kScrollStartTargetBlock.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kScrollStartTargetInline.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kScrollStartTargetX.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kScrollStartTargetY.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kScrollStartX.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kScrollStartY.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kScrollTimelineAxis.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kScrollTimelineName.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kScrollbarColor.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kScrollbarGutter.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kScrollbarWidth.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kShapeImageThreshold.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kShapeMargin.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kShapeOutside.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kShapeRendering.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kSize.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kSizeAdjust.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kSpeak.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kSpeakAs.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kSrc.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kStopColor.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kStopOpacity.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kStroke.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kStrokeDasharray.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kStrokeDashoffset.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kStrokeLinecap.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kStrokeLinejoin.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kStrokeMiterlimit.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kStrokeOpacity.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kStrokeWidth.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kSuffix.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kSymbols.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kSyntax.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kSystem.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kTabSize.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kTableLayout.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kTextAlign.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kTextAlignLast.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kTextAnchor.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kTextAutospace.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kTextBoxEdge.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kTextBoxTrim.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kTextCombineUpright.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kTextDecorationColor.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kTextDecorationLine.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kTextDecorationSkipInk.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kTextDecorationStyle.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kTextDecorationThickness.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kTextEmphasisColor.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kTextEmphasisPosition.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kTextEmphasisStyle.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kTextIndent.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kTextOverflow.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kTextShadow.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kTextTransform.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kTextUnderlineOffset.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kTextUnderlinePosition.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kTextWrap.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kTimelineScope.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kTop.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kTouchAction.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kTransform.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kTransformBox.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kTransformOrigin.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kTransformStyle.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kTransitionBehavior.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kTransitionDelay.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kTransitionDuration.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kTransitionProperty.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kTransitionTimingFunction.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kTranslate.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kTypes.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kUnicodeBidi.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kUnicodeRange.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kUserSelect.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kVectorEffect.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kVerticalAlign.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kViewTimelineAxis.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kViewTimelineInset.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kViewTimelineName.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kViewTransitionClass.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kViewTransitionName.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kVisibility.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kWebkitBorderHorizontalSpacing.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kWebkitBorderImage.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kWebkitBorderVerticalSpacing.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kWebkitBoxAlign.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kWebkitBoxDecorationBreak.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kWebkitBoxDirection.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kWebkitBoxFlex.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kWebkitBoxOrdinalGroup.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kWebkitBoxOrient.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kWebkitBoxPack.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kWebkitBoxReflect.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kWebkitLineBreak.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kWebkitLineClamp.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kWebkitMaskBoxImageOutset.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kWebkitMaskBoxImageRepeat.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kWebkitMaskBoxImageSlice.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kWebkitMaskBoxImageSource.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kWebkitMaskBoxImageWidth.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kWebkitMaskPositionX.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kWebkitMaskPositionY.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kWebkitPerspectiveOriginX.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kWebkitPerspectiveOriginY.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kWebkitPrintColorAdjust.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kWebkitRtlOrdering.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kWebkitRubyPosition.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kWebkitTapHighlightColor.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kWebkitTextCombine.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kWebkitTextDecorationsInEffect.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kWebkitTextFillColor.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kWebkitTextSecurity.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kWebkitTextStrokeColor.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kWebkitTextStrokeWidth.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kWebkitTransformOriginX.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kWebkitTransformOriginY.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kWebkitTransformOriginZ.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kWebkitUserDrag.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kWebkitUserModify.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kWhiteSpaceCollapse.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kWidows.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kWidth.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kWillChange.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kWordBreak.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kWordSpacing.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kX.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kY.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kZIndex.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAlternativeAnimationWithTimeline.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAnimation.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAnimationRange.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBackground.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBackgroundPosition.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBorder.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBorderBlock.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBorderBlockColor.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBorderBlockEnd.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBorderBlockStart.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBorderBlockStyle.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBorderBlockWidth.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBorderBottom.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBorderColor.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBorderImage.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBorderInline.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBorderInlineColor.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBorderInlineEnd.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBorderInlineStart.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBorderInlineStyle.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBorderInlineWidth.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBorderLeft.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBorderRadius.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBorderRight.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBorderSpacing.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBorderStyle.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBorderTop.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kBorderWidth.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kColumnRule.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kColumns.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kContainIntrinsicSize.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kContainer.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kFlex.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kFlexFlow.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kFont.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kFontSynthesis.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kFontVariant.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kGap.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kGrid.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kGridArea.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kGridColumn.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kGridRow.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kGridTemplate.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kInset.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kInsetBlock.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kInsetInline.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kListStyle.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kMargin.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kMarginBlock.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kMarginInline.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kMarker.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kMask.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kMaskPosition.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kOffset.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kOutline.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kOverflow.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kOverscrollBehavior.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kPadding.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kPaddingBlock.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kPaddingInline.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kPageBreakAfter.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kPageBreakBefore.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kPageBreakInside.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kPlaceContent.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kPlaceItems.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kPlaceSelf.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kPositionTry.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kScrollMargin.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kScrollMarginBlock.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kScrollMarginInline.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kScrollPadding.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kScrollPaddingBlock.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kScrollPaddingInline.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kScrollStart.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kScrollStartTarget.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kScrollTimeline.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kTextDecoration.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kTextEmphasis.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kTextSpacing.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kTransition.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kViewTimeline.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kWebkitColumnBreakAfter.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kWebkitColumnBreakBefore.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kWebkitColumnBreakInside.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kWebkitMaskBoxImage.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kWebkitTextStroke.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kWhiteSpace.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitAppearance.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitAppRegion.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitMaskClip.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitMaskComposite.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitMaskImage.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitMaskOrigin.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitMaskRepeat.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitMaskSize.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitBorderEndColor.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitBorderEndStyle.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitBorderEndWidth.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitBorderStartColor.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitBorderStartStyle.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitBorderStartWidth.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitBorderBeforeColor.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitBorderBeforeStyle.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitBorderBeforeWidth.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitBorderAfterColor.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitBorderAfterStyle.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitBorderAfterWidth.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitMarginEnd.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitMarginStart.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitMarginBefore.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitMarginAfter.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitPaddingEnd.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitPaddingStart.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitPaddingBefore.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitPaddingAfter.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitLogicalWidth.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitLogicalHeight.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitMinLogicalWidth.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitMinLogicalHeight.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitMaxLogicalWidth.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitMaxLogicalHeight.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitBorderAfter.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitBorderBefore.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitBorderEnd.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitBorderStart.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitMask.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitMaskPosition.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasEpubCaptionSide.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasEpubTextCombine.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasEpubTextEmphasis.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasEpubTextEmphasisColor.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasEpubTextEmphasisStyle.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasEpubTextOrientation.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasEpubTextTransform.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasEpubWordBreak.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasEpubWritingMode.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitAlignContent.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitAlignItems.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitAlignSelf.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitAnimation.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitAlternativeAnimationWithTimeline.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitAnimationDelay.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitAnimationDirection.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitAnimationDuration.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitAnimationFillMode.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitAnimationIterationCount.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitAnimationName.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitAnimationPlayState.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitAnimationTimingFunction.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitBackfaceVisibility.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitBackgroundClip.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitBackgroundOrigin.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitBackgroundSize.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitBorderBottomLeftRadius.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitBorderBottomRightRadius.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitBorderRadius.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitBorderTopLeftRadius.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitBorderTopRightRadius.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitBoxShadow.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitBoxSizing.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitClipPath.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitColumnCount.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitColumnGap.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitColumnRule.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitColumnRuleColor.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitColumnRuleStyle.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitColumnRuleWidth.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitColumnSpan.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitColumnWidth.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitColumns.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitFilter.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitFlex.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitFlexBasis.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitFlexDirection.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitFlexFlow.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitFlexGrow.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitFlexShrink.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitFlexWrap.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitFontFeatureSettings.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitHyphenateCharacter.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitJustifyContent.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitOpacity.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitOrder.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitPerspective.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitPerspectiveOrigin.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitShapeImageThreshold.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitShapeMargin.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitShapeOutside.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitTextEmphasis.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitTextEmphasisColor.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitTextEmphasisPosition.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitTextEmphasisStyle.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitTextSizeAdjust.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitTransform.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitTransformOrigin.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitTransformStyle.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitTransition.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitTransitionDelay.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitTransitionDuration.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitTransitionProperty.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitTransitionTimingFunction.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWebkitUserSelect.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasWordWrap.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasGridColumnGap.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasGridRowGap.
    static_cast<uint16_t>(CSSPropertyID::kInvalid),  // kAliasGridGap.
};

// Same check as for kPropertyVisitedIDs.
static_assert(static_cast<size_t>(CSSPropertyID::kInvalid) < 65536);
static_assert(static_cast<size_t>(CSSPropertyID::kColor) < 65536);
static_assert(static_cast<size_t>(CSSPropertyID::kInternalForcedColor) < 65536);
static_assert(static_cast<size_t>(CSSPropertyID::kBackgroundColor) < 65536);
static_assert(static_cast<size_t>(CSSPropertyID::kBorderBlockEndColor) < 65536);
static_assert(static_cast<size_t>(CSSPropertyID::kBorderBlockStartColor) < 65536);
static_assert(static_cast<size_t>(CSSPropertyID::kBorderBottomColor) < 65536);
static_assert(static_cast<size_t>(CSSPropertyID::kBorderInlineEndColor) < 65536);
static_assert(static_cast<size_t>(CSSPropertyID::kBorderInlineStartColor) < 65536);
static_assert(static_cast<size_t>(CSSPropertyID::kBorderLeftColor) < 65536);
static_assert(static_cast<size_t>(CSSPropertyID::kBorderRightColor) < 65536);
static_assert(static_cast<size_t>(CSSPropertyID::kBorderTopColor) < 65536);
static_assert(static_cast<size_t>(CSSPropertyID::kCaretColor) < 65536);
static_assert(static_cast<size_t>(CSSPropertyID::kColumnRuleColor) < 65536);
static_assert(static_cast<size_t>(CSSPropertyID::kFill) < 65536);
static_assert(static_cast<size_t>(CSSPropertyID::kOutlineColor) < 65536);
static_assert(static_cast<size_t>(CSSPropertyID::kStroke) < 65536);
static_assert(static_cast<size_t>(CSSPropertyID::kTextDecorationColor) < 65536);
static_assert(static_cast<size_t>(CSSPropertyID::kTextEmphasisColor) < 65536);
static_assert(static_cast<size_t>(CSSPropertyID::kWebkitTextFillColor) < 65536);
static_assert(static_cast<size_t>(CSSPropertyID::kWebkitTextStrokeColor) < 65536);
}  // namespace webf
