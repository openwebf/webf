/*
 * Copyright (C) 2000 Lars Knoll (knoll@kde.org)
 *           (C) 2000 Antti Koivisto (koivisto@kde.org)
 *           (C) 2000 Dirk Mueller (mueller@kde.org)
 * Copyright (C) 2003, 2005, 2006, 2007, 2008, 2009, 2010, 2011 Apple Inc. All rights reserved.
 * Copyright (C) 2006 Graham Dennis (graham.dennis@gmail.com)
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public License
 * along with this library; see the file COPYING.LIB.  If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301, USA.
 *
 */

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_STYLE_COMPUTED_STYLE_H
#define WEBF_CORE_STYLE_COMPUTED_STYLE_H

#include <memory>
#include "code_gen/css_property_names.h"
#include "core/style/computed_style_constants.h"
#include "core/style/computed_style_base_constants.h"
#include "core/platform/fonts/font_description.h"
#include "core/platform/fonts/font.h"
#include "foundation/macros.h"
#include "foundation/atomic_string.h"
#include "core/platform/graphics/color.h"
#include "core/platform/geometry/length.h"
#include "core/platform/geometry/layout_unit.h"
#include "core/platform/text/text_direction.h"
#include "core/platform/text/writing_mode.h"

namespace webf {

class ComputedStyleBuilder;

// Typedef for TextDecoration which is a bitmask of TextDecorationLine values
using TextDecoration = uint8_t;

// Represents the computed style for an element
class ComputedStyle : public std::enable_shared_from_this<ComputedStyle> {

 public:
  ComputedStyle();
  ComputedStyle(const ComputedStyle& other);
  
  // Create the initial style singleton
  static const ComputedStyle& GetInitialStyle();
  
  // Clone this style
  std::unique_ptr<ComputedStyle> Clone() const;
  
  // Clone for style builder
  std::unique_ptr<ComputedStyleBuilder> CloneAsBuilder() const;
  
  // Display property
  EDisplay Display() const { return display_; }
  void SetDisplay(EDisplay display) { display_ = display; }
  
  // Position property
  EPosition Position() const { return position_; }
  void SetPosition(EPosition position) { position_ = position; }
  
  // Overflow properties
  EOverflow OverflowX() const { return overflow_x_; }
  void SetOverflowX(EOverflow overflow) { overflow_x_ = overflow; }
  
  EOverflow OverflowY() const { return overflow_y_; }
  void SetOverflowY(EOverflow overflow) { overflow_y_ = overflow; }
  
  // Direction
  TextDirection GetDirection() const { return direction_; }
  void SetDirection(TextDirection direction) { direction_ = direction; }
  
  // Writing mode
  WritingMode GetWritingMode() const { return writing_mode_; }
  void SetWritingMode(WritingMode mode) { writing_mode_ = mode; }
  
  // Colors
  const Color& Color() const { return color_; }
  void SetColor(const ::webf::Color& color) { color_ = color; }
  
  const ::webf::Color& BackgroundColor() const { return background_color_; }
  void SetBackgroundColor(const ::webf::Color& color) { background_color_ = color; }
  
  // Font
  const FontDescription& GetFontDescription() const { return font_description_; }
  void SetFontDescription(const FontDescription& desc) { font_description_ = desc; }
  
  float GetFontSize() const { return font_description_.ComputedSize(); }
  
  // Get Font object - returns by value since Font uses WEBF_DISALLOW_NEW
  Font GetFont() const { 
    return Font(font_description_);
  }
  
  // Opacity
  float Opacity() const { return opacity_; }
  void SetOpacity(float opacity) { opacity_ = opacity; }
  
  // Z-index
  int ZIndex() const { return z_index_; }
  void SetZIndex(int z_index) { z_index_ = z_index; }
  
  bool HasAutoZIndex() const { return has_auto_z_index_; }
  void SetHasAutoZIndex(bool has_auto) { has_auto_z_index_ = has_auto; }
  
