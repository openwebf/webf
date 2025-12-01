/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
#ifndef WEBF_CORE_STYLE_NINE_PIECE_IMAGE_H_
#define WEBF_CORE_STYLE_NINE_PIECE_IMAGE_H_

#include "foundation/macros.h"
#include "core/platform/geometry/length.h"
#include "core/platform/geometry/length_box.h"

namespace webf {

// Forward declaration
class StyleImage;

// Image rule constants
enum ImageRule {
  kStretchImageRule = 0,
  kRepeatImageRule = 1,
  kRoundImageRule = 2,
  kSpaceImageRule = 3
};

// Stub implementation for border image support
class NinePieceImage {
  WEBF_DISALLOW_NEW();
 public:
  NinePieceImage() = default;
  NinePieceImage(const NinePieceImage& other) = default;
  NinePieceImage& operator=(const NinePieceImage& other) = default;
  
  // Border image length type
  class BorderImageLength {
   public:
    BorderImageLength() = default;
    BorderImageLength(int value) : value_(value) {}
    int value() const { return value_; }
   private:
    int value_ = 0;
  };
  
  // Outset methods
  BorderImageLength Outset() const {
    return outset_;
  }
  
  void SetOutset(const BorderImageLength& outset) {
    outset_ = outset;
  }
  
  void SetOutset(int value) {
    outset_ = BorderImageLength(value);
  }
  
  // Border slice methods
  BorderImageLength BorderSlices() const {
    return border_slices_;
  }
  
  void SetBorderSlices(const BorderImageLength& slices) {
    border_slices_ = slices;
  }
  
  // Image slice methods - return LengthBox for compatibility
  LengthBox ImageSlices() const {
    return image_slices_;
  }
  
  void SetImageSlices(const LengthBox& slices) {
    image_slices_ = slices;
  }
  
  // Rule methods
  ImageRule HorizontalRule() const {
    return horizontal_rule_;
  }
  
  ImageRule VerticalRule() const {
    return vertical_rule_;
  }
  
  void SetVerticalRule(ImageRule rule) {
    vertical_rule_ = rule;
  }
  
  void SetHorizontalRule(ImageRule rule) {
    horizontal_rule_ = rule;
  }
  
  // Fill methods
  bool Fill() const {
    return fill_;
  }
  
  void SetFill(bool fill) {
    fill_ = fill;
  }
  
  // Image source
  StyleImage* GetImage() const {
    return image_source_;
  }
  
  void SetImage(StyleImage* image) {
    image_source_ = image;
  }
  
 private:
  StyleImage* image_source_ = nullptr;
  ImageRule horizontal_rule_ = kStretchImageRule;
  ImageRule vertical_rule_ = kStretchImageRule;
  bool fill_ = false;
  LengthBox image_slices_;
  BorderImageLength outset_;
  BorderImageLength border_slices_;
};

// Utility functions for border image
namespace style_building_utils {
  inline bool BorderImageLengthMatchesAllSides(const NinePieceImage::BorderImageLength& length, const NinePieceImage::BorderImageLength& expected) {
    return length.value() == expected.value();
  }
  
  inline bool LengthMatchesAllSides(const LengthBox& slices, const Length& expected) {
    // TODO: Implement proper comparison
    return true; // Stub implementation
  }
}

// Utility function
inline NinePieceImage::BorderImageLength BorderImageLength(int value) {
  return NinePieceImage::BorderImageLength(value);
}

}  // namespace webf

#endif  // WEBF_CORE_STYLE_NINE_PIECE_IMAGE_H_