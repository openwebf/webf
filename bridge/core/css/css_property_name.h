// Copyright 2018 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CSS_PROPERTY_NAME_H
#define WEBF_CSS_PROPERTY_NAME_H

#include <optional>
#include "foundation/macros.h"
#include "foundation/atomic_string.h"
#include "css_property_names.h"

namespace webf {

class ExecutingContext;

// This class may be used to represent the name of any valid CSS property,
// including custom properties.
class CSSPropertyName {
  WEBF_STACK_ALLOCATED();

 public:
  explicit CSSPropertyName(CSSPropertyID property_id)
      : value_(static_cast<int>(property_id)) {
    assert(Id() != CSSPropertyID::kInvalid);
    assert(Id() != CSSPropertyID::kVariable);
  }

  explicit CSSPropertyName(const AtomicString& custom_property_name)
      : value_(static_cast<int>(CSSPropertyID::kVariable)),
        custom_property_name_(custom_property_name) {
    assert(!custom_property_name.empty());
  }

  static std::optional<CSSPropertyName> From(
      const ExecutingContext* execution_context,
      const std::string& value) {
    const CSSPropertyID property_id = CssPropertyID(execution_context, value);
    if (property_id == CSSPropertyID::kInvalid) {
      return std::nullopt;
    }
    if (property_id == CSSPropertyID::kVariable) {
      return std::make_optional(CSSPropertyName(AtomicString(value)));
    }
    return std::make_optional(CSSPropertyName(property_id));
  }

  bool operator==(const CSSPropertyName&) const;
  bool operator!=(const CSSPropertyName& other) const {
    return !(*this == other);
  }

  [[nodiscard]] CSSPropertyID Id() const {
    assert(!IsEmptyValue() && !IsDeletedValue());
    return static_cast<CSSPropertyID>(value_);
  }

  bool IsCustomProperty() const { return Id() == CSSPropertyID::kVariable; }

  AtomicString ToAtomicString() const;

 private:
  // For HashTraits::EmptyValue().
  static constexpr int kEmptyValue = -1;
  // For HashTraits::ConstructDeletedValue(...).
  static constexpr int kDeletedValue = -2;

  explicit CSSPropertyName(int value) : value_(value) {
    assert(value == kEmptyValue || value == kDeletedValue);
  }

  unsigned GetHash() const;
  bool IsEmptyValue() const { return value_ == kEmptyValue; }
  bool IsDeletedValue() const { return value_ == kDeletedValue; }

  // The value_ field is either a CSSPropertyID, kEmptyValue, or
  // kDeletedValue.
  int value_;
  AtomicString custom_property_name_;
};


}  // namespace webf

#endif  // WEBF_CSS_PROPERTY_NAME_H
