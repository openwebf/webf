// Copyright 2016 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifndef WEBF_CORE_CSS_CSS_IDENTIFIER_VALUE_H_
#define WEBF_CORE_CSS_CSS_IDENTIFIER_VALUE_H_

#include "core/css/css_value.h"
//#include "core/css/css_value_id_mappings.h"
#include "css_value_keywords.h"
#include "foundation/casting.h"

namespace webf {

// CSSIdentifierValue stores CSS value keywords, e.g. 'none', 'auto',
// 'lower-roman'.
// conflicts with CSSOM's CSSKeywordValue class.
class CSSIdentifierValue : public CSSValue {
 public:
  static std::shared_ptr<CSSIdentifierValue> Create(CSSValueID);

  template <typename T>
  static std::shared_ptr<CSSIdentifierValue> Create(T value) {
    static_assert(!std::is_same<T, CSSValueID>::value,
                  "Do not call create() with a CSSValueID; call "
                  "createIdentifier() instead");
    return std::make_shared<CSSIdentifierValue>(value);
  }

  static std::shared_ptr<CSSIdentifierValue> Create(const Length& value) {
    return std::make_shared<CSSIdentifierValue>(value);
  }

  explicit CSSIdentifierValue(CSSValueID);
  explicit CSSIdentifierValue(CSSValueID, bool was_quirky);

  template <typename T>
  CSSIdentifierValue(T t) : CSSValue(kIdentifierClass), value_id_(PlatformEnumToCSSValueID(t)) {}

  CSSIdentifierValue(const Length&);

  [[nodiscard]] CSSValueID GetValueID() const { return value_id_; }

  std::string CustomCSSText() const;

  bool Equals(const CSSIdentifierValue& other) const { return value_id_ == other.value_id_; }

  template <typename T>
  inline T ConvertTo() const {  // Overridden for special cases in CSSPrimitiveValueMappings.h
    return CssValueIDToPlatformEnum<T>(value_id_);
  }

  bool WasQuirky() const { return was_quirky_; }

  void TraceAfterDispatch(GCVisitor*) const;

 private:
  CSSValueID value_id_;
};

template <>
struct DowncastTraits<CSSIdentifierValue> {
  static bool AllowFrom(const CSSValue& value) { return value.IsIdentifierValue(); }
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_CSS_IDENTIFIER_VALUE_H_
