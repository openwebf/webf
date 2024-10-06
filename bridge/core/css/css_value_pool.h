/*
 * Copyright (C) 2011, 2012 Apple Inc. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY APPLE INC. AND ITS CONTRIBUTORS ``AS IS''
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL APPLE INC. OR ITS CONTRIBUTORS
 * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 * THE POSSIBILITY OF SUCH DAMAGE.
 */

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CSS_VALUE_POOL_H
#define WEBF_CSS_VALUE_POOL_H

#include "core/base/types/pass_key.h"
#include "core/css/css_color.h"
#include "core/css/css_identifier_value.h"
#include "core/css/css_initial_value.h"
#include "core/css/css_inherit_value.h"
#include "core/css/css_numeric_literal_value.h"
#include "core/css/css_revert_layer_value.h"
#include "core/css/css_revert_value.h"
#include "core/css/css_unset_value.h"
#include "core/css/css_initial_color_value.h"
#include "core/css/css_invalid_variable_value.h"
#include "css_property_names.h"
#include "css_value_keywords.h"
// #include "core/css/css_custom_ident_value.h"
// #include "core/css/css_cyclic_variable_value.h"
#include "core/css/css_font_family_value.h"
#include "core/css/css_value_list.h"
// #include "core/css/css_inherited_value.h"
// #include "core/css/fixed_size_cache.h"
// #include "core/css/css_cyclic_variable_value.h"

namespace webf {

class CSSValuePool {
 public:
  using PassKey = webf::PassKey<CSSValuePool>;

  CSSValuePool();

  static const int kMaximumCacheableIntegerValue = 255;
  using CSSColor = cssvalue::CSSColor;
  using CSSUnsetValue = cssvalue::CSSUnsetValue;
  using CSSRevertValue = cssvalue::CSSRevertValue;
  using CSSRevertLayerValue = cssvalue::CSSRevertLayerValue;

  //  // Special keys for deleted and empty values. Use white and transparent as
  //  // they're common colors and worth having an early-out for.
  //  struct ColorHashTraitsForCSSValuePool : WTF::GenericHashTraits<Color> {
  //    STATIC_ONLY(ColorHashTraitsForCSSValuePool);
  //    static unsigned GetHash(const Color& key) { return key.GetHash(); }
  //    static Color EmptyValue() { return Color::kTransparent; }
  //    static Color DeletedValue() { return Color::kWhite; }
  //  };
    using FontFaceValueCache = std::unordered_map<std::string, std::shared_ptr<const CSSValueList>>;
    static const unsigned kMaximumFontFaceCacheSize = 128;
    using FontFamilyValueCache = std::unordered_map<std::string, std::shared_ptr<CSSFontFamilyValue>>;
  //
  //  CSSValuePool();
  //  CSSValuePool(const CSSValuePool&) = delete;
  //  CSSValuePool& operator=(const CSSValuePool&) = delete;
  //
  //  // Cached individual values.
  const std::shared_ptr<const CSSColor>& TransparentColor() const { return color_transparent_; }
  const std::shared_ptr<const CSSColor>& WhiteColor() const { return color_white_; }
  const std::shared_ptr<const CSSColor>& BlackColor() const { return color_black_; }
  const std::shared_ptr<const CSSInheritedValue>& InheritedValue() { return inherited_value_; }
  const std::shared_ptr<const CSSInitialValue>& InitialValue() const { return initial_value_; }
  const std::shared_ptr<const CSSInitialValue>& InitialSharedPointerValue() const { return initial_value_; }
  const std::shared_ptr<const CSSUnsetValue>& UnsetValue() { return unset_value_; }
  const std::shared_ptr<const CSSRevertValue>& RevertValue() { return revert_value_; }
  const std::shared_ptr<const CSSRevertLayerValue>& RevertLayerValue() { return revert_layer_value_; }
  const std::shared_ptr<const CSSInvalidVariableValue>& InvalidVariableValue() { return invalid_variable_value_; }
  const std::shared_ptr<const CSSInitialColorValue>& InitialColorValue() { return initial_color_value_; }

