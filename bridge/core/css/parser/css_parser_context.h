// Copyright 2016 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CSS_PARSER_CONTEXT_H
#define WEBF_CSS_PARSER_CONTEXT_H

#include "bindings/qjs/atomic_string.h"
#include "css_parser_mode.h"
#include "core/dom/document.h"
#include "core/executing_context.h"

namespace webf {

class Document;
class StyleSheetContents;

class CSSParserContext final {

 public:
  explicit CSSParserContext(const CSSParserContext* other,
                            const Document* use_counter_document = nullptr);
  CSSParserContext(const CSSParserContext*, const StyleSheetContents*);
  CSSParserContext(const Document&,
                   const AtomicString& base_url_override,
//                   bool origin_clean,
//                   const Referrer& referrer,
                   const AtomicString& charset = AtomicString()); // TODO: WTF::TextEncoding;（encoding移除，默认都是utf8）

  CSSParserContext(const AtomicString& base_url,
//                   bool origin_clean,
                   const AtomicString& charset,
                   CSSParserMode,
//                   const Referrer& referrer,
//                   bool is_html_document,
//                   SecureContextMode,
//                   const DOMWrapperWorld* world,
                   const Document* use_counter_document
//                   ResourceFetchRestriction resource_fetch_restriction
                   );

  CSSParserContext(CSSParserMode,
                   SecureContextMode,
                   const Document* use_counter_document = nullptr);

  bool IsForMarkupSanitization() const;

  bool IsUseCounterRecordingEnabled() { return document_ != nullptr; }
  const Document* GetDocument() const;
  ExecutingContext* GetExecutingContext() const;
  CSSParserMode Mode() const { return mode_; }


 private:
  AtomicString base_url_;
  CSSParserMode mode_;
  AtomicString charset_;
  Member<const Document> document_;

};

std::shared_ptr<const CSSParserContext> StrictCSSParserContext(SecureContextMode);

}  // namespace webf

#endif  // WEBF_CSS_PARSER_CONTEXT_H
