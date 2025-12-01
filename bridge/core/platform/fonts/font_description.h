/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2000 Lars Knoll (knoll@kde.org)
 *           (C) 2000 Antti Koivisto (koivisto@kde.org)
 *           (C) 2000 Dirk Mueller (mueller@kde.org)
 * Copyright (C) 2003, 2004, 2005, 2006, 2007, 2008 Apple Inc. All rights
 * reserved.
 * Copyright (C) 2007 Nicholas Shanks <webkit@nickshanks.com>
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

#ifndef WEBF_CORE_PLATFORM_FONTS_FONT_DESCRIPTION_H_
#define WEBF_CORE_PLATFORM_FONTS_FONT_DESCRIPTION_H_

#include <cinttypes>
#include "core/platform/fonts/font_family.h"
#include "core/style/computed_style_constants.h"
#include "font_family_names.h"
#include "foundation/macros.h"

namespace webf {

typedef struct {
  uint32_t parts[1];
} FieldsAsUnsignedType;

class FontDescription {
  USING_FAST_MALLOC(FontDescription);

 public:
  enum HashCategory { kHashEmptyValue = 0, kHashDeletedValue, kHashRegularValue };

  enum GenericFamilyType : uint8_t {
    kNoFamily,
    kStandardFamily,
    kWebkitBodyFamily,
    kSerifFamily,
    kSansSerifFamily,
    kMonospaceFamily,
    kCursiveFamily,
    kFantasyFamily
  };
  
  enum class Kerning : uint8_t {
    kAuto,
    kNormal,
    kNone
  };

  FontDescription();
  FontDescription(const FontDescription&);

  FontDescription& operator=(const FontDescription&);
  bool operator==(const FontDescription&) const;
  bool operator!=(const FontDescription& other) const { return !(*this == other); }
  
  // Font properties
  const FontFamily& Family() const { return family_list_; }
  void SetFamily(const FontFamily& family) { family_list_ = family; }
  
  float SpecifiedSize() const { return specified_size_; }
  void SetSpecifiedSize(float size) { specified_size_ = size; }
  
  float ComputedSize() const { return computed_size_; }
  void SetComputedSize(float size) { computed_size_ = size; }
  
  class FontSelectionValue {
   public:
    FontSelectionValue() : value_(0) {}
    explicit FontSelectionValue(float value) : value_(value) {}
    float Value() const { return value_; }
    bool operator==(const FontSelectionValue& other) const { return value_ == other.value_; }
   private:
    float value_;
  };
  
  FontSelectionValue Weight() const { return weight_; }
  void SetWeight(FontSelectionValue weight) { weight_ = weight; }
  
  FontSelectionValue Style() const { return style_; }
  void SetStyle(FontSelectionValue style) { style_ = style; }
  
  FontSelectionValue Stretch() const { return stretch_; }
  void SetStretch(FontSelectionValue stretch) { stretch_ = stretch; }
  
  // Text rendering
  TextRenderingMode TextRendering() const { return TextRenderingMode::kAuto; } // TODO: Implement
  
  // Font smoothing
  FontSmoothingMode FontSmoothing() const { return FontSmoothingMode::kAuto; } // TODO: Implement
  
  // Feature settings (stub for now)
  int FeatureSettings() const { return 0; }
  
  // Kerning
  Kerning GetKerning() const { return kerning_; }
  void SetKerning(Kerning k) { kerning_ = k; }
  
  // Font optical sizing
  int FontOpticalSizing() const { return 0; }
  
  // Font palette
  int GetFontPalette() const { return 0; }
  
  // Font size  
  float GetSize() const { return computed_size_; }
  
  // Font size adjust
  float SizeAdjust() const { return 1.0f; }
  
  // Font synthesis enum types
  enum class FontSynthesisSmallCaps : uint8_t {
    kAuto,
    kNone
  };
  enum class FontSynthesisStyle : uint8_t {
    kAuto,
    kNone
  };
  enum class FontSynthesisWeight : uint8_t {
    kAuto,
    kNone
  };
  
  // Font synthesis getters
  FontSynthesisSmallCaps GetFontSynthesisSmallCaps() const { return FontSynthesisSmallCaps::kAuto; }
  FontSynthesisStyle GetFontSynthesisStyle() const { return FontSynthesisStyle::kAuto; }
  FontSynthesisWeight GetFontSynthesisWeight() const { return FontSynthesisWeight::kAuto; }
  
  // Font variant settings - both with and without Get/Font prefix
  int GetFontVariantCaps() const { return 0; }
  int GetFontVariantEastAsian() const { return 0; }
  int GetFontVariantLigatures() const { return 0; }
  int GetVariantLigatures() const { return GetFontVariantLigatures(); } // Alias for generated code
  int GetFontVariantNumeric() const { return 0; }
  int GetFontVariantPosition() const { return 0; }
  int GetFontVariationSettings() const { return 0; }
  int GetFontVariantAlternates() const { return 0; }
  // Shorter names for generated code
  int VariantCaps() const { return GetFontVariantCaps(); }
  int VariantEastAsian() const { return GetFontVariantEastAsian(); }
  int VariantLigatures() const { return GetFontVariantLigatures(); }
  int VariantNumeric() const { return GetFontVariantNumeric(); }
  int VariantPosition() const { return GetFontVariantPosition(); }
  int VariationSettings() const { return GetFontVariationSettings(); }
  int VariantAlternates() const { return GetFontVariantAlternates(); }
  int VariantEmoji() const { return 0; } // TODO: Implement font-variant-emoji

 private:
  FontFamily family_list_;  // The list of font families to be used.
  float specified_size_ = 0.0f;
  float computed_size_ = 0.0f;
  FontSelectionValue weight_;
  FontSelectionValue style_;
  FontSelectionValue stretch_;
  Kerning kerning_ = Kerning::kAuto;
};

}  // namespace webf

#endif  // WEBF_CORE_PLATFORM_FONTS_FONT_DESCRIPTION_H_
