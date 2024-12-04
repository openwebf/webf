// Copyright 2019 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef WEBF_CORE_CSS_PROPERTIES_CSS_COLOR_FUNCTION_PARSER_H_
#define WEBF_CORE_CSS_PROPERTIES_CSS_COLOR_FUNCTION_PARSER_H_

#include <array>
#include "core/css/css_color_channel_map.h"
#include "core/css/css_value.h"
#include "core/css/parser/css_parser_context.h"
#include "core/css/parser/css_parser_token_range.h"
#include "core/css/parser/css_parser_token_stream.h"
#include "core/platform/graphics/color.h"
#include "foundation/macros.h"

namespace webf {

class CSSValue;

class ColorFunctionParser {
 public:
  ColorFunctionParser() = default;
  // Parses the color inputs rgb(), rgba(), hsl(), hsla(), hwb(), lab(),
  // oklab(), lch(), oklch() and color(). https://www.w3.org/TR/css-color-4/
  std::shared_ptr<const CSSValue> ConsumeFunctionalSyntaxColor(CSSParserTokenRange& input_range,
                                                               std::shared_ptr<const CSSParserContext> context);
  std::shared_ptr<const CSSValue> ConsumeFunctionalSyntaxColor(CSSParserTokenStream& input_stream,
                                                               std::shared_ptr<const CSSParserContext> context);

  struct FunctionMetadata;

 private:
  template <class T>
  typename std::enable_if<std::is_same<T, CSSParserTokenStream>::value || std::is_same<T, CSSParserTokenRange>::value,
                          std::shared_ptr<const CSSValue>>::type
  ConsumeFunctionalSyntaxColorInternal(T& input_range, std::shared_ptr<const CSSParserContext> context);

  enum class ChannelType { kNone, kPercentage, kNumber, kRelative };
  bool ConsumeColorSpaceAndOriginColor(CSSParserTokenRange& args,
                                       CSSValueID function_id,
                                       std::shared_ptr<const CSSParserContext> context);
  bool ConsumeChannel(CSSParserTokenRange& args, std::shared_ptr<const CSSParserContext> context, int index);
  bool ConsumeAlpha(CSSParserTokenRange& args, std::shared_ptr<const CSSParserContext> context);
  bool MakePerColorSpaceAdjustments();

  Color::ColorSpace color_space_ = Color::ColorSpace::kNone;
  std::optional<double> channels_[3];
  ChannelType channel_types_[3];
  std::optional<double> alpha_ = 1.0;

  // Metadata about the current function being parsed. Set by
  // `ConsumeColorSpaceAndOriginColor()` after parsing the preamble of the
  // function.
  const FunctionMetadata* function_metadata_ = nullptr;

  // Legacy colors have commas separating their channels. This syntax is
  // incompatible with CSSColor4 features like "none" or alpha with a slash.
  bool is_legacy_syntax_ = false;
  bool has_none_ = false;

  // For relative colors
  bool is_relative_color_ = false;
  Color origin_color_;
  CSSColorChannelMap color_channel_map_;
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_PROPERTIES_CSS_COLOR_FUNCTION_PARSER_H_
