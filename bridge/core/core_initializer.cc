/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "core_initializer.h"
#include "../foundation/string/string_statics.h"
#include "core/css/media_query_evaluator.h"
#include "core/css/parser/css_parser_token_range.h"
#include "core/css/style_change_reason.h"
#include "core/dom/qualified_name.h"
#include "foundation/dtoa.h"
#include "names_installer.h"

namespace webf {

void CoreInitializer::Initialize() {
  StringImpl::InitStatics();
  CSSParserTokenRange::InitStaticEOFToken();
  Length::Initialize();
  style_change_extra_data::Init();
  MediaQueryEvaluator::Init();
  internal::InitializeDoubleConverter();
  StringStatics::Init();
  names_installer::Init();
  QualifiedName::Init();
}

}  // namespace webf