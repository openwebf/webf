// Copyright 2017 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#include "core/css/properties/css_parsing_utils.h"

#include <cmath>
#include <memory>
#include <utility>

//#include "core/css/counter_style_map.h"
//#include "core/css/css_appearance_auto_base_select_value_pair.h"
#include "core/css/css_axis_value.h"
#include "core/css/css_value_pair.h"
//#include "core/css/css_basic_shape_values.h"
//#include "core/css/css_border_image.h"
//#include "core/css/css_bracketed_value_list.h"
//#include "core/css/css_color.h"
//#include "core/css/css_color_mix_value.h"
//#include "core/css/css_content_distribution_value.h"
//#include "core/css/css_crossfade_value.h"
//#include "core/css/css_custom_ident_value.h"
//#include "core/css/css_font_family_value.h"
//#include "core/css/css_font_feature_value.h"
//#include "core/css/css_font_style_range_value.h"
//#include "core/css/css_function_value.h"
//#include "core/css/css_gradient_value.h"
//#include "core/css/css_grid_auto_repeat_value.h"
//#include "core/css/css_grid_integer_repeat_value.h"
//#include "core/css/css_grid_template_areas_value.h"
//#include "core/css/css_identifier_value.h"
//#include "core/css/css_image_set_option_value.h"
//#include "core/css/css_image_set_type_value.h"
//#include "core/css/css_image_set_value.h"
//#include "core/css/css_image_value.h"
//#include "core/css/css_inherited_value.h"
//#include "core/css/css_initial_value.h"
//#include "core/css/css_light_dark_value_pair.h"
//#include "core/css/css_math_expression_node.h"
//#include "core/css/css_math_function_value.h"
//#include "core/css/css_numeric_literal_value.h"
//#include "core/css/css_paint_value.h"
//#include "core/css/css_palette_mix_value.h"
//#include "core/css/css_path_value.h"
//#include "core/css/css_primitive_value.h"
//#include "core/css/css_property_names.h"
//#include "core/css/css_property_value.h"
//#include "core/css/css_ratio_value.h"
//#include "core/css/css_ray_value.h"
//#include "core/css/css_revert_layer_value.h"
//#include "core/css/css_revert_value.h"
//#include "core/css/css_scroll_value.h"
//#include "core/css/css_shadow_value.h"
//#include "core/css/css_string_value.h"
//#include "core/css/css_timing_function_value.h"
//#include "core/css/css_unset_value.h"
//#include "core/css/css_uri_value.h"
//#include "core/css/css_value.h"
//#include "core/css/css_value_list.h"
//#include "core/css/css_value_pair.h"
//#include "core/css/css_variable_data.h"
//#include "core/css/css_view_value.h"
//#include "core/css/parser/css_parser_context.h"
//#include "core/css/parser/css_parser_fast_paths.h"
//#include "core/css/parser/css_parser_idioms.h"
//#include "core/css/parser/css_parser_local_context.h"
//#include "core/css/parser/css_parser_mode.h"
//#include "core/css/parser/css_parser_save_point.h"
//#include "core/css/parser/css_parser_token.h"
//#include "core/css/parser/css_parser_token_range.h"
//#include "core/css/parser/css_parser_token_stream.h"
//#include "core/css/parser/css_variable_parser.h"
//#include "core/css/properties/css_color_function_parser.h"
//#include "core/css/properties/css_parsing_utils.h"
//#include "core/css/properties/css_property.h"
//#include "core/css/properties/longhand.h"
//#include "core/css/style_color.h"
//#include "core/css/css_value_keywords.h"
//#include "core/dom/document.h"
//#include "core/frame/deprecation/deprecation.h"
//#include "core/frame/web_feature.h"
//#include "core/inspector/console_message.h"
//#include "core/page/chrome_client.h"
//#include "core/page/page.h"
//#include "core/style_property_shorthand.h"
//#include "core/svg/svg_parsing_error.h"
//#include "core/svg/svg_path_utilities.h"
//#include "third_party/blink/renderer/platform/animation/timing_function.h"
//#include "third_party/blink/renderer/platform/fonts/font_selection_types.h"
//#include "third_party/blink/renderer/platform/graphics/color.h"
//#include "third_party/blink/renderer/platform/heap/garbage_collected.h"
//#include "third_party/blink/renderer/platform/instrumentation/use_counter.h"
//#include "third_party/blink/renderer/platform/loader/fetch/fetch_initiator_type_names.h"
//#include "third_party/blink/renderer/platform/runtime_enabled_features.h"
//#include "third_party/blink/renderer/platform/wtf/text/string_builder.h"
//#include "gfx/animation/keyframe/timing_function.h"
//#include "ui/gfx/color_utils.h"

