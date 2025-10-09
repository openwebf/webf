/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "font_builder.h"

#include "core/style/computed_style.h"
#include "core/platform/fonts/font_description.h"

// Undefine Windows macros that conflict with our method names
#ifdef CreateFont
#undef CreateFont
#endif

namespace webf {

void FontBuilder::CreateFont(ComputedStyleBuilder& builder, 
                            const ComputedStyle* parent_style) {
  // TODO: Implement font creation logic
  // This would update the computed style builder with the font description
  
  if (dirty_) {
    builder.SetFontDescription(font_description_);
    dirty_ = false;
  }
}

void FontBuilder::SetFontFamily(const FontFamily& family) {
  font_description_.SetFamily(family);
  dirty_ = true;
}

void FontBuilder::SetFontSize(float size) {
  font_description_.SetComputedSize(size);
  font_description_.SetSpecifiedSize(size);
  dirty_ = true;
}

void FontBuilder::SetFontWeight(FontDescription::FontSelectionValue weight) {
  font_description_.SetWeight(weight);
  dirty_ = true;
}

void FontBuilder::SetFontStyle(FontDescription::FontSelectionValue style) {
  font_description_.SetStyle(style);
  dirty_ = true;
}

void FontBuilder::SetFontStretch(FontDescription::FontSelectionValue stretch) {
  font_description_.SetStretch(stretch);
  dirty_ = true;
}

void FontBuilder::SetLineHeight(const Length& line_height) {
  // TODO: Implement line height setting
  dirty_ = true;
}

}  // namespace webf