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

#include "css_property_names.h"
#include "css_value_keywords.h"
#include "core/base/types/pass_key.h"
#include "core/css/css_color.h"
//#include "core/css/css_custom_ident_value.h"
//#include "core/css/css_cyclic_variable_value.h"
//#include "core/css/css_font_family_value.h"
#include "core/css/css_identifier_value.h"
//#include "core/css/css_inherited_value.h"
#include "core/css/css_initial_color_value.h"
#include "core/css/css_initial_value.h"
#include "core/css/css_invalid_variable_value.h"
#include "core/css/css_numeric_literal_value.h"
#include "core/css/css_revert_layer_value.h"
#include "core/css/css_revert_value.h"
#include "core/css/css_unset_value.h"
#include "core/css/css_value_list.h"
//#include "core/css/fixed_size_cache.h"
#include "core/css/css_cyclic_variable_value.h"

namespace webf {

class CSSValuePool final {
 public:
  using PassKey = webf::PassKey<CSSValuePool>;

  // TODO(sashab): Make all the value pools store const CSSValues.
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
//  using FontFaceValueCache =
//      HeapHashMap<AtomicString, Member<const CSSValueList>>;
//  static const unsigned kMaximumFontFaceCacheSize = 128;
//  using FontFamilyValueCache = HeapHashMap<String, Member<CSSFontFamilyValue>>;
//
//  CSSValuePool();
//  CSSValuePool(const CSSValuePool&) = delete;
//  CSSValuePool& operator=(const CSSValuePool&) = delete;
//
//  // Cached individual values.
//  CSSColor* TransparentColor() { return color_transparent_.Get(); }
//  CSSColor* WhiteColor() { return color_white_.Get(); }
//  CSSColor* BlackColor() { return color_black_.Get(); }
//  CSSInheritedValue* InheritedValue() { return inherited_value_.Get(); }
  CSSInitialValue* InitialValue() { return initial_value_.get(); }
  std::shared_ptr<CSSInitialValue> InitialSharedPointerValue() { return initial_value_; }
  CSSUnsetValue* UnsetValue() { return unset_value_.get(); }
  CSSRevertValue* RevertValue() { return revert_value_.get(); }
  CSSRevertLayerValue* RevertLayerValue() { return revert_layer_value_.get(); }
  CSSInvalidVariableValue* InvalidVariableValue() {
    return invalid_variable_value_.get();
  }
  CSSCyclicVariableValue* CyclicVariableValue() {
    return cyclic_variable_value_.get();
  }
//  CSSInitialColorValue* InitialColorValue() {
//    return initial_color_value_.Get();
//  }

  // Vector caches.
  std::shared_ptr<CSSIdentifierValue> IdentifierCacheValue(CSSValueID ident) {
    return identifier_value_cache_[static_cast<int>(ident)];
  }
  std::shared_ptr<CSSIdentifierValue> SetIdentifierCacheValue(CSSValueID ident,
                                              std::shared_ptr<CSSIdentifierValue> css_value) {
    identifier_value_cache_[static_cast<int>(ident)] = css_value;
    return css_value;
  }
  std::shared_ptr<CSSNumericLiteralValue> PixelCacheValue(int int_value) {
    return pixel_value_cache_[int_value];
  }
  std::shared_ptr<CSSNumericLiteralValue> SetPixelCacheValue(
      int int_value,
      std::shared_ptr<CSSNumericLiteralValue> css_value) {
    pixel_value_cache_[int_value] = css_value;
    return css_value;
  }
  std::shared_ptr<CSSNumericLiteralValue> PercentCacheValue(int int_value) {
    return percent_value_cache_[int_value];
  }
  std::shared_ptr<CSSNumericLiteralValue> SetPercentCacheValue(
      int int_value,
      std::shared_ptr<CSSNumericLiteralValue> css_value) {
    percent_value_cache_[int_value] = css_value;
    return css_value;
  }
  std::shared_ptr<CSSNumericLiteralValue> NumberCacheValue(int int_value) {
    return number_value_cache_[int_value];
  }
  std::shared_ptr<CSSNumericLiteralValue> SetNumberCacheValue(
      int int_value,
      std::shared_ptr<CSSNumericLiteralValue> css_value) {
    number_value_cache_[int_value] = css_value;
    return css_value;
  }

//  // Hash map caches.
//  CSSColor* GetOrCreateColor(const Color& color) {
//    // This is the empty value of the hash table.
//    // See ColorHashTraitsForCSSValuePool.
//    if (color == Color::kTransparent) {
//      return TransparentColor();
//    }
//
//    // Just because they are common.
//    if (color == Color::kWhite) {
//      return WhiteColor();
//    }
//    if (color == Color::kBlack) {
//      return BlackColor();
//    }
//
//    unsigned hash = color.GetHash();
//    if (Member<CSSColor>* found = color_value_cache_.Find(color, hash); found) {
//      return found->Get();
//    }
//    return color_value_cache_
//        .Insert(color, MakeGarbageCollected<CSSColor>(color), hash)
//        .Get();
//  }
//  FontFamilyValueCache::AddResult GetFontFamilyCacheEntry(
//      const String& family_name) {
//    return font_family_value_cache_.insert(family_name, nullptr);
//  }
//  FontFaceValueCache::AddResult GetFontFaceCacheEntry(
//      const AtomicString& string) {
//    // Just wipe out the cache and start rebuilding if it gets too big.
//    if (font_face_value_cache_.size() > kMaximumFontFaceCacheSize) {
//      font_face_value_cache_.clear();
//    }
//    return font_face_value_cache_.insert(string, nullptr);
//  }
//
//  void Trace(Visitor*) const;
//
 private:
//  // Cached individual values.
//  Member<CSSInheritedValue> inherited_value_;
  std::shared_ptr<CSSInitialValue> initial_value_;
  std::shared_ptr<CSSUnsetValue> unset_value_;
  std::shared_ptr<CSSRevertValue> revert_value_;
  std::shared_ptr<CSSRevertLayerValue> revert_layer_value_;
  std::shared_ptr<CSSInvalidVariableValue> invalid_variable_value_;
  std::shared_ptr<CSSCyclicVariableValue> cyclic_variable_value_;
  std::shared_ptr<CSSInitialColorValue> initial_color_value_;
  std::shared_ptr<CSSColor> color_transparent_;
  std::shared_ptr<CSSColor> color_white_;
  std::shared_ptr<CSSColor> color_black_;

  // TODO(guopengfei)：将HeapVector替换为std::vector
  // Vector caches.
  std::vector<std::shared_ptr<CSSIdentifierValue>>
      identifier_value_cache_;
  std::vector<std::shared_ptr<CSSNumericLiteralValue>>
      pixel_value_cache_;
  std::vector<std::shared_ptr<CSSNumericLiteralValue>>
      percent_value_cache_;
  std::vector<std::shared_ptr<CSSNumericLiteralValue>>
      number_value_cache_;
//
//  // Hash map caches.
//  static const unsigned kColorCacheSize = 512;
//  FixedSizeCache<Color,
//                 Member<CSSColor>,
//                 ColorHashTraitsForCSSValuePool,
//                 kColorCacheSize>
//      color_value_cache_;
//  FontFaceValueCache font_face_value_cache_;
//  FontFamilyValueCache font_family_value_cache_;
//
//  friend CSSValuePool& CssValuePool();
};

CSSValuePool& CssValuePool();

}  // namespace webf

#endif  // WEBF_CSS_VALUE_POOL_H
