// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2024-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_CSS_PARSER_SIZES_ATTRIBUTE_PARSER_H_
#define WEBF_CORE_CSS_PARSER_SIZES_ATTRIBUTE_PARSER_H_

#include <memory>
#include "foundation/macros.h"
#include "foundation/string/wtf_string.h"

namespace webf {

// Forward declarations
class MediaValues;
class MediaQuerySet;
class CSSParserTokenStream;
class ExecutingContext;
class HTMLImageElement;

// Parser for the HTML sizes attribute for responsive images
// https://html.spec.whatwg.org/multipage/images.html#sizes-attributes
class SizesAttributeParser {
  WEBF_STACK_ALLOCATED();

 public:
  SizesAttributeParser(MediaValues* media_values,
                       const String& attribute,
                       ExecutingContext* executing_context,
                       const HTMLImageElement* img = nullptr);

  bool IsAuto();
  float Size();

 private:
  bool Parse(CSSParserTokenStream&);
  float EffectiveSize();
  bool CalculateLengthInPixels(CSSParserTokenStream&, float& result);
  bool MediaConditionMatches(const MediaQuerySet& media_condition);
  float EffectiveSizeDefaultValue();

  MediaValues* media_values_{};
  ExecutingContext* executing_context_{};
  float size_{};
  bool size_was_set_{};
  bool is_valid_{};
  bool is_auto_{};
  const HTMLImageElement* img_{};
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_PARSER_SIZES_ATTRIBUTE_PARSER_H_