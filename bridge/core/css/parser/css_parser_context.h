// Copyright 2016 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CSS_PARSER_CONTEXT_H
#define WEBF_CSS_PARSER_CONTEXT_H

#include "bindings/qjs/atomic_string.h"
#include "core/dom/document.h"
#include "core/executing_context.h"
#include "core/base/auto_reset.h"
#include "css_parser_mode.h"
#include "core/platform/url/kurl.h"

namespace webf {

class Document;
class StyleSheetContents;

enum class SecureContextMode { kInsecureContext, kSecureContext };

class CSSParserContext final {
 public:
  explicit CSSParserContext(CSSParserMode, const Document* use_counter_document = nullptr);
  explicit CSSParserContext(const CSSParserContext*, const StyleSheetContents*);
  explicit CSSParserContext(const Document&, const std::string& base_url_override);
  explicit CSSParserContext(const std::string& base_url, CSSParserMode mode, const Document* use_counter_document);


  const KURL& BaseURL() const { return base_url_; }

  bool IsForMarkupSanitization() const;

  void SetMode(CSSParserMode mode) { mode_ = mode; }

  bool IsUseCounterRecordingEnabled() const { return document_ != nullptr; }
  const Document* GetDocument() const;
  ExecutingContext* GetExecutingContext() const;
  bool IsDocumentHandleEqual(const Document* other) const;
  CSSParserMode Mode() const { return mode_; }

  KURL CompleteURL(const std::string& url) const;

  // Like CompleteURL(), but if `url` is empty a null KURL is returned.
  KURL CompleteNonEmptyURL(const std::string& url) const;


  // Overrides |mode_| of a CSSParserContext within the scope, allowing us to
  // switching parsing mode while parsing different parts of a style sheet.
  // TODO(xiaochengh): This isn't the right approach, as it breaks the
  // immutability of CSSParserContext. We should introduce some local context.
  class ParserModeOverridingScope {
    WEBF_STACK_ALLOCATED();

   public:
    ParserModeOverridingScope(const CSSParserContext& context,
                              CSSParserMode mode)
        : mode_reset_(const_cast<CSSParserMode*>(&context.mode_), mode) {}

   private:
    AutoReset<CSSParserMode> mode_reset_;
  };


 private:
  KURL base_url_;
  CSSParserMode mode_;
  Member<const Document> document_;
};

std::shared_ptr<const CSSParserContext> StrictCSSParserContext(SecureContextMode);

}  // namespace webf

#endif  // WEBF_CSS_PARSER_CONTEXT_H
