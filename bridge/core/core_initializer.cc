/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#include "foundation/string_statics.h"
#include "core_initializer.h"
#include "core/css/style_change_reason.h"
#include "core/css/parser/css_parser_token_range.h"
#include "core/css/media_query_evaluator.h"
#include "foundation/dtoa.h"

namespace webf {

void CoreInitializer::Initialize() {
  StringImpl::InitStatics();
  CSSParserTokenRange::InitStaticEOFToken();
  Length::Initialize();
  style_change_extra_data::Init();
  MediaQueryEvaluator::Init();
  internal::InitializeDoubleConverter();
  StringStatics::Init();
}

}