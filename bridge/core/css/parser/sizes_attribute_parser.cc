// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2024-present The WebF authors. All rights reserved.
 */

#include "core/css/parser/sizes_attribute_parser.h"

#include "core/css/parser/css_parser_token_stream.h"
#include "core/css/parser/css_tokenizer.h"
#include "core/css/media_values.h"
#include "core/css/media_list.h"

namespace webf {

SizesAttributeParser::SizesAttributeParser(MediaValues* media_values,
                                           const String& attribute,
                                           ExecutingContext* executing_context,
                                           const HTMLImageElement* img)
    : media_values_(media_values),
      executing_context_(executing_context),
      size_(0),
      size_was_set_(false),
      is_valid_(false),
      is_auto_(false),
      img_(img) {
  CSSTokenizer tokenizer{attribute.ToStringView()};
  CSSParserTokenStream stream(tokenizer);
  is_valid_ = Parse(stream);
}

bool SizesAttributeParser::IsAuto() {
  return is_auto_;
}

float SizesAttributeParser::Size() {
  if (is_valid_) {
    return EffectiveSize();
  }
  return EffectiveSizeDefaultValue();
}

bool SizesAttributeParser::Parse(CSSParserTokenStream& stream) {
  // Sizes parsing algorithm:
  // https://html.spec.whatwg.org/multipage/images.html#parse-a-sizes-attribute
  
  // Check for "auto" keyword
  stream.ConsumeWhitespace();
  if (stream.Peek().GetType() == kIdentToken && 
      stream.Peek().Value() == "auto") {
    stream.ConsumeIncludingWhitespace();
    if (stream.AtEnd()) {
      is_auto_ = true;
      return true;
    }
  }

  // TODO: Implement full sizes parsing
  // For now, just try to parse a single length
  float length = 0;
  if (CalculateLengthInPixels(stream, length)) {
    size_ = length;
    size_was_set_ = true;
    return true;
  }

  return false;
}

float SizesAttributeParser::EffectiveSize() {
  if (size_was_set_) {
    return size_;
  }
  return EffectiveSizeDefaultValue();
}

bool SizesAttributeParser::CalculateLengthInPixels(CSSParserTokenStream& stream, float& result) {
  // TODO: Implement proper length parsing using CSS length resolver
  // For now, just handle simple pixel values
  const CSSParserToken& token = stream.Peek();
  if (token.GetType() == kDimensionToken) {
    // Check if it's a pixel unit
    if (token.GetUnitType() == CSSPrimitiveValue::UnitType::kPixels) {
      result = static_cast<float>(token.NumericValue());
      stream.ConsumeIncludingWhitespace();
      return true;
    }
  } else if (token.GetType() == kNumberToken && token.NumericValue() == 0) {
    // Handle zero without unit
    result = 0;
    stream.ConsumeIncludingWhitespace();
    return true;
  }
  
  // TODO: Handle other units (vw, em, rem, etc.) and calc()
  return false;
}

bool SizesAttributeParser::MediaConditionMatches(const MediaQuerySet& media_condition) {
  // TODO: Implement media query evaluation
  // For now, assume all media conditions match
  return true;
}

float SizesAttributeParser::EffectiveSizeDefaultValue() {
  // Default to viewport width as per spec
  if (media_values_) {
    return static_cast<float>(media_values_->DeviceWidth());
  }
  return 100.0f; // Fallback value
}

}  // namespace webf