/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CSS_RESOLVER_FONT_BUILDER_H
#define WEBF_CSS_RESOLVER_FONT_BUILDER_H

#include "core/style/computed_style.h"
#include "core/platform/fonts/font_description.h"
#include "core/platform/geometry/length.h"
#include "foundation/macros.h"

namespace webf {

class ComputedStyleBuilder;
class FontDescription;

// Builds font properties during style resolution
class FontBuilder {
  WEBF_STACK_ALLOCATED();

 public:
  FontBuilder() = default;
  ~FontBuilder() = default;

  // Create the font from current settings
  void CreateFont(ComputedStyleBuilder&, const ComputedStyle* parent_style);

  // Set font properties
  void SetFontFamily(const FontFamily&);
  void SetFontSize(float size);
  void SetFontWeight(FontDescription::FontSelectionValue);
  void SetFontStyle(FontDescription::FontSelectionValue);
  void SetFontStretch(FontDescription::FontSelectionValue);
  void SetLineHeight(const Length&);

  // Get font description
  const FontDescription& GetFontDescription() const { return font_description_; }

 private:
  FontDescription font_description_;
  bool dirty_ = false;
};

}  // namespace webf

#endif  // WEBF_CSS_RESOLVER_FONT_BUILDER_H