//
// Created by 谢作兵 on 28/06/24.
//

#ifndef WEBF_SHORTHANDS_H
#define WEBF_SHORTHANDS_H

#include "core/css/properties/shorthand.h"

namespace webf {


class ComputedStyle;
class CSSParserContext;
class CSSParserLocalContext;
class CSSValue;
class LayoutObject;
class Node;

namespace css_shorthand {

// -alternative-animation-with-timeline
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class AlternativeAnimationWithTimeline final : public Shorthand {
 public:
  constexpr AlternativeAnimationWithTimeline() : Shorthand(CSSPropertyID::kAlternativeAnimationWithTimeline, kProperty | kIdempotent, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// animation
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Animation final : public Shorthand {
 public:
  constexpr Animation() : Shorthand(CSSPropertyID::kAnimation, kProperty | kIdempotent, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  CSSPropertyID GetAlternative() const override {
    return CSSPropertyID::kAlternativeAnimationWithTimeline;
  }
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// animation-range
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class AnimationRange final : public Shorthand {
 public:
  constexpr AnimationRange() : Shorthand(CSSPropertyID::kAnimationRange, kProperty | kIdempotent, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// background
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Background final : public Shorthand {
 public:
  constexpr Background() : Shorthand(CSSPropertyID::kBackground, kProperty | kSupportsIncrementalStyle | kIdempotent | kValidForKeyframe | kValidForPageContext, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// background-position
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BackgroundPosition final : public Shorthand {
 public:
  constexpr BackgroundPosition() : Shorthand(CSSPropertyID::kBackgroundPosition, kProperty | kSupportsIncrementalStyle | kIdempotent | kValidForKeyframe | kValidForPageContext, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// border
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Border final : public Shorthand {
 public:
  constexpr Border() : Shorthand(CSSPropertyID::kBorder, kProperty | kIdempotent | kValidForKeyframe | kValidForPageContext, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// border-block
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BorderBlock final : public Shorthand {
 public:
  constexpr BorderBlock() : Shorthand(CSSPropertyID::kBorderBlock, kProperty | kIdempotent | kValidForKeyframe | kValidForPageContext, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// border-block-color
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BorderBlockColor final : public Shorthand {
 public:
  constexpr BorderBlockColor() : Shorthand(CSSPropertyID::kBorderBlockColor, kProperty | kIdempotent | kValidForKeyframe | kValidForPageContext, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// border-block-end
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BorderBlockEnd final : public Shorthand {
 public:
  constexpr BorderBlockEnd() : Shorthand(CSSPropertyID::kBorderBlockEnd, kProperty | kIdempotent | kValidForKeyframe | kValidForPageContext | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
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

// border-block-start
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BorderBlockStart final : public Shorthand {
 public:
  constexpr BorderBlockStart() : Shorthand(CSSPropertyID::kBorderBlockStart, kProperty | kIdempotent | kValidForKeyframe | kValidForPageContext | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
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

// border-block-style
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BorderBlockStyle final : public Shorthand {
 public:
  constexpr BorderBlockStyle() : Shorthand(CSSPropertyID::kBorderBlockStyle, kProperty | kIdempotent | kValidForKeyframe | kValidForPageContext, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// border-block-width
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BorderBlockWidth final : public Shorthand {
 public:
  constexpr BorderBlockWidth() : Shorthand(CSSPropertyID::kBorderBlockWidth, kProperty | kIdempotent | kValidForKeyframe | kValidForPageContext, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// border-bottom
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BorderBottom final : public Shorthand {
 public:
  constexpr BorderBottom() : Shorthand(CSSPropertyID::kBorderBottom, kProperty | kIdempotent | kValidForKeyframe | kValidForPageContext | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
};

// border-color
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BorderColor final : public Shorthand {
 public:
  constexpr BorderColor() : Shorthand(CSSPropertyID::kBorderColor, kProperty | kSupportsIncrementalStyle | kIdempotent | kValidForKeyframe | kValidForPageContext, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// border-image
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BorderImage final : public Shorthand {
 public:
  constexpr BorderImage() : Shorthand(CSSPropertyID::kBorderImage, kProperty | kIdempotent | kValidForKeyframe | kValidForPageContext, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// border-inline
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BorderInline final : public Shorthand {
 public:
  constexpr BorderInline() : Shorthand(CSSPropertyID::kBorderInline, kProperty | kIdempotent | kValidForKeyframe | kValidForPageContext, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// border-inline-color
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BorderInlineColor final : public Shorthand {
 public:
  constexpr BorderInlineColor() : Shorthand(CSSPropertyID::kBorderInlineColor, kProperty | kIdempotent | kValidForKeyframe | kValidForPageContext, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// border-inline-end
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BorderInlineEnd final : public Shorthand {
 public:
  constexpr BorderInlineEnd() : Shorthand(CSSPropertyID::kBorderInlineEnd, kProperty | kIdempotent | kValidForKeyframe | kValidForPageContext | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
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

// border-inline-start
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BorderInlineStart final : public Shorthand {
 public:
  constexpr BorderInlineStart() : Shorthand(CSSPropertyID::kBorderInlineStart, kProperty | kIdempotent | kValidForKeyframe | kValidForPageContext | kSurrogate | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  const CSSProperty* SurrogateFor(TextDirection, webf::WritingMode) const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
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

// border-inline-style
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BorderInlineStyle final : public Shorthand {
 public:
  constexpr BorderInlineStyle() : Shorthand(CSSPropertyID::kBorderInlineStyle, kProperty | kIdempotent | kValidForKeyframe | kValidForPageContext, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// border-inline-width
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BorderInlineWidth final : public Shorthand {
 public:
  constexpr BorderInlineWidth() : Shorthand(CSSPropertyID::kBorderInlineWidth, kProperty | kIdempotent | kValidForKeyframe | kValidForPageContext, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// border-left
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BorderLeft final : public Shorthand {
 public:
  constexpr BorderLeft() : Shorthand(CSSPropertyID::kBorderLeft, kProperty | kIdempotent | kValidForKeyframe | kValidForPageContext | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
};

// border-radius
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BorderRadius final : public Shorthand {
 public:
  constexpr BorderRadius() : Shorthand(CSSPropertyID::kBorderRadius, kProperty | kIdempotent | kValidForKeyframe | kValidForPageContext | kValidForPermissionElement, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// border-right
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BorderRight final : public Shorthand {
 public:
  constexpr BorderRight() : Shorthand(CSSPropertyID::kBorderRight, kProperty | kIdempotent | kValidForKeyframe | kValidForPageContext | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
};

// border-spacing
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BorderSpacing final : public Shorthand {
 public:
  constexpr BorderSpacing() : Shorthand(CSSPropertyID::kBorderSpacing, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// border-style
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BorderStyle final : public Shorthand {
 public:
  constexpr BorderStyle() : Shorthand(CSSPropertyID::kBorderStyle, kProperty | kIdempotent | kValidForKeyframe | kValidForPageContext, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// border-top
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BorderTop final : public Shorthand {
 public:
  constexpr BorderTop() : Shorthand(CSSPropertyID::kBorderTop, kProperty | kIdempotent | kValidForKeyframe | kValidForPageContext | kInLogicalPropertyGroup, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
  bool IsInSameLogicalPropertyGroupWithDifferentMappingLogic(CSSPropertyID) const override;
};

// border-width
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class BorderWidth final : public Shorthand {
 public:
  constexpr BorderWidth() : Shorthand(CSSPropertyID::kBorderWidth, kProperty | kIdempotent | kValidForKeyframe | kValidForPageContext, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// column-rule
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ColumnRule final : public Shorthand {
 public:
  constexpr ColumnRule() : Shorthand(CSSPropertyID::kColumnRule, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// columns
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Columns final : public Shorthand {
 public:
  constexpr Columns() : Shorthand(CSSPropertyID::kColumns, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// contain-intrinsic-size
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ContainIntrinsicSize final : public Shorthand {
 public:
  constexpr ContainIntrinsicSize() : Shorthand(CSSPropertyID::kContainIntrinsicSize, kProperty | kIdempotent | kValidForKeyframe | kValidForPermissionElement, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// container
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Container final : public Shorthand {
 public:
  constexpr Container() : Shorthand(CSSPropertyID::kContainer, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// flex
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Flex final : public Shorthand {
 public:
  constexpr Flex() : Shorthand(CSSPropertyID::kFlex, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// flex-flow
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class FlexFlow final : public Shorthand {
 public:
  constexpr FlexFlow() : Shorthand(CSSPropertyID::kFlexFlow, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// font
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Font final : public Shorthand {
 public:
  constexpr Font() : Shorthand(CSSPropertyID::kFont, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// font-synthesis
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class FontSynthesis final : public Shorthand {
 public:
  constexpr FontSynthesis() : Shorthand(CSSPropertyID::kFontSynthesis, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// font-variant
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class FontVariant final : public Shorthand {
 public:
  constexpr FontVariant() : Shorthand(CSSPropertyID::kFontVariant, kDescriptor | kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// gap
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Gap final : public Shorthand {
 public:
  constexpr Gap() : Shorthand(CSSPropertyID::kGap, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// grid
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Grid final : public Shorthand {
 public:
  constexpr Grid() : Shorthand(CSSPropertyID::kGrid, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool IsLayoutDependentProperty() const override { return true; }
  bool IsLayoutDependent(const ComputedStyle*, LayoutObject*) const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// grid-area
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class GridArea final : public Shorthand {
 public:
  constexpr GridArea() : Shorthand(CSSPropertyID::kGridArea, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// grid-column
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class GridColumn final : public Shorthand {
 public:
  constexpr GridColumn() : Shorthand(CSSPropertyID::kGridColumn, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// grid-row
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class GridRow final : public Shorthand {
 public:
  constexpr GridRow() : Shorthand(CSSPropertyID::kGridRow, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// grid-template
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class GridTemplate final : public Shorthand {
 public:
  constexpr GridTemplate() : Shorthand(CSSPropertyID::kGridTemplate, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool IsLayoutDependentProperty() const override { return true; }
  bool IsLayoutDependent(const ComputedStyle*, LayoutObject*) const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// inset
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Inset final : public Shorthand {
 public:
  constexpr Inset() : Shorthand(CSSPropertyID::kInset, kProperty | kIdempotent | kValidForKeyframe | kValidForPositionTry, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool IsLayoutDependentProperty() const override { return true; }
  bool IsLayoutDependent(const ComputedStyle*, LayoutObject*) const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// inset-block
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class InsetBlock final : public Shorthand {
 public:
  constexpr InsetBlock() : Shorthand(CSSPropertyID::kInsetBlock, kProperty | kIdempotent | kValidForKeyframe | kValidForPositionTry, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool IsLayoutDependentProperty() const override { return true; }
  bool IsLayoutDependent(const ComputedStyle*, LayoutObject*) const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// inset-inline
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class InsetInline final : public Shorthand {
 public:
  constexpr InsetInline() : Shorthand(CSSPropertyID::kInsetInline, kProperty | kIdempotent | kValidForKeyframe | kValidForPositionTry, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool IsLayoutDependentProperty() const override { return true; }
  bool IsLayoutDependent(const ComputedStyle*, LayoutObject*) const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// list-style
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ListStyle final : public Shorthand {
 public:
  constexpr ListStyle() : Shorthand(CSSPropertyID::kListStyle, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// margin
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Margin final : public Shorthand {
 public:
  constexpr Margin() : Shorthand(CSSPropertyID::kMargin, kProperty | kIdempotent | kValidForKeyframe | kValidForPositionTry | kValidForLimitedPageContext | kValidForPageContext | kValidForPermissionElement, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool IsLayoutDependentProperty() const override { return true; }
  bool IsLayoutDependent(const ComputedStyle*, LayoutObject*) const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// margin-block
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class MarginBlock final : public Shorthand {
 public:
  constexpr MarginBlock() : Shorthand(CSSPropertyID::kMarginBlock, kProperty | kIdempotent | kValidForKeyframe | kValidForPositionTry | kValidForLimitedPageContext | kValidForPageContext, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool IsLayoutDependentProperty() const override { return true; }
  bool IsLayoutDependent(const ComputedStyle*, LayoutObject*) const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// margin-inline
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class MarginInline final : public Shorthand {
 public:
  constexpr MarginInline() : Shorthand(CSSPropertyID::kMarginInline, kProperty | kIdempotent | kValidForKeyframe | kValidForPositionTry | kValidForLimitedPageContext | kValidForPageContext, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool IsLayoutDependentProperty() const override { return true; }
  bool IsLayoutDependent(const ComputedStyle*, LayoutObject*) const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// marker
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Marker final : public Shorthand {
 public:
  constexpr Marker() : Shorthand(CSSPropertyID::kMarker, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// mask
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Mask final : public Shorthand {
 public:
  constexpr Mask() : Shorthand(CSSPropertyID::kMask, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// mask-position
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class MaskPosition final : public Shorthand {
 public:
  constexpr MaskPosition() : Shorthand(CSSPropertyID::kMaskPosition, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// offset
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Offset final : public Shorthand {
 public:
  constexpr Offset() : Shorthand(CSSPropertyID::kOffset, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// outline
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Outline final : public Shorthand {
 public:
  constexpr Outline() : Shorthand(CSSPropertyID::kOutline, kProperty | kIdempotent | kValidForKeyframe | kValidForPageContext, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// overflow
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Overflow final : public Shorthand {
 public:
  constexpr Overflow() : Shorthand(CSSPropertyID::kOverflow, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// overscroll-behavior
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class OverscrollBehavior final : public Shorthand {
 public:
  constexpr OverscrollBehavior() : Shorthand(CSSPropertyID::kOverscrollBehavior, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// padding
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Padding final : public Shorthand {
 public:
  constexpr Padding() : Shorthand(CSSPropertyID::kPadding, kProperty | kSupportsIncrementalStyle | kIdempotent | kValidForKeyframe | kValidForPageContext, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool IsLayoutDependentProperty() const override { return true; }
  bool IsLayoutDependent(const ComputedStyle*, LayoutObject*) const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// padding-block
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class PaddingBlock final : public Shorthand {
 public:
  constexpr PaddingBlock() : Shorthand(CSSPropertyID::kPaddingBlock, kProperty | kIdempotent | kValidForKeyframe | kValidForPageContext, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// padding-inline
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class PaddingInline final : public Shorthand {
 public:
  constexpr PaddingInline() : Shorthand(CSSPropertyID::kPaddingInline, kProperty | kIdempotent | kValidForKeyframe | kValidForPageContext, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// page-break-after
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class PageBreakAfter final : public Shorthand {
 public:
  constexpr PageBreakAfter() : Shorthand(CSSPropertyID::kPageBreakAfter, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// page-break-before
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class PageBreakBefore final : public Shorthand {
 public:
  constexpr PageBreakBefore() : Shorthand(CSSPropertyID::kPageBreakBefore, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// page-break-inside
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class PageBreakInside final : public Shorthand {
 public:
  constexpr PageBreakInside() : Shorthand(CSSPropertyID::kPageBreakInside, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// place-content
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class PlaceContent final : public Shorthand {
 public:
  constexpr PlaceContent() : Shorthand(CSSPropertyID::kPlaceContent, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// place-items
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class PlaceItems final : public Shorthand {
 public:
  constexpr PlaceItems() : Shorthand(CSSPropertyID::kPlaceItems, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// place-self
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class PlaceSelf final : public Shorthand {
 public:
  constexpr PlaceSelf() : Shorthand(CSSPropertyID::kPlaceSelf, kProperty | kIdempotent | kValidForKeyframe | kValidForPositionTry, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// position-try
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class PositionTry final : public Shorthand {
 public:
  constexpr PositionTry() : Shorthand(CSSPropertyID::kPositionTry, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// scroll-margin
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ScrollMargin final : public Shorthand {
 public:
  constexpr ScrollMargin() : Shorthand(CSSPropertyID::kScrollMargin, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// scroll-margin-block
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ScrollMarginBlock final : public Shorthand {
 public:
  constexpr ScrollMarginBlock() : Shorthand(CSSPropertyID::kScrollMarginBlock, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// scroll-margin-inline
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ScrollMarginInline final : public Shorthand {
 public:
  constexpr ScrollMarginInline() : Shorthand(CSSPropertyID::kScrollMarginInline, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// scroll-padding
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ScrollPadding final : public Shorthand {
 public:
  constexpr ScrollPadding() : Shorthand(CSSPropertyID::kScrollPadding, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// scroll-padding-block
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ScrollPaddingBlock final : public Shorthand {
 public:
  constexpr ScrollPaddingBlock() : Shorthand(CSSPropertyID::kScrollPaddingBlock, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// scroll-padding-inline
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ScrollPaddingInline final : public Shorthand {
 public:
  constexpr ScrollPaddingInline() : Shorthand(CSSPropertyID::kScrollPaddingInline, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// scroll-start
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ScrollStart final : public Shorthand {
 public:
  constexpr ScrollStart() : Shorthand(CSSPropertyID::kScrollStart, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// scroll-start-target
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ScrollStartTarget final : public Shorthand {
 public:
  constexpr ScrollStartTarget() : Shorthand(CSSPropertyID::kScrollStartTarget, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// scroll-timeline
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ScrollTimeline final : public Shorthand {
 public:
  constexpr ScrollTimeline() : Shorthand(CSSPropertyID::kScrollTimeline, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// text-decoration
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class TextDecoration final : public Shorthand {
 public:
  constexpr TextDecoration() : Shorthand(CSSPropertyID::kTextDecoration, kProperty | kIdempotent | kValidForKeyframe | kValidForPageContext, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// text-emphasis
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class TextEmphasis final : public Shorthand {
 public:
  constexpr TextEmphasis() : Shorthand(CSSPropertyID::kTextEmphasis, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// text-spacing
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class TextSpacing final : public Shorthand {
 public:
  constexpr TextSpacing() : Shorthand(CSSPropertyID::kTextSpacing, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// transition
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class Transition final : public Shorthand {
 public:
  constexpr Transition() : Shorthand(CSSPropertyID::kTransition, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// view-timeline
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class ViewTimeline final : public Shorthand {
 public:
  constexpr ViewTimeline() : Shorthand(CSSPropertyID::kViewTimeline, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// -webkit-column-break-after
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitColumnBreakAfter final : public Shorthand {
 public:
  constexpr WebkitColumnBreakAfter() : Shorthand(CSSPropertyID::kWebkitColumnBreakAfter, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// -webkit-column-break-before
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitColumnBreakBefore final : public Shorthand {
 public:
  constexpr WebkitColumnBreakBefore() : Shorthand(CSSPropertyID::kWebkitColumnBreakBefore, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// -webkit-column-break-inside
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitColumnBreakInside final : public Shorthand {
 public:
  constexpr WebkitColumnBreakInside() : Shorthand(CSSPropertyID::kWebkitColumnBreakInside, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// -webkit-mask-box-image
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitMaskBoxImage final : public Shorthand {
 public:
  constexpr WebkitMaskBoxImage() : Shorthand(CSSPropertyID::kWebkitMaskBoxImage, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// -webkit-text-stroke
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitTextStroke final : public Shorthand {
 public:
  constexpr WebkitTextStroke() : Shorthand(CSSPropertyID::kWebkitTextStroke, kProperty | kIdempotent | kValidForKeyframe, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// white-space
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WhiteSpace final : public Shorthand {
 public:
  constexpr WhiteSpace() : Shorthand(CSSPropertyID::kWhiteSpace, kProperty | kIdempotent | kValidForKeyframe | kValidForPageContext, '\0') { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  bool ParseShorthand(bool, CSSParserTokenStream&, const CSSParserContext&, const CSSParserLocalContext&, std::vector<CSSPropertyValue>&) const override;
  const CSSValue* CSSValueFromComputedStyleInternal(const ComputedStyle&, const LayoutObject*, bool allow_visited_style, CSSValuePhase value_phase) const override;
};

// -webkit-border-after
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitBorderAfter final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitBorderAfter() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-border-before
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitBorderBefore final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitBorderBefore() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-border-end
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitBorderEnd final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitBorderEnd() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-border-start
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitBorderStart final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitBorderStart() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-mask
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitMask final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitMask() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-mask-position
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitMaskPosition final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitMaskPosition() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -epub-text-emphasis
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class EpubTextEmphasis final : public CSSUnresolvedProperty {
 public:
  constexpr EpubTextEmphasis() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-animation
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitAnimation final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitAnimation() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
  CSSPropertyID GetAlternative() const override {
    return CSSPropertyID::kAliasWebkitAlternativeAnimationWithTimeline;
  }
};

// -webkit-alternative-animation-with-timeline
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitAlternativeAnimationWithTimeline final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitAlternativeAnimationWithTimeline() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
  CSSExposure Exposure(const ExecutingContext*) const override;
};

// -webkit-border-radius
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitBorderRadius final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitBorderRadius() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-column-rule
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitColumnRule final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitColumnRule() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-columns
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitColumns final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitColumns() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-flex
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitFlex final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitFlex() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-flex-flow
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitFlexFlow final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitFlexFlow() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-text-emphasis
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitTextEmphasis final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitTextEmphasis() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// -webkit-transition
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class WebkitTransition final : public CSSUnresolvedProperty {
 public:
  constexpr WebkitTransition() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

// grid-gap
// NOTE: Multiple inheritance is not allowed here, since the class must be
// reinterpret_cast-able to CSSUnresolvedProperty. See css_property_instances.cc.tmpl
// (the cast happens in GetPropertyInternal()).
class GridGap final : public CSSUnresolvedProperty {
 public:
  constexpr GridGap() : CSSUnresolvedProperty() { }
  const char* GetPropertyName() const override;
  const AtomicString& GetPropertyNameAtomicString() const override;
  const char* GetJSPropertyName() const override;
};

 
}  // namespace css_shorthand

}  // namespace webf

#endif  // WEBF_SHORTHANDS_H