namespace webf {
namespace css_parsing_utils {

// https://drafts.csswg.org/css-syntax/#typedef-any-value
bool IsTokenAllowedForAnyValue(const CSSParserToken& token) {
  switch (token.GetType()) {
    case kBadStringToken:
    case kEOFToken:
    case kBadUrlToken:
      return false;
    case kRightParenthesisToken:
    case kRightBracketToken:
    case kRightBraceToken:
      return token.GetBlockType() == CSSParserToken::kBlockEnd;
    default:
      return true;
  }
}

bool ConsumeCommaIncludingWhitespace(CSSParserTokenRange& range) {
  CSSParserToken value = range.Peek();
  if (value.GetType() != kCommaToken) {
    return false;
  }
  range.ConsumeIncludingWhitespace();
  return true;
}

bool ConsumeCommaIncludingWhitespace(CSSParserTokenStream& stream) {
  CSSParserToken value = stream.Peek();
  if (value.GetType() != kCommaToken) {
    return false;
  }
  stream.ConsumeIncludingWhitespace();
  return true;
}

bool ConsumeSlashIncludingWhitespace(CSSParserTokenRange& range) {
  CSSParserToken value = range.Peek();
  if (value.GetType() != kDelimiterToken || value.Delimiter() != '/') {
    return false;
  }
  range.ConsumeIncludingWhitespace();
  return true;
}

bool ConsumeSlashIncludingWhitespace(CSSParserTokenStream& stream) {
  CSSParserToken value = stream.Peek();
  if (value.GetType() != kDelimiterToken || value.Delimiter() != '/') {
    return false;
  }
  stream.ConsumeIncludingWhitespace();
  return true;
}

CSSParserTokenRange ConsumeFunction(CSSParserTokenRange& range) {
  assert(range.Peek().GetType() == kFunctionToken);
  CSSParserTokenRange contents = range.ConsumeBlock();
  range.ConsumeWhitespace();
  contents.ConsumeWhitespace();
  return contents;
}

CSSParserTokenRange ConsumeFunction(CSSParserTokenStream& stream) {
  assert(stream.Peek().GetType() == kFunctionToken);
  CSSParserTokenRange contents((std::vector<CSSParserToken>()));
  {
    CSSParserTokenStream::BlockGuard guard(stream);
    contents = stream.ConsumeUntilPeekedTypeIs<>();
  }
  stream.ConsumeWhitespace();
  contents.ConsumeWhitespace();
  return contents;
}

bool ConsumeAnyValue(CSSParserTokenRange& range) {
  bool result = IsTokenAllowedForAnyValue(range.Peek());
  unsigned nesting_level = 0;

  while (nesting_level || result) {
    const CSSParserToken& token = range.Consume();
    if (token.GetBlockType() == CSSParserToken::kBlockStart) {
      nesting_level++;
    } else if (token.GetBlockType() == CSSParserToken::kBlockEnd) {
      nesting_level--;
    }
    if (range.AtEnd()) {
      return result;
    }
    result = result && IsTokenAllowedForAnyValue(range.Peek());
  }

  return result;
}


}

}  // namespace blink
