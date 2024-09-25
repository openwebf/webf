// Copyright 2016 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "css_parser_context.h"
#include "core/css/style_sheet_contents.h"
#include "core/dom/document.h"

namespace webf {

CSSParserContext::CSSParserContext(CSSParserMode mode, const Document* use_counter_document)
    : CSSParserContext("", mode, nullptr) {}

CSSParserContext::CSSParserContext(const Document& document, const std::string& base_url_override)
    : document_(&document), base_url_(base_url_override) {}

CSSParserContext::CSSParserContext(const CSSParserContext* other, const StyleSheetContents* style_sheet_contents)
    : document_(StyleSheetContents::SingleOwnerDocument(style_sheet_contents)),
      mode_(CSSParserMode::kHTMLStandardMode),
      base_url_(other->base_url_) {}

CSSParserContext::CSSParserContext(const std::string& base_url,
                                   webf::CSSParserMode mode,
                                   const webf::Document* use_counter_document)
    : document_(use_counter_document), mode_(mode), base_url_(base_url) {}

CSSParserContext::CSSParserContext(const webf::ExecutingContext* context): document_(context->document()), base_url_("") {}

ExecutingContext* CSSParserContext::GetExecutingContext() const {
  return (document_.Get()) ? document_.Get()->GetExecutingContext() : nullptr;
}

bool CSSParserContext::IsDocumentHandleEqual(const webf::Document* other) const {
  return document_.Get() == other;
}

const Document* CSSParserContext::GetDocument() const {
  return document_.Get();
}

KURL CSSParserContext::CompleteURL(const std::string& url) const {
  if (url.empty()) {
    return KURL();
  }
  return KURL(BaseURL(), url);
}

KURL CSSParserContext::CompleteNonEmptyURL(const std::string& url) const {
  if (url.empty()) {
    return KURL("");
  }
  return CompleteURL(url);
}


bool CSSParserContext::IsForMarkupSanitization() const {
  return document_ && document_->IsForMarkupSanitization();
}

// TODO(xiaochengh): This function never returns null. Change it to return a
// const reference to avoid confusion.
std::shared_ptr<const CSSParserContext> StrictCSSParserContext(SecureContextMode secure_context_mode) {
  /* // TODO(guopengfei)：
  thread_local static std::shared_ptr<CSSParserContext> strict_context_pool = std::make_shared<CSSParserContext>();
  thread_local static std::shared_ptr<CSSParserContext> secure_strict_context_pool = std::make_shared<CSSParserContext>();

  std::shared_ptr<CSSParserContext> context =
      secure_context_mode == SecureContextMode::kSecureContext
          ? secure_strict_context_pool
          : strict_context_pool;
  if (!context) {
    context = std::make_shared<CSSParserContext>(kHTMLStandardMode,
                                                     secure_context_mode);
    ((void)0)(&context);
  }

  return context;
  */
  return nullptr;
}

void CSSParserContext::Trace(webf::GCVisitor* visitor) const {
  visitor->TraceMember(document_);
}

}  // namespace webf