  // Box model - dimensions
  const Length& Width() const { return width_; }
  void SetWidth(const Length& width) { width_ = width; }
  
  const Length& Height() const { return height_; }
  void SetHeight(const Length& height) { height_ = height; }
  
  const Length& MinWidth() const { return min_width_; }
  void SetMinWidth(const Length& width) { min_width_ = width; }
  
  const Length& MinHeight() const { return min_height_; }
  void SetMinHeight(const Length& height) { min_height_ = height; }
  
  const Length& MaxWidth() const { return max_width_; }
  void SetMaxWidth(const Length& width) { max_width_ = width; }
  
  const Length& MaxHeight() const { return max_height_; }
  void SetMaxHeight(const Length& height) { max_height_ = height; }
  
  // Box model - margins
  const Length& MarginTop() const { return margin_top_; }
  void SetMarginTop(const Length& margin) { margin_top_ = margin; }
  
  const Length& MarginRight() const { return margin_right_; }
  void SetMarginRight(const Length& margin) { margin_right_ = margin; }
  
  const Length& MarginBottom() const { return margin_bottom_; }
  void SetMarginBottom(const Length& margin) { margin_bottom_ = margin; }
  
  const Length& MarginLeft() const { return margin_left_; }
  void SetMarginLeft(const Length& margin) { margin_left_ = margin; }
  
  // Box model - padding
  const Length& PaddingTop() const { return padding_top_; }
  void SetPaddingTop(const Length& padding) { padding_top_ = padding; }
  
  const Length& PaddingRight() const { return padding_right_; }
  void SetPaddingRight(const Length& padding) { padding_right_ = padding; }
  
  const Length& PaddingBottom() const { return padding_bottom_; }
  void SetPaddingBottom(const Length& padding) { padding_bottom_ = padding; }
  
  const Length& PaddingLeft() const { return padding_left_; }
  void SetPaddingLeft(const Length& padding) { padding_left_ = padding; }
  
  // Border widths
  LayoutUnit BorderTopWidth() const { return border_top_width_; }
  void SetBorderTopWidth(LayoutUnit width) { border_top_width_ = width; }
  
  LayoutUnit BorderRightWidth() const { return border_right_width_; }
  void SetBorderRightWidth(LayoutUnit width) { border_right_width_ = width; }
  
  LayoutUnit BorderBottomWidth() const { return border_bottom_width_; }
  void SetBorderBottomWidth(LayoutUnit width) { border_bottom_width_ = width; }
  
  LayoutUnit BorderLeftWidth() const { return border_left_width_; }
  void SetBorderLeftWidth(LayoutUnit width) { border_left_width_ = width; }
  
  // Border styles
  EBorderStyle BorderTopStyle() const { return border_top_style_; }
  void SetBorderTopStyle(EBorderStyle style) { border_top_style_ = style; }
  
  EBorderStyle BorderRightStyle() const { return border_right_style_; }
  void SetBorderRightStyle(EBorderStyle style) { border_right_style_ = style; }
  
  EBorderStyle BorderBottomStyle() const { return border_bottom_style_; }
  void SetBorderBottomStyle(EBorderStyle style) { border_bottom_style_ = style; }
  
  EBorderStyle BorderLeftStyle() const { return border_left_style_; }
  void SetBorderLeftStyle(EBorderStyle style) { border_left_style_ = style; }
  
  // Border colors
  const ::webf::Color& BorderTopColor() const { return border_top_color_; }
  void SetBorderTopColor(const ::webf::Color& color) { border_top_color_ = color; }
  
  const ::webf::Color& BorderRightColor() const { return border_right_color_; }
  void SetBorderRightColor(const ::webf::Color& color) { border_right_color_ = color; }
  
  const ::webf::Color& BorderBottomColor() const { return border_bottom_color_; }
  void SetBorderBottomColor(const ::webf::Color& color) { border_bottom_color_ = color; }
  
