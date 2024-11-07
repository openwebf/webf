// Copyright 2023 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef WEBF_CORE_CSS_STYLE_SCOPE_DATA_H_
#define WEBF_CORE_CSS_STYLE_SCOPE_DATA_H_

#include "core/dom/element_rare_data_field.h"
#include "bindings/qjs/cppgc/gc_visitor.h"

namespace webf {

class StyleScope;

// Implicit @scope rules are scoped to the parent element of the owner node of
// the stylesheet that defined the @scope rule. Each such parent element holds
// a StyleScopeData instance, with references back to the StyleScopes that
// are "triggered" by that element.
//
// This can be used to quickly determine if a given StyleScope is triggered
// by an Element (a check that would otherwise potentially be expensive, due
// to a single StyleSheetContents/StyleScope being shared by multiple
// CSSStyleSheets).
class StyleScopeData final : public ElementRareDataField {
 public:
  void Trace(GCVisitor*) const override;

  void AddTriggeredImplicitScope(const StyleScope&);
  void RemoveTriggeredImplicitScope(const StyleScope&);
  bool TriggersScope(const StyleScope&) const;

  const std::vector<std::shared_ptr<const StyleScope>>& GetTriggeredScopes() const {
    return triggered_implicit_scopes_;
  }

 private:
  friend class StyleScopeDataTest;

  // An element is assumed to trigger a single StyleScope in the common case
  // (i.e. only have one <style> element beneath it).
  //
  // It's possible however to have trigger more than one StyleScope,
  // for example:
  //
  // - When there's more than one <style> child.
  // - When the element is a shadow host, and there's more than one
  //   adopted stylesheet.
  // - Or when there's a combination of <style> elements and adopted
  //   stylesheets.
  std::vector<std::shared_ptr<const StyleScope>> triggered_implicit_scopes_;
};


}

#endif  // WEBF_CORE_CSS_STYLE_SCOPE_DATA_H_
