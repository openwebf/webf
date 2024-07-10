// Copyright 2019 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_LONGHANDS_H
#define WEBF_LONGHANDS_H

#include "core/css/properties/longhand.h"

namespace webf {

class ComputedStyle;
class CSSParserContext;
class CSSParserLocalContext;
class CSSValue;
class LayoutObject;
class Node;

namespace css_longhand {

// color-scheme
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ColorScheme final : public Longhand {
 public:
  constexpr ColorScheme() : Longhand(CSSPropertyID::kColorScheme, kProperty | kInherited | kIdempotent | kValidForKeyframe | kValidForPermissionElement | kValidForHighlightLegacy, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
//  const CSSValue* InitialValue() const override;
//  void ApplyInitial(StyleResolverState&) const override;
//  void ApplyInherit(StyleResolverState&) const override;
//  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// forced-color-adjust
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ForcedColorAdjust final : public Longhand {
 public:
  constexpr ForcedColorAdjust() : Longhand(CSSPropertyID::kForcedColorAdjust, kProperty | kInherited | kIdempotent | kValidForKeyframe | kValidForPermissionElement | kValidForHighlightLegacy, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// mask-image
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class MaskImage final : public Longhand {
 public:
  constexpr MaskImage() : Longhand(CSSPropertyID::kMaskImage, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// math-depth
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class MathDepth final : public Longhand {
 public:
  constexpr MathDepth() : Longhand(CSSPropertyID::kMathDepth, kProperty | kInherited | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// position
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Position final : public Longhand {
 public:
  constexpr Position() : Longhand(CSSPropertyID::kPosition, kProperty | kIdempotent | kValidForKeyframe | kValidForPermissionElement, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// position-anchor
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class PositionAnchor final : public Longhand {
 public:
  constexpr PositionAnchor() : Longhand(CSSPropertyID::kPositionAnchor, kProperty | kIdempotent | kValidForKeyframe | kValidForPositionTry | kValidForPermissionElement, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// text-size-adjust
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class TextSizeAdjust final : public Longhand {
 public:
  constexpr TextSizeAdjust() : Longhand(CSSPropertyID::kTextSizeAdjust, kInterpolable | kProperty | kInherited | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// appearance
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Appearance final : public Longhand {
 public:
  constexpr Appearance() : Longhand(CSSPropertyID::kAppearance, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// color
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Color final : public Longhand {
 public:
  constexpr Color() : Longhand(CSSPropertyID::kColor, kInterpolable | kProperty | kInherited | kSupportsIncrementalStyle | kIdempotent | kValidForFirstLetter | kValidForFirstLine | kValidForCue | kValidForMarker | kValidForFormattedText | kValidForFormattedTextRun | kValidForKeyframe | kValidForPageContext | kValidForPermissionElement | kHighlightColors | kValidForHighlightLegacy | kValidForHighlight, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const webf::Color ColorIncludingFallback(bool, const ComputedStyle&, bool* is_current_color = nullptr) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// direction
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Direction final : public Longhand {
 public:
  constexpr Direction() : Longhand(CSSPropertyID::kDirection, kProperty | kInherited | kIdempotent | kValidForMarker | kValidForFormattedText | kValidForFormattedTextRun | kValidForKeyframe | kValidForPageContext, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool IsAffectedByAll() const override { return false; }
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// font-family
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class FontFamily final : public Longhand {
 public:
  constexpr FontFamily() : Longhand(CSSPropertyID::kFontFamily, kDescriptor | kProperty | kInherited | kIdempotent | kValidForFirstLetter | kValidForFirstLine | kValidForCue | kValidForMarker | kValidForFormattedText | kValidForFormattedTextRun | kValidForKeyframe | kValidForPageContext | kAffectsFont, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// font-feature-settings
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class FontFeatureSettings final : public Longhand {
 public:
  constexpr FontFeatureSettings() : Longhand(CSSPropertyID::kFontFeatureSettings, kDescriptor | kProperty | kInherited | kIdempotent | kValidForFirstLetter | kValidForFirstLine | kValidForMarker | kValidForFormattedText | kValidForFormattedTextRun | kValidForKeyframe | kValidForPermissionElement | kAffectsFont, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// font-kerning
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class FontKerning final : public Longhand {
 public:
  constexpr FontKerning() : Longhand(CSSPropertyID::kFontKerning, kProperty | kInherited | kIdempotent | kValidForFirstLetter | kValidForFirstLine | kValidForMarker | kValidForFormattedText | kValidForFormattedTextRun | kValidForKeyframe | kValidForPageContext | kValidForPermissionElement | kAffectsFont, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// font-optical-sizing
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class FontOpticalSizing final : public Longhand {
 public:
  constexpr FontOpticalSizing() : Longhand(CSSPropertyID::kFontOpticalSizing, kProperty | kInherited | kIdempotent | kValidForFirstLetter | kValidForFirstLine | kValidForMarker | kValidForKeyframe | kValidForPageContext | kValidForPermissionElement | kAffectsFont, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// font-palette
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class FontPalette final : public Longhand {
 public:
  constexpr FontPalette() : Longhand(CSSPropertyID::kFontPalette, kInterpolable | kProperty | kInherited | kIdempotent | kValidForFirstLetter | kValidForFirstLine | kValidForMarker | kValidForKeyframe | kValidForPageContext | kAffectsFont, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// font-size
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class FontSize final : public Longhand {
 public:
  constexpr FontSize() : Longhand(CSSPropertyID::kFontSize, kInterpolable | kProperty | kInherited | kIdempotent | kValidForFirstLetter | kValidForFirstLine | kValidForCue | kValidForMarker | kValidForFormattedText | kValidForFormattedTextRun | kValidForKeyframe | kValidForPageContext | kValidForPermissionElement | kAffectsFont, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// font-size-adjust
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class FontSizeAdjust final : public Longhand {
 public:
  constexpr FontSizeAdjust() : Longhand(CSSPropertyID::kFontSizeAdjust, kInterpolable | kProperty | kInherited | kIdempotent | kValidForFirstLetter | kValidForFirstLine | kValidForMarker | kValidForKeyframe | kValidForPageContext | kAffectsFont, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// font-stretch
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class FontStretch final : public Longhand {
 public:
  constexpr FontStretch() : Longhand(CSSPropertyID::kFontStretch, kInterpolable | kDescriptor | kProperty | kInherited | kIdempotent | kValidForFirstLetter | kValidForFirstLine | kValidForCue | kValidForMarker | kValidForFormattedText | kValidForFormattedTextRun | kValidForKeyframe | kValidForPageContext | kValidForPermissionElement | kAffectsFont, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// font-style
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class FontStyle final : public Longhand {
 public:
  constexpr FontStyle() : Longhand(CSSPropertyID::kFontStyle, kInterpolable | kDescriptor | kProperty | kInherited | kIdempotent | kValidForFirstLetter | kValidForFirstLine | kValidForCue | kValidForMarker | kValidForFormattedText | kValidForFormattedTextRun | kValidForKeyframe | kValidForPageContext | kValidForPermissionElement | kAffectsFont, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// font-synthesis-small-caps
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class FontSynthesisSmallCaps final : public Longhand {
 public:
  constexpr FontSynthesisSmallCaps() : Longhand(CSSPropertyID::kFontSynthesisSmallCaps, kProperty | kInherited | kIdempotent | kValidForFirstLetter | kValidForFirstLine | kValidForMarker | kValidForKeyframe | kValidForPermissionElement | kAffectsFont, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// font-synthesis-style
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class FontSynthesisStyle final : public Longhand {
 public:
  constexpr FontSynthesisStyle() : Longhand(CSSPropertyID::kFontSynthesisStyle, kProperty | kInherited | kIdempotent | kValidForFirstLetter | kValidForFirstLine | kValidForMarker | kValidForKeyframe | kValidForPermissionElement | kAffectsFont, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// font-synthesis-weight
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class FontSynthesisWeight final : public Longhand {
 public:
  constexpr FontSynthesisWeight() : Longhand(CSSPropertyID::kFontSynthesisWeight, kProperty | kInherited | kIdempotent | kValidForFirstLetter | kValidForFirstLine | kValidForMarker | kValidForKeyframe | kValidForPermissionElement | kAffectsFont, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// font-variant-alternates
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class FontVariantAlternates final : public Longhand {
 public:
  constexpr FontVariantAlternates() : Longhand(CSSPropertyID::kFontVariantAlternates, kProperty | kInherited | kIdempotent | kValidForFirstLetter | kValidForFirstLine | kValidForMarker | kValidForFormattedText | kValidForFormattedTextRun | kValidForKeyframe | kAffectsFont, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// font-variant-caps
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class FontVariantCaps final : public Longhand {
 public:
  constexpr FontVariantCaps() : Longhand(CSSPropertyID::kFontVariantCaps, kProperty | kInherited | kIdempotent | kValidForFirstLetter | kValidForFirstLine | kValidForMarker | kValidForFormattedText | kValidForFormattedTextRun | kValidForKeyframe | kAffectsFont, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// font-variant-east-asian
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class FontVariantEastAsian final : public Longhand {
 public:
  constexpr FontVariantEastAsian() : Longhand(CSSPropertyID::kFontVariantEastAsian, kProperty | kInherited | kIdempotent | kValidForFirstLetter | kValidForFirstLine | kValidForMarker | kValidForFormattedText | kValidForFormattedTextRun | kValidForKeyframe | kAffectsFont, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// font-variant-emoji
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class FontVariantEmoji final : public Longhand {
 public:
  constexpr FontVariantEmoji() : Longhand(CSSPropertyID::kFontVariantEmoji, kProperty | kInherited | kIdempotent | kValidForFirstLetter | kValidForFirstLine | kValidForMarker | kValidForKeyframe | kAffectsFont, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// font-variant-ligatures
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class FontVariantLigatures final : public Longhand {
 public:
  constexpr FontVariantLigatures() : Longhand(CSSPropertyID::kFontVariantLigatures, kProperty | kInherited | kIdempotent | kValidForFirstLetter | kValidForFirstLine | kValidForMarker | kValidForFormattedText | kValidForFormattedTextRun | kValidForKeyframe | kAffectsFont, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// font-variant-numeric
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class FontVariantNumeric final : public Longhand {
 public:
  constexpr FontVariantNumeric() : Longhand(CSSPropertyID::kFontVariantNumeric, kProperty | kInherited | kIdempotent | kValidForFirstLetter | kValidForFirstLine | kValidForMarker | kValidForFormattedText | kValidForFormattedTextRun | kValidForKeyframe | kAffectsFont, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// font-variant-position
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class FontVariantPosition final : public Longhand {
 public:
  constexpr FontVariantPosition() : Longhand(CSSPropertyID::kFontVariantPosition, kProperty | kInherited | kIdempotent | kValidForFirstLetter | kValidForFirstLine | kValidForMarker | kValidForKeyframe | kAffectsFont, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// font-variation-settings
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class FontVariationSettings final : public Longhand {
 public:
  constexpr FontVariationSettings() : Longhand(CSSPropertyID::kFontVariationSettings, kInterpolable | kProperty | kInherited | kIdempotent | kValidForFirstLetter | kValidForFirstLine | kValidForCue | kValidForMarker | kValidForFormattedText | kValidForFormattedTextRun | kValidForKeyframe | kAffectsFont, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// font-weight
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class FontWeight final : public Longhand {
 public:
  constexpr FontWeight() : Longhand(CSSPropertyID::kFontWeight, kInterpolable | kDescriptor | kProperty | kInherited | kIdempotent | kValidForFirstLetter | kValidForFirstLine | kValidForCue | kValidForMarker | kValidForFormattedText | kValidForFormattedTextRun | kValidForKeyframe | kValidForPageContext | kValidForPermissionElement | kAffectsFont, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// inset-area
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class InsetArea final : public Longhand {
 public:
  constexpr InsetArea() : Longhand(CSSPropertyID::kInsetArea, kProperty | kIdempotent | kValidForKeyframe | kValidForPositionTry | kValidForPermissionElement, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// -internal-visited-color
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class InternalVisitedColor final : public Longhand {
 public:
  constexpr InternalVisitedColor() : Longhand(CSSPropertyID::kInternalVisitedColor, kProperty | kInherited | kVisited | kInternal | kIdempotent | kValidForFirstLetter | kValidForFirstLine | kValidForCue | kValidForMarker | kValidForKeyframe | kVisitedHighlightColors | kValidForHighlightLegacy | kValidForHighlight, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const webf::Color ColorIncludingFallback(bool, const ComputedStyle&, bool* is_current_color = nullptr) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// text-orientation
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class TextOrientation final : public Longhand {
 public:
  constexpr TextOrientation() : Longhand(CSSPropertyID::kTextOrientation, kProperty | kInherited | kIdempotent | kValidForFormattedText | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// text-rendering
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class TextRendering final : public Longhand {
 public:
  constexpr TextRendering() : Longhand(CSSPropertyID::kTextRendering, kProperty | kInherited | kIdempotent | kValidForKeyframe | kValidForPermissionElement | kAffectsFont, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// text-spacing-trim
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class TextSpacingTrim final : public Longhand {
 public:
  constexpr TextSpacingTrim() : Longhand(CSSPropertyID::kTextSpacingTrim, kProperty | kInherited | kIdempotent | kValidForKeyframe | kValidForPermissionElement | kAffectsFont, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// -webkit-font-smoothing
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitFontSmoothing final : public Longhand {
 public:
  constexpr WebkitFontSmoothing() : Longhand(CSSPropertyID::kWebkitFontSmoothing, kProperty | kInherited | kIdempotent | kValidForFirstLetter | kValidForFirstLine | kValidForKeyframe | kValidForPermissionElement | kAffectsFont, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// -webkit-locale
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitLocale final : public Longhand {
 public:
  constexpr WebkitLocale() : Longhand(CSSPropertyID::kWebkitLocale, kProperty | kInherited | kIdempotent | kValidForKeyframe | kAffectsFont, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// -webkit-text-orientation
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitTextOrientation final : public Longhand {
 public:
  constexpr WebkitTextOrientation() : Longhand(CSSPropertyID::kWebkitTextOrientation, kProperty | kInherited | kIdempotent | kValidForKeyframe | kSurrogate, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// -webkit-writing-mode
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitWritingMode final : public Longhand {
 public:
  constexpr WebkitWritingMode() : Longhand(CSSPropertyID::kWebkitWritingMode, kProperty | kInherited | kIdempotent | kValidForKeyframe | kSurrogate, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// writing-mode
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WritingMode final : public Longhand {
 public:
  constexpr WritingMode() : Longhand(CSSPropertyID::kWritingMode, kProperty | kInherited | kIdempotent | kValidForFormattedText | kValidForKeyframe | kValidForPageContext, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// zoom
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Zoom final : public Longhand {
 public:
  constexpr Zoom() : Longhand(CSSPropertyID::kZoom, kProperty | kIdempotent | kValidForKeyframe | kValidForPermissionElement, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// accent-color
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class AccentColor final : public Longhand {
 public:
  constexpr AccentColor() : Longhand(CSSPropertyID::kAccentColor, kInterpolable | kProperty | kInherited | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// additive-symbols
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class AdditiveSymbols final : public Longhand {
 public:
  constexpr AdditiveSymbols() : Longhand(CSSPropertyID::kAdditiveSymbols, kDescriptor | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// align-content
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class AlignContent final : public Longhand {
 public:
  constexpr AlignContent() : Longhand(CSSPropertyID::kAlignContent, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// align-items
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class AlignItems final : public Longhand {
 public:
  constexpr AlignItems() : Longhand(CSSPropertyID::kAlignItems, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// align-self
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class AlignSelf final : public Longhand {
 public:
  constexpr AlignSelf() : Longhand(CSSPropertyID::kAlignSelf, kProperty | kIdempotent | kValidForKeyframe | kValidForPositionTry | kValidForPermissionElement, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// alignment-baseline
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class AlignmentBaseline final : public Longhand {
 public:
  constexpr AlignmentBaseline() : Longhand(CSSPropertyID::kAlignmentBaseline, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// all
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class All final : public Longhand {
 public:
  constexpr All() : Longhand(CSSPropertyID::kAll, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool IsAffectedByAll() const override { return false; }
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// anchor-name
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class AnchorName final : public Longhand {
 public:
  constexpr AnchorName() : Longhand(CSSPropertyID::kAnchorName, kProperty | kIdempotent | kValidForKeyframe | kValidForPermissionElement, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// anchor-scope
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class AnchorScope final : public Longhand {
 public:
  constexpr AnchorScope() : Longhand(CSSPropertyID::kAnchorScope, kProperty | kIdempotent | kValidForKeyframe | kValidForPermissionElement, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// animation-composition
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class AnimationComposition final : public Longhand {
 public:
  constexpr AnimationComposition() : Longhand(CSSPropertyID::kAnimationComposition, kProperty | kIdempotent | kValidForMarker | kValidForKeyframe, ',') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const CSSValue* InitialValue() const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// animation-delay
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class AnimationDelay final : public Longhand {
 public:
  constexpr AnimationDelay() : Longhand(CSSPropertyID::kAnimationDelay, kProperty | kAnimation | kIdempotent | kValidForMarker, ',') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const CSSValue* InitialValue() const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// animation-direction
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class AnimationDirection final : public Longhand {
 public:
  constexpr AnimationDirection() : Longhand(CSSPropertyID::kAnimationDirection, kProperty | kAnimation | kIdempotent | kValidForMarker, ',') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const CSSValue* InitialValue() const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// animation-duration
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class AnimationDuration final : public Longhand {
 public:
  constexpr AnimationDuration() : Longhand(CSSPropertyID::kAnimationDuration, kProperty | kAnimation | kIdempotent | kValidForMarker, ',') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const CSSValue* InitialValue() const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// animation-fill-mode
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class AnimationFillMode final : public Longhand {
 public:
  constexpr AnimationFillMode() : Longhand(CSSPropertyID::kAnimationFillMode, kProperty | kAnimation | kIdempotent | kValidForMarker, ',') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const CSSValue* InitialValue() const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// animation-iteration-count
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class AnimationIterationCount final : public Longhand {
 public:
  constexpr AnimationIterationCount() : Longhand(CSSPropertyID::kAnimationIterationCount, kProperty | kAnimation | kIdempotent | kValidForMarker, ',') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const CSSValue* InitialValue() const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// animation-name
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class AnimationName final : public Longhand {
 public:
  constexpr AnimationName() : Longhand(CSSPropertyID::kAnimationName, kProperty | kAnimation | kIdempotent | kValidForMarker, ',') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const CSSValue* InitialValue() const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// animation-play-state
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class AnimationPlayState final : public Longhand {
 public:
  constexpr AnimationPlayState() : Longhand(CSSPropertyID::kAnimationPlayState, kProperty | kAnimation | kIdempotent | kValidForMarker, ',') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const CSSValue* InitialValue() const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// animation-range-end
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class AnimationRangeEnd final : public Longhand {
 public:
  constexpr AnimationRangeEnd() : Longhand(CSSPropertyID::kAnimationRangeEnd, kProperty | kAnimation | kIdempotent | kValidForMarker, ',') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const CSSValue* InitialValue() const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// animation-range-start
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class AnimationRangeStart final : public Longhand {
 public:
  constexpr AnimationRangeStart() : Longhand(CSSPropertyID::kAnimationRangeStart, kProperty | kAnimation | kIdempotent | kValidForMarker, ',') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const CSSValue* InitialValue() const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// animation-timeline
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class AnimationTimeline final : public Longhand {
 public:
  constexpr AnimationTimeline() : Longhand(CSSPropertyID::kAnimationTimeline, kProperty | kAnimation | kIdempotent | kValidForMarker | kValidForKeyframe, ',') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const CSSValue* InitialValue() const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// animation-timing-function
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class AnimationTimingFunction final : public Longhand {
 public:
  constexpr AnimationTimingFunction() : Longhand(CSSPropertyID::kAnimationTimingFunction, kProperty | kAnimation | kIdempotent | kValidForMarker | kValidForKeyframe, ',') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const CSSValue* InitialValue() const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// app-region
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class AppRegion final : public Longhand {
 public:
  constexpr AppRegion() : Longhand(CSSPropertyID::kAppRegion, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// ascent-override
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class AscentOverride final : public Longhand {
 public:
  constexpr AscentOverride() : Longhand(CSSPropertyID::kAscentOverride, kDescriptor | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// aspect-ratio
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class AspectRatio final : public Longhand {
 public:
  constexpr AspectRatio() : Longhand(CSSPropertyID::kAspectRatio, kInterpolable | kProperty | kIdempotent | kValidForKeyframe | kValidForPermissionElement, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// backdrop-filter
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BackdropFilter final : public Longhand {
 public:
  constexpr BackdropFilter() : Longhand(CSSPropertyID::kBackdropFilter, kInterpolable | kCompositableProperty | kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// backface-visibility
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BackfaceVisibility final : public Longhand {
 public:
  constexpr BackfaceVisibility() : Longhand(CSSPropertyID::kBackfaceVisibility, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// background-attachment
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BackgroundAttachment final : public Longhand {
 public:
  constexpr BackgroundAttachment() : Longhand(CSSPropertyID::kBackgroundAttachment, kProperty | kSupportsIncrementalStyle | kIdempotent | kValidForFirstLetter | kValidForFirstLine | kValidForCue | kValidForKeyframe | kValidForPageContext | kBackground, ' ') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// background-blend-mode
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BackgroundBlendMode final : public Longhand {
 public:
  constexpr BackgroundBlendMode() : Longhand(CSSPropertyID::kBackgroundBlendMode, kProperty | kIdempotent | kValidForFirstLetter | kValidForFirstLine | kValidForKeyframe | kValidForPageContext, ' ') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// background-clip
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BackgroundClip final : public Longhand {
 public:
  constexpr BackgroundClip() : Longhand(CSSPropertyID::kBackgroundClip, kProperty | kSupportsIncrementalStyle | kIdempotent | kValidForFirstLetter | kValidForFirstLine | kValidForCue | kValidForKeyframe | kValidForPageContext | kBackground, ' ') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// background-color
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BackgroundColor final : public Longhand {
 public:
  constexpr BackgroundColor() : Longhand(CSSPropertyID::kBackgroundColor, kInterpolable | kCompositableProperty | kProperty | kSupportsIncrementalStyle | kIdempotent | kValidForFirstLetter | kValidForFirstLine | kValidForCue | kValidForKeyframe | kValidForPageContext | kValidForPermissionElement | kBackground | kHighlightColors | kValidForHighlightLegacy | kValidForHighlight, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const webf::Color ColorIncludingFallback(bool, const ComputedStyle&, bool* is_current_color = nullptr) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// background-image
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BackgroundImage final : public Longhand {
 public:
  constexpr BackgroundImage() : Longhand(CSSPropertyID::kBackgroundImage, kInterpolable | kProperty | kSupportsIncrementalStyle | kIdempotent | kValidForFirstLetter | kValidForFirstLine | kValidForCue | kValidForKeyframe | kValidForPageContext | kBackground, ' ') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// background-origin
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BackgroundOrigin final : public Longhand {
 public:
  constexpr BackgroundOrigin() : Longhand(CSSPropertyID::kBackgroundOrigin, kProperty | kSupportsIncrementalStyle | kIdempotent | kValidForFirstLetter | kValidForFirstLine | kValidForCue | kValidForKeyframe | kValidForPageContext | kBackground, ' ') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// background-position-x
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BackgroundPositionX final : public Longhand {
 public:
  constexpr BackgroundPositionX() : Longhand(CSSPropertyID::kBackgroundPositionX, kInterpolable | kProperty | kSupportsIncrementalStyle | kIdempotent | kValidForFirstLetter | kValidForFirstLine | kValidForCue | kValidForKeyframe | kValidForPageContext | kBackground, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// background-position-y
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BackgroundPositionY final : public Longhand {
 public:
  constexpr BackgroundPositionY() : Longhand(CSSPropertyID::kBackgroundPositionY, kInterpolable | kProperty | kSupportsIncrementalStyle | kIdempotent | kValidForFirstLetter | kValidForFirstLine | kValidForCue | kValidForKeyframe | kValidForPageContext | kBackground, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// background-repeat
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BackgroundRepeat final : public Longhand {
 public:
  constexpr BackgroundRepeat() : Longhand(CSSPropertyID::kBackgroundRepeat, kProperty | kSupportsIncrementalStyle | kIdempotent | kValidForFirstLetter | kValidForFirstLine | kValidForCue | kValidForKeyframe | kValidForPageContext, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// background-size
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BackgroundSize final : public Longhand {
 public:
  constexpr BackgroundSize() : Longhand(CSSPropertyID::kBackgroundSize, kInterpolable | kProperty | kSupportsIncrementalStyle | kIdempotent | kValidForFirstLetter | kValidForFirstLine | kValidForCue | kValidForKeyframe | kValidForPageContext | kBackground, ' ') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// base-palette
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BasePalette final : public Longhand {
 public:
  constexpr BasePalette() : Longhand(CSSPropertyID::kBasePalette, kDescriptor | kIdempotent | kValidForKeyframe | kValidForPermissionElement, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// baseline-shift
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BaselineShift final : public Longhand {
 public:
  constexpr BaselineShift() : Longhand(CSSPropertyID::kBaselineShift, kInterpolable | kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// baseline-source
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BaselineSource final : public Longhand {
 public:
  constexpr BaselineSource() : Longhand(CSSPropertyID::kBaselineSource, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// block-size
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BlockSize final : public Longhand {
 public:
  constexpr BlockSize() : Longhand(CSSPropertyID::kBlockSize, kProperty | kIdempotent | kValidForKeyframe | kValidForPositionTry | kValidForPageContext | kValidForPermissionElement | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool IsLayoutDependentProperty() const override { return true; }
  bool IsLayoutDependent(const ComputedStyle*, LayoutObject*) const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  const CSSProperty& ResolveDirectionAwarePropertyInternal(
      TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(
      const ComputedStyle&,
      const LayoutObject*,
      bool allow_visited_style,
      CSSValuePhase value_phase) const override {
    // Directional properties are resolved by CSSDirectionAwareResolver
    // before calling CSSValueFromComputedStyleInternal.
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return nullptr;
  }
};

// border-block-end-color
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BorderBlockEndColor final : public Longhand {
 public:
  constexpr BorderBlockEndColor() : Longhand(CSSPropertyID::kBorderBlockEndColor, kProperty | kIdempotent | kValidForFirstLetter | kValidForKeyframe | kValidForPageContext | kValidForPermissionElement | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  const CSSProperty& ResolveDirectionAwarePropertyInternal(
      TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(
      const ComputedStyle&,
      const LayoutObject*,
      bool allow_visited_style,
      CSSValuePhase value_phase) const override {
    // Directional properties are resolved by CSSDirectionAwareResolver
    // before calling CSSValueFromComputedStyleInternal.
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return nullptr;
  }
};

// border-block-end-style
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BorderBlockEndStyle final : public Longhand {
 public:
  constexpr BorderBlockEndStyle() : Longhand(CSSPropertyID::kBorderBlockEndStyle, kProperty | kIdempotent | kValidForFirstLetter | kValidForKeyframe | kValidForPageContext | kValidForPermissionElement | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  const CSSProperty& ResolveDirectionAwarePropertyInternal(
      TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(
      const ComputedStyle&,
      const LayoutObject*,
      bool allow_visited_style,
      CSSValuePhase value_phase) const override {
    // Directional properties are resolved by CSSDirectionAwareResolver
    // before calling CSSValueFromComputedStyleInternal.
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return nullptr;
  }
};

// border-block-end-width
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BorderBlockEndWidth final : public Longhand {
 public:
  constexpr BorderBlockEndWidth() : Longhand(CSSPropertyID::kBorderBlockEndWidth, kProperty | kIdempotent | kValidForFirstLetter | kValidForKeyframe | kValidForPageContext | kValidForPermissionElement | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  const CSSProperty& ResolveDirectionAwarePropertyInternal(
      TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(
      const ComputedStyle&,
      const LayoutObject*,
      bool allow_visited_style,
      CSSValuePhase value_phase) const override {
    // Directional properties are resolved by CSSDirectionAwareResolver
    // before calling CSSValueFromComputedStyleInternal.
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return nullptr;
  }
};

// border-block-start-color
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BorderBlockStartColor final : public Longhand {
 public:
  constexpr BorderBlockStartColor() : Longhand(CSSPropertyID::kBorderBlockStartColor, kProperty | kIdempotent | kValidForFirstLetter | kValidForKeyframe | kValidForPageContext | kValidForPermissionElement | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  const CSSProperty& ResolveDirectionAwarePropertyInternal(
      TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(
      const ComputedStyle&,
      const LayoutObject*,
      bool allow_visited_style,
      CSSValuePhase value_phase) const override {
    // Directional properties are resolved by CSSDirectionAwareResolver
    // before calling CSSValueFromComputedStyleInternal.
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return nullptr;
  }
};

// border-block-start-style
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BorderBlockStartStyle final : public Longhand {
 public:
  constexpr BorderBlockStartStyle() : Longhand(CSSPropertyID::kBorderBlockStartStyle, kProperty | kIdempotent | kValidForFirstLetter | kValidForKeyframe | kValidForPageContext | kValidForPermissionElement | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  const CSSProperty& ResolveDirectionAwarePropertyInternal(
      TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(
      const ComputedStyle&,
      const LayoutObject*,
      bool allow_visited_style,
      CSSValuePhase value_phase) const override {
    // Directional properties are resolved by CSSDirectionAwareResolver
    // before calling CSSValueFromComputedStyleInternal.
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return nullptr;
  }
};

// border-block-start-width
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BorderBlockStartWidth final : public Longhand {
 public:
  constexpr BorderBlockStartWidth() : Longhand(CSSPropertyID::kBorderBlockStartWidth, kProperty | kIdempotent | kValidForFirstLetter | kValidForKeyframe | kValidForPageContext | kValidForPermissionElement | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  const CSSProperty& ResolveDirectionAwarePropertyInternal(
      TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(
      const ComputedStyle&,
      const LayoutObject*,
      bool allow_visited_style,
      CSSValuePhase value_phase) const override {
    // Directional properties are resolved by CSSDirectionAwareResolver
    // before calling CSSValueFromComputedStyleInternal.
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return nullptr;
  }
};

// border-bottom-color
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BorderBottomColor final : public Longhand {
 public:
  constexpr BorderBottomColor() : Longhand(CSSPropertyID::kBorderBottomColor, kInterpolable | kProperty | kSupportsIncrementalStyle | kIdempotent | kValidForFirstLetter | kValidForKeyframe | kValidForPageContext | kValidForPermissionElement | kBorder | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const webf::Color ColorIncludingFallback(bool, const ComputedStyle&, bool* is_current_color = nullptr) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// border-bottom-left-radius
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BorderBottomLeftRadius final : public Longhand {
 public:
  constexpr BorderBottomLeftRadius() : Longhand(CSSPropertyID::kBorderBottomLeftRadius, kInterpolable | kProperty | kIdempotent | kValidForFirstLetter | kValidForKeyframe | kValidForPageContext | kValidForPermissionElement | kBorder | kBorderRadius | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// border-bottom-right-radius
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BorderBottomRightRadius final : public Longhand {
 public:
  constexpr BorderBottomRightRadius() : Longhand(CSSPropertyID::kBorderBottomRightRadius, kInterpolable | kProperty | kIdempotent | kValidForFirstLetter | kValidForKeyframe | kValidForPageContext | kValidForPermissionElement | kBorder | kBorderRadius | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// border-bottom-style
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BorderBottomStyle final : public Longhand {
 public:
  constexpr BorderBottomStyle() : Longhand(CSSPropertyID::kBorderBottomStyle, kProperty | kIdempotent | kValidForFirstLetter | kValidForKeyframe | kValidForPageContext | kValidForPermissionElement | kBorder | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// border-bottom-width
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BorderBottomWidth final : public Longhand {
 public:
  constexpr BorderBottomWidth() : Longhand(CSSPropertyID::kBorderBottomWidth, kInterpolable | kProperty | kIdempotent | kOverlapping | kValidForFirstLetter | kValidForKeyframe | kValidForPageContext | kValidForPermissionElement | kBorder | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// border-collapse
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BorderCollapse final : public Longhand {
 public:
  constexpr BorderCollapse() : Longhand(CSSPropertyID::kBorderCollapse, kProperty | kInherited | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// border-end-end-radius
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BorderEndEndRadius final : public Longhand {
 public:
  constexpr BorderEndEndRadius() : Longhand(CSSPropertyID::kBorderEndEndRadius, kProperty | kIdempotent | kValidForFirstLetter | kValidForKeyframe | kValidForPageContext | kValidForPermissionElement | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  const CSSProperty& ResolveDirectionAwarePropertyInternal(
      TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(
      const ComputedStyle&,
      const LayoutObject*,
      bool allow_visited_style,
      CSSValuePhase value_phase) const override {
    // Directional properties are resolved by CSSDirectionAwareResolver
    // before calling CSSValueFromComputedStyleInternal.
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return nullptr;
  }
};

// border-end-start-radius
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BorderEndStartRadius final : public Longhand {
 public:
  constexpr BorderEndStartRadius() : Longhand(CSSPropertyID::kBorderEndStartRadius, kProperty | kIdempotent | kValidForFirstLetter | kValidForKeyframe | kValidForPageContext | kValidForPermissionElement | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  const CSSProperty& ResolveDirectionAwarePropertyInternal(
      TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(
      const ComputedStyle&,
      const LayoutObject*,
      bool allow_visited_style,
      CSSValuePhase value_phase) const override {
    // Directional properties are resolved by CSSDirectionAwareResolver
    // before calling CSSValueFromComputedStyleInternal.
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return nullptr;
  }
};

// border-image-outset
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BorderImageOutset final : public Longhand {
 public:
  constexpr BorderImageOutset() : Longhand(CSSPropertyID::kBorderImageOutset, kInterpolable | kProperty | kIdempotent | kOverlapping | kValidForFirstLetter | kValidForKeyframe | kBorder, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const CSSValue* InitialValue() const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// border-image-repeat
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BorderImageRepeat final : public Longhand {
 public:
  constexpr BorderImageRepeat() : Longhand(CSSPropertyID::kBorderImageRepeat, kProperty | kIdempotent | kOverlapping | kValidForFirstLetter | kValidForKeyframe | kBorder, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const CSSValue* InitialValue() const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// border-image-slice
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BorderImageSlice final : public Longhand {
 public:
  constexpr BorderImageSlice() : Longhand(CSSPropertyID::kBorderImageSlice, kInterpolable | kProperty | kIdempotent | kOverlapping | kValidForFirstLetter | kValidForKeyframe | kBorder, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const CSSValue* InitialValue() const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// border-image-source
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BorderImageSource final : public Longhand {
 public:
  constexpr BorderImageSource() : Longhand(CSSPropertyID::kBorderImageSource, kInterpolable | kProperty | kIdempotent | kOverlapping | kValidForFirstLetter | kValidForKeyframe | kBorder, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const CSSValue* InitialValue() const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// border-image-width
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BorderImageWidth final : public Longhand {
 public:
  constexpr BorderImageWidth() : Longhand(CSSPropertyID::kBorderImageWidth, kInterpolable | kProperty | kIdempotent | kOverlapping | kValidForFirstLetter | kValidForKeyframe | kBorder, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const CSSValue* InitialValue() const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// border-inline-end-color
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BorderInlineEndColor final : public Longhand {
 public:
  constexpr BorderInlineEndColor() : Longhand(CSSPropertyID::kBorderInlineEndColor, kProperty | kIdempotent | kValidForFirstLetter | kValidForKeyframe | kValidForPageContext | kValidForPermissionElement | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  const CSSProperty& ResolveDirectionAwarePropertyInternal(
      TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(
      const ComputedStyle&,
      const LayoutObject*,
      bool allow_visited_style,
      CSSValuePhase value_phase) const override {
    // Directional properties are resolved by CSSDirectionAwareResolver
    // before calling CSSValueFromComputedStyleInternal.
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return nullptr;
  }
};

// border-inline-end-style
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BorderInlineEndStyle final : public Longhand {
 public:
  constexpr BorderInlineEndStyle() : Longhand(CSSPropertyID::kBorderInlineEndStyle, kProperty | kIdempotent | kValidForFirstLetter | kValidForKeyframe | kValidForPageContext | kValidForPermissionElement | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  const CSSProperty& ResolveDirectionAwarePropertyInternal(
      TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(
      const ComputedStyle&,
      const LayoutObject*,
      bool allow_visited_style,
      CSSValuePhase value_phase) const override {
    // Directional properties are resolved by CSSDirectionAwareResolver
    // before calling CSSValueFromComputedStyleInternal.
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return nullptr;
  }
};

// border-inline-end-width
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BorderInlineEndWidth final : public Longhand {
 public:
  constexpr BorderInlineEndWidth() : Longhand(CSSPropertyID::kBorderInlineEndWidth, kProperty | kIdempotent | kValidForFirstLetter | kValidForKeyframe | kValidForPageContext | kValidForPermissionElement | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  const CSSProperty& ResolveDirectionAwarePropertyInternal(
      TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(
      const ComputedStyle&,
      const LayoutObject*,
      bool allow_visited_style,
      CSSValuePhase value_phase) const override {
    // Directional properties are resolved by CSSDirectionAwareResolver
    // before calling CSSValueFromComputedStyleInternal.
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return nullptr;
  }
};

// border-inline-start-color
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BorderInlineStartColor final : public Longhand {
 public:
  constexpr BorderInlineStartColor() : Longhand(CSSPropertyID::kBorderInlineStartColor, kProperty | kIdempotent | kValidForFirstLetter | kValidForKeyframe | kValidForPageContext | kValidForPermissionElement | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  const CSSProperty& ResolveDirectionAwarePropertyInternal(
      TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(
      const ComputedStyle&,
      const LayoutObject*,
      bool allow_visited_style,
      CSSValuePhase value_phase) const override {
    // Directional properties are resolved by CSSDirectionAwareResolver
    // before calling CSSValueFromComputedStyleInternal.
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return nullptr;
  }
};

// border-inline-start-style
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BorderInlineStartStyle final : public Longhand {
 public:
  constexpr BorderInlineStartStyle() : Longhand(CSSPropertyID::kBorderInlineStartStyle, kProperty | kIdempotent | kValidForFirstLetter | kValidForKeyframe | kValidForPageContext | kValidForPermissionElement | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  const CSSProperty& ResolveDirectionAwarePropertyInternal(
      TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(
      const ComputedStyle&,
      const LayoutObject*,
      bool allow_visited_style,
      CSSValuePhase value_phase) const override {
    // Directional properties are resolved by CSSDirectionAwareResolver
    // before calling CSSValueFromComputedStyleInternal.
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return nullptr;
  }
};

// border-inline-start-width
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BorderInlineStartWidth final : public Longhand {
 public:
  constexpr BorderInlineStartWidth() : Longhand(CSSPropertyID::kBorderInlineStartWidth, kProperty | kIdempotent | kValidForFirstLetter | kValidForKeyframe | kValidForPageContext | kValidForPermissionElement | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  const CSSProperty& ResolveDirectionAwarePropertyInternal(
      TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(
      const ComputedStyle&,
      const LayoutObject*,
      bool allow_visited_style,
      CSSValuePhase value_phase) const override {
    // Directional properties are resolved by CSSDirectionAwareResolver
    // before calling CSSValueFromComputedStyleInternal.
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return nullptr;
  }
};

// border-left-color
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BorderLeftColor final : public Longhand {
 public:
  constexpr BorderLeftColor() : Longhand(CSSPropertyID::kBorderLeftColor, kInterpolable | kProperty | kSupportsIncrementalStyle | kIdempotent | kValidForFirstLetter | kValidForKeyframe | kValidForPageContext | kValidForPermissionElement | kBorder | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const webf::Color ColorIncludingFallback(bool, const ComputedStyle&, bool* is_current_color = nullptr) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// border-left-style
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BorderLeftStyle final : public Longhand {
 public:
  constexpr BorderLeftStyle() : Longhand(CSSPropertyID::kBorderLeftStyle, kProperty | kIdempotent | kValidForFirstLetter | kValidForKeyframe | kValidForPageContext | kValidForPermissionElement | kBorder | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// border-left-width
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BorderLeftWidth final : public Longhand {
 public:
  constexpr BorderLeftWidth() : Longhand(CSSPropertyID::kBorderLeftWidth, kInterpolable | kProperty | kIdempotent | kOverlapping | kValidForFirstLetter | kValidForKeyframe | kValidForPageContext | kValidForPermissionElement | kBorder | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// border-right-color
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BorderRightColor final : public Longhand {
 public:
  constexpr BorderRightColor() : Longhand(CSSPropertyID::kBorderRightColor, kInterpolable | kProperty | kSupportsIncrementalStyle | kIdempotent | kValidForFirstLetter | kValidForKeyframe | kValidForPageContext | kValidForPermissionElement | kBorder | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const webf::Color ColorIncludingFallback(bool, const ComputedStyle&, bool* is_current_color = nullptr) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// border-right-style
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BorderRightStyle final : public Longhand {
 public:
  constexpr BorderRightStyle() : Longhand(CSSPropertyID::kBorderRightStyle, kProperty | kIdempotent | kValidForFirstLetter | kValidForKeyframe | kValidForPageContext | kValidForPermissionElement | kBorder | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// border-right-width
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BorderRightWidth final : public Longhand {
 public:
  constexpr BorderRightWidth() : Longhand(CSSPropertyID::kBorderRightWidth, kInterpolable | kProperty | kIdempotent | kOverlapping | kValidForFirstLetter | kValidForKeyframe | kValidForPageContext | kValidForPermissionElement | kBorder | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// border-start-end-radius
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BorderStartEndRadius final : public Longhand {
 public:
  constexpr BorderStartEndRadius() : Longhand(CSSPropertyID::kBorderStartEndRadius, kProperty | kIdempotent | kValidForFirstLetter | kValidForKeyframe | kValidForPageContext | kValidForPermissionElement | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  const CSSProperty& ResolveDirectionAwarePropertyInternal(
      TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(
      const ComputedStyle&,
      const LayoutObject*,
      bool allow_visited_style,
      CSSValuePhase value_phase) const override {
    // Directional properties are resolved by CSSDirectionAwareResolver
    // before calling CSSValueFromComputedStyleInternal.
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return nullptr;
  }
};

// border-start-start-radius
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BorderStartStartRadius final : public Longhand {
 public:
  constexpr BorderStartStartRadius() : Longhand(CSSPropertyID::kBorderStartStartRadius, kProperty | kIdempotent | kValidForFirstLetter | kValidForKeyframe | kValidForPageContext | kValidForPermissionElement | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  const CSSProperty& ResolveDirectionAwarePropertyInternal(
      TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(
      const ComputedStyle&,
      const LayoutObject*,
      bool allow_visited_style,
      CSSValuePhase value_phase) const override {
    // Directional properties are resolved by CSSDirectionAwareResolver
    // before calling CSSValueFromComputedStyleInternal.
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return nullptr;
  }
};

// border-top-color
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BorderTopColor final : public Longhand {
 public:
  constexpr BorderTopColor() : Longhand(CSSPropertyID::kBorderTopColor, kInterpolable | kProperty | kSupportsIncrementalStyle | kIdempotent | kValidForFirstLetter | kValidForKeyframe | kValidForPageContext | kValidForPermissionElement | kBorder | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const webf::Color ColorIncludingFallback(bool, const ComputedStyle&, bool* is_current_color = nullptr) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// border-top-left-radius
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BorderTopLeftRadius final : public Longhand {
 public:
  constexpr BorderTopLeftRadius() : Longhand(CSSPropertyID::kBorderTopLeftRadius, kInterpolable | kProperty | kIdempotent | kValidForFirstLetter | kValidForKeyframe | kValidForPageContext | kValidForPermissionElement | kBorder | kBorderRadius | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// border-top-right-radius
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BorderTopRightRadius final : public Longhand {
 public:
  constexpr BorderTopRightRadius() : Longhand(CSSPropertyID::kBorderTopRightRadius, kInterpolable | kProperty | kIdempotent | kValidForFirstLetter | kValidForKeyframe | kValidForPageContext | kValidForPermissionElement | kBorder | kBorderRadius | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// border-top-style
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BorderTopStyle final : public Longhand {
 public:
  constexpr BorderTopStyle() : Longhand(CSSPropertyID::kBorderTopStyle, kProperty | kSupportsIncrementalStyle | kIdempotent | kValidForFirstLetter | kValidForKeyframe | kValidForPageContext | kValidForPermissionElement | kBorder | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// border-top-width
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BorderTopWidth final : public Longhand {
 public:
  constexpr BorderTopWidth() : Longhand(CSSPropertyID::kBorderTopWidth, kInterpolable | kProperty | kIdempotent | kOverlapping | kValidForFirstLetter | kValidForKeyframe | kValidForPageContext | kValidForPermissionElement | kBorder | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// bottom
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Bottom final : public Longhand {
 public:
  constexpr Bottom() : Longhand(CSSPropertyID::kBottom, kInterpolable | kProperty | kSupportsIncrementalStyle | kIdempotent | kValidForKeyframe | kValidForPositionTry | kValidForPermissionElement | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool IsLayoutDependentProperty() const override { return true; }
  bool IsLayoutDependent(const ComputedStyle*, LayoutObject*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// box-shadow
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BoxShadow final : public Longhand {
 public:
  constexpr BoxShadow() : Longhand(CSSPropertyID::kBoxShadow, kInterpolable | kProperty | kIdempotent | kValidForFirstLetter | kValidForFirstLine | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// box-sizing
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BoxSizing final : public Longhand {
 public:
  constexpr BoxSizing() : Longhand(CSSPropertyID::kBoxSizing, kProperty | kIdempotent | kValidForKeyframe | kValidForPageContext | kValidForPermissionElement, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// break-after
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BreakAfter final : public Longhand {
 public:
  constexpr BreakAfter() : Longhand(CSSPropertyID::kBreakAfter, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// break-before
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BreakBefore final : public Longhand {
 public:
  constexpr BreakBefore() : Longhand(CSSPropertyID::kBreakBefore, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// break-inside
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BreakInside final : public Longhand {
 public:
  constexpr BreakInside() : Longhand(CSSPropertyID::kBreakInside, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// buffered-rendering
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BufferedRendering final : public Longhand {
 public:
  constexpr BufferedRendering() : Longhand(CSSPropertyID::kBufferedRendering, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// caption-side
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class CaptionSide final : public Longhand {
 public:
  constexpr CaptionSide() : Longhand(CSSPropertyID::kCaptionSide, kProperty | kInherited | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// caret-color
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class CaretColor final : public Longhand {
 public:
  constexpr CaretColor() : Longhand(CSSPropertyID::kCaretColor, kInterpolable | kProperty | kInherited | kIdempotent | kValidForKeyframe | kValidForHighlightLegacy, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const webf::Color ColorIncludingFallback(bool, const ComputedStyle&, bool* is_current_color = nullptr) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// clear
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Clear final : public Longhand {
 public:
  constexpr Clear() : Longhand(CSSPropertyID::kClear, kProperty | kIdempotent | kValidForKeyframe | kValidForPermissionElement, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// clip
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Clip final : public Longhand {
 public:
  constexpr Clip() : Longhand(CSSPropertyID::kClip, kInterpolable | kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// clip-path
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ClipPath final : public Longhand {
 public:
  constexpr ClipPath() : Longhand(CSSPropertyID::kClipPath, kInterpolable | kCompositableProperty | kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// clip-rule
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ClipRule final : public Longhand {
 public:
  constexpr ClipRule() : Longhand(CSSPropertyID::kClipRule, kProperty | kInherited | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// color-interpolation
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ColorInterpolation final : public Longhand {
 public:
  constexpr ColorInterpolation() : Longhand(CSSPropertyID::kColorInterpolation, kProperty | kInherited | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// color-interpolation-filters
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ColorInterpolationFilters final : public Longhand {
 public:
  constexpr ColorInterpolationFilters() : Longhand(CSSPropertyID::kColorInterpolationFilters, kProperty | kInherited | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// color-rendering
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ColorRendering final : public Longhand {
 public:
  constexpr ColorRendering() : Longhand(CSSPropertyID::kColorRendering, kProperty | kInherited | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// column-count
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ColumnCount final : public Longhand {
 public:
  constexpr ColumnCount() : Longhand(CSSPropertyID::kColumnCount, kInterpolable | kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// column-fill
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ColumnFill final : public Longhand {
 public:
  constexpr ColumnFill() : Longhand(CSSPropertyID::kColumnFill, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// column-gap
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ColumnGap final : public Longhand {
 public:
  constexpr ColumnGap() : Longhand(CSSPropertyID::kColumnGap, kInterpolable | kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// column-rule-color
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ColumnRuleColor final : public Longhand {
 public:
  constexpr ColumnRuleColor() : Longhand(CSSPropertyID::kColumnRuleColor, kInterpolable | kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const webf::Color ColorIncludingFallback(bool, const ComputedStyle&, bool* is_current_color = nullptr) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// column-rule-style
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ColumnRuleStyle final : public Longhand {
 public:
  constexpr ColumnRuleStyle() : Longhand(CSSPropertyID::kColumnRuleStyle, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// column-rule-width
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ColumnRuleWidth final : public Longhand {
 public:
  constexpr ColumnRuleWidth() : Longhand(CSSPropertyID::kColumnRuleWidth, kInterpolable | kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// column-span
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ColumnSpan final : public Longhand {
 public:
  constexpr ColumnSpan() : Longhand(CSSPropertyID::kColumnSpan, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// column-width
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ColumnWidth final : public Longhand {
 public:
  constexpr ColumnWidth() : Longhand(CSSPropertyID::kColumnWidth, kInterpolable | kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// contain
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Contain final : public Longhand {
 public:
  constexpr Contain() : Longhand(CSSPropertyID::kContain, kProperty | kIdempotent | kValidForKeyframe | kValidForPermissionElement, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// contain-intrinsic-block-size
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ContainIntrinsicBlockSize final : public Longhand {
 public:
  constexpr ContainIntrinsicBlockSize() : Longhand(CSSPropertyID::kContainIntrinsicBlockSize, kProperty | kIdempotent | kValidForKeyframe | kValidForPermissionElement | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  const CSSProperty& ResolveDirectionAwarePropertyInternal(
      TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(
      const ComputedStyle&,
      const LayoutObject*,
      bool allow_visited_style,
      CSSValuePhase value_phase) const override {
    // Directional properties are resolved by CSSDirectionAwareResolver
    // before calling CSSValueFromComputedStyleInternal.
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return nullptr;
  }
};

// contain-intrinsic-height
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ContainIntrinsicHeight final : public Longhand {
 public:
  constexpr ContainIntrinsicHeight() : Longhand(CSSPropertyID::kContainIntrinsicHeight, kInterpolable | kProperty | kIdempotent | kValidForKeyframe | kValidForPermissionElement, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// contain-intrinsic-inline-size
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ContainIntrinsicInlineSize final : public Longhand {
 public:
  constexpr ContainIntrinsicInlineSize() : Longhand(CSSPropertyID::kContainIntrinsicInlineSize, kProperty | kIdempotent | kValidForKeyframe | kValidForPermissionElement | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  const CSSProperty& ResolveDirectionAwarePropertyInternal(
      TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(
      const ComputedStyle&,
      const LayoutObject*,
      bool allow_visited_style,
      CSSValuePhase value_phase) const override {
    // Directional properties are resolved by CSSDirectionAwareResolver
    // before calling CSSValueFromComputedStyleInternal.
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return nullptr;
  }
};

// contain-intrinsic-width
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ContainIntrinsicWidth final : public Longhand {
 public:
  constexpr ContainIntrinsicWidth() : Longhand(CSSPropertyID::kContainIntrinsicWidth, kInterpolable | kProperty | kIdempotent | kValidForKeyframe | kValidForPermissionElement, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// container-name
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ContainerName final : public Longhand {
 public:
  constexpr ContainerName() : Longhand(CSSPropertyID::kContainerName, kProperty | kIdempotent | kValidForKeyframe | kValidForPermissionElement, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// container-type
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ContainerType final : public Longhand {
 public:
  constexpr ContainerType() : Longhand(CSSPropertyID::kContainerType, kProperty | kIdempotent | kValidForKeyframe | kValidForPermissionElement, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// content
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Content final : public Longhand {
 public:
  constexpr Content() : Longhand(CSSPropertyID::kContent, kProperty | kSupportsIncrementalStyle | kIdempotent | kValidForMarker | kValidForKeyframe | kValidForPageContext, ',') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// content-visibility
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ContentVisibility final : public Longhand {
 public:
  constexpr ContentVisibility() : Longhand(CSSPropertyID::kContentVisibility, kProperty | kIdempotent | kValidForKeyframe | kValidForPermissionElement, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// counter-increment
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class CounterIncrement final : public Longhand {
 public:
  constexpr CounterIncrement() : Longhand(CSSPropertyID::kCounterIncrement, kProperty | kIdempotent | kValidForKeyframe | kValidForPageContext | kValidForPermissionElement, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// counter-reset
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class CounterReset final : public Longhand {
 public:
  constexpr CounterReset() : Longhand(CSSPropertyID::kCounterReset, kProperty | kIdempotent | kValidForKeyframe | kValidForPageContext | kValidForPermissionElement, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// counter-set
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class CounterSet final : public Longhand {
 public:
  constexpr CounterSet() : Longhand(CSSPropertyID::kCounterSet, kProperty | kIdempotent | kValidForKeyframe | kValidForPageContext | kValidForPermissionElement, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// cursor
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Cursor final : public Longhand {
 public:
  constexpr Cursor() : Longhand(CSSPropertyID::kCursor, kProperty | kInherited | kIdempotent | kValidForKeyframe | kValidForPermissionElement | kValidForHighlightLegacy, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// cx
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Cx final : public Longhand {
 public:
  constexpr Cx() : Longhand(CSSPropertyID::kCx, kInterpolable | kProperty | kSupportsIncrementalStyle | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// cy
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Cy final : public Longhand {
 public:
  constexpr Cy() : Longhand(CSSPropertyID::kCy, kInterpolable | kProperty | kSupportsIncrementalStyle | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// d
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class D final : public Longhand {
 public:
  constexpr D() : Longhand(CSSPropertyID::kD, kInterpolable | kProperty | kSupportsIncrementalStyle | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// descent-override
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class DescentOverride final : public Longhand {
 public:
  constexpr DescentOverride() : Longhand(CSSPropertyID::kDescentOverride, kDescriptor | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// display
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Display final : public Longhand {
 public:
  constexpr Display() : Longhand(CSSPropertyID::kDisplay, kProperty | kIdempotent | kValidForKeyframe | kValidForPermissionElement, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// dominant-baseline
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class DominantBaseline final : public Longhand {
 public:
  constexpr DominantBaseline() : Longhand(CSSPropertyID::kDominantBaseline, kProperty | kInherited | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// dynamic-range-limit
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class DynamicRangeLimit final : public Longhand {
 public:
  constexpr DynamicRangeLimit() : Longhand(CSSPropertyID::kDynamicRangeLimit, kInterpolable | kProperty | kInherited | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// empty-cells
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class EmptyCells final : public Longhand {
 public:
  constexpr EmptyCells() : Longhand(CSSPropertyID::kEmptyCells, kProperty | kInherited | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// fallback
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Fallback final : public Longhand {
 public:
  constexpr Fallback() : Longhand(CSSPropertyID::kFallback, kDescriptor | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// field-sizing
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class FieldSizing final : public Longhand {
 public:
  constexpr FieldSizing() : Longhand(CSSPropertyID::kFieldSizing, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// fill
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Fill final : public Longhand {
 public:
  constexpr Fill() : Longhand(CSSPropertyID::kFill, kInterpolable | kProperty | kInherited | kIdempotent | kValidForKeyframe | kValidForHighlightLegacy | kValidForHighlight, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const webf::Color ColorIncludingFallback(bool, const ComputedStyle&, bool* is_current_color = nullptr) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// fill-opacity
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class FillOpacity final : public Longhand {
 public:
  constexpr FillOpacity() : Longhand(CSSPropertyID::kFillOpacity, kInterpolable | kProperty | kInherited | kIdempotent | kAcceptsNumericLiteral | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// fill-rule
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class FillRule final : public Longhand {
 public:
  constexpr FillRule() : Longhand(CSSPropertyID::kFillRule, kProperty | kInherited | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// filter
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Filter final : public Longhand {
 public:
  constexpr Filter() : Longhand(CSSPropertyID::kFilter, kInterpolable | kCompositableProperty | kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// flex-basis
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class FlexBasis final : public Longhand {
 public:
  constexpr FlexBasis() : Longhand(CSSPropertyID::kFlexBasis, kInterpolable | kProperty | kIdempotent | kValidForKeyframe | kValidForPermissionElement, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// flex-direction
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class FlexDirection final : public Longhand {
 public:
  constexpr FlexDirection() : Longhand(CSSPropertyID::kFlexDirection, kProperty | kIdempotent | kValidForKeyframe | kValidForPermissionElement, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const CSSValue* InitialValue() const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// flex-grow
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class FlexGrow final : public Longhand {
 public:
  constexpr FlexGrow() : Longhand(CSSPropertyID::kFlexGrow, kInterpolable | kProperty | kIdempotent | kValidForKeyframe | kValidForPermissionElement, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// flex-shrink
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class FlexShrink final : public Longhand {
 public:
  constexpr FlexShrink() : Longhand(CSSPropertyID::kFlexShrink, kInterpolable | kProperty | kIdempotent | kValidForKeyframe | kValidForPermissionElement, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// flex-wrap
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class FlexWrap final : public Longhand {
 public:
  constexpr FlexWrap() : Longhand(CSSPropertyID::kFlexWrap, kProperty | kIdempotent | kValidForKeyframe | kValidForPermissionElement, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const CSSValue* InitialValue() const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// float
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Float final : public Longhand {
 public:
  constexpr Float() : Longhand(CSSPropertyID::kFloat, kProperty | kIdempotent | kValidForFirstLetter | kValidForKeyframe | kValidForPermissionElement, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// flood-color
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class FloodColor final : public Longhand {
 public:
  constexpr FloodColor() : Longhand(CSSPropertyID::kFloodColor, kInterpolable | kProperty | kSupportsIncrementalStyle | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const webf::Color ColorIncludingFallback(bool, const ComputedStyle&, bool* is_current_color = nullptr) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// flood-opacity
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class FloodOpacity final : public Longhand {
 public:
  constexpr FloodOpacity() : Longhand(CSSPropertyID::kFloodOpacity, kInterpolable | kProperty | kSupportsIncrementalStyle | kIdempotent | kAcceptsNumericLiteral | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// font-display
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class FontDisplay final : public Longhand {
 public:
  constexpr FontDisplay() : Longhand(CSSPropertyID::kFontDisplay, kDescriptor | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// grid-auto-columns
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class GridAutoColumns final : public Longhand {
 public:
  constexpr GridAutoColumns() : Longhand(CSSPropertyID::kGridAutoColumns, kProperty | kIdempotent | kValidForKeyframe, ' ') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const CSSValue* InitialValue() const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// grid-auto-flow
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class GridAutoFlow final : public Longhand {
 public:
  constexpr GridAutoFlow() : Longhand(CSSPropertyID::kGridAutoFlow, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const CSSValue* InitialValue() const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// grid-auto-rows
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class GridAutoRows final : public Longhand {
 public:
  constexpr GridAutoRows() : Longhand(CSSPropertyID::kGridAutoRows, kProperty | kIdempotent | kValidForKeyframe, ' ') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const CSSValue* InitialValue() const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// grid-column-end
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class GridColumnEnd final : public Longhand {
 public:
  constexpr GridColumnEnd() : Longhand(CSSPropertyID::kGridColumnEnd, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// grid-column-start
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class GridColumnStart final : public Longhand {
 public:
  constexpr GridColumnStart() : Longhand(CSSPropertyID::kGridColumnStart, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// grid-row-end
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class GridRowEnd final : public Longhand {
 public:
  constexpr GridRowEnd() : Longhand(CSSPropertyID::kGridRowEnd, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// grid-row-start
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class GridRowStart final : public Longhand {
 public:
  constexpr GridRowStart() : Longhand(CSSPropertyID::kGridRowStart, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// grid-template-areas
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class GridTemplateAreas final : public Longhand {
 public:
  constexpr GridTemplateAreas() : Longhand(CSSPropertyID::kGridTemplateAreas, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const CSSValue* InitialValue() const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// grid-template-columns
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class GridTemplateColumns final : public Longhand {
 public:
  constexpr GridTemplateColumns() : Longhand(CSSPropertyID::kGridTemplateColumns, kInterpolable | kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool IsLayoutDependentProperty() const override { return true; }
  bool IsLayoutDependent(const ComputedStyle*, LayoutObject*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const CSSValue* InitialValue() const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// grid-template-rows
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class GridTemplateRows final : public Longhand {
 public:
  constexpr GridTemplateRows() : Longhand(CSSPropertyID::kGridTemplateRows, kInterpolable | kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool IsLayoutDependentProperty() const override { return true; }
  bool IsLayoutDependent(const ComputedStyle*, LayoutObject*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const CSSValue* InitialValue() const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// height
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Height final : public Longhand {
 public:
  constexpr Height() : Longhand(CSSPropertyID::kHeight, kInterpolable | kProperty | kSupportsIncrementalStyle | kIdempotent | kValidForFormattedText | kValidForKeyframe | kValidForPositionTry | kValidForPageContext | kValidForPermissionElement | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool IsLayoutDependentProperty() const override { return true; }
  bool IsLayoutDependent(const ComputedStyle*, LayoutObject*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// hyphenate-character
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class HyphenateCharacter final : public Longhand {
 public:
  constexpr HyphenateCharacter() : Longhand(CSSPropertyID::kHyphenateCharacter, kProperty | kInherited | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// hyphenate-limit-chars
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class HyphenateLimitChars final : public Longhand {
 public:
  constexpr HyphenateLimitChars() : Longhand(CSSPropertyID::kHyphenateLimitChars, kProperty | kInherited | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// hyphens
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Hyphens final : public Longhand {
 public:
  constexpr Hyphens() : Longhand(CSSPropertyID::kHyphens, kProperty | kInherited | kIdempotent | kValidForMarker | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// image-orientation
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ImageOrientation final : public Longhand {
 public:
  constexpr ImageOrientation() : Longhand(CSSPropertyID::kImageOrientation, kProperty | kInherited | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// image-rendering
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ImageRendering final : public Longhand {
 public:
  constexpr ImageRendering() : Longhand(CSSPropertyID::kImageRendering, kProperty | kInherited | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// inherits
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Inherits final : public Longhand {
 public:
  constexpr Inherits() : Longhand(CSSPropertyID::kInherits, kDescriptor | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// initial-letter
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class InitialLetter final : public Longhand {
 public:
  constexpr InitialLetter() : Longhand(CSSPropertyID::kInitialLetter, kProperty | kIdempotent | kValidForFirstLetter | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// initial-value
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class InitialValue final : public Longhand {
 public:
  constexpr InitialValue() : Longhand(CSSPropertyID::kInitialValue, kDescriptor | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// inline-size
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class InlineSize final : public Longhand {
 public:
  constexpr InlineSize() : Longhand(CSSPropertyID::kInlineSize, kProperty | kIdempotent | kValidForKeyframe | kValidForPositionTry | kValidForPageContext | kValidForPermissionElement | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool IsLayoutDependentProperty() const override { return true; }
  bool IsLayoutDependent(const ComputedStyle*, LayoutObject*) const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  const CSSProperty& ResolveDirectionAwarePropertyInternal(
      TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(
      const ComputedStyle&,
      const LayoutObject*,
      bool allow_visited_style,
      CSSValuePhase value_phase) const override {
    // Directional properties are resolved by CSSDirectionAwareResolver
    // before calling CSSValueFromComputedStyleInternal.
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return nullptr;
  }
};

// inset-block-end
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class InsetBlockEnd final : public Longhand {
 public:
  constexpr InsetBlockEnd() : Longhand(CSSPropertyID::kInsetBlockEnd, kProperty | kIdempotent | kValidForKeyframe | kValidForPositionTry | kValidForPageContext | kValidForPermissionElement | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool IsLayoutDependentProperty() const override { return true; }
  bool IsLayoutDependent(const ComputedStyle*, LayoutObject*) const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  const CSSProperty& ResolveDirectionAwarePropertyInternal(
      TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(
      const ComputedStyle&,
      const LayoutObject*,
      bool allow_visited_style,
      CSSValuePhase value_phase) const override {
    // Directional properties are resolved by CSSDirectionAwareResolver
    // before calling CSSValueFromComputedStyleInternal.
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return nullptr;
  }
};

// inset-block-start
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class InsetBlockStart final : public Longhand {
 public:
  constexpr InsetBlockStart() : Longhand(CSSPropertyID::kInsetBlockStart, kProperty | kIdempotent | kValidForKeyframe | kValidForPositionTry | kValidForPermissionElement | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool IsLayoutDependentProperty() const override { return true; }
  bool IsLayoutDependent(const ComputedStyle*, LayoutObject*) const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  const CSSProperty& ResolveDirectionAwarePropertyInternal(
      TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(
      const ComputedStyle&,
      const LayoutObject*,
      bool allow_visited_style,
      CSSValuePhase value_phase) const override {
    // Directional properties are resolved by CSSDirectionAwareResolver
    // before calling CSSValueFromComputedStyleInternal.
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return nullptr;
  }
};

// inset-inline-end
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class InsetInlineEnd final : public Longhand {
 public:
  constexpr InsetInlineEnd() : Longhand(CSSPropertyID::kInsetInlineEnd, kProperty | kIdempotent | kValidForKeyframe | kValidForPositionTry | kValidForPermissionElement | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool IsLayoutDependentProperty() const override { return true; }
  bool IsLayoutDependent(const ComputedStyle*, LayoutObject*) const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  const CSSProperty& ResolveDirectionAwarePropertyInternal(
      TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(
      const ComputedStyle&,
      const LayoutObject*,
      bool allow_visited_style,
      CSSValuePhase value_phase) const override {
    // Directional properties are resolved by CSSDirectionAwareResolver
    // before calling CSSValueFromComputedStyleInternal.
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return nullptr;
  }
};

// inset-inline-start
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class InsetInlineStart final : public Longhand {
 public:
  constexpr InsetInlineStart() : Longhand(CSSPropertyID::kInsetInlineStart, kProperty | kIdempotent | kValidForKeyframe | kValidForPositionTry | kValidForPermissionElement | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool IsLayoutDependentProperty() const override { return true; }
  bool IsLayoutDependent(const ComputedStyle*, LayoutObject*) const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  const CSSProperty& ResolveDirectionAwarePropertyInternal(
      TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(
      const ComputedStyle&,
      const LayoutObject*,
      bool allow_visited_style,
      CSSValuePhase value_phase) const override {
    // Directional properties are resolved by CSSDirectionAwareResolver
    // before calling CSSValueFromComputedStyleInternal.
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return nullptr;
  }
};

// -internal-align-content-block
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class InternalAlignContentBlock final : public Longhand {
 public:
  constexpr InternalAlignContentBlock() : Longhand(CSSPropertyID::kInternalAlignContentBlock, kProperty | kInternal | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// -internal-empty-line-height
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class InternalEmptyLineHeight final : public Longhand {
 public:
  constexpr InternalEmptyLineHeight() : Longhand(CSSPropertyID::kInternalEmptyLineHeight, kProperty | kInherited | kInternal | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// -internal-font-size-delta
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class InternalFontSizeDelta final : public Longhand {
 public:
  constexpr InternalFontSizeDelta() : Longhand(CSSPropertyID::kInternalFontSizeDelta, kProperty | kInternal | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// -internal-forced-background-color
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class InternalForcedBackgroundColor final : public Longhand {
 public:
  constexpr InternalForcedBackgroundColor() : Longhand(CSSPropertyID::kInternalForcedBackgroundColor, kProperty | kInternal | kIdempotent | kValidForFirstLetter | kValidForFirstLine | kValidForCue | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const webf::Color ColorIncludingFallback(bool, const ComputedStyle&, bool* is_current_color = nullptr) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// -internal-forced-border-color
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class InternalForcedBorderColor final : public Longhand {
 public:
  constexpr InternalForcedBorderColor() : Longhand(CSSPropertyID::kInternalForcedBorderColor, kProperty | kInternal | kIdempotent | kValidForFirstLetter | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const webf::Color ColorIncludingFallback(bool, const ComputedStyle&, bool* is_current_color = nullptr) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// -internal-forced-color
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class InternalForcedColor final : public Longhand {
 public:
  constexpr InternalForcedColor() : Longhand(CSSPropertyID::kInternalForcedColor, kProperty | kInherited | kInternal | kIdempotent | kValidForFirstLetter | kValidForFirstLine | kValidForCue | kValidForMarker | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const webf::Color ColorIncludingFallback(bool, const ComputedStyle&, bool* is_current_color = nullptr) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// -internal-forced-outline-color
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class InternalForcedOutlineColor final : public Longhand {
 public:
  constexpr InternalForcedOutlineColor() : Longhand(CSSPropertyID::kInternalForcedOutlineColor, kProperty | kInternal | kIdempotent | kValidForCue | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const webf::Color ColorIncludingFallback(bool, const ComputedStyle&, bool* is_current_color = nullptr) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// -internal-forced-visited-color
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class InternalForcedVisitedColor final : public Longhand {
 public:
  constexpr InternalForcedVisitedColor() : Longhand(CSSPropertyID::kInternalForcedVisitedColor, kProperty | kInherited | kVisited | kInternal | kIdempotent | kValidForFirstLetter | kValidForFirstLine | kValidForCue | kValidForMarker | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const webf::Color ColorIncludingFallback(bool, const ComputedStyle&, bool* is_current_color = nullptr) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// -internal-overflow-block
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class InternalOverflowBlock final : public Longhand {
 public:
  constexpr InternalOverflowBlock() : Longhand(CSSPropertyID::kInternalOverflowBlock, kProperty | kInternal | kIdempotent | kValidForKeyframe | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  const CSSProperty& ResolveDirectionAwarePropertyInternal(
      TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(
      const ComputedStyle&,
      const LayoutObject*,
      bool allow_visited_style,
      CSSValuePhase value_phase) const override {
    // Directional properties are resolved by CSSDirectionAwareResolver
    // before calling CSSValueFromComputedStyleInternal.
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return nullptr;
  }
};

// -internal-overflow-inline
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class InternalOverflowInline final : public Longhand {
 public:
  constexpr InternalOverflowInline() : Longhand(CSSPropertyID::kInternalOverflowInline, kProperty | kInternal | kIdempotent | kValidForKeyframe | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  const CSSProperty& ResolveDirectionAwarePropertyInternal(
      TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(
      const ComputedStyle&,
      const LayoutObject*,
      bool allow_visited_style,
      CSSValuePhase value_phase) const override {
    // Directional properties are resolved by CSSDirectionAwareResolver
    // before calling CSSValueFromComputedStyleInternal.
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return nullptr;
  }
};

// -internal-visited-background-color
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class InternalVisitedBackgroundColor final : public Longhand {
 public:
  constexpr InternalVisitedBackgroundColor() : Longhand(CSSPropertyID::kInternalVisitedBackgroundColor, kProperty | kVisited | kInternal | kIdempotent | kValidForFirstLetter | kValidForFirstLine | kValidForCue | kValidForKeyframe | kVisitedHighlightColors | kValidForHighlightLegacy | kValidForHighlight, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const webf::Color ColorIncludingFallback(bool, const ComputedStyle&, bool* is_current_color = nullptr) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// -internal-visited-border-block-end-color
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class InternalVisitedBorderBlockEndColor final : public Longhand {
 public:
  constexpr InternalVisitedBorderBlockEndColor() : Longhand(CSSPropertyID::kInternalVisitedBorderBlockEndColor, kProperty | kVisited | kInternal | kIdempotent | kValidForFirstLetter | kValidForKeyframe | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  const CSSProperty& ResolveDirectionAwarePropertyInternal(
      TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(
      const ComputedStyle&,
      const LayoutObject*,
      bool allow_visited_style,
      CSSValuePhase value_phase) const override {
    // Directional properties are resolved by CSSDirectionAwareResolver
    // before calling CSSValueFromComputedStyleInternal.
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return nullptr;
  }
};

// -internal-visited-border-block-start-color
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class InternalVisitedBorderBlockStartColor final : public Longhand {
 public:
  constexpr InternalVisitedBorderBlockStartColor() : Longhand(CSSPropertyID::kInternalVisitedBorderBlockStartColor, kProperty | kVisited | kInternal | kIdempotent | kValidForFirstLetter | kValidForKeyframe | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  const CSSProperty& ResolveDirectionAwarePropertyInternal(
      TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(
      const ComputedStyle&,
      const LayoutObject*,
      bool allow_visited_style,
      CSSValuePhase value_phase) const override {
    // Directional properties are resolved by CSSDirectionAwareResolver
    // before calling CSSValueFromComputedStyleInternal.
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return nullptr;
  }
};

// -internal-visited-border-bottom-color
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class InternalVisitedBorderBottomColor final : public Longhand {
 public:
  constexpr InternalVisitedBorderBottomColor() : Longhand(CSSPropertyID::kInternalVisitedBorderBottomColor, kProperty | kVisited | kInternal | kIdempotent | kValidForFirstLetter | kValidForKeyframe | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const webf::Color ColorIncludingFallback(bool, const ComputedStyle&, bool* is_current_color = nullptr) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// -internal-visited-border-inline-end-color
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class InternalVisitedBorderInlineEndColor final : public Longhand {
 public:
  constexpr InternalVisitedBorderInlineEndColor() : Longhand(CSSPropertyID::kInternalVisitedBorderInlineEndColor, kProperty | kVisited | kInternal | kIdempotent | kValidForFirstLetter | kValidForKeyframe | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  const CSSProperty& ResolveDirectionAwarePropertyInternal(
      TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(
      const ComputedStyle&,
      const LayoutObject*,
      bool allow_visited_style,
      CSSValuePhase value_phase) const override {
    // Directional properties are resolved by CSSDirectionAwareResolver
    // before calling CSSValueFromComputedStyleInternal.
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return nullptr;
  }
};

// -internal-visited-border-inline-start-color
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class InternalVisitedBorderInlineStartColor final : public Longhand {
 public:
  constexpr InternalVisitedBorderInlineStartColor() : Longhand(CSSPropertyID::kInternalVisitedBorderInlineStartColor, kProperty | kVisited | kInternal | kIdempotent | kValidForFirstLetter | kValidForKeyframe | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  const CSSProperty& ResolveDirectionAwarePropertyInternal(
      TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(
      const ComputedStyle&,
      const LayoutObject*,
      bool allow_visited_style,
      CSSValuePhase value_phase) const override {
    // Directional properties are resolved by CSSDirectionAwareResolver
    // before calling CSSValueFromComputedStyleInternal.
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return nullptr;
  }
};

// -internal-visited-border-left-color
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class InternalVisitedBorderLeftColor final : public Longhand {
 public:
  constexpr InternalVisitedBorderLeftColor() : Longhand(CSSPropertyID::kInternalVisitedBorderLeftColor, kProperty | kVisited | kInternal | kIdempotent | kValidForFirstLetter | kValidForKeyframe | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const webf::Color ColorIncludingFallback(bool, const ComputedStyle&, bool* is_current_color = nullptr) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// -internal-visited-border-right-color
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class InternalVisitedBorderRightColor final : public Longhand {
 public:
  constexpr InternalVisitedBorderRightColor() : Longhand(CSSPropertyID::kInternalVisitedBorderRightColor, kProperty | kVisited | kInternal | kIdempotent | kValidForFirstLetter | kValidForKeyframe | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const webf::Color ColorIncludingFallback(bool, const ComputedStyle&, bool* is_current_color = nullptr) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// -internal-visited-border-top-color
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class InternalVisitedBorderTopColor final : public Longhand {
 public:
  constexpr InternalVisitedBorderTopColor() : Longhand(CSSPropertyID::kInternalVisitedBorderTopColor, kProperty | kVisited | kInternal | kIdempotent | kValidForFirstLetter | kValidForKeyframe | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const webf::Color ColorIncludingFallback(bool, const ComputedStyle&, bool* is_current_color = nullptr) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// -internal-visited-caret-color
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class InternalVisitedCaretColor final : public Longhand {
 public:
  constexpr InternalVisitedCaretColor() : Longhand(CSSPropertyID::kInternalVisitedCaretColor, kProperty | kInherited | kVisited | kInternal | kIdempotent | kValidForKeyframe | kValidForHighlightLegacy, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const webf::Color ColorIncludingFallback(bool, const ComputedStyle&, bool* is_current_color = nullptr) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// -internal-visited-column-rule-color
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class InternalVisitedColumnRuleColor final : public Longhand {
 public:
  constexpr InternalVisitedColumnRuleColor() : Longhand(CSSPropertyID::kInternalVisitedColumnRuleColor, kProperty | kVisited | kInternal | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const webf::Color ColorIncludingFallback(bool, const ComputedStyle&, bool* is_current_color = nullptr) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// -internal-visited-fill
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class InternalVisitedFill final : public Longhand {
 public:
  constexpr InternalVisitedFill() : Longhand(CSSPropertyID::kInternalVisitedFill, kProperty | kInherited | kVisited | kInternal | kIdempotent | kValidForKeyframe | kValidForHighlightLegacy | kValidForHighlight, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const webf::Color ColorIncludingFallback(bool, const ComputedStyle&, bool* is_current_color = nullptr) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// -internal-visited-outline-color
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class InternalVisitedOutlineColor final : public Longhand {
 public:
  constexpr InternalVisitedOutlineColor() : Longhand(CSSPropertyID::kInternalVisitedOutlineColor, kProperty | kVisited | kInternal | kIdempotent | kValidForCue | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const webf::Color ColorIncludingFallback(bool, const ComputedStyle&, bool* is_current_color = nullptr) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// -internal-visited-stroke
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class InternalVisitedStroke final : public Longhand {
 public:
  constexpr InternalVisitedStroke() : Longhand(CSSPropertyID::kInternalVisitedStroke, kProperty | kInherited | kVisited | kInternal | kIdempotent | kValidForKeyframe | kValidForHighlightLegacy | kValidForHighlight, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const webf::Color ColorIncludingFallback(bool, const ComputedStyle&, bool* is_current_color = nullptr) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// -internal-visited-text-decoration-color
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class InternalVisitedTextDecorationColor final : public Longhand {
 public:
  constexpr InternalVisitedTextDecorationColor() : Longhand(CSSPropertyID::kInternalVisitedTextDecorationColor, kProperty | kVisited | kInternal | kIdempotent | kValidForFirstLetter | kValidForFirstLine | kValidForCue | kValidForKeyframe | kValidForHighlightLegacy | kValidForHighlight, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const webf::Color ColorIncludingFallback(bool, const ComputedStyle&, bool* is_current_color = nullptr) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// -internal-visited-text-emphasis-color
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class InternalVisitedTextEmphasisColor final : public Longhand {
 public:
  constexpr InternalVisitedTextEmphasisColor() : Longhand(CSSPropertyID::kInternalVisitedTextEmphasisColor, kProperty | kInherited | kVisited | kInternal | kIdempotent | kValidForKeyframe | kValidForHighlightLegacy | kValidForHighlight, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const webf::Color ColorIncludingFallback(bool, const ComputedStyle&, bool* is_current_color = nullptr) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// -internal-visited-text-fill-color
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class InternalVisitedTextFillColor final : public Longhand {
 public:
  constexpr InternalVisitedTextFillColor() : Longhand(CSSPropertyID::kInternalVisitedTextFillColor, kProperty | kInherited | kVisited | kInternal | kIdempotent | kValidForKeyframe | kValidForHighlightLegacy | kValidForHighlight, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const webf::Color ColorIncludingFallback(bool, const ComputedStyle&, bool* is_current_color = nullptr) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// -internal-visited-text-stroke-color
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class InternalVisitedTextStrokeColor final : public Longhand {
 public:
  constexpr InternalVisitedTextStrokeColor() : Longhand(CSSPropertyID::kInternalVisitedTextStrokeColor, kProperty | kInherited | kVisited | kInternal | kIdempotent | kValidForKeyframe | kValidForHighlightLegacy | kValidForHighlight, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const webf::Color ColorIncludingFallback(bool, const ComputedStyle&, bool* is_current_color = nullptr) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// isolation
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Isolation final : public Longhand {
 public:
  constexpr Isolation() : Longhand(CSSPropertyID::kIsolation, kProperty | kIdempotent | kValidForKeyframe | kValidForPermissionElement, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// justify-content
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class JustifyContent final : public Longhand {
 public:
  constexpr JustifyContent() : Longhand(CSSPropertyID::kJustifyContent, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// justify-items
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class JustifyItems final : public Longhand {
 public:
  constexpr JustifyItems() : Longhand(CSSPropertyID::kJustifyItems, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// justify-self
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class JustifySelf final : public Longhand {
 public:
  constexpr JustifySelf() : Longhand(CSSPropertyID::kJustifySelf, kProperty | kIdempotent | kValidForKeyframe | kValidForPositionTry | kValidForPermissionElement, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// left
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Left final : public Longhand {
 public:
  constexpr Left() : Longhand(CSSPropertyID::kLeft, kInterpolable | kProperty | kSupportsIncrementalStyle | kIdempotent | kValidForKeyframe | kValidForPositionTry | kValidForPermissionElement | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool IsLayoutDependentProperty() const override { return true; }
  bool IsLayoutDependent(const ComputedStyle*, LayoutObject*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// letter-spacing
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class LetterSpacing final : public Longhand {
 public:
  constexpr LetterSpacing() : Longhand(CSSPropertyID::kLetterSpacing, kInterpolable | kProperty | kInherited | kIdempotent | kValidForFirstLetter | kValidForFirstLine | kValidForMarker | kValidForKeyframe | kValidForPageContext | kValidForPermissionElement, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// lighting-color
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class LightingColor final : public Longhand {
 public:
  constexpr LightingColor() : Longhand(CSSPropertyID::kLightingColor, kInterpolable | kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const webf::Color ColorIncludingFallback(bool, const ComputedStyle&, bool* is_current_color = nullptr) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// line-break
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class LineBreak final : public Longhand {
 public:
  constexpr LineBreak() : Longhand(CSSPropertyID::kLineBreak, kProperty | kInherited | kIdempotent | kValidForMarker | kValidForFormattedText | kValidForKeyframe | kSurrogate, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// line-clamp
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class LineClamp final : public Longhand {
 public:
  constexpr LineClamp() : Longhand(CSSPropertyID::kLineClamp, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// line-gap-override
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class LineGapOverride final : public Longhand {
 public:
  constexpr LineGapOverride() : Longhand(CSSPropertyID::kLineGapOverride, kDescriptor | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// line-height
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class LineHeight final : public Longhand {
 public:
  constexpr LineHeight() : Longhand(CSSPropertyID::kLineHeight, kInterpolable | kProperty | kInherited | kIdempotent | kValidForFirstLetter | kValidForFirstLine | kValidForCue | kValidForMarker | kValidForKeyframe | kValidForPageContext, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// list-style-image
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ListStyleImage final : public Longhand {
 public:
  constexpr ListStyleImage() : Longhand(CSSPropertyID::kListStyleImage, kInterpolable | kProperty | kInherited | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// list-style-position
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ListStylePosition final : public Longhand {
 public:
  constexpr ListStylePosition() : Longhand(CSSPropertyID::kListStylePosition, kProperty | kInherited | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// list-style-type
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ListStyleType final : public Longhand {
 public:
  constexpr ListStyleType() : Longhand(CSSPropertyID::kListStyleType, kProperty | kInherited | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// margin-block-end
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class MarginBlockEnd final : public Longhand {
 public:
  constexpr MarginBlockEnd() : Longhand(CSSPropertyID::kMarginBlockEnd, kProperty | kIdempotent | kValidForFirstLetter | kValidForKeyframe | kValidForPositionTry | kValidForLimitedPageContext | kValidForPageContext | kValidForPermissionElement | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool IsLayoutDependentProperty() const override { return true; }
  bool IsLayoutDependent(const ComputedStyle*, LayoutObject*) const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  const CSSProperty& ResolveDirectionAwarePropertyInternal(
      TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(
      const ComputedStyle&,
      const LayoutObject*,
      bool allow_visited_style,
      CSSValuePhase value_phase) const override {
    // Directional properties are resolved by CSSDirectionAwareResolver
    // before calling CSSValueFromComputedStyleInternal.
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return nullptr;
  }
};

// margin-block-start
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class MarginBlockStart final : public Longhand {
 public:
  constexpr MarginBlockStart() : Longhand(CSSPropertyID::kMarginBlockStart, kProperty | kIdempotent | kValidForFirstLetter | kValidForKeyframe | kValidForPositionTry | kValidForLimitedPageContext | kValidForPageContext | kValidForPermissionElement | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool IsLayoutDependentProperty() const override { return true; }
  bool IsLayoutDependent(const ComputedStyle*, LayoutObject*) const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  const CSSProperty& ResolveDirectionAwarePropertyInternal(
      TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(
      const ComputedStyle&,
      const LayoutObject*,
      bool allow_visited_style,
      CSSValuePhase value_phase) const override {
    // Directional properties are resolved by CSSDirectionAwareResolver
    // before calling CSSValueFromComputedStyleInternal.
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return nullptr;
  }
};

// margin-bottom
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class MarginBottom final : public Longhand {
 public:
  constexpr MarginBottom() : Longhand(CSSPropertyID::kMarginBottom, kInterpolable | kProperty | kSupportsIncrementalStyle | kIdempotent | kValidForFirstLetter | kValidForKeyframe | kValidForPositionTry | kValidForLimitedPageContext | kValidForPageContext | kValidForPermissionElement | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool IsLayoutDependentProperty() const override { return true; }
  bool IsLayoutDependent(const ComputedStyle*, LayoutObject*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// margin-inline-end
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class MarginInlineEnd final : public Longhand {
 public:
  constexpr MarginInlineEnd() : Longhand(CSSPropertyID::kMarginInlineEnd, kProperty | kIdempotent | kValidForFirstLetter | kValidForKeyframe | kValidForPositionTry | kValidForLimitedPageContext | kValidForPageContext | kValidForPermissionElement | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool IsLayoutDependentProperty() const override { return true; }
  bool IsLayoutDependent(const ComputedStyle*, LayoutObject*) const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  const CSSProperty& ResolveDirectionAwarePropertyInternal(
      TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(
      const ComputedStyle&,
      const LayoutObject*,
      bool allow_visited_style,
      CSSValuePhase value_phase) const override {
    // Directional properties are resolved by CSSDirectionAwareResolver
    // before calling CSSValueFromComputedStyleInternal.
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return nullptr;
  }
};

// margin-inline-start
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class MarginInlineStart final : public Longhand {
 public:
  constexpr MarginInlineStart() : Longhand(CSSPropertyID::kMarginInlineStart, kProperty | kIdempotent | kValidForFirstLetter | kValidForKeyframe | kValidForPositionTry | kValidForLimitedPageContext | kValidForPageContext | kValidForPermissionElement | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool IsLayoutDependentProperty() const override { return true; }
  bool IsLayoutDependent(const ComputedStyle*, LayoutObject*) const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  const CSSProperty& ResolveDirectionAwarePropertyInternal(
      TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(
      const ComputedStyle&,
      const LayoutObject*,
      bool allow_visited_style,
      CSSValuePhase value_phase) const override {
    // Directional properties are resolved by CSSDirectionAwareResolver
    // before calling CSSValueFromComputedStyleInternal.
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return nullptr;
  }
};

// margin-left
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class MarginLeft final : public Longhand {
 public:
  constexpr MarginLeft() : Longhand(CSSPropertyID::kMarginLeft, kInterpolable | kProperty | kSupportsIncrementalStyle | kIdempotent | kValidForFirstLetter | kValidForKeyframe | kValidForPositionTry | kValidForLimitedPageContext | kValidForPageContext | kValidForPermissionElement | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool IsLayoutDependentProperty() const override { return true; }
  bool IsLayoutDependent(const ComputedStyle*, LayoutObject*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// margin-right
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class MarginRight final : public Longhand {
 public:
  constexpr MarginRight() : Longhand(CSSPropertyID::kMarginRight, kInterpolable | kProperty | kSupportsIncrementalStyle | kIdempotent | kValidForFirstLetter | kValidForKeyframe | kValidForPositionTry | kValidForLimitedPageContext | kValidForPageContext | kValidForPermissionElement | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool IsLayoutDependentProperty() const override { return true; }
  bool IsLayoutDependent(const ComputedStyle*, LayoutObject*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// margin-top
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class MarginTop final : public Longhand {
 public:
  constexpr MarginTop() : Longhand(CSSPropertyID::kMarginTop, kInterpolable | kProperty | kSupportsIncrementalStyle | kIdempotent | kValidForFirstLetter | kValidForKeyframe | kValidForPositionTry | kValidForLimitedPageContext | kValidForPageContext | kValidForPermissionElement | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool IsLayoutDependentProperty() const override { return true; }
  bool IsLayoutDependent(const ComputedStyle*, LayoutObject*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// marker-end
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class MarkerEnd final : public Longhand {
 public:
  constexpr MarkerEnd() : Longhand(CSSPropertyID::kMarkerEnd, kProperty | kInherited | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// marker-mid
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class MarkerMid final : public Longhand {
 public:
  constexpr MarkerMid() : Longhand(CSSPropertyID::kMarkerMid, kProperty | kInherited | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// marker-start
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class MarkerStart final : public Longhand {
 public:
  constexpr MarkerStart() : Longhand(CSSPropertyID::kMarkerStart, kProperty | kInherited | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// mask-clip
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class MaskClip final : public Longhand {
 public:
  constexpr MaskClip() : Longhand(CSSPropertyID::kMaskClip, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const CSSValue* InitialValue() const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// mask-composite
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class MaskComposite final : public Longhand {
 public:
  constexpr MaskComposite() : Longhand(CSSPropertyID::kMaskComposite, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const CSSValue* InitialValue() const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// mask-mode
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class MaskMode final : public Longhand {
 public:
  constexpr MaskMode() : Longhand(CSSPropertyID::kMaskMode, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const CSSValue* InitialValue() const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// mask-origin
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class MaskOrigin final : public Longhand {
 public:
  constexpr MaskOrigin() : Longhand(CSSPropertyID::kMaskOrigin, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const CSSValue* InitialValue() const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// mask-repeat
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class MaskRepeat final : public Longhand {
 public:
  constexpr MaskRepeat() : Longhand(CSSPropertyID::kMaskRepeat, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const CSSValue* InitialValue() const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// mask-size
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class MaskSize final : public Longhand {
 public:
  constexpr MaskSize() : Longhand(CSSPropertyID::kMaskSize, kInterpolable | kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const CSSValue* InitialValue() const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// mask-type
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class MaskType final : public Longhand {
 public:
  constexpr MaskType() : Longhand(CSSPropertyID::kMaskType, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// math-shift
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class MathShift final : public Longhand {
 public:
  constexpr MathShift() : Longhand(CSSPropertyID::kMathShift, kProperty | kInherited | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// math-style
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class MathStyle final : public Longhand {
 public:
  constexpr MathStyle() : Longhand(CSSPropertyID::kMathStyle, kProperty | kInherited | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// max-block-size
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class MaxBlockSize final : public Longhand {
 public:
  constexpr MaxBlockSize() : Longhand(CSSPropertyID::kMaxBlockSize, kProperty | kIdempotent | kValidForKeyframe | kValidForPositionTry | kValidForPageContext | kValidForPermissionElement | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  const CSSProperty& ResolveDirectionAwarePropertyInternal(
      TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(
      const ComputedStyle&,
      const LayoutObject*,
      bool allow_visited_style,
      CSSValuePhase value_phase) const override {
    // Directional properties are resolved by CSSDirectionAwareResolver
    // before calling CSSValueFromComputedStyleInternal.
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return nullptr;
  }
};

// max-height
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class MaxHeight final : public Longhand {
 public:
  constexpr MaxHeight() : Longhand(CSSPropertyID::kMaxHeight, kInterpolable | kProperty | kSupportsIncrementalStyle | kIdempotent | kValidForKeyframe | kValidForPositionTry | kValidForPageContext | kValidForPermissionElement | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// max-inline-size
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class MaxInlineSize final : public Longhand {
 public:
  constexpr MaxInlineSize() : Longhand(CSSPropertyID::kMaxInlineSize, kProperty | kIdempotent | kValidForKeyframe | kValidForPositionTry | kValidForPageContext | kValidForPermissionElement | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  const CSSProperty& ResolveDirectionAwarePropertyInternal(
      TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(
      const ComputedStyle&,
      const LayoutObject*,
      bool allow_visited_style,
      CSSValuePhase value_phase) const override {
    // Directional properties are resolved by CSSDirectionAwareResolver
    // before calling CSSValueFromComputedStyleInternal.
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return nullptr;
  }
};

// max-width
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class MaxWidth final : public Longhand {
 public:
  constexpr MaxWidth() : Longhand(CSSPropertyID::kMaxWidth, kInterpolable | kProperty | kSupportsIncrementalStyle | kIdempotent | kValidForKeyframe | kValidForPositionTry | kValidForPageContext | kValidForPermissionElement | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// min-block-size
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class MinBlockSize final : public Longhand {
 public:
  constexpr MinBlockSize() : Longhand(CSSPropertyID::kMinBlockSize, kProperty | kIdempotent | kValidForKeyframe | kValidForPositionTry | kValidForPageContext | kValidForPermissionElement | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  const CSSProperty& ResolveDirectionAwarePropertyInternal(
      TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(
      const ComputedStyle&,
      const LayoutObject*,
      bool allow_visited_style,
      CSSValuePhase value_phase) const override {
    // Directional properties are resolved by CSSDirectionAwareResolver
    // before calling CSSValueFromComputedStyleInternal.
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return nullptr;
  }
};

// min-height
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class MinHeight final : public Longhand {
 public:
  constexpr MinHeight() : Longhand(CSSPropertyID::kMinHeight, kInterpolable | kProperty | kSupportsIncrementalStyle | kIdempotent | kValidForKeyframe | kValidForPositionTry | kValidForPageContext | kValidForPermissionElement | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// min-inline-size
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class MinInlineSize final : public Longhand {
 public:
  constexpr MinInlineSize() : Longhand(CSSPropertyID::kMinInlineSize, kProperty | kIdempotent | kValidForKeyframe | kValidForPositionTry | kValidForPageContext | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  const CSSProperty& ResolveDirectionAwarePropertyInternal(
      TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(
      const ComputedStyle&,
      const LayoutObject*,
      bool allow_visited_style,
      CSSValuePhase value_phase) const override {
    // Directional properties are resolved by CSSDirectionAwareResolver
    // before calling CSSValueFromComputedStyleInternal.
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return nullptr;
  }
};

// min-width
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class MinWidth final : public Longhand {
 public:
  constexpr MinWidth() : Longhand(CSSPropertyID::kMinWidth, kInterpolable | kProperty | kSupportsIncrementalStyle | kIdempotent | kValidForKeyframe | kValidForPositionTry | kValidForPageContext | kValidForPermissionElement | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// mix-blend-mode
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class MixBlendMode final : public Longhand {
 public:
  constexpr MixBlendMode() : Longhand(CSSPropertyID::kMixBlendMode, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// navigation
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Navigation final : public Longhand {
 public:
  constexpr Navigation() : Longhand(CSSPropertyID::kNavigation, kDescriptor | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
};

// negative
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Negative final : public Longhand {
 public:
  constexpr Negative() : Longhand(CSSPropertyID::kNegative, kDescriptor | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// object-fit
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ObjectFit final : public Longhand {
 public:
  constexpr ObjectFit() : Longhand(CSSPropertyID::kObjectFit, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// object-position
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ObjectPosition final : public Longhand {
 public:
  constexpr ObjectPosition() : Longhand(CSSPropertyID::kObjectPosition, kInterpolable | kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// object-view-box
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ObjectViewBox final : public Longhand {
 public:
  constexpr ObjectViewBox() : Longhand(CSSPropertyID::kObjectViewBox, kInterpolable | kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// offset-anchor
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class OffsetAnchor final : public Longhand {
 public:
  constexpr OffsetAnchor() : Longhand(CSSPropertyID::kOffsetAnchor, kInterpolable | kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// offset-distance
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class OffsetDistance final : public Longhand {
 public:
  constexpr OffsetDistance() : Longhand(CSSPropertyID::kOffsetDistance, kInterpolable | kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// offset-path
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class OffsetPath final : public Longhand {
 public:
  constexpr OffsetPath() : Longhand(CSSPropertyID::kOffsetPath, kInterpolable | kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// offset-position
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class OffsetPosition final : public Longhand {
 public:
  constexpr OffsetPosition() : Longhand(CSSPropertyID::kOffsetPosition, kInterpolable | kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// offset-rotate
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class OffsetRotate final : public Longhand {
 public:
  constexpr OffsetRotate() : Longhand(CSSPropertyID::kOffsetRotate, kInterpolable | kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// opacity
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Opacity final : public Longhand {
 public:
  constexpr Opacity() : Longhand(CSSPropertyID::kOpacity, kInterpolable | kCompositableProperty | kProperty | kSupportsIncrementalStyle | kIdempotent | kAcceptsNumericLiteral | kValidForFirstLetter | kValidForFirstLine | kValidForCue | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// order
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Order final : public Longhand {
 public:
  constexpr Order() : Longhand(CSSPropertyID::kOrder, kInterpolable | kProperty | kIdempotent | kValidForKeyframe | kValidForPermissionElement, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// origin-trial-test-property
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class OriginTrialTestProperty final : public Longhand {
 public:
  constexpr OriginTrialTestProperty() : Longhand(CSSPropertyID::kOriginTrialTestProperty, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// orphans
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Orphans final : public Longhand {
 public:
  constexpr Orphans() : Longhand(CSSPropertyID::kOrphans, kInterpolable | kProperty | kInherited | kIdempotent | kValidForKeyframe | kValidForPermissionElement, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// outline-color
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class OutlineColor final : public Longhand {
 public:
  constexpr OutlineColor() : Longhand(CSSPropertyID::kOutlineColor, kInterpolable | kProperty | kIdempotent | kValidForCue | kValidForKeyframe | kValidForPageContext | kValidForPermissionElement, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const webf::Color ColorIncludingFallback(bool, const ComputedStyle&, bool* is_current_color = nullptr) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// outline-offset
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class OutlineOffset final : public Longhand {
 public:
  constexpr OutlineOffset() : Longhand(CSSPropertyID::kOutlineOffset, kInterpolable | kProperty | kIdempotent | kValidForCue | kValidForKeyframe | kValidForPageContext | kValidForPermissionElement, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// outline-style
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class OutlineStyle final : public Longhand {
 public:
  constexpr OutlineStyle() : Longhand(CSSPropertyID::kOutlineStyle, kProperty | kIdempotent | kValidForCue | kValidForKeyframe | kValidForPageContext | kValidForPermissionElement, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// outline-width
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class OutlineWidth final : public Longhand {
 public:
  constexpr OutlineWidth() : Longhand(CSSPropertyID::kOutlineWidth, kInterpolable | kProperty | kIdempotent | kValidForCue | kValidForKeyframe | kValidForPageContext | kValidForPermissionElement, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// overflow-anchor
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class OverflowAnchor final : public Longhand {
 public:
  constexpr OverflowAnchor() : Longhand(CSSPropertyID::kOverflowAnchor, kProperty | kIdempotent | kValidForKeyframe | kValidForPermissionElement, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// overflow-block
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class OverflowBlock final : public Longhand {
 public:
  constexpr OverflowBlock() : Longhand(CSSPropertyID::kOverflowBlock, kProperty | kIdempotent | kValidForKeyframe | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  const CSSProperty& ResolveDirectionAwarePropertyInternal(
      TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(
      const ComputedStyle&,
      const LayoutObject*,
      bool allow_visited_style,
      CSSValuePhase value_phase) const override {
    // Directional properties are resolved by CSSDirectionAwareResolver
    // before calling CSSValueFromComputedStyleInternal.
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return nullptr;
  }
};

// overflow-clip-margin
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class OverflowClipMargin final : public Longhand {
 public:
  constexpr OverflowClipMargin() : Longhand(CSSPropertyID::kOverflowClipMargin, kProperty | kIdempotent | kValidForKeyframe, ' ') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// overflow-inline
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class OverflowInline final : public Longhand {
 public:
  constexpr OverflowInline() : Longhand(CSSPropertyID::kOverflowInline, kProperty | kIdempotent | kValidForKeyframe | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  const CSSProperty& ResolveDirectionAwarePropertyInternal(
      TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(
      const ComputedStyle&,
      const LayoutObject*,
      bool allow_visited_style,
      CSSValuePhase value_phase) const override {
    // Directional properties are resolved by CSSDirectionAwareResolver
    // before calling CSSValueFromComputedStyleInternal.
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return nullptr;
  }
};

// overflow-wrap
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class OverflowWrap final : public Longhand {
 public:
  constexpr OverflowWrap() : Longhand(CSSPropertyID::kOverflowWrap, kProperty | kInherited | kIdempotent | kValidForMarker | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// overflow-x
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class OverflowX final : public Longhand {
 public:
  constexpr OverflowX() : Longhand(CSSPropertyID::kOverflowX, kProperty | kValidForKeyframe | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// overflow-y
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class OverflowY final : public Longhand {
 public:
  constexpr OverflowY() : Longhand(CSSPropertyID::kOverflowY, kProperty | kValidForKeyframe | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// overlay
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Overlay final : public Longhand {
 public:
  constexpr Overlay() : Longhand(CSSPropertyID::kOverlay, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// override-colors
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class OverrideColors final : public Longhand {
 public:
  constexpr OverrideColors() : Longhand(CSSPropertyID::kOverrideColors, kDescriptor | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// overscroll-behavior-block
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class OverscrollBehaviorBlock final : public Longhand {
 public:
  constexpr OverscrollBehaviorBlock() : Longhand(CSSPropertyID::kOverscrollBehaviorBlock, kProperty | kIdempotent | kValidForKeyframe | kValidForPermissionElement | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  const CSSProperty& ResolveDirectionAwarePropertyInternal(
      TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(
      const ComputedStyle&,
      const LayoutObject*,
      bool allow_visited_style,
      CSSValuePhase value_phase) const override {
    // Directional properties are resolved by CSSDirectionAwareResolver
    // before calling CSSValueFromComputedStyleInternal.
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return nullptr;
  }
};

// overscroll-behavior-inline
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class OverscrollBehaviorInline final : public Longhand {
 public:
  constexpr OverscrollBehaviorInline() : Longhand(CSSPropertyID::kOverscrollBehaviorInline, kProperty | kIdempotent | kValidForKeyframe | kValidForPermissionElement | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  const CSSProperty& ResolveDirectionAwarePropertyInternal(
      TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(
      const ComputedStyle&,
      const LayoutObject*,
      bool allow_visited_style,
      CSSValuePhase value_phase) const override {
    // Directional properties are resolved by CSSDirectionAwareResolver
    // before calling CSSValueFromComputedStyleInternal.
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return nullptr;
  }
};

// overscroll-behavior-x
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class OverscrollBehaviorX final : public Longhand {
 public:
  constexpr OverscrollBehaviorX() : Longhand(CSSPropertyID::kOverscrollBehaviorX, kProperty | kIdempotent | kValidForKeyframe | kValidForPermissionElement | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// overscroll-behavior-y
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class OverscrollBehaviorY final : public Longhand {
 public:
  constexpr OverscrollBehaviorY() : Longhand(CSSPropertyID::kOverscrollBehaviorY, kProperty | kIdempotent | kValidForKeyframe | kValidForPermissionElement | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// pad
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Pad final : public Longhand {
 public:
  constexpr Pad() : Longhand(CSSPropertyID::kPad, kDescriptor | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// padding-block-end
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class PaddingBlockEnd final : public Longhand {
 public:
  constexpr PaddingBlockEnd() : Longhand(CSSPropertyID::kPaddingBlockEnd, kProperty | kIdempotent | kValidForKeyframe | kValidForPageContext | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool IsLayoutDependentProperty() const override { return true; }
  bool IsLayoutDependent(const ComputedStyle*, LayoutObject*) const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  const CSSProperty& ResolveDirectionAwarePropertyInternal(
      TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(
      const ComputedStyle&,
      const LayoutObject*,
      bool allow_visited_style,
      CSSValuePhase value_phase) const override {
    // Directional properties are resolved by CSSDirectionAwareResolver
    // before calling CSSValueFromComputedStyleInternal.
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return nullptr;
  }
};

// padding-block-start
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class PaddingBlockStart final : public Longhand {
 public:
  constexpr PaddingBlockStart() : Longhand(CSSPropertyID::kPaddingBlockStart, kProperty | kIdempotent | kValidForKeyframe | kValidForPageContext | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool IsLayoutDependentProperty() const override { return true; }
  bool IsLayoutDependent(const ComputedStyle*, LayoutObject*) const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  const CSSProperty& ResolveDirectionAwarePropertyInternal(
      TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(
      const ComputedStyle&,
      const LayoutObject*,
      bool allow_visited_style,
      CSSValuePhase value_phase) const override {
    // Directional properties are resolved by CSSDirectionAwareResolver
    // before calling CSSValueFromComputedStyleInternal.
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return nullptr;
  }
};

// padding-bottom
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class PaddingBottom final : public Longhand {
 public:
  constexpr PaddingBottom() : Longhand(CSSPropertyID::kPaddingBottom, kInterpolable | kProperty | kSupportsIncrementalStyle | kIdempotent | kValidForFirstLetter | kValidForKeyframe | kValidForPageContext | kValidForPermissionElement | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool IsLayoutDependentProperty() const override { return true; }
  bool IsLayoutDependent(const ComputedStyle*, LayoutObject*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// padding-inline-end
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class PaddingInlineEnd final : public Longhand {
 public:
  constexpr PaddingInlineEnd() : Longhand(CSSPropertyID::kPaddingInlineEnd, kProperty | kIdempotent | kValidForKeyframe | kValidForPageContext | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool IsLayoutDependentProperty() const override { return true; }
  bool IsLayoutDependent(const ComputedStyle*, LayoutObject*) const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  const CSSProperty& ResolveDirectionAwarePropertyInternal(
      TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(
      const ComputedStyle&,
      const LayoutObject*,
      bool allow_visited_style,
      CSSValuePhase value_phase) const override {
    // Directional properties are resolved by CSSDirectionAwareResolver
    // before calling CSSValueFromComputedStyleInternal.
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return nullptr;
  }
};

// padding-inline-start
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class PaddingInlineStart final : public Longhand {
 public:
  constexpr PaddingInlineStart() : Longhand(CSSPropertyID::kPaddingInlineStart, kProperty | kIdempotent | kValidForKeyframe | kValidForPageContext | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool IsLayoutDependentProperty() const override { return true; }
  bool IsLayoutDependent(const ComputedStyle*, LayoutObject*) const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  const CSSProperty& ResolveDirectionAwarePropertyInternal(
      TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(
      const ComputedStyle&,
      const LayoutObject*,
      bool allow_visited_style,
      CSSValuePhase value_phase) const override {
    // Directional properties are resolved by CSSDirectionAwareResolver
    // before calling CSSValueFromComputedStyleInternal.
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return nullptr;
  }
};

// padding-left
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class PaddingLeft final : public Longhand {
 public:
  constexpr PaddingLeft() : Longhand(CSSPropertyID::kPaddingLeft, kInterpolable | kProperty | kSupportsIncrementalStyle | kIdempotent | kValidForFirstLetter | kValidForKeyframe | kValidForPageContext | kValidForPermissionElement | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool IsLayoutDependentProperty() const override { return true; }
  bool IsLayoutDependent(const ComputedStyle*, LayoutObject*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// padding-right
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class PaddingRight final : public Longhand {
 public:
  constexpr PaddingRight() : Longhand(CSSPropertyID::kPaddingRight, kInterpolable | kProperty | kSupportsIncrementalStyle | kIdempotent | kValidForFirstLetter | kValidForKeyframe | kValidForPageContext | kValidForPermissionElement | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool IsLayoutDependentProperty() const override { return true; }
  bool IsLayoutDependent(const ComputedStyle*, LayoutObject*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// padding-top
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class PaddingTop final : public Longhand {
 public:
  constexpr PaddingTop() : Longhand(CSSPropertyID::kPaddingTop, kInterpolable | kProperty | kSupportsIncrementalStyle | kIdempotent | kValidForFirstLetter | kValidForKeyframe | kValidForPageContext | kValidForPermissionElement | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool IsLayoutDependentProperty() const override { return true; }
  bool IsLayoutDependent(const ComputedStyle*, LayoutObject*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// page
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Page final : public Longhand {
 public:
  constexpr Page() : Longhand(CSSPropertyID::kPage, kProperty | kIdempotent | kValidForKeyframe | kValidForPermissionElement, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// page-orientation
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class PageOrientation final : public Longhand {
 public:
  constexpr PageOrientation() : Longhand(CSSPropertyID::kPageOrientation, kDescriptor | kProperty | kIdempotent | kValidForKeyframe | kValidForLimitedPageContext | kValidForPageContext, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// paint-order
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class PaintOrder final : public Longhand {
 public:
  constexpr PaintOrder() : Longhand(CSSPropertyID::kPaintOrder, kProperty | kInherited | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// perspective
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Perspective final : public Longhand {
 public:
  constexpr Perspective() : Longhand(CSSPropertyID::kPerspective, kInterpolable | kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// perspective-origin
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class PerspectiveOrigin final : public Longhand {
 public:
  constexpr PerspectiveOrigin() : Longhand(CSSPropertyID::kPerspectiveOrigin, kInterpolable | kProperty | kIdempotent | kOverlapping | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool IsLayoutDependentProperty() const override { return true; }
  bool IsLayoutDependent(const ComputedStyle*, LayoutObject*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// pointer-events
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class PointerEvents final : public Longhand {
 public:
  constexpr PointerEvents() : Longhand(CSSPropertyID::kPointerEvents, kProperty | kInherited | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// popover-hide-delay
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class PopoverHideDelay final : public Longhand {
 public:
  constexpr PopoverHideDelay() : Longhand(CSSPropertyID::kPopoverHideDelay, kInterpolable | kProperty | kSupportsIncrementalStyle | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// popover-show-delay
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class PopoverShowDelay final : public Longhand {
 public:
  constexpr PopoverShowDelay() : Longhand(CSSPropertyID::kPopoverShowDelay, kInterpolable | kProperty | kSupportsIncrementalStyle | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// position-try-options
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class PositionTryOptions final : public Longhand {
 public:
  constexpr PositionTryOptions() : Longhand(CSSPropertyID::kPositionTryOptions, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// position-try-order
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class PositionTryOrder final : public Longhand {
 public:
  constexpr PositionTryOrder() : Longhand(CSSPropertyID::kPositionTryOrder, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const CSSValue* InitialValue() const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// position-visibility
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class PositionVisibility final : public Longhand {
 public:
  constexpr PositionVisibility() : Longhand(CSSPropertyID::kPositionVisibility, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// prefix
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Prefix final : public Longhand {
 public:
  constexpr Prefix() : Longhand(CSSPropertyID::kPrefix, kDescriptor | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// quotes
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Quotes final : public Longhand {
 public:
  constexpr Quotes() : Longhand(CSSPropertyID::kQuotes, kProperty | kInherited | kIdempotent | kValidForKeyframe | kValidForPageContext, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// r
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class R final : public Longhand {
 public:
  constexpr R() : Longhand(CSSPropertyID::kR, kInterpolable | kProperty | kSupportsIncrementalStyle | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// range
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Range final : public Longhand {
 public:
  constexpr Range() : Longhand(CSSPropertyID::kRange, kDescriptor | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// reading-flow
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
//class ReadingFlow final : public Longhand {
// public:
//  constexpr ReadingFlow() : Longhand(CSSPropertyID::kReadingFlow, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
//  const char* GetPropertyName() const override;
//  const AtomicString& GetPropertyNameAtomicString() const override;
//  const char* GetJSPropertyName() const override;
//  CSSExposure Exposure(const ExecutingContext*) const override;
//  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
//  void ApplyInitial(StyleResolverState&) const override;
//  void ApplyInherit(StyleResolverState&) const override;
//  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
//};

// resize
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Resize final : public Longhand {
 public:
  constexpr Resize() : Longhand(CSSPropertyID::kResize, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// right
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Right final : public Longhand {
 public:
  constexpr Right() : Longhand(CSSPropertyID::kRight, kInterpolable | kProperty | kSupportsIncrementalStyle | kIdempotent | kValidForKeyframe | kValidForPositionTry | kValidForPermissionElement | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool IsLayoutDependentProperty() const override { return true; }
  bool IsLayoutDependent(const ComputedStyle*, LayoutObject*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// rotate
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Rotate final : public Longhand {
 public:
  constexpr Rotate() : Longhand(CSSPropertyID::kRotate, kInterpolable | kCompositableProperty | kProperty | kSupportsIncrementalStyle | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// row-gap
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class RowGap final : public Longhand {
 public:
  constexpr RowGap() : Longhand(CSSPropertyID::kRowGap, kInterpolable | kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// ruby-align
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class RubyAlign final : public Longhand {
 public:
  constexpr RubyAlign() : Longhand(CSSPropertyID::kRubyAlign, kProperty | kInherited | kIdempotent | kValidForKeyframe | kValidForPermissionElement, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// ruby-position
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class RubyPosition final : public Longhand {
 public:
  constexpr RubyPosition() : Longhand(CSSPropertyID::kRubyPosition, kProperty | kInherited | kIdempotent | kValidForFirstLine | kValidForKeyframe | kValidForPermissionElement, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// rx
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Rx final : public Longhand {
 public:
  constexpr Rx() : Longhand(CSSPropertyID::kRx, kInterpolable | kProperty | kSupportsIncrementalStyle | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// ry
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Ry final : public Longhand {
 public:
  constexpr Ry() : Longhand(CSSPropertyID::kRy, kInterpolable | kProperty | kSupportsIncrementalStyle | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// scale
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Scale final : public Longhand {
 public:
  constexpr Scale() : Longhand(CSSPropertyID::kScale, kInterpolable | kCompositableProperty | kProperty | kSupportsIncrementalStyle | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// scroll-behavior
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ScrollBehavior final : public Longhand {
 public:
  constexpr ScrollBehavior() : Longhand(CSSPropertyID::kScrollBehavior, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// scroll-margin-block-end
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ScrollMarginBlockEnd final : public Longhand {
 public:
  constexpr ScrollMarginBlockEnd() : Longhand(CSSPropertyID::kScrollMarginBlockEnd, kProperty | kIdempotent | kValidForKeyframe | kValidForPermissionElement | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  const CSSProperty& ResolveDirectionAwarePropertyInternal(
      TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(
      const ComputedStyle&,
      const LayoutObject*,
      bool allow_visited_style,
      CSSValuePhase value_phase) const override {
    // Directional properties are resolved by CSSDirectionAwareResolver
    // before calling CSSValueFromComputedStyleInternal.
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return nullptr;
  }
};

// scroll-margin-block-start
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ScrollMarginBlockStart final : public Longhand {
 public:
  constexpr ScrollMarginBlockStart() : Longhand(CSSPropertyID::kScrollMarginBlockStart, kProperty | kIdempotent | kValidForKeyframe | kValidForPermissionElement | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  const CSSProperty& ResolveDirectionAwarePropertyInternal(
      TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(
      const ComputedStyle&,
      const LayoutObject*,
      bool allow_visited_style,
      CSSValuePhase value_phase) const override {
    // Directional properties are resolved by CSSDirectionAwareResolver
    // before calling CSSValueFromComputedStyleInternal.
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return nullptr;
  }
};

// scroll-margin-bottom
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ScrollMarginBottom final : public Longhand {
 public:
  constexpr ScrollMarginBottom() : Longhand(CSSPropertyID::kScrollMarginBottom, kProperty | kIdempotent | kValidForKeyframe | kValidForPermissionElement | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// scroll-margin-inline-end
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ScrollMarginInlineEnd final : public Longhand {
 public:
  constexpr ScrollMarginInlineEnd() : Longhand(CSSPropertyID::kScrollMarginInlineEnd, kProperty | kIdempotent | kValidForKeyframe | kValidForPermissionElement | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  const CSSProperty& ResolveDirectionAwarePropertyInternal(
      TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(
      const ComputedStyle&,
      const LayoutObject*,
      bool allow_visited_style,
      CSSValuePhase value_phase) const override {
    // Directional properties are resolved by CSSDirectionAwareResolver
    // before calling CSSValueFromComputedStyleInternal.
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return nullptr;
  }
};

// scroll-margin-inline-start
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ScrollMarginInlineStart final : public Longhand {
 public:
  constexpr ScrollMarginInlineStart() : Longhand(CSSPropertyID::kScrollMarginInlineStart, kProperty | kIdempotent | kValidForKeyframe | kValidForPermissionElement | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  const CSSProperty& ResolveDirectionAwarePropertyInternal(
      TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(
      const ComputedStyle&,
      const LayoutObject*,
      bool allow_visited_style,
      CSSValuePhase value_phase) const override {
    // Directional properties are resolved by CSSDirectionAwareResolver
    // before calling CSSValueFromComputedStyleInternal.
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return nullptr;
  }
};

// scroll-margin-left
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ScrollMarginLeft final : public Longhand {
 public:
  constexpr ScrollMarginLeft() : Longhand(CSSPropertyID::kScrollMarginLeft, kProperty | kIdempotent | kValidForKeyframe | kValidForPermissionElement | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// scroll-margin-right
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ScrollMarginRight final : public Longhand {
 public:
  constexpr ScrollMarginRight() : Longhand(CSSPropertyID::kScrollMarginRight, kProperty | kIdempotent | kValidForKeyframe | kValidForPermissionElement | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// scroll-margin-top
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ScrollMarginTop final : public Longhand {
 public:
  constexpr ScrollMarginTop() : Longhand(CSSPropertyID::kScrollMarginTop, kProperty | kIdempotent | kValidForKeyframe | kValidForPermissionElement | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// scroll-markers
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ScrollMarkers final : public Longhand {
 public:
  constexpr ScrollMarkers() : Longhand(CSSPropertyID::kScrollMarkers, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// scroll-padding-block-end
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ScrollPaddingBlockEnd final : public Longhand {
 public:
  constexpr ScrollPaddingBlockEnd() : Longhand(CSSPropertyID::kScrollPaddingBlockEnd, kProperty | kIdempotent | kValidForKeyframe | kValidForPermissionElement | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  const CSSProperty& ResolveDirectionAwarePropertyInternal(
      TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(
      const ComputedStyle&,
      const LayoutObject*,
      bool allow_visited_style,
      CSSValuePhase value_phase) const override {
    // Directional properties are resolved by CSSDirectionAwareResolver
    // before calling CSSValueFromComputedStyleInternal.
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return nullptr;
  }
};

// scroll-padding-block-start
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ScrollPaddingBlockStart final : public Longhand {
 public:
  constexpr ScrollPaddingBlockStart() : Longhand(CSSPropertyID::kScrollPaddingBlockStart, kProperty | kIdempotent | kValidForKeyframe | kValidForPermissionElement | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  const CSSProperty& ResolveDirectionAwarePropertyInternal(
      TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(
      const ComputedStyle&,
      const LayoutObject*,
      bool allow_visited_style,
      CSSValuePhase value_phase) const override {
    // Directional properties are resolved by CSSDirectionAwareResolver
    // before calling CSSValueFromComputedStyleInternal.
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return nullptr;
  }
};

// scroll-padding-bottom
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ScrollPaddingBottom final : public Longhand {
 public:
  constexpr ScrollPaddingBottom() : Longhand(CSSPropertyID::kScrollPaddingBottom, kProperty | kIdempotent | kValidForKeyframe | kValidForPermissionElement | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// scroll-padding-inline-end
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ScrollPaddingInlineEnd final : public Longhand {
 public:
  constexpr ScrollPaddingInlineEnd() : Longhand(CSSPropertyID::kScrollPaddingInlineEnd, kProperty | kIdempotent | kValidForKeyframe | kValidForPermissionElement | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  const CSSProperty& ResolveDirectionAwarePropertyInternal(
      TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(
      const ComputedStyle&,
      const LayoutObject*,
      bool allow_visited_style,
      CSSValuePhase value_phase) const override {
    // Directional properties are resolved by CSSDirectionAwareResolver
    // before calling CSSValueFromComputedStyleInternal.
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return nullptr;
  }
};

// scroll-padding-inline-start
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ScrollPaddingInlineStart final : public Longhand {
 public:
  constexpr ScrollPaddingInlineStart() : Longhand(CSSPropertyID::kScrollPaddingInlineStart, kProperty | kIdempotent | kValidForKeyframe | kValidForPermissionElement | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  const CSSProperty& ResolveDirectionAwarePropertyInternal(
      TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(
      const ComputedStyle&,
      const LayoutObject*,
      bool allow_visited_style,
      CSSValuePhase value_phase) const override {
    // Directional properties are resolved by CSSDirectionAwareResolver
    // before calling CSSValueFromComputedStyleInternal.
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return nullptr;
  }
};

// scroll-padding-left
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ScrollPaddingLeft final : public Longhand {
 public:
  constexpr ScrollPaddingLeft() : Longhand(CSSPropertyID::kScrollPaddingLeft, kProperty | kIdempotent | kValidForKeyframe | kValidForPermissionElement | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// scroll-padding-right
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ScrollPaddingRight final : public Longhand {
 public:
  constexpr ScrollPaddingRight() : Longhand(CSSPropertyID::kScrollPaddingRight, kProperty | kIdempotent | kValidForKeyframe | kValidForPermissionElement | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// scroll-padding-top
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ScrollPaddingTop final : public Longhand {
 public:
  constexpr ScrollPaddingTop() : Longhand(CSSPropertyID::kScrollPaddingTop, kProperty | kIdempotent | kValidForKeyframe | kValidForPermissionElement | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// scroll-snap-align
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ScrollSnapAlign final : public Longhand {
 public:
  constexpr ScrollSnapAlign() : Longhand(CSSPropertyID::kScrollSnapAlign, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// scroll-snap-stop
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ScrollSnapStop final : public Longhand {
 public:
  constexpr ScrollSnapStop() : Longhand(CSSPropertyID::kScrollSnapStop, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// scroll-snap-type
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ScrollSnapType final : public Longhand {
 public:
  constexpr ScrollSnapType() : Longhand(CSSPropertyID::kScrollSnapType, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// scroll-start-block
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ScrollStartBlock final : public Longhand {
 public:
  constexpr ScrollStartBlock() : Longhand(CSSPropertyID::kScrollStartBlock, kProperty | kIdempotent | kValidForKeyframe | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  const CSSProperty& ResolveDirectionAwarePropertyInternal(
      TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(
      const ComputedStyle&,
      const LayoutObject*,
      bool allow_visited_style,
      CSSValuePhase value_phase) const override {
    // Directional properties are resolved by CSSDirectionAwareResolver
    // before calling CSSValueFromComputedStyleInternal.
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return nullptr;
  }
};

// scroll-start-inline
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ScrollStartInline final : public Longhand {
 public:
  constexpr ScrollStartInline() : Longhand(CSSPropertyID::kScrollStartInline, kProperty | kIdempotent | kValidForKeyframe | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  const CSSProperty& ResolveDirectionAwarePropertyInternal(
      TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(
      const ComputedStyle&,
      const LayoutObject*,
      bool allow_visited_style,
      CSSValuePhase value_phase) const override {
    // Directional properties are resolved by CSSDirectionAwareResolver
    // before calling CSSValueFromComputedStyleInternal.
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return nullptr;
  }
};

// scroll-start-target-block
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ScrollStartTargetBlock final : public Longhand {
 public:
  constexpr ScrollStartTargetBlock() : Longhand(CSSPropertyID::kScrollStartTargetBlock, kProperty | kIdempotent | kValidForKeyframe | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  const CSSProperty& ResolveDirectionAwarePropertyInternal(
      TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(
      const ComputedStyle&,
      const LayoutObject*,
      bool allow_visited_style,
      CSSValuePhase value_phase) const override {
    // Directional properties are resolved by CSSDirectionAwareResolver
    // before calling CSSValueFromComputedStyleInternal.
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return nullptr;
  }
};

// scroll-start-target-inline
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ScrollStartTargetInline final : public Longhand {
 public:
  constexpr ScrollStartTargetInline() : Longhand(CSSPropertyID::kScrollStartTargetInline, kProperty | kIdempotent | kValidForKeyframe | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  const CSSProperty& ResolveDirectionAwarePropertyInternal(
      TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(
      const ComputedStyle&,
      const LayoutObject*,
      bool allow_visited_style,
      CSSValuePhase value_phase) const override {
    // Directional properties are resolved by CSSDirectionAwareResolver
    // before calling CSSValueFromComputedStyleInternal.
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return nullptr;
  }
};

// scroll-start-target-x
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ScrollStartTargetX final : public Longhand {
 public:
  constexpr ScrollStartTargetX() : Longhand(CSSPropertyID::kScrollStartTargetX, kProperty | kIdempotent | kValidForKeyframe | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// scroll-start-target-y
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ScrollStartTargetY final : public Longhand {
 public:
  constexpr ScrollStartTargetY() : Longhand(CSSPropertyID::kScrollStartTargetY, kProperty | kIdempotent | kValidForKeyframe | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// scroll-start-x
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ScrollStartX final : public Longhand {
 public:
  constexpr ScrollStartX() : Longhand(CSSPropertyID::kScrollStartX, kProperty | kIdempotent | kValidForKeyframe | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// scroll-start-y
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ScrollStartY final : public Longhand {
 public:
  constexpr ScrollStartY() : Longhand(CSSPropertyID::kScrollStartY, kProperty | kIdempotent | kValidForKeyframe | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// scroll-timeline-axis
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ScrollTimelineAxis final : public Longhand {
 public:
  constexpr ScrollTimelineAxis() : Longhand(CSSPropertyID::kScrollTimelineAxis, kProperty | kIdempotent | kValidForKeyframe, ',') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const CSSValue* InitialValue() const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// scroll-timeline-name
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ScrollTimelineName final : public Longhand {
 public:
  constexpr ScrollTimelineName() : Longhand(CSSPropertyID::kScrollTimelineName, kProperty | kIdempotent | kValidForKeyframe, ',') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const CSSValue* InitialValue() const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// scrollbar-color
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ScrollbarColor final : public Longhand {
 public:
  constexpr ScrollbarColor() : Longhand(CSSPropertyID::kScrollbarColor, kInterpolable | kProperty | kInherited | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// scrollbar-gutter
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ScrollbarGutter final : public Longhand {
 public:
  constexpr ScrollbarGutter() : Longhand(CSSPropertyID::kScrollbarGutter, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// scrollbar-width
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ScrollbarWidth final : public Longhand {
 public:
  constexpr ScrollbarWidth() : Longhand(CSSPropertyID::kScrollbarWidth, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// shape-image-threshold
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ShapeImageThreshold final : public Longhand {
 public:
  constexpr ShapeImageThreshold() : Longhand(CSSPropertyID::kShapeImageThreshold, kInterpolable | kProperty | kIdempotent | kAcceptsNumericLiteral | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// shape-margin
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ShapeMargin final : public Longhand {
 public:
  constexpr ShapeMargin() : Longhand(CSSPropertyID::kShapeMargin, kInterpolable | kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// shape-outside
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ShapeOutside final : public Longhand {
 public:
  constexpr ShapeOutside() : Longhand(CSSPropertyID::kShapeOutside, kInterpolable | kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// shape-rendering
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ShapeRendering final : public Longhand {
 public:
  constexpr ShapeRendering() : Longhand(CSSPropertyID::kShapeRendering, kProperty | kInherited | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// size
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Size final : public Longhand {
 public:
  constexpr Size() : Longhand(CSSPropertyID::kSize, kProperty | kIdempotent | kValidForKeyframe | kValidForLimitedPageContext | kValidForPageContext, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// size-adjust
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class SizeAdjust final : public Longhand {
 public:
  constexpr SizeAdjust() : Longhand(CSSPropertyID::kSizeAdjust, kDescriptor | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// speak
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Speak final : public Longhand {
 public:
  constexpr Speak() : Longhand(CSSPropertyID::kSpeak, kProperty | kInherited | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// speak-as
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class SpeakAs final : public Longhand {
 public:
  constexpr SpeakAs() : Longhand(CSSPropertyID::kSpeakAs, kDescriptor | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// src
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Src final : public Longhand {
 public:
  constexpr Src() : Longhand(CSSPropertyID::kSrc, kDescriptor | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// stop-color
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class StopColor final : public Longhand {
 public:
  constexpr StopColor() : Longhand(CSSPropertyID::kStopColor, kInterpolable | kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const webf::Color ColorIncludingFallback(bool, const ComputedStyle&, bool* is_current_color = nullptr) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// stop-opacity
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class StopOpacity final : public Longhand {
 public:
  constexpr StopOpacity() : Longhand(CSSPropertyID::kStopOpacity, kInterpolable | kProperty | kIdempotent | kAcceptsNumericLiteral | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// stroke
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Stroke final : public Longhand {
 public:
  constexpr Stroke() : Longhand(CSSPropertyID::kStroke, kInterpolable | kProperty | kInherited | kIdempotent | kValidForKeyframe | kValidForHighlightLegacy | kValidForHighlight, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const webf::Color ColorIncludingFallback(bool, const ComputedStyle&, bool* is_current_color = nullptr) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// stroke-dasharray
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class StrokeDasharray final : public Longhand {
 public:
  constexpr StrokeDasharray() : Longhand(CSSPropertyID::kStrokeDasharray, kInterpolable | kProperty | kInherited | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// stroke-dashoffset
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class StrokeDashoffset final : public Longhand {
 public:
  constexpr StrokeDashoffset() : Longhand(CSSPropertyID::kStrokeDashoffset, kInterpolable | kProperty | kInherited | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// stroke-linecap
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class StrokeLinecap final : public Longhand {
 public:
  constexpr StrokeLinecap() : Longhand(CSSPropertyID::kStrokeLinecap, kProperty | kInherited | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// stroke-linejoin
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class StrokeLinejoin final : public Longhand {
 public:
  constexpr StrokeLinejoin() : Longhand(CSSPropertyID::kStrokeLinejoin, kProperty | kInherited | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// stroke-miterlimit
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class StrokeMiterlimit final : public Longhand {
 public:
  constexpr StrokeMiterlimit() : Longhand(CSSPropertyID::kStrokeMiterlimit, kInterpolable | kProperty | kInherited | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// stroke-opacity
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class StrokeOpacity final : public Longhand {
 public:
  constexpr StrokeOpacity() : Longhand(CSSPropertyID::kStrokeOpacity, kInterpolable | kProperty | kInherited | kIdempotent | kAcceptsNumericLiteral | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// stroke-width
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class StrokeWidth final : public Longhand {
 public:
  constexpr StrokeWidth() : Longhand(CSSPropertyID::kStrokeWidth, kInterpolable | kProperty | kInherited | kIdempotent | kValidForKeyframe | kValidForHighlightLegacy | kValidForHighlight, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// suffix
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Suffix final : public Longhand {
 public:
  constexpr Suffix() : Longhand(CSSPropertyID::kSuffix, kDescriptor | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// symbols
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Symbols final : public Longhand {
 public:
  constexpr Symbols() : Longhand(CSSPropertyID::kSymbols, kDescriptor | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// syntax
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Syntax final : public Longhand {
 public:
  constexpr Syntax() : Longhand(CSSPropertyID::kSyntax, kDescriptor | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// system
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class System final : public Longhand {
 public:
  constexpr System() : Longhand(CSSPropertyID::kSystem, kDescriptor | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// tab-size
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class TabSize final : public Longhand {
 public:
  constexpr TabSize() : Longhand(CSSPropertyID::kTabSize, kInterpolable | kProperty | kInherited | kIdempotent | kValidForMarker | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// table-layout
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class TableLayout final : public Longhand {
 public:
  constexpr TableLayout() : Longhand(CSSPropertyID::kTableLayout, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// text-align
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class TextAlign final : public Longhand {
 public:
  constexpr TextAlign() : Longhand(CSSPropertyID::kTextAlign, kProperty | kInherited | kIdempotent | kValidForFormattedText | kValidForKeyframe | kValidForPageContext, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// text-align-last
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class TextAlignLast final : public Longhand {
 public:
  constexpr TextAlignLast() : Longhand(CSSPropertyID::kTextAlignLast, kProperty | kInherited | kIdempotent | kValidForKeyframe | kValidForPageContext, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// text-anchor
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class TextAnchor final : public Longhand {
 public:
  constexpr TextAnchor() : Longhand(CSSPropertyID::kTextAnchor, kProperty | kInherited | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// text-autospace
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class TextAutospace final : public Longhand {
 public:
  constexpr TextAutospace() : Longhand(CSSPropertyID::kTextAutospace, kProperty | kInherited | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// text-box-edge
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class TextBoxEdge final : public Longhand {
 public:
  constexpr TextBoxEdge() : Longhand(CSSPropertyID::kTextBoxEdge, kProperty | kInherited | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// text-box-trim
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class TextBoxTrim final : public Longhand {
 public:
  constexpr TextBoxTrim() : Longhand(CSSPropertyID::kTextBoxTrim, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// text-combine-upright
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class TextCombineUpright final : public Longhand {
 public:
  constexpr TextCombineUpright() : Longhand(CSSPropertyID::kTextCombineUpright, kProperty | kInherited | kIdempotent | kValidForMarker | kValidForFormattedText | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// text-decoration-color
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class TextDecorationColor final : public Longhand {
 public:
  constexpr TextDecorationColor() : Longhand(CSSPropertyID::kTextDecorationColor, kInterpolable | kProperty | kSupportsIncrementalStyle | kIdempotent | kValidForFirstLetter | kValidForFirstLine | kValidForCue | kValidForFormattedText | kValidForFormattedTextRun | kValidForKeyframe | kValidForPageContext | kValidForHighlightLegacy | kValidForHighlight, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const webf::Color ColorIncludingFallback(bool, const ComputedStyle&, bool* is_current_color = nullptr) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// text-decoration-line
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class TextDecorationLine final : public Longhand {
 public:
  constexpr TextDecorationLine() : Longhand(CSSPropertyID::kTextDecorationLine, kProperty | kIdempotent | kValidForFirstLetter | kValidForFirstLine | kValidForCue | kValidForFormattedText | kValidForFormattedTextRun | kValidForKeyframe | kValidForPageContext | kValidForHighlightLegacy | kValidForHighlight, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// text-decoration-skip-ink
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class TextDecorationSkipInk final : public Longhand {
 public:
  constexpr TextDecorationSkipInk() : Longhand(CSSPropertyID::kTextDecorationSkipInk, kProperty | kInherited | kIdempotent | kValidForFirstLetter | kValidForFirstLine | kValidForCue | kValidForMarker | kValidForFormattedText | kValidForFormattedTextRun | kValidForKeyframe | kValidForPageContext | kValidForHighlightLegacy | kValidForHighlight, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// text-decoration-style
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class TextDecorationStyle final : public Longhand {
 public:
  constexpr TextDecorationStyle() : Longhand(CSSPropertyID::kTextDecorationStyle, kProperty | kIdempotent | kValidForFirstLetter | kValidForFirstLine | kValidForCue | kValidForFormattedText | kValidForFormattedTextRun | kValidForKeyframe | kValidForPageContext | kValidForHighlightLegacy | kValidForHighlight, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// text-decoration-thickness
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class TextDecorationThickness final : public Longhand {
 public:
  constexpr TextDecorationThickness() : Longhand(CSSPropertyID::kTextDecorationThickness, kProperty | kIdempotent | kValidForFirstLetter | kValidForFirstLine | kValidForFormattedText | kValidForFormattedTextRun | kValidForKeyframe | kValidForPageContext | kValidForHighlightLegacy | kValidForHighlight, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// text-emphasis-color
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class TextEmphasisColor final : public Longhand {
 public:
  constexpr TextEmphasisColor() : Longhand(CSSPropertyID::kTextEmphasisColor, kInterpolable | kProperty | kInherited | kIdempotent | kValidForMarker | kValidForKeyframe | kValidForHighlightLegacy | kValidForHighlight, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const webf::Color ColorIncludingFallback(bool, const ComputedStyle&, bool* is_current_color = nullptr) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// text-emphasis-position
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class TextEmphasisPosition final : public Longhand {
 public:
  constexpr TextEmphasisPosition() : Longhand(CSSPropertyID::kTextEmphasisPosition, kProperty | kInherited | kIdempotent | kValidForMarker | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// text-emphasis-style
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class TextEmphasisStyle final : public Longhand {
 public:
  constexpr TextEmphasisStyle() : Longhand(CSSPropertyID::kTextEmphasisStyle, kProperty | kInherited | kIdempotent | kValidForMarker | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// text-indent
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class TextIndent final : public Longhand {
 public:
  constexpr TextIndent() : Longhand(CSSPropertyID::kTextIndent, kInterpolable | kProperty | kInherited | kIdempotent | kValidForKeyframe | kValidForPageContext, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// text-overflow
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class TextOverflow final : public Longhand {
 public:
  constexpr TextOverflow() : Longhand(CSSPropertyID::kTextOverflow, kProperty | kIdempotent | kValidForFormattedText | kValidForKeyframe | kValidForPageContext, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// text-shadow
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class TextShadow final : public Longhand {
 public:
  constexpr TextShadow() : Longhand(CSSPropertyID::kTextShadow, kInterpolable | kProperty | kInherited | kIdempotent | kValidForFirstLetter | kValidForFirstLine | kValidForCue | kValidForMarker | kValidForFormattedText | kValidForFormattedTextRun | kValidForKeyframe | kValidForPageContext | kValidForHighlightLegacy | kValidForHighlight, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// text-transform
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class TextTransform final : public Longhand {
 public:
  constexpr TextTransform() : Longhand(CSSPropertyID::kTextTransform, kProperty | kInherited | kIdempotent | kValidForFirstLetter | kValidForFirstLine | kValidForMarker | kValidForFormattedText | kValidForFormattedTextRun | kValidForKeyframe | kValidForPageContext, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// text-underline-offset
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class TextUnderlineOffset final : public Longhand {
 public:
  constexpr TextUnderlineOffset() : Longhand(CSSPropertyID::kTextUnderlineOffset, kInterpolable | kProperty | kInherited | kIdempotent | kValidForFirstLetter | kValidForFirstLine | kValidForFormattedText | kValidForFormattedTextRun | kValidForKeyframe | kValidForPageContext | kValidForHighlight, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// text-underline-position
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class TextUnderlinePosition final : public Longhand {
 public:
  constexpr TextUnderlinePosition() : Longhand(CSSPropertyID::kTextUnderlinePosition, kProperty | kInherited | kIdempotent | kValidForFirstLetter | kValidForFirstLine | kValidForFormattedText | kValidForFormattedTextRun | kValidForKeyframe | kValidForPageContext, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// text-wrap
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class TextWrap final : public Longhand {
 public:
  constexpr TextWrap() : Longhand(CSSPropertyID::kTextWrap, kProperty | kInherited | kIdempotent | kValidForCue | kValidForMarker | kValidForKeyframe | kValidForPageContext, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// timeline-scope
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class TimelineScope final : public Longhand {
 public:
  constexpr TimelineScope() : Longhand(CSSPropertyID::kTimelineScope, kProperty | kIdempotent | kValidForKeyframe, ',') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// top
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Top final : public Longhand {
 public:
  constexpr Top() : Longhand(CSSPropertyID::kTop, kInterpolable | kProperty | kSupportsIncrementalStyle | kIdempotent | kValidForKeyframe | kValidForPositionTry | kValidForPermissionElement | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool IsLayoutDependentProperty() const override { return true; }
  bool IsLayoutDependent(const ComputedStyle*, LayoutObject*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// touch-action
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class TouchAction final : public Longhand {
 public:
  constexpr TouchAction() : Longhand(CSSPropertyID::kTouchAction, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// transform
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Transform final : public Longhand {
 public:
  constexpr Transform() : Longhand(CSSPropertyID::kTransform, kInterpolable | kCompositableProperty | kProperty | kSupportsIncrementalStyle | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool IsLayoutDependentProperty() const override { return true; }
  bool IsLayoutDependent(const ComputedStyle*, LayoutObject*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// transform-box
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class TransformBox final : public Longhand {
 public:
  constexpr TransformBox() : Longhand(CSSPropertyID::kTransformBox, kProperty | kSupportsIncrementalStyle | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// transform-origin
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class TransformOrigin final : public Longhand {
 public:
  constexpr TransformOrigin() : Longhand(CSSPropertyID::kTransformOrigin, kInterpolable | kProperty | kSupportsIncrementalStyle | kIdempotent | kOverlapping | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool IsLayoutDependentProperty() const override { return true; }
  bool IsLayoutDependent(const ComputedStyle*, LayoutObject*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// transform-style
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class TransformStyle final : public Longhand {
 public:
  constexpr TransformStyle() : Longhand(CSSPropertyID::kTransformStyle, kProperty | kSupportsIncrementalStyle | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// transition-behavior
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class TransitionBehavior final : public Longhand {
 public:
  constexpr TransitionBehavior() : Longhand(CSSPropertyID::kTransitionBehavior, kProperty | kAnimation | kIdempotent | kValidForMarker | kValidForKeyframe, ',') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const CSSValue* InitialValue() const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// transition-delay
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class TransitionDelay final : public Longhand {
 public:
  constexpr TransitionDelay() : Longhand(CSSPropertyID::kTransitionDelay, kProperty | kAnimation | kIdempotent | kValidForMarker | kValidForKeyframe, ',') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const CSSValue* InitialValue() const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// transition-duration
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class TransitionDuration final : public Longhand {
 public:
  constexpr TransitionDuration() : Longhand(CSSPropertyID::kTransitionDuration, kProperty | kAnimation | kIdempotent | kValidForMarker | kValidForKeyframe, ',') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const CSSValue* InitialValue() const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// transition-property
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class TransitionProperty final : public Longhand {
 public:
  constexpr TransitionProperty() : Longhand(CSSPropertyID::kTransitionProperty, kProperty | kAnimation | kIdempotent | kValidForMarker | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const CSSValue* InitialValue() const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// transition-timing-function
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class TransitionTimingFunction final : public Longhand {
 public:
  constexpr TransitionTimingFunction() : Longhand(CSSPropertyID::kTransitionTimingFunction, kProperty | kAnimation | kIdempotent | kValidForMarker | kValidForKeyframe, ',') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const CSSValue* InitialValue() const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// translate
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Translate final : public Longhand {
 public:
  constexpr Translate() : Longhand(CSSPropertyID::kTranslate, kInterpolable | kCompositableProperty | kProperty | kSupportsIncrementalStyle | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool IsLayoutDependentProperty() const override { return true; }
  bool IsLayoutDependent(const ComputedStyle*, LayoutObject*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// types
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Types final : public Longhand {
 public:
  constexpr Types() : Longhand(CSSPropertyID::kTypes, kDescriptor | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
};

// unicode-bidi
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class UnicodeBidi final : public Longhand {
 public:
  constexpr UnicodeBidi() : Longhand(CSSPropertyID::kUnicodeBidi, kProperty | kIdempotent | kValidForMarker | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool IsAffectedByAll() const override { return false; }
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// unicode-range
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class UnicodeRange final : public Longhand {
 public:
  constexpr UnicodeRange() : Longhand(CSSPropertyID::kUnicodeRange, kDescriptor | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// user-select
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class UserSelect final : public Longhand {
 public:
  constexpr UserSelect() : Longhand(CSSPropertyID::kUserSelect, kProperty | kInherited | kIdempotent | kValidForKeyframe | kValidForPermissionElement, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// vector-effect
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class VectorEffect final : public Longhand {
 public:
  constexpr VectorEffect() : Longhand(CSSPropertyID::kVectorEffect, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// vertical-align
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class VerticalAlign final : public Longhand {
 public:
  constexpr VerticalAlign() : Longhand(CSSPropertyID::kVerticalAlign, kInterpolable | kProperty | kIdempotent | kValidForFirstLetter | kValidForFirstLine | kValidForKeyframe | kValidForPageContext, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// view-timeline-axis
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ViewTimelineAxis final : public Longhand {
 public:
  constexpr ViewTimelineAxis() : Longhand(CSSPropertyID::kViewTimelineAxis, kProperty | kIdempotent | kValidForKeyframe, ',') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const CSSValue* InitialValue() const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// view-timeline-inset
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ViewTimelineInset final : public Longhand {
 public:
  constexpr ViewTimelineInset() : Longhand(CSSPropertyID::kViewTimelineInset, kProperty | kIdempotent | kValidForKeyframe, ',') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const CSSValue* InitialValue() const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// view-timeline-name
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ViewTimelineName final : public Longhand {
 public:
  constexpr ViewTimelineName() : Longhand(CSSPropertyID::kViewTimelineName, kProperty | kIdempotent | kValidForKeyframe, ',') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const CSSValue* InitialValue() const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// view-transition-class
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ViewTransitionClass final : public Longhand {
 public:
  constexpr ViewTransitionClass() : Longhand(CSSPropertyID::kViewTransitionClass, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// view-transition-name
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ViewTransitionName final : public Longhand {
 public:
  constexpr ViewTransitionName() : Longhand(CSSPropertyID::kViewTransitionName, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// visibility
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Visibility final : public Longhand {
 public:
  constexpr Visibility() : Longhand(CSSPropertyID::kVisibility, kInterpolable | kProperty | kInherited | kIdempotent | kValidForFirstLetter | kValidForFirstLine | kValidForCue | kValidForKeyframe | kValidForPageContext | kValidForPermissionElement, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// -webkit-border-horizontal-spacing
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitBorderHorizontalSpacing final : public Longhand {
 public:
  constexpr WebkitBorderHorizontalSpacing() : Longhand(CSSPropertyID::kWebkitBorderHorizontalSpacing, kInterpolable | kProperty | kInherited | kIdempotent | kValidForFirstLetter | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// -webkit-border-image
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitBorderImage final : public Longhand {
 public:
  constexpr WebkitBorderImage() : Longhand(CSSPropertyID::kWebkitBorderImage, kProperty | kIdempotent | kOverlapping | kLegacyOverlapping | kValidForFirstLetter | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool IsAffectedByAll() const override { return false; }
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// -webkit-border-vertical-spacing
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitBorderVerticalSpacing final : public Longhand {
 public:
  constexpr WebkitBorderVerticalSpacing() : Longhand(CSSPropertyID::kWebkitBorderVerticalSpacing, kInterpolable | kProperty | kInherited | kIdempotent | kValidForFirstLetter | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// -webkit-box-align
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitBoxAlign final : public Longhand {
 public:
  constexpr WebkitBoxAlign() : Longhand(CSSPropertyID::kWebkitBoxAlign, kProperty | kIdempotent | kValidForKeyframe | kValidForPermissionElement, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// -webkit-box-decoration-break
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitBoxDecorationBreak final : public Longhand {
 public:
  constexpr WebkitBoxDecorationBreak() : Longhand(CSSPropertyID::kWebkitBoxDecorationBreak, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// -webkit-box-direction
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitBoxDirection final : public Longhand {
 public:
  constexpr WebkitBoxDirection() : Longhand(CSSPropertyID::kWebkitBoxDirection, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// -webkit-box-flex
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitBoxFlex final : public Longhand {
 public:
  constexpr WebkitBoxFlex() : Longhand(CSSPropertyID::kWebkitBoxFlex, kProperty | kIdempotent | kAcceptsNumericLiteral | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// -webkit-box-ordinal-group
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitBoxOrdinalGroup final : public Longhand {
 public:
  constexpr WebkitBoxOrdinalGroup() : Longhand(CSSPropertyID::kWebkitBoxOrdinalGroup, kProperty | kIdempotent | kValidForKeyframe | kValidForPermissionElement, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// -webkit-box-orient
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitBoxOrient final : public Longhand {
 public:
  constexpr WebkitBoxOrient() : Longhand(CSSPropertyID::kWebkitBoxOrient, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// -webkit-box-pack
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitBoxPack final : public Longhand {
 public:
  constexpr WebkitBoxPack() : Longhand(CSSPropertyID::kWebkitBoxPack, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// -webkit-box-reflect
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitBoxReflect final : public Longhand {
 public:
  constexpr WebkitBoxReflect() : Longhand(CSSPropertyID::kWebkitBoxReflect, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// -webkit-line-break
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitLineBreak final : public Longhand {
 public:
  constexpr WebkitLineBreak() : Longhand(CSSPropertyID::kWebkitLineBreak, kProperty | kInherited | kIdempotent | kValidForFormattedText | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// -webkit-line-clamp
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitLineClamp final : public Longhand {
 public:
  constexpr WebkitLineClamp() : Longhand(CSSPropertyID::kWebkitLineClamp, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// -webkit-mask-box-image-outset
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitMaskBoxImageOutset final : public Longhand {
 public:
  constexpr WebkitMaskBoxImageOutset() : Longhand(CSSPropertyID::kWebkitMaskBoxImageOutset, kInterpolable | kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// -webkit-mask-box-image-repeat
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitMaskBoxImageRepeat final : public Longhand {
 public:
  constexpr WebkitMaskBoxImageRepeat() : Longhand(CSSPropertyID::kWebkitMaskBoxImageRepeat, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// -webkit-mask-box-image-slice
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitMaskBoxImageSlice final : public Longhand {
 public:
  constexpr WebkitMaskBoxImageSlice() : Longhand(CSSPropertyID::kWebkitMaskBoxImageSlice, kInterpolable | kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// -webkit-mask-box-image-source
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitMaskBoxImageSource final : public Longhand {
 public:
  constexpr WebkitMaskBoxImageSource() : Longhand(CSSPropertyID::kWebkitMaskBoxImageSource, kInterpolable | kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// -webkit-mask-box-image-width
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitMaskBoxImageWidth final : public Longhand {
 public:
  constexpr WebkitMaskBoxImageWidth() : Longhand(CSSPropertyID::kWebkitMaskBoxImageWidth, kInterpolable | kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// -webkit-mask-position-x
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitMaskPositionX final : public Longhand {
 public:
  constexpr WebkitMaskPositionX() : Longhand(CSSPropertyID::kWebkitMaskPositionX, kInterpolable | kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const CSSValue* InitialValue() const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// -webkit-mask-position-y
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitMaskPositionY final : public Longhand {
 public:
  constexpr WebkitMaskPositionY() : Longhand(CSSPropertyID::kWebkitMaskPositionY, kInterpolable | kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const CSSValue* InitialValue() const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// -webkit-perspective-origin-x
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitPerspectiveOriginX final : public Longhand {
 public:
  constexpr WebkitPerspectiveOriginX() : Longhand(CSSPropertyID::kWebkitPerspectiveOriginX, kInterpolable | kProperty | kIdempotent | kOverlapping | kLegacyOverlapping | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool IsAffectedByAll() const override { return false; }
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// -webkit-perspective-origin-y
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitPerspectiveOriginY final : public Longhand {
 public:
  constexpr WebkitPerspectiveOriginY() : Longhand(CSSPropertyID::kWebkitPerspectiveOriginY, kInterpolable | kProperty | kIdempotent | kOverlapping | kLegacyOverlapping | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool IsAffectedByAll() const override { return false; }
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// -webkit-print-color-adjust
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitPrintColorAdjust final : public Longhand {
 public:
  constexpr WebkitPrintColorAdjust() : Longhand(CSSPropertyID::kWebkitPrintColorAdjust, kProperty | kInherited | kIdempotent | kValidForKeyframe | kValidForPermissionElement, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// -webkit-rtl-ordering
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitRtlOrdering final : public Longhand {
 public:
  constexpr WebkitRtlOrdering() : Longhand(CSSPropertyID::kWebkitRtlOrdering, kProperty | kInherited | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// -webkit-ruby-position
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitRubyPosition final : public Longhand {
 public:
  constexpr WebkitRubyPosition() : Longhand(CSSPropertyID::kWebkitRubyPosition, kProperty | kInherited | kIdempotent | kValidForKeyframe | kValidForPermissionElement | kSurrogate, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// -webkit-tap-highlight-color
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitTapHighlightColor final : public Longhand {
 public:
  constexpr WebkitTapHighlightColor() : Longhand(CSSPropertyID::kWebkitTapHighlightColor, kProperty | kInherited | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const webf::Color ColorIncludingFallback(bool, const ComputedStyle&, bool* is_current_color = nullptr) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// -webkit-text-combine
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitTextCombine final : public Longhand {
 public:
  constexpr WebkitTextCombine() : Longhand(CSSPropertyID::kWebkitTextCombine, kProperty | kInherited | kIdempotent | kValidForKeyframe | kSurrogate, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// -webkit-text-decorations-in-effect
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitTextDecorationsInEffect final : public Longhand {
 public:
  constexpr WebkitTextDecorationsInEffect() : Longhand(CSSPropertyID::kWebkitTextDecorationsInEffect, kProperty | kInherited | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// -webkit-text-fill-color
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitTextFillColor final : public Longhand {
 public:
  constexpr WebkitTextFillColor() : Longhand(CSSPropertyID::kWebkitTextFillColor, kProperty | kInherited | kIdempotent | kValidForKeyframe | kValidForHighlightLegacy | kValidForHighlight, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const webf::Color ColorIncludingFallback(bool, const ComputedStyle&, bool* is_current_color = nullptr) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// -webkit-text-security
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitTextSecurity final : public Longhand {
 public:
  constexpr WebkitTextSecurity() : Longhand(CSSPropertyID::kWebkitTextSecurity, kProperty | kInherited | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// -webkit-text-stroke-color
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitTextStrokeColor final : public Longhand {
 public:
  constexpr WebkitTextStrokeColor() : Longhand(CSSPropertyID::kWebkitTextStrokeColor, kInterpolable | kProperty | kInherited | kIdempotent | kValidForKeyframe | kValidForHighlightLegacy | kValidForHighlight, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  const webf::Color ColorIncludingFallback(bool, const ComputedStyle&, bool* is_current_color = nullptr) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// -webkit-text-stroke-width
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitTextStrokeWidth final : public Longhand {
 public:
  constexpr WebkitTextStrokeWidth() : Longhand(CSSPropertyID::kWebkitTextStrokeWidth, kProperty | kInherited | kIdempotent | kValidForKeyframe | kValidForHighlightLegacy | kValidForHighlight, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// -webkit-transform-origin-x
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitTransformOriginX final : public Longhand {
 public:
  constexpr WebkitTransformOriginX() : Longhand(CSSPropertyID::kWebkitTransformOriginX, kInterpolable | kProperty | kIdempotent | kOverlapping | kLegacyOverlapping | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool IsAffectedByAll() const override { return false; }
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// -webkit-transform-origin-y
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitTransformOriginY final : public Longhand {
 public:
  constexpr WebkitTransformOriginY() : Longhand(CSSPropertyID::kWebkitTransformOriginY, kInterpolable | kProperty | kIdempotent | kOverlapping | kLegacyOverlapping | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool IsAffectedByAll() const override { return false; }
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// -webkit-transform-origin-z
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitTransformOriginZ final : public Longhand {
 public:
  constexpr WebkitTransformOriginZ() : Longhand(CSSPropertyID::kWebkitTransformOriginZ, kInterpolable | kProperty | kIdempotent | kOverlapping | kLegacyOverlapping | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool IsAffectedByAll() const override { return false; }
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// -webkit-user-drag
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitUserDrag final : public Longhand {
 public:
  constexpr WebkitUserDrag() : Longhand(CSSPropertyID::kWebkitUserDrag, kProperty | kIdempotent | kValidForKeyframe | kValidForPermissionElement, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// -webkit-user-modify
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitUserModify final : public Longhand {
 public:
  constexpr WebkitUserModify() : Longhand(CSSPropertyID::kWebkitUserModify, kProperty | kInherited | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool IsAffectedByAll() const override { return false; }
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// white-space-collapse
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WhiteSpaceCollapse final : public Longhand {
 public:
  constexpr WhiteSpaceCollapse() : Longhand(CSSPropertyID::kWhiteSpaceCollapse, kProperty | kInherited | kIdempotent | kValidForCue | kValidForMarker | kValidForKeyframe | kValidForPageContext, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// widows
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Widows final : public Longhand {
 public:
  constexpr Widows() : Longhand(CSSPropertyID::kWidows, kInterpolable | kProperty | kInherited | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// width
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Width final : public Longhand {
 public:
  constexpr Width() : Longhand(CSSPropertyID::kWidth, kInterpolable | kProperty | kSupportsIncrementalStyle | kIdempotent | kValidForFormattedText | kValidForKeyframe | kValidForPositionTry | kValidForPageContext | kValidForPermissionElement | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool IsLayoutDependentProperty() const override { return true; }
  bool IsLayoutDependent(const ComputedStyle*, LayoutObject*) const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// will-change
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WillChange final : public Longhand {
 public:
  constexpr WillChange() : Longhand(CSSPropertyID::kWillChange, kProperty | kIdempotent | kValidForKeyframe | kValidForPermissionElement, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// word-break
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WordBreak final : public Longhand {
 public:
  constexpr WordBreak() : Longhand(CSSPropertyID::kWordBreak, kProperty | kInherited | kIdempotent | kValidForMarker | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// word-spacing
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WordSpacing final : public Longhand {
 public:
  constexpr WordSpacing() : Longhand(CSSPropertyID::kWordSpacing, kInterpolable | kProperty | kInherited | kIdempotent | kValidForFirstLetter | kValidForFirstLine | kValidForMarker | kValidForKeyframe | kValidForPageContext | kValidForPermissionElement, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// x
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class X final : public Longhand {
 public:
  constexpr X() : Longhand(CSSPropertyID::kX, kInterpolable | kProperty | kSupportsIncrementalStyle | kIdempotent | kValidForKeyframe | kValidForPermissionElement, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// y
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Y final : public Longhand {
 public:
  constexpr Y() : Longhand(CSSPropertyID::kY, kInterpolable | kProperty | kSupportsIncrementalStyle | kIdempotent | kValidForKeyframe | kValidForPermissionElement, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// z-index
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ZIndex final : public Longhand {
 public:
  constexpr ZIndex() : Longhand(CSSPropertyID::kZIndex, kInterpolable | kProperty | kIdempotent | kValidForKeyframe | kValidForPermissionElement, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSValue* ParseSingleValue(CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  void ApplyInitial(StyleResolverState&) const override;
  void ApplyInherit(StyleResolverState&) const override;
  void ApplyValue(StyleResolverState&, const CSSValue&, ValueMode) const override;
};

// -webkit-appearance
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitAppearance final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitAppearance() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-app-region
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitAppRegion final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitAppRegion() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-mask-clip
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitMaskClip final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitMaskClip() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-mask-composite
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitMaskComposite final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitMaskComposite() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-mask-image
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitMaskImage final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitMaskImage() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-mask-origin
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitMaskOrigin final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitMaskOrigin() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-mask-repeat
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitMaskRepeat final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitMaskRepeat() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-mask-size
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitMaskSize final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitMaskSize() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-border-end-color
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitBorderEndColor final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitBorderEndColor() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-border-end-style
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitBorderEndStyle final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitBorderEndStyle() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-border-end-width
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitBorderEndWidth final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitBorderEndWidth() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-border-start-color
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitBorderStartColor final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitBorderStartColor() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-border-start-style
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitBorderStartStyle final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitBorderStartStyle() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-border-start-width
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitBorderStartWidth final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitBorderStartWidth() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-border-before-color
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitBorderBeforeColor final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitBorderBeforeColor() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-border-before-style
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitBorderBeforeStyle final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitBorderBeforeStyle() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-border-before-width
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitBorderBeforeWidth final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitBorderBeforeWidth() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-border-after-color
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitBorderAfterColor final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitBorderAfterColor() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-border-after-style
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitBorderAfterStyle final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitBorderAfterStyle() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-border-after-width
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitBorderAfterWidth final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitBorderAfterWidth() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-margin-end
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitMarginEnd final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitMarginEnd() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-margin-start
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitMarginStart final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitMarginStart() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-margin-before
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitMarginBefore final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitMarginBefore() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-margin-after
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitMarginAfter final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitMarginAfter() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-padding-end
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitPaddingEnd final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitPaddingEnd() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-padding-start
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitPaddingStart final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitPaddingStart() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-padding-before
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitPaddingBefore final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitPaddingBefore() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-padding-after
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitPaddingAfter final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitPaddingAfter() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-logical-width
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitLogicalWidth final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitLogicalWidth() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-logical-height
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitLogicalHeight final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitLogicalHeight() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-min-logical-width
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitMinLogicalWidth final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitMinLogicalWidth() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-min-logical-height
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitMinLogicalHeight final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitMinLogicalHeight() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-max-logical-width
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitMaxLogicalWidth final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitMaxLogicalWidth() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-max-logical-height
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitMaxLogicalHeight final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitMaxLogicalHeight() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -epub-caption-side
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class EpubCaptionSide final : public CSSUnresolvedProperty {
 public:
  constexpr EpubCaptionSide() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -epub-text-combine
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class EpubTextCombine final : public CSSUnresolvedProperty {
 public:
  constexpr EpubTextCombine() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -epub-text-emphasis-color
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class EpubTextEmphasisColor final : public CSSUnresolvedProperty {
 public:
  constexpr EpubTextEmphasisColor() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -epub-text-emphasis-style
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class EpubTextEmphasisStyle final : public CSSUnresolvedProperty {
 public:
  constexpr EpubTextEmphasisStyle() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -epub-text-orientation
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class EpubTextOrientation final : public CSSUnresolvedProperty {
 public:
  constexpr EpubTextOrientation() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -epub-text-transform
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class EpubTextTransform final : public CSSUnresolvedProperty {
 public:
  constexpr EpubTextTransform() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -epub-word-break
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class EpubWordBreak final : public CSSUnresolvedProperty {
 public:
  constexpr EpubWordBreak() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -epub-writing-mode
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class EpubWritingMode final : public CSSUnresolvedProperty {
 public:
  constexpr EpubWritingMode() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-align-content
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitAlignContent final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitAlignContent() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-align-items
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitAlignItems final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitAlignItems() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-align-self
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitAlignSelf final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitAlignSelf() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-animation-delay
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitAnimationDelay final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitAnimationDelay() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-animation-direction
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitAnimationDirection final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitAnimationDirection() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-animation-duration
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitAnimationDuration final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitAnimationDuration() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-animation-fill-mode
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitAnimationFillMode final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitAnimationFillMode() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-animation-iteration-count
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitAnimationIterationCount final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitAnimationIterationCount() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-animation-name
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitAnimationName final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitAnimationName() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-animation-play-state
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitAnimationPlayState final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitAnimationPlayState() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-animation-timing-function
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitAnimationTimingFunction final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitAnimationTimingFunction() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-backface-visibility
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitBackfaceVisibility final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitBackfaceVisibility() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-background-clip
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitBackgroundClip final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitBackgroundClip() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-background-origin
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitBackgroundOrigin final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitBackgroundOrigin() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-background-size
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitBackgroundSize final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitBackgroundSize() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-border-bottom-left-radius
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitBorderBottomLeftRadius final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitBorderBottomLeftRadius() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-border-bottom-right-radius
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitBorderBottomRightRadius final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitBorderBottomRightRadius() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-border-top-left-radius
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitBorderTopLeftRadius final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitBorderTopLeftRadius() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-border-top-right-radius
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitBorderTopRightRadius final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitBorderTopRightRadius() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-box-shadow
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitBoxShadow final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitBoxShadow() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-box-sizing
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitBoxSizing final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitBoxSizing() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-clip-path
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitClipPath final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitClipPath() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-column-count
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitColumnCount final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitColumnCount() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-column-gap
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitColumnGap final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitColumnGap() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-column-rule-color
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitColumnRuleColor final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitColumnRuleColor() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-column-rule-style
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitColumnRuleStyle final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitColumnRuleStyle() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-column-rule-width
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitColumnRuleWidth final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitColumnRuleWidth() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-column-span
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitColumnSpan final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitColumnSpan() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-column-width
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitColumnWidth final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitColumnWidth() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-filter
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitFilter final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitFilter() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-flex-basis
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitFlexBasis final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitFlexBasis() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-flex-direction
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitFlexDirection final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitFlexDirection() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-flex-grow
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitFlexGrow final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitFlexGrow() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-flex-shrink
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitFlexShrink final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitFlexShrink() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-flex-wrap
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitFlexWrap final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitFlexWrap() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-font-feature-settings
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitFontFeatureSettings final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitFontFeatureSettings() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-hyphenate-character
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitHyphenateCharacter final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitHyphenateCharacter() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-justify-content
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitJustifyContent final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitJustifyContent() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-opacity
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitOpacity final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitOpacity() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-order
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitOrder final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitOrder() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-perspective
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitPerspective final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitPerspective() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-perspective-origin
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitPerspectiveOrigin final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitPerspectiveOrigin() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-shape-image-threshold
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitShapeImageThreshold final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitShapeImageThreshold() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-shape-margin
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitShapeMargin final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitShapeMargin() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-shape-outside
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitShapeOutside final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitShapeOutside() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-text-emphasis-color
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitTextEmphasisColor final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitTextEmphasisColor() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-text-emphasis-position
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitTextEmphasisPosition final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitTextEmphasisPosition() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-text-emphasis-style
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitTextEmphasisStyle final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitTextEmphasisStyle() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-text-size-adjust
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitTextSizeAdjust final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitTextSizeAdjust() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-transform
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitTransform final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitTransform() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-transform-origin
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitTransformOrigin final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitTransformOrigin() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-transform-style
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitTransformStyle final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitTransformStyle() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-transition-delay
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitTransitionDelay final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitTransitionDelay() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-transition-duration
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitTransitionDuration final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitTransitionDuration() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-transition-property
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitTransitionProperty final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitTransitionProperty() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-transition-timing-function
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitTransitionTimingFunction final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitTransitionTimingFunction() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-user-select
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitUserSelect final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitUserSelect() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// word-wrap
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WordWrap final : public CSSUnresolvedProperty {
 public:
  constexpr WordWrap() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// grid-column-gap
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class GridColumnGap final : public CSSUnresolvedProperty {
 public:
  constexpr GridColumnGap() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// grid-row-gap
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class GridRowGap final : public CSSUnresolvedProperty {
 public:
  constexpr GridRowGap() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};


}  // namespace css_longhand

}  // namespace webf

#endif  // WEBF_LONGHANDS_H