  const ::webf::Color& BorderLeftColor() const { return border_left_color_; }
  void SetBorderLeftColor(const ::webf::Color& color) { border_left_color_ = color; }
  
  // Positioning offsets
  const Length& Top() const { return top_; }
  void SetTop(const Length& top) { top_ = top; }
  
  const Length& Right() const { return right_; }
  void SetRight(const Length& right) { right_ = right; }
  
  const Length& Bottom() const { return bottom_; }
  void SetBottom(const Length& bottom) { bottom_ = bottom; }
  
  const Length& Left() const { return left_; }
  void SetLeft(const Length& left) { left_ = left; }
  
  // Text properties
  ETextAlign TextAlign() const { return text_align_; }
  void SetTextAlign(ETextAlign align) { text_align_ = align; }
  
  ::webf::TextDecoration GetTextDecoration() const { return text_decoration_; }
  void SetTextDecoration(::webf::TextDecoration decoration) { text_decoration_ = decoration; }
  
  ETextTransform TextTransform() const { return text_transform_; }
  void SetTextTransform(ETextTransform transform) { text_transform_ = transform; }
  
  const Length& LineHeight() const { return line_height_; }
  void SetLineHeight(const Length& height) { line_height_ = height; }
  
  // Layout properties
  EFloat Float() const { return float_; }
  void SetFloat(EFloat float_value) { float_ = float_value; }
  
  EClear Clear() const { return clear_; }
  void SetClear(EClear clear) { clear_ = clear; }
  
  EOverflow Overflow() const { return overflow_x_; } // For shorthand
  void SetOverflow(EOverflow overflow) { 
    overflow_x_ = overflow; 
    overflow_y_ = overflow; 
  }
  
  // Visibility
  EVisibility Visibility() const { return visibility_; }
  void SetVisibility(EVisibility visibility) { visibility_ = visibility; }
  
  // Flexbox properties
  EFlexDirection FlexDirection() const { return flex_direction_; }
  void SetFlexDirection(EFlexDirection direction) { flex_direction_ = direction; }
  
  EFlexWrap FlexWrap() const { return flex_wrap_; }
  void SetFlexWrap(EFlexWrap wrap) { flex_wrap_ = wrap; }
  
  ContentPosition JustifyContent() const { return justify_content_; }
  void SetJustifyContent(ContentPosition position) { justify_content_ = position; }
  
  ItemPosition AlignItems() const { return align_items_; }
  void SetAlignItems(ItemPosition position) { align_items_ = position; }
  
  ContentPosition AlignContent() const { return align_content_; }
  void SetAlignContent(ContentPosition position) { align_content_ = position; }
  
  float FlexGrow() const { return flex_grow_; }
  void SetFlexGrow(float grow) { flex_grow_ = grow; }
  
  float FlexShrink() const { return flex_shrink_; }
  void SetFlexShrink(float shrink) { flex_shrink_ = shrink; }
  
  const Length& FlexBasis() const { return flex_basis_; }
  void SetFlexBasis(const Length& basis) { flex_basis_ = basis; }
  
  // Writing direction
  TextDirection Direction() const { return direction_; }
  // WritingMode GetWritingMode() is already declared above
  
  // Locale
  const AtomicString& Locale() const { return locale_; }
  void SetLocale(const AtomicString& locale) { locale_ = locale; }
  
  // Quirks mode
  bool IsQuirksModeDocumentForView() const { return is_quirks_mode_document_; }
  void SetIsQuirksModeDocumentForView(bool quirks) { is_quirks_mode_document_ = quirks; }
  
  // Forced color adjust
  EForcedColorAdjust ForcedColorAdjust() const { return forced_color_adjust_; }
  void SetForcedColorAdjust(EForcedColorAdjust adjust) { forced_color_adjust_ = adjust; }
  
