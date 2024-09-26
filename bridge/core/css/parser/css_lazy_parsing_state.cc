// Copyright 2016 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "css_lazy_parsing_state.h"
#include "core/css/style_sheet_contents.h"
#include "css_parser_context.h"
#include "bindings/qjs/cppgc/gc_visitor.h"

namespace webf {

CSSLazyParsingState::CSSLazyParsingState(std::shared_ptr<const CSSParserContext> context,
                                         const std::string& sheet_text,
                                         std::shared_ptr<StyleSheetContents> contents)
    : context_(context),
      sheet_text_(sheet_text),
      owning_contents_(contents),
      should_use_count_(context_->IsUseCounterRecordingEnabled()){}

std::shared_ptr<const CSSParserContext> CSSLazyParsingState::Context() {
  assert(owning_contents_);
  if (!should_use_count_) {
    assert(!context_->IsUseCounterRecordingEnabled());
    return context_;
  }

  // Try as good as possible to grab a valid Document if the old Document has
  // gone away, so we can still use UseCounter.
  if (!document_) {
    document_ = owning_contents_->AnyOwnerDocument();
  }

  return context_;
}

void CSSLazyParsingState::Trace(GCVisitor* visitor) const {
  visitor->TraceMember(document_);
}

}  // namespace webf
