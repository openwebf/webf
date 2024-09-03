/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#include "core_initializer.h"
#include "core/css/style_change_reason.h"
#include "core/css/parser/css_parser_token_range.h"

namespace webf {

void CoreInitializer::Initialize() {
  CSSParserTokenRange::InitStaticEOFToken();
  style_change_extra_data::Init();
}

}