  // Zoom
  float EffectiveZoom() const { return effective_zoom_; }
  void SetEffectiveZoom(float zoom) { effective_zoom_ = zoom; }
  
  // Specified line height
  Length SpecifiedLineHeight() const { return line_height_; }
  
  // Inheritance checks
  bool InheritedEqual(const ComputedStyle& other) const;
  bool NonInheritedEqual(const ComputedStyle& other) const;

 private:
  // Non-inherited properties
  EDisplay display_ = EDisplay::kInline;
  EPosition position_ = EPosition::kStatic;
  EOverflow overflow_x_ = EOverflow::kVisible;
  EOverflow overflow_y_ = EOverflow::kVisible;
  float opacity_ = 1.0f;
  int z_index_ = 0;
  bool has_auto_z_index_ = true;
  ::webf::Color background_color_ = ::webf::Color::kTransparent;
  
  // Box model - dimensions
  Length width_ = Length::Auto();
  Length height_ = Length::Auto();
  Length min_width_ = Length::Auto();
  Length min_height_ = Length::Auto();
  Length max_width_ = Length::None();
  Length max_height_ = Length::None();
  
  // Box model - margins
  Length margin_top_ = Length::Fixed(0);
  Length margin_right_ = Length::Fixed(0);
  Length margin_bottom_ = Length::Fixed(0);
  Length margin_left_ = Length::Fixed(0);
  
  // Box model - padding
  Length padding_top_ = Length::Fixed(0);
  Length padding_right_ = Length::Fixed(0);
  Length padding_bottom_ = Length::Fixed(0);
  Length padding_left_ = Length::Fixed(0);
  
  // Border properties
  LayoutUnit border_top_width_ = LayoutUnit(0);
  LayoutUnit border_right_width_ = LayoutUnit(0);
  LayoutUnit border_bottom_width_ = LayoutUnit(0);
  LayoutUnit border_left_width_ = LayoutUnit(0);
  
  EBorderStyle border_top_style_ = EBorderStyle::kNone;
  EBorderStyle border_right_style_ = EBorderStyle::kNone;
  EBorderStyle border_bottom_style_ = EBorderStyle::kNone;
  EBorderStyle border_left_style_ = EBorderStyle::kNone;
  
  ::webf::Color border_top_color_ = ::webf::Color::kBlack;
  ::webf::Color border_right_color_ = ::webf::Color::kBlack;
  ::webf::Color border_bottom_color_ = ::webf::Color::kBlack;
  ::webf::Color border_left_color_ = ::webf::Color::kBlack;
  
  // Positioning offsets
  Length top_ = Length::Auto();
  Length right_ = Length::Auto();
  Length bottom_ = Length::Auto();
  Length left_ = Length::Auto();
  
  // Layout properties
  EFloat float_ = EFloat::kNone;
  EClear clear_ = EClear::kNone;
  EVisibility visibility_ = EVisibility::kVisible;
  
  // Flexbox properties
  EFlexDirection flex_direction_ = EFlexDirection::kRow;
  EFlexWrap flex_wrap_ = EFlexWrap::kNowrap;
  ContentPosition justify_content_ = ContentPosition::kNormal;
  ItemPosition align_items_ = ItemPosition::kNormal;
  ContentPosition align_content_ = ContentPosition::kNormal;
  float flex_grow_ = 0.0f;
  float flex_shrink_ = 1.0f;
  Length flex_basis_ = Length::Auto();
  
  // Inherited properties
  TextDirection direction_ = TextDirection::kLtr;
  WritingMode writing_mode_ = WritingMode::kHorizontalTb;
  ::webf::Color color_ = ::webf::Color::kBlack;
  FontDescription font_description_;
  AtomicString locale_;
  bool is_quirks_mode_document_ = false;
  
  // Text properties (inherited)
  ETextAlign text_align_ = ETextAlign::kStart;
  uint8_t text_decoration_ = 0; // Will use TextDecorationLine values
  ETextTransform text_transform_ = ETextTransform::kNone;
  Length line_height_ = Length::Auto();
  
