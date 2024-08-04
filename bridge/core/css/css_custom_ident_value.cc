// Copyright 2015 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#include "core/css/css_custom_ident_value.h"

#include "core/css/css_markup.h"
#include "core/css/properties/css_unresolved_property.h"
#include "core/dom/tree_scope.h"
#include "core/style/scoped_css_name.h"

namespace webf {

CSSCustomIdentValue::CSSCustomIdentValue(const std::string& str)
    : CSSValue(kCustomIdentClass), string_(str), property_id_(CSSPropertyID::kInvalid) {
  needs_tree_scope_population_ = true;
}

CSSCustomIdentValue::CSSCustomIdentValue(CSSPropertyID id) : CSSValue(kCustomIdentClass), string_(), property_id_(id) {
  assert(IsKnownPropertyID());
}

CSSCustomIdentValue::CSSCustomIdentValue(const ScopedCSSName& name) : CSSCustomIdentValue(name.GetName()) {
  tree_scope_ = name.GetTreeScope();
  needs_tree_scope_population_ = false;
}

std::string CSSCustomIdentValue::CustomCSSText() const {
  if (IsKnownPropertyID()) {
    return CSSUnresolvedProperty::Get(property_id_).GetPropertyName();
  }
  std::string builder;
  SerializeIdentifier(string_, builder);
  return builder;
}

std::shared_ptr<const CSSCustomIdentValue> CSSCustomIdentValue::PopulateWithTreeScope(
    std::shared_ptr<const TreeScope>& tree_scope) const {
  assert(this->needs_tree_scope_population_);
  std::shared_ptr<CSSCustomIdentValue> populated = std::make_shared<CSSCustomIdentValue>(*this);
  populated->tree_scope_ = tree_scope;
  populated->needs_tree_scope_population_ = false;
  return populated;
}

void CSSCustomIdentValue::TraceAfterDispatch(GCVisitor* visitor) const {
  // visitor->TraceMember(tree_scope_);
  CSSValue::TraceAfterDispatch(visitor);
}

}  // namespace webf
