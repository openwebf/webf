// Copyright 2016 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CSS_LAZY_PARSING_STATE_H
#define WEBF_CSS_LAZY_PARSING_STATE_H


#include "bindings/qjs/atomic_string.h"
#include "bindings/qjs/cppgc/member.h"

namespace webf {

class CSSParserContext;
class StyleSheetContents;
class Document;

class CSSLazyParsingState final {
 public:
  CSSLazyParsingState(
      std::shared_ptr<const CSSParserContext>,
      const AtomicString& sheet_text,
      std::shared_ptr<StyleSheetContents>);

  const AtomicString& SheetText() const { return sheet_text_; }

  void Trace(GCVisitor*) const;

 private:
  std::shared_ptr<const CSSParserContext> context_;
  // Also referenced on the css resource.
  AtomicString sheet_text_;

  // Weak to ensure lazy state will never cause the contents to live longer than
  // it should (we DCHECK this fact). Normally, the <link> tag will keep the
  // StyleSheetContents alive.
  //
  // When we mutate a stylesheet's rules, we do copy-on-write on its
  // StyleSheetContents, invalidating this pointer. However, we also Copy()
  // every single rule, which parses them eagerly, so we don't need to worry
  // about what happens to the CSSLazyParsingState in that case.
  // This happens in StyleSheetContents' copy constructor.
  std::shared_ptr<StyleSheetContents> owning_contents_;

  // Cache the document as a proxy for caching the UseCounter. Grabbing the
  // UseCounter per every property parse is a bit more expensive.
  Member<Document> document_;

  // Whether or not use counting is enabled for parsing. This will usually be
  // true, except for when stylesheets with @imports are removed from the page.
  // See StyleRuleImport::setCSSStyleSheet.
//  const bool should_use_count_;
};

}  // namespace webf

#endif  // WEBF_CSS_LAZY_PARSING_STATE_H