  // Color adjustment properties (inherited)
  EForcedColorAdjust forced_color_adjust_ = EForcedColorAdjust::kAuto;
  
  // Zoom
  float effective_zoom_ = 1.0f;
  
  friend class ComputedStyleBuilder;
};

// Builder pattern for ComputedStyle
class ComputedStyleBuilder {

 public:
  ComputedStyleBuilder();
  explicit ComputedStyleBuilder(const ComputedStyle& style);
  ~ComputedStyleBuilder();
  
  // Delete copy operations
  ComputedStyleBuilder(const ComputedStyleBuilder&) = delete;
  ComputedStyleBuilder& operator=(const ComputedStyleBuilder&) = delete;
  
  // Allow move operations
  ComputedStyleBuilder(ComputedStyleBuilder&&) = default;
  ComputedStyleBuilder& operator=(ComputedStyleBuilder&&) = default;
  
  // Take the built style
  std::shared_ptr<const ComputedStyle> TakeStyle();
  
  // Display
  ComputedStyleBuilder& SetDisplay(EDisplay display) {
    style_->SetDisplay(display);
    return *this;
  }
  
  // Position
  ComputedStyleBuilder& SetPosition(EPosition position) {
    style_->SetPosition(position);
    return *this;
  }
  
  // Overflow
  ComputedStyleBuilder& SetOverflowX(EOverflow overflow) {
    style_->SetOverflowX(overflow);
    return *this;
  }
  
  ComputedStyleBuilder& SetOverflowY(EOverflow overflow) {
    style_->SetOverflowY(overflow);
    return *this;
  }
  
  // Direction
  ComputedStyleBuilder& SetDirection(TextDirection direction) {
    style_->SetDirection(direction);
    return *this;
  }
  
  // Writing mode
  ComputedStyleBuilder& SetWritingMode(WritingMode mode) {
    style_->SetWritingMode(mode);
    return *this;
  }
  
  // Colors
  ComputedStyleBuilder& SetColor(const ::webf::Color& color) {
    style_->SetColor(color);
    return *this;
  }
  
  const ::webf::Color& Color() const {
    return style_->Color();
  }
  
  ComputedStyleBuilder& SetBackgroundColor(const ::webf::Color& color) {
    style_->SetBackgroundColor(color);
    return *this;
  }
  
  // Font
  ComputedStyleBuilder& SetFontDescription(const FontDescription& desc) {
    style_->SetFontDescription(desc);
    return *this;
  }
  
  ComputedStyleBuilder& SetFontSize(float size) {
    FontDescription desc = style_->GetFontDescription();
    desc.SetComputedSize(size);
    desc.SetSpecifiedSize(size);
    style_->SetFontDescription(desc);
    return *this;
  }
  
  // Opacity
  ComputedStyleBuilder& SetOpacity(float opacity) {
    style_->SetOpacity(opacity);
    return *this;
  }
  
  // Z-index
  ComputedStyleBuilder& SetZIndex(int z_index) {
    style_->SetZIndex(z_index);
    return *this;
  }
  
  ComputedStyleBuilder& SetHasAutoZIndex(bool has_auto) {
    style_->SetHasAutoZIndex(has_auto);
    return *this;
  }
  
  // Locale
  ComputedStyleBuilder& SetLocale(const AtomicString& locale) {
    style_->SetLocale(locale);
    return *this;
  }
  
  // Forced color adjust
  ComputedStyleBuilder& SetForcedColorAdjust(EForcedColorAdjust adjust) {
    style_->SetForcedColorAdjust(adjust);
    return *this;
  }
  
  // Box model - dimensions
  ComputedStyleBuilder& SetWidth(const Length& width) {
    style_->SetWidth(width);
    return *this;
  }
  
  ComputedStyleBuilder& SetHeight(const Length& height) {
    style_->SetHeight(height);
    return *this;
  }
  
  ComputedStyleBuilder& SetMinWidth(const Length& width) {
    style_->SetMinWidth(width);
    return *this;
  }
  
  ComputedStyleBuilder& SetMinHeight(const Length& height) {
    style_->SetMinHeight(height);
    return *this;
  }
  
  ComputedStyleBuilder& SetMaxWidth(const Length& width) {
    style_->SetMaxWidth(width);
    return *this;
  }
  
  ComputedStyleBuilder& SetMaxHeight(const Length& height) {
    style_->SetMaxHeight(height);
    return *this;
  }
  
  // Box model - margins
  ComputedStyleBuilder& SetMarginTop(const Length& margin) {
    style_->SetMarginTop(margin);
    return *this;
  }
  
  ComputedStyleBuilder& SetMarginRight(const Length& margin) {
    style_->SetMarginRight(margin);
    return *this;
  }
  
  ComputedStyleBuilder& SetMarginBottom(const Length& margin) {
    style_->SetMarginBottom(margin);
    return *this;
  }
  
  ComputedStyleBuilder& SetMarginLeft(const Length& margin) {
    style_->SetMarginLeft(margin);
    return *this;
  }
  
  // Box model - padding
  ComputedStyleBuilder& SetPaddingTop(const Length& padding) {
    style_->SetPaddingTop(padding);
    return *this;
  }
  
  ComputedStyleBuilder& SetPaddingRight(const Length& padding) {
    style_->SetPaddingRight(padding);
    return *this;
  }
  
  ComputedStyleBuilder& SetPaddingBottom(const Length& padding) {
    style_->SetPaddingBottom(padding);
    return *this;
  }
  
  ComputedStyleBuilder& SetPaddingLeft(const Length& padding) {
    style_->SetPaddingLeft(padding);
    return *this;
  }
  
  // Border widths
  ComputedStyleBuilder& SetBorderTopWidth(LayoutUnit width) {
    style_->SetBorderTopWidth(width);
    return *this;
  }
  
  ComputedStyleBuilder& SetBorderRightWidth(LayoutUnit width) {
    style_->SetBorderRightWidth(width);
    return *this;
  }
  
  ComputedStyleBuilder& SetBorderBottomWidth(LayoutUnit width) {
    style_->SetBorderBottomWidth(width);
    return *this;
  }
  
  ComputedStyleBuilder& SetBorderLeftWidth(LayoutUnit width) {
    style_->SetBorderLeftWidth(width);
    return *this;
  }
  
  // Border styles
  ComputedStyleBuilder& SetBorderTopStyle(EBorderStyle style) {
    style_->SetBorderTopStyle(style);
    return *this;
  }
  
  ComputedStyleBuilder& SetBorderRightStyle(EBorderStyle style) {
    style_->SetBorderRightStyle(style);
    return *this;
  }
  
  ComputedStyleBuilder& SetBorderBottomStyle(EBorderStyle style) {
    style_->SetBorderBottomStyle(style);
    return *this;
  }
  
  ComputedStyleBuilder& SetBorderLeftStyle(EBorderStyle style) {
    style_->SetBorderLeftStyle(style);
    return *this;
  }
  
  // Border colors
  ComputedStyleBuilder& SetBorderTopColor(const ::webf::Color& color) {
    style_->SetBorderTopColor(color);
    return *this;
  }
  
  ComputedStyleBuilder& SetBorderRightColor(const ::webf::Color& color) {
    style_->SetBorderRightColor(color);
    return *this;
  }
  
  ComputedStyleBuilder& SetBorderBottomColor(const ::webf::Color& color) {
    style_->SetBorderBottomColor(color);
    return *this;
  }
  
  ComputedStyleBuilder& SetBorderLeftColor(const ::webf::Color& color) {
    style_->SetBorderLeftColor(color);
    return *this;
  }
  
  // Positioning offsets
  ComputedStyleBuilder& SetTop(const Length& top) {
    style_->SetTop(top);
    return *this;
  }
  
  ComputedStyleBuilder& SetRight(const Length& right) {
    style_->SetRight(right);
    return *this;
  }
  
  ComputedStyleBuilder& SetBottom(const Length& bottom) {
    style_->SetBottom(bottom);
    return *this;
  }
  
  ComputedStyleBuilder& SetLeft(const Length& left) {
    style_->SetLeft(left);
    return *this;
  }
  
  // Text properties
  ComputedStyleBuilder& SetTextAlign(ETextAlign align) {
    style_->SetTextAlign(align);
    return *this;
  }
  
  ComputedStyleBuilder& SetTextDecoration(::webf::TextDecoration decoration) {
    style_->SetTextDecoration(decoration);
    return *this;
  }
  
  ComputedStyleBuilder& SetTextTransform(ETextTransform transform) {
    style_->SetTextTransform(transform);
    return *this;
  }
  
  ComputedStyleBuilder& SetLineHeight(const Length& height) {
    style_->SetLineHeight(height);
    return *this;
  }
  
  // Layout properties
  ComputedStyleBuilder& SetFloat(EFloat float_value) {
    style_->SetFloat(float_value);
    return *this;
  }
  
  ComputedStyleBuilder& SetClear(EClear clear) {
    style_->SetClear(clear);
    return *this;
  }
  
  ComputedStyleBuilder& SetOverflow(EOverflow overflow) {
    style_->SetOverflow(overflow);
    return *this;
  }
  
  // Visibility
  ComputedStyleBuilder& SetVisibility(EVisibility visibility) {
    style_->SetVisibility(visibility);
    return *this;
  }
  
  // Flexbox properties
  ComputedStyleBuilder& SetFlexDirection(EFlexDirection direction) {
    style_->SetFlexDirection(direction);
    return *this;
  }
  
  ComputedStyleBuilder& SetFlexWrap(EFlexWrap wrap) {
    style_->SetFlexWrap(wrap);
    return *this;
  }
  
  ComputedStyleBuilder& SetJustifyContent(ContentPosition position) {
    style_->SetJustifyContent(position);
    return *this;
  }
  
  ComputedStyleBuilder& SetAlignItems(ItemPosition position) {
    style_->SetAlignItems(position);
    return *this;
  }
  
  ComputedStyleBuilder& SetAlignContent(ContentPosition position) {
    style_->SetAlignContent(position);
    return *this;
  }
  
  ComputedStyleBuilder& SetFlexGrow(float grow) {
    style_->SetFlexGrow(grow);
    return *this;
  }
  
  ComputedStyleBuilder& SetFlexShrink(float shrink) {
    style_->SetFlexShrink(shrink);
    return *this;
  }
  
  ComputedStyleBuilder& SetFlexBasis(const Length& basis) {
    style_->SetFlexBasis(basis);
    return *this;
  }
  
  // Quirks mode
  ComputedStyleBuilder& SetIsQuirksModeDocumentForView(bool quirks) {
    style_->SetIsQuirksModeDocumentForView(quirks);
    return *this;
  }
  
  // Get properties for modification during building
  const FontDescription& GetFontDescription() const {
    return style_->GetFontDescription();
  }
  
  const AtomicString& Locale() const {
    return style_->Locale();
  }
  
  // Get Font object
  Font GetFont() const { return style_->GetFont(); }
  
  // Get writing mode
  WritingMode GetWritingMode() const { return style_->GetWritingMode(); }
  
  // Get effective zoom
  float EffectiveZoom() const { return style_->EffectiveZoom(); }
  
  // Get specified line height
  Length SpecifiedLineHeight() const { return style_->SpecifiedLineHeight(); }

 private:
  std::unique_ptr<ComputedStyle> style_;
};

}  // namespace webf

#endif  // WEBF_CORE_STYLE_COMPUTED_STYLE_H