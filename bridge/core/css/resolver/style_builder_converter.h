/*
 * Copyright (C) 2013 Google Inc. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 *     * Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above
 * copyright notice, this list of conditions and the following disclaimer
 * in the documentation and/or other materials provided with the
 * distribution.
 *     * Neither the name of Google Inc. nor the names of its
 * contributors may be used to endorse or promote products derived from
 * this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#ifndef WEBF_CORE_CSS_RESOLVER_STYLE_BUILDER_CONVERTER_H_
#define WEBF_CORE_CSS_RESOLVER_STYLE_BUILDER_CONVERTER_H_

#include <memory>
#include "core/css/css_value.h"
#include "core/css/css_value_list.h"
#include "core/style/computed_style_constants.h"
#include "core/style/computed_style_base_constants.h"
#include "foundation/macros.h"
#include "core/platform/geometry/length.h"
#include "core/css/style_color.h"
#include "core/platform/fonts/font_selection_types.h"

namespace webf {

class CSSIdentifierValue;
class CSSPrimitiveValue;
class CSSValue;
class StyleResolverState;
class CSSToLengthConversionData;

// Converts CSS values to internal style representations.
// This is used during style building to convert parsed CSS values
// into the types used by ComputedStyle.
class StyleBuilderConverter {
  WEBF_STATIC_ONLY(StyleBuilderConverter);

 public:
  // Basic converters
  static Length ConvertLength(const StyleResolverState&, const CSSValue&);
  static Length ConvertLengthOrAuto(const StyleResolverState&, const CSSValue&);
  static Length ConvertLengthSizing(const StyleResolverState&, const CSSValue&);
  static Length ConvertLengthMaxSizing(const StyleResolverState&, const CSSValue&);
  
  // Numeric converters
  static float ConvertNumber(const StyleResolverState&, const CSSValue&);
  static float ConvertAlpha(const StyleResolverState&, const CSSValue&);
  static int ConvertInteger(const StyleResolverState&, const CSSValue&);
  
  // Color converters
  static StyleColor ConvertStyleColor(const StyleResolverState&, const CSSValue&);
  static Color ConvertColor(const StyleResolverState&, const CSSValue&);
  
  // Enum converters that exist in WebF
  static EDisplay ConvertDisplay(const StyleResolverState&, const CSSValue&);
  static EPosition ConvertPosition(const StyleResolverState&, const CSSValue&);
  static EFloat ConvertFloat(const StyleResolverState&, const CSSValue&);
  static EOverflow ConvertOverflow(const StyleResolverState&, const CSSValue&);
  
  // Font converters
  static FontSelectionValue ConvertFontWeight(const StyleResolverState&, const CSSValue&);
  static float ConvertFontSize(const StyleResolverState&, const CSSValue&);
  
  // Line height converter
  static Length ConvertLineHeight(const StyleResolverState&, const CSSValue&);

 private:
  // Helper methods
  static Length ConvertToLength(const StyleResolverState&,
                               const CSSPrimitiveValue&,
                               const CSSToLengthConversionData&);
  static float ConvertToFloat(const StyleResolverState&,
                             const CSSPrimitiveValue&);
  static int ConvertToInt(const StyleResolverState&,
                         const CSSPrimitiveValue&);
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_RESOLVER_STYLE_BUILDER_CONVERTER_H_