  // Vector caches.
  const std::shared_ptr<const CSSIdentifierValue>& IdentifierCacheValue(CSSValueID ident) {
    if (identifier_value_cache_.size() <= static_cast<int>(ident)) {
      return nullptr;
    }
    return identifier_value_cache_[static_cast<int>(ident)];
  }
  std::shared_ptr<const CSSIdentifierValue> SetIdentifierCacheValue(
      CSSValueID ident,
      std::shared_ptr<const CSSIdentifierValue> css_value) {
    if (static_cast<int>(ident) >= identifier_value_cache_.size()) {
      identifier_value_cache_.resize(static_cast<int>(ident) + 1);
    }
    identifier_value_cache_[static_cast<int>(ident)] = css_value;
    return css_value;
  }
  std::shared_ptr<const CSSNumericLiteralValue> PixelCacheValue(int int_value) {
    if (pixel_value_cache_.size() <= static_cast<size_t>(int_value)) {
      return nullptr;
    }
    return pixel_value_cache_[int_value];
  }
  std::shared_ptr<const CSSNumericLiteralValue> SetPixelCacheValue(
      int int_value,
      std::shared_ptr<const CSSNumericLiteralValue> css_value) {
    pixel_value_cache_[int_value] = css_value;
    return css_value;
  }
  std::shared_ptr<const CSSNumericLiteralValue> PercentCacheValue(int int_value) {
    if (percent_value_cache_.size() <= static_cast<size_t>(int_value)) {
      return nullptr;
    }
    return percent_value_cache_[int_value];
  }
  std::shared_ptr<const CSSNumericLiteralValue> SetPercentCacheValue(
      int int_value,
      std::shared_ptr<const CSSNumericLiteralValue> css_value) {
    percent_value_cache_[int_value] = css_value;
    return css_value;
  }
  std::shared_ptr<const CSSNumericLiteralValue> NumberCacheValue(int int_value) {
    if (number_value_cache_.size() <= static_cast<size_t>(int_value)) {
      return nullptr;
    }
    return number_value_cache_[int_value];
  }
  std::shared_ptr<const CSSNumericLiteralValue> SetNumberCacheValue(
      int int_value,
      std::shared_ptr<const CSSNumericLiteralValue> css_value) {
    number_value_cache_[int_value] = css_value;
    return css_value;
  }

  // Hash map caches.
  std::shared_ptr<const CSSColor> GetOrCreateColor(const Color& color) {
    // This is the empty value of the hash table.
    // See ColorHashTraitsForCSSValuePool.
    if (color == Color::kTransparent) {
      return TransparentColor();
    }

    // Just because they are common.
    if (color == Color::kWhite) {
      return WhiteColor();
    }
    if (color == Color::kBlack) {
      return BlackColor();
    }

    if (auto found = color_value_cache_.find(color); found != color_value_cache_.end()) {
      return found->second;
    }
    color_value_cache_[color] = std::make_shared<CSSColor>(color);
    return color_value_cache_[color];
  }


  auto GetFontFamilyCacheEntry(
      const std::string& family_name) {
    return font_family_value_cache_.insert({family_name, nullptr});
  }

  auto GetFontFaceCacheEntry(
      const std::string& string) {
    // Just wipe out the cache and start rebuilding if it gets too big.
    if (font_face_value_cache_.size() > kMaximumFontFaceCacheSize) {
      font_face_value_cache_.clear();
    }
    return font_face_value_cache_.insert({string, nullptr});
  }

  FontFamilyValueCache GetFontFamilyCache() {
    return font_family_value_cache_;
  }

  FontFaceValueCache GetFontFaceValueCache() {
    return font_face_value_cache_;
  }

 private:
  //  // Cached individual values.
  std::shared_ptr<const CSSInheritedValue> inherited_value_;
  std::shared_ptr<const CSSInitialValue> initial_value_;
  std::shared_ptr<const CSSUnsetValue> unset_value_;
  std::shared_ptr<const CSSRevertValue> revert_value_;
  std::shared_ptr<const CSSRevertLayerValue> revert_layer_value_;
  std::shared_ptr<const CSSInvalidVariableValue> invalid_variable_value_;
  std::shared_ptr<const CSSInitialColorValue> initial_color_value_;
  std::shared_ptr<const CSSColor> color_transparent_;
  std::shared_ptr<const CSSColor> color_white_;
  std::shared_ptr<const CSSColor> color_black_;

  std::vector<std::shared_ptr<const CSSIdentifierValue>> identifier_value_cache_;
  std::vector<std::shared_ptr<const CSSNumericLiteralValue>> pixel_value_cache_;
  std::vector<std::shared_ptr<const CSSNumericLiteralValue>> percent_value_cache_;
  std::vector<std::shared_ptr<const CSSNumericLiteralValue>> number_value_cache_;

  std::unordered_map<Color, std::shared_ptr<const CSSColor>, Color::KeyHasher> color_value_cache_;
  FontFaceValueCache font_face_value_cache_;
  FontFamilyValueCache font_family_value_cache_;
};

CSSValuePool& CssValuePool();

}  // namespace webf

#endif  // WEBF_CSS_VALUE_POOL_H
