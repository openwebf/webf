/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "style_builder.h"

#include "core/css/css_identifier_value.h"
#include "core/css/css_primitive_value.h"
#include "core/css/css_value_list.h"
#include "core/css/css_color.h"
#include "core/css/resolver/style_resolver_state.h"
#include "core/style/computed_style.h"

namespace webf {

void StyleBuilder::ApplyProperty(CSSPropertyID property_id,
                               StyleResolverState& state,
                               const CSSValue& value) {
  
  // Handle CSS-wide keywords
  if (value.IsInitialValue()) {
    ApplyInitialProperty(property_id, state);
    return;
  }
  
  if (value.IsInheritedValue()) {
    ApplyInheritedProperty(property_id, state);
    return;
  }
  
  if (value.IsUnsetValue()) {
    ApplyUnsetProperty(property_id, state);
    return;
  }
  
  // Apply specific property handlers
  switch (property_id) {
    case CSSPropertyID::kColor:
      ApplyColorProperty(state, value);
      break;
    case CSSPropertyID::kBackgroundColor:
      ApplyBackgroundColorProperty(state, value);
      break;
    case CSSPropertyID::kDisplay:
      ApplyDisplayProperty(state, value);
      break;
    case CSSPropertyID::kPosition:
      ApplyPositionProperty(state, value);
      break;
    case CSSPropertyID::kWidth:
      ApplyWidthProperty(state, value);
      break;
    case CSSPropertyID::kHeight:
      ApplyHeightProperty(state, value);
      break;
    case CSSPropertyID::kMarginTop:
    case CSSPropertyID::kMarginRight:
    case CSSPropertyID::kMarginBottom:
    case CSSPropertyID::kMarginLeft:
      ApplyMarginProperty(property_id, state, value);
      break;
    case CSSPropertyID::kPaddingTop:
    case CSSPropertyID::kPaddingRight:
    case CSSPropertyID::kPaddingBottom:
    case CSSPropertyID::kPaddingLeft:
      ApplyPaddingProperty(property_id, state, value);
      break;
    case CSSPropertyID::kBorderTopWidth:
    case CSSPropertyID::kBorderRightWidth:
    case CSSPropertyID::kBorderBottomWidth:
    case CSSPropertyID::kBorderLeftWidth:
    case CSSPropertyID::kBorderTopColor:
    case CSSPropertyID::kBorderRightColor:
    case CSSPropertyID::kBorderBottomColor:
    case CSSPropertyID::kBorderLeftColor:
    case CSSPropertyID::kBorderTopStyle:
    case CSSPropertyID::kBorderRightStyle:
    case CSSPropertyID::kBorderBottomStyle:
    case CSSPropertyID::kBorderLeftStyle:
      ApplyBorderProperty(property_id, state, value);
      break;
    case CSSPropertyID::kFontFamily:
    case CSSPropertyID::kFontSize:
    case CSSPropertyID::kFontWeight:
    case CSSPropertyID::kFontStyle:
    case CSSPropertyID::kLineHeight:
      ApplyFontProperty(property_id, state, value);
      break;
    case CSSPropertyID::kTextAlign:
    case CSSPropertyID::kTextDecoration:
    case CSSPropertyID::kTextTransform:
    case CSSPropertyID::kTextIndent:
    case CSSPropertyID::kLetterSpacing:
    case CSSPropertyID::kWordSpacing:
      ApplyTextProperty(property_id, state, value);
      break;
    case CSSPropertyID::kFlexDirection:
    case CSSPropertyID::kFlexWrap:
    case CSSPropertyID::kFlexGrow:
    case CSSPropertyID::kFlexShrink:
    case CSSPropertyID::kFlexBasis:
    case CSSPropertyID::kJustifyContent:
    case CSSPropertyID::kAlignItems:
    case CSSPropertyID::kAlignContent:
      ApplyFlexProperty(property_id, state, value);
      break;
    case CSSPropertyID::kTransform:
      ApplyTransformProperty(state, value);
      break;
    case CSSPropertyID::kOpacity:
      ApplyOpacityProperty(state, value);
      break;
    case CSSPropertyID::kOverflowX:
    case CSSPropertyID::kOverflowY:
      ApplyOverflowProperty(property_id, state, value);
      break;
    case CSSPropertyID::kZIndex:
      ApplyZIndexProperty(state, value);
      break;
    default:
      // TODO: Implement more property handlers
      break;
  }
}

void StyleBuilder::ApplyInitialProperty(CSSPropertyID property_id,
                                      StyleResolverState& state) {
  // TODO: Apply initial value for the property
  // This would reset the property to its initial value
}

void StyleBuilder::ApplyInheritedProperty(CSSPropertyID property_id,
                                        StyleResolverState& state) {
  // TODO: Apply inherited value for the property
  // This would copy the value from the parent style
}

void StyleBuilder::ApplyUnsetProperty(CSSPropertyID property_id,
                                    StyleResolverState& state) {
  // TODO: Apply unset value for the property
  // This would either inherit or reset to initial based on whether
  // the property is inherited by default
}

void StyleBuilder::ApplyAllProperty(StyleResolverState& state,
                                  const CSSValue& value,
                                  TextDirection direction,
                                  CSSPropertyValueSet::PropertySetFlag flag) {
  // TODO: Implement 'all' property handling
  // This would apply the given value to all properties
}

void StyleBuilder::ApplyColorProperty(StyleResolverState& state,
                                    const CSSValue& value) {
  if (value.IsColorValue()) {
    const auto& color_value = static_cast<const cssvalue::CSSColor&>(value);
    state.StyleBuilder().SetColor(color_value.Value());
  } else if (value.IsIdentifierValue()) {
    // TODO: Handle color keywords like 'red', 'blue', etc.
  }
}

void StyleBuilder::ApplyBackgroundColorProperty(StyleResolverState& state,
                                              const CSSValue& value) {
  if (value.IsColorValue()) {
    const auto& color_value = static_cast<const cssvalue::CSSColor&>(value);
    state.StyleBuilder().SetBackgroundColor(color_value.Value());
  } else if (value.IsIdentifierValue()) {
    // TODO: Handle color keywords like 'transparent', 'currentColor', etc.
  }
}

void StyleBuilder::ApplyDisplayProperty(StyleResolverState& state,
                                      const CSSValue& value) {
  if (value.IsIdentifierValue()) {
    const auto& ident_value = static_cast<const CSSIdentifierValue&>(value);
    EDisplay display = EDisplay::kInline;
    
    switch (ident_value.GetValueID()) {
      case CSSValueID::kBlock:
        display = EDisplay::kBlock;
        break;
      case CSSValueID::kInline:
        display = EDisplay::kInline;
        break;
      case CSSValueID::kInlineBlock:
        display = EDisplay::kInlineBlock;
        break;
      case CSSValueID::kFlex:
        display = EDisplay::kFlex;
        break;
      case CSSValueID::kInlineFlex:
        display = EDisplay::kInlineFlex;
        break;
      case CSSValueID::kNone:
        display = EDisplay::kNone;
        break;
      case CSSValueID::kContents:
        display = EDisplay::kContents;
        break;
      default:
        break;
    }
    
    state.StyleBuilder().SetDisplay(display);
  }
}

void StyleBuilder::ApplyPositionProperty(StyleResolverState& state,
                                       const CSSValue& value) {
  if (value.IsIdentifierValue()) {
    const auto& ident_value = static_cast<const CSSIdentifierValue&>(value);
    EPosition position = EPosition::kStatic;
    
    switch (ident_value.GetValueID()) {
      case CSSValueID::kStatic:
        position = EPosition::kStatic;
        break;
      case CSSValueID::kRelative:
        position = EPosition::kRelative;
        break;
      case CSSValueID::kAbsolute:
        position = EPosition::kAbsolute;
        break;
      case CSSValueID::kFixed:
        position = EPosition::kFixed;
        break;
      case CSSValueID::kSticky:
        position = EPosition::kSticky;
        break;
      default:
        break;
    }
    
    state.StyleBuilder().SetPosition(position);
  }
}

void StyleBuilder::ApplyWidthProperty(StyleResolverState& state,
                                    const CSSValue& value) {
  // TODO: Implement width property handling
  // This would parse length values and apply them
}

void StyleBuilder::ApplyHeightProperty(StyleResolverState& state,
                                     const CSSValue& value) {
  // TODO: Implement height property handling
  // This would parse length values and apply them
}

void StyleBuilder::ApplyMarginProperty(CSSPropertyID property_id,
                                     StyleResolverState& state,
                                     const CSSValue& value) {
  // TODO: Implement margin property handling
  // This would parse length values and apply them to the appropriate side
}

void StyleBuilder::ApplyPaddingProperty(CSSPropertyID property_id,
                                      StyleResolverState& state,
                                      const CSSValue& value) {
  // TODO: Implement padding property handling
  // This would parse length values and apply them to the appropriate side
}

void StyleBuilder::ApplyBorderProperty(CSSPropertyID property_id,
                                     StyleResolverState& state,
                                     const CSSValue& value) {
  // TODO: Implement border property handling
  // This would handle border width, color, and style
}

void StyleBuilder::ApplyFontProperty(CSSPropertyID property_id,
                                   StyleResolverState& state,
                                   const CSSValue& value) {
  // TODO: Implement font property handling
  // This would handle font family, size, weight, style, etc.
}

void StyleBuilder::ApplyTextProperty(CSSPropertyID property_id,
                                   StyleResolverState& state,
                                   const CSSValue& value) {
  // TODO: Implement text property handling
  // This would handle text alignment, decoration, transform, etc.
}

void StyleBuilder::ApplyFlexProperty(CSSPropertyID property_id,
                                   StyleResolverState& state,
                                   const CSSValue& value) {
  // TODO: Implement flex property handling
  // This would handle flex container and item properties
}

void StyleBuilder::ApplyTransformProperty(StyleResolverState& state,
                                        const CSSValue& value) {
  // TODO: Implement transform property handling
  // This would parse transform functions and apply them
}

void StyleBuilder::ApplyOpacityProperty(StyleResolverState& state,
                                      const CSSValue& value) {
  if (value.IsPrimitiveValue()) {
    const auto& primitive_value = static_cast<const CSSPrimitiveValue&>(value);
    if (primitive_value.IsNumber()) {
      float opacity = primitive_value.GetFloatValue();
      state.StyleBuilder().SetOpacity(opacity);
    }
  }
}

void StyleBuilder::ApplyOverflowProperty(CSSPropertyID property_id,
                                       StyleResolverState& state,
                                       const CSSValue& value) {
  if (value.IsIdentifierValue()) {
    const auto& ident_value = static_cast<const CSSIdentifierValue&>(value);
    EOverflow overflow = EOverflow::kVisible;
    
    switch (ident_value.GetValueID()) {
      case CSSValueID::kVisible:
        overflow = EOverflow::kVisible;
        break;
      case CSSValueID::kHidden:
        overflow = EOverflow::kHidden;
        break;
      case CSSValueID::kScroll:
        overflow = EOverflow::kScroll;
        break;
      case CSSValueID::kAuto:
        overflow = EOverflow::kAuto;
        break;
      case CSSValueID::kClip:
        overflow = EOverflow::kClip;
        break;
      default:
        break;
    }
    
    if (property_id == CSSPropertyID::kOverflowX) {
      state.StyleBuilder().SetOverflowX(overflow);
    } else {
      state.StyleBuilder().SetOverflowY(overflow);
    }
  }
}

void StyleBuilder::ApplyZIndexProperty(StyleResolverState& state,
                                     const CSSValue& value) {
  if (value.IsIdentifierValue()) {
    const auto& ident_value = static_cast<const CSSIdentifierValue&>(value);
    if (ident_value.GetValueID() == CSSValueID::kAuto) {
      state.StyleBuilder().SetZIndex(0);
      state.StyleBuilder().SetHasAutoZIndex(true);
    }
  } else if (value.IsPrimitiveValue()) {
    const auto& primitive_value = static_cast<const CSSPrimitiveValue&>(value);
    if (primitive_value.IsInteger()) {
      state.StyleBuilder().SetZIndex(primitive_value.GetIntValue());
      state.StyleBuilder().SetHasAutoZIndex(false);
    }
  }
}

}  // namespace webf