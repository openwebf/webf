/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CSS_RESOLVER_FONT_BUILDER_H
#define WEBF_CSS_RESOLVER_FONT_BUILDER_H

#include "core/platform/fonts/font_description.h"
#include "core/style/computed_style.h"
#include "core/style/computed_style_constants.h"
#include "core/platform/geometry/length.h"
#include "foundation/macros.h"

// Undefine Windows macros that conflict with our method names
#ifdef CreateFont
#undef CreateFont
#endif

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
  
  // Font family methods
  void SetFamilyDescription(const FontFamily& family) {
    font_description_.SetFamily(family);
  }
  
  // Font feature settings
  static int InitialFeatureSettings() { return 0; }
  void SetFeatureSettings(int settings) {
    // TODO: Implement
  }
  
  // Font kerning - keep name as is since it doesn't have Font prefix
  static FontDescription::Kerning InitialKerning() { return FontDescription::Kerning::kAuto; }
  void SetKerning(FontDescription::Kerning kerning) {
    // TODO: Implement when FontDescription supports it
  }
  
  // Font optical sizing
  static int InitialFontOpticalSizing() { return 0; }
  void SetFontOpticalSizing(int sizing) {
    // TODO: Implement
  }
  
  // Font palette
  static int InitialFontPalette() { return 0; }
  void SetFontPalette(int palette) {
    // TODO: Implement
  }
  
  // Font size
  static float InitialSize() { return 16.0f; }
  void SetSize(float size) {
    font_description_.SetSpecifiedSize(size);
    font_description_.SetComputedSize(size);
  }
  
  // Font size adjust
  static float InitialSizeAdjust() { return 1.0f; }
  void SetSizeAdjust(float adjust) {
    // TODO: Implement
  }
  
  // Font stretch
  static FontDescription::FontSelectionValue InitialStretch() { 
    return FontDescription::FontSelectionValue(100); // Normal stretch
  }
  void SetStretch(FontDescription::FontSelectionValue stretch) {
    font_description_.SetStretch(stretch);
  }
  
  // Font style
  static FontDescription::FontSelectionValue InitialStyle() { 
    return FontDescription::FontSelectionValue(0); // Normal style
  }
  void SetStyle(FontDescription::FontSelectionValue style) {
    font_description_.SetStyle(style);
  }
  
  // Font synthesis
  static FontDescription::FontSynthesisSmallCaps InitialFontSynthesisSmallCaps() { 
    return FontDescription::FontSynthesisSmallCaps::kAuto; 
  }
  static FontDescription::FontSynthesisStyle InitialFontSynthesisStyle() { 
    return FontDescription::FontSynthesisStyle::kAuto; 
  }
  static FontDescription::FontSynthesisWeight InitialFontSynthesisWeight() { 
    return FontDescription::FontSynthesisWeight::kAuto; 
  }
  void SetFontSynthesisSmallCaps(FontDescription::FontSynthesisSmallCaps value) {
    // TODO: Implement
  }
  void SetFontSynthesisStyle(FontDescription::FontSynthesisStyle value) {
    // TODO: Implement
  }
  void SetFontSynthesisWeight(FontDescription::FontSynthesisWeight value) {
    // TODO: Implement
  }
  
  // Font variant settings - some use full names, some don't
  static int InitialFontVariantAlternates() { return 0; }
  static int InitialVariantCaps() { return 0; }
  static int InitialVariantEastAsian() { return 0; }
  static int InitialVariantLigatures() { return 0; }
  static int InitialVariantNumeric() { return 0; }
  static int InitialVariantPosition() { return 0; }
  static int InitialVariationSettings() { return 0; }
  void SetFontVariantAlternates(int value) {
    // TODO: Implement
  }
  void SetVariantCaps(int value) {
    // TODO: Implement
  }
  void SetVariantEastAsian(int value) {
    // TODO: Implement
  }
  void SetVariantLigatures(int value) {
    // TODO: Implement
  }
  void SetVariantNumeric(int value) {
    // TODO: Implement
  }
  void SetVariantPosition(int value) {
    // TODO: Implement
  }
  void SetVariationSettings(int value) {
    // TODO: Implement
  }
  
  // Font variant emoji
  static int InitialVariantEmoji() { return 0; }
  void SetVariantEmoji(int value) {
    // TODO: Implement
  }
  
  // Font weight
  static FontDescription::FontSelectionValue InitialWeight() { 
    return FontDescription::FontSelectionValue(400); // Normal weight
  }
  void SetWeight(FontDescription::FontSelectionValue weight) {
    font_description_.SetWeight(weight);
  }
  
  // Text rendering
  static TextRenderingMode InitialTextRendering() { return TextRenderingMode::kAuto; }
  void SetTextRendering(TextRenderingMode rendering) {
    // TODO: Implement
  }
  
  // Font smoothing
  static FontSmoothingMode InitialFontSmoothing() { return FontSmoothingMode::kAuto; }
  void SetFontSmoothing(FontSmoothingMode smoothing) {
    // TODO: Implement
  }

 private:
  FontDescription font_description_;
  bool dirty_ = false;
};

}  // namespace webf

#endif  // WEBF_CSS_RESOLVER_FONT_BUILDER_H