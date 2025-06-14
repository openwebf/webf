// Copyright 2015 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifndef WEBF_CORE_CSS_CSS_CUSTOM_IDENT_VALUE_H_
#define WEBF_CORE_CSS_CSS_CUSTOM_IDENT_VALUE_H_

#include "core/css/css_value.h"
#include "css_property_name.h"

namespace webf {

class TreeScope;
class ScopedCSSName;

class CSSCustomIdentValue : public CSSValue {
 public:
  explicit CSSCustomIdentValue(const std::string&);
  explicit CSSCustomIdentValue(CSSPropertyID);
  explicit CSSCustomIdentValue(const ScopedCSSName&);

  const TreeScope* GetTreeScope() const { return tree_scope_; }
  const std::string& Value() const {
    assert(!IsKnownPropertyID());
    return string_;
  }
  bool IsKnownPropertyID() const { return property_id_ != CSSPropertyID::kInvalid; }
  CSSPropertyID ValueAsPropertyID() const {
    assert(IsKnownPropertyID());
    return property_id_;
  }

  std::string CustomCSSText() const;

  std::shared_ptr<const CSSCustomIdentValue> PopulateWithTreeScope(const TreeScope* tree_scope) const;

  bool Equals(const CSSCustomIdentValue& other) const {
    if (IsKnownPropertyID()) {
      return property_id_ == other.property_id_;
    }
    return IsScopedValue() == other.IsScopedValue() && tree_scope_ == other.tree_scope_ && string_ == other.string_;
  }

  void TraceAfterDispatch(GCVisitor*) const;

 private:
  const TreeScope* tree_scope_;
  std::string string_;
  CSSPropertyID property_id_;
};

template <>
struct DowncastTraits<CSSCustomIdentValue> {
  static bool AllowFrom(const CSSValue& value) { return value.IsCustomIdentValue(); }
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_CSS_CUSTOM_IDENT_VALUE_H_
