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
#include "foundation/macros.h"
#include "foundation/atomic_string.h"
#include "core/platform/graphics/color.h"
#include "core/platform/geometry/length.h"
#include "core/platform/text/text_direction.h"
#include "core/platform/text/writing_mode.h"

namespace webf {

class ComputedStyleBuilder;

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
  
  // Opacity
  float Opacity() const { return opacity_; }
  void SetOpacity(float opacity) { opacity_ = opacity; }
  
  // Z-index
  int ZIndex() const { return z_index_; }
  void SetZIndex(int z_index) { z_index_ = z_index; }
  
  bool HasAutoZIndex() const { return has_auto_z_index_; }
  void SetHasAutoZIndex(bool has_auto) { has_auto_z_index_ = has_auto; }
  
  // Locale
  const AtomicString& Locale() const { return locale_; }
  void SetLocale(const AtomicString& locale) { locale_ = locale; }
  
  // Quirks mode
  bool IsQuirksModeDocumentForView() const { return is_quirks_mode_document_; }
  void SetIsQuirksModeDocumentForView(bool quirks) { is_quirks_mode_document_ = quirks; }
  
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
  
  // Inherited properties
  TextDirection direction_ = TextDirection::kLtr;
  WritingMode writing_mode_ = WritingMode::kHorizontalTb;
  ::webf::Color color_ = ::webf::Color::kBlack;
  FontDescription font_description_;
  AtomicString locale_;
  bool is_quirks_mode_document_ = false;
  
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

 private:
  std::unique_ptr<ComputedStyle> style_;
};

}  // namespace webf

#endif  // WEBF_CORE_STYLE_COMPUTED_STYLE_H