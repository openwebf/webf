// Copyright 2016 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "css_lazy_parsing_state.h"
#include "css_parser_context.h"
#include "bindings/qjs/cppgc/gc_visitor.h"

namespace webf {

CSSLazyParsingState::CSSLazyParsingState(std::shared_ptr<const CSSParserContext> context,
                                         const AtomicString& sheet_text,
                                         std::shared_ptr<StyleSheetContents> contents)
    : context_(context),
      sheet_text_(sheet_text),
      owning_contents_(contents) {}


void CSSLazyParsingState::Trace(GCVisitor* visitor) const {
  visitor->TraceMember(document_);
}

}  // namespace webf
