// Copyright 2019 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef WEBF_CORE_CSS_PROPERTIES_CSS_COLOR_FUNCTION_PARSER_H_
#define WEBF_CORE_CSS_PROPERTIES_CSS_COLOR_FUNCTION_PARSER_H_

#include <array>
#include "core/css/css_value.h"
#include "core/css/parser/css_parser_context.h"
#include "core/css/parser/css_parser_token_range.h"
#include "core/css/parser/css_parser_token_stream.h"
#include "core/css/css_color_channel_map.h"
#include "core/platform/graphics/color.h"
#include "foundation/macros.h"

namespace webf {

class ColorFunctionParser {
  WEBF_STACK_ALLOCATED();

 public:
  ColorFunctionParser() = default;
  // Parses the color inputs rgb(), rgba(), hsl(), hsla(), hwb(), lab(),
  // oklab(), lch(), oklch() and color(). https://www.w3.org/TR/css-color-4/
  std::shared_ptr<const CSSValue> ConsumeFunctionalSyntaxColor(CSSParserTokenRange& input_range,
                                                               const CSSParserContext& context);
  std::shared_ptr<const CSSValue> ConsumeFunctionalSyntaxColor(CSSParserTokenStream& input_stream, const CSSParserContext& context);

  struct FunctionMetadata;

 private:
  template <class T>
      requires std::is_same_v<T, CSSParserTokenStream> ||
      std::is_same_v<T, CSSParserTokenRange> std::shared_ptr<const CSSValue> ConsumeFunctionalSyntaxColorInternal(
          T& input_range,
          const CSSParserContext& context);

  enum class ChannelType { kNone, kPercentage, kNumber, kRelative };
  bool ConsumeChannel(CSSParserTokenRange& args, const CSSParserContext& context, int index);
  bool ConsumeAlpha(CSSParserTokenRange& args, const CSSParserContext& context);

  static std::optional<double> TryResolveColorChannel(const std::shared_ptr<const CSSValue>& value,
                                                      ChannelType channel_type,
                                                      double percentage_base,
                                                      const CSSColorChannelMap& color_channel_map);
  static std::optional<double> TryResolveAlpha(const std::shared_ptr<const CSSValue>& value,
                                               ChannelType channel_type,
                                               const CSSColorChannelMap& color_channel_map);
  static std::optional<double> TryResolveRelativeChannelValue(const std::shared_ptr<const CSSValue>& value,
                                                              ChannelType channel_type,
                                                              double percentage_base,
                                                              const CSSColorChannelMap& color_channel_map);

  std::array<std::shared_ptr<const CSSValue>, 3> unresolved_channels_;
  std::array<std::optional<double>, 3> channels_;
  std::array<ChannelType, 3> channel_types_;
  std::shared_ptr<const CSSValue> unresolved_alpha_;
  ChannelType alpha_channel_type_;
  std::optional<double> alpha_ = 1.0;

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
