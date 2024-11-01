/*
 * (C) 1999-2003 Lars Knoll (knoll@kde.org)
 * Copyright (C) 2004, 2005, 2006 Apple Computer, Inc.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public License
 * along with this library; see the file COPYING.LIB.  If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301, USA.
 */

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CSS_VALUE_PAIR_H
#define WEBF_CSS_VALUE_PAIR_H

// #include "core/core_export.h"
#include "core/css/css_value.h"
#include "foundation/casting.h"

namespace webf {

class CSSValuePair : public CSSValue {
 public:
  enum IdenticalValuesPolicy { kDropIdenticalValues, kKeepIdenticalValues };

  CSSValuePair(const std::shared_ptr<const CSSValue>& first,
               const std::shared_ptr<const CSSValue>& second,
               IdenticalValuesPolicy identical_values_policy)
      : CSSValue(kValuePairClass), first_(first), second_(second), identical_values_policy_(identical_values_policy) {
    assert(first_);
    assert(second_);
  }

  std::shared_ptr<const CSSValue> First() const { return first_; }
  std::shared_ptr<const CSSValue> Second() const { return second_; }

  bool KeepIdenticalValues() const { return identical_values_policy_ == kKeepIdenticalValues; }

  std::string CustomCSSText() const {
    std::string first = first_->CssText();
    std::string second = second_->CssText();
    if (identical_values_policy_ == kDropIdenticalValues && first == second) {
      return first;
    }
    std::string result;
    result.append(first);
    result.append(" ");
    result.append(second);
    return result;
  }

  bool Equals(const CSSValuePair& other) const {
    return webf::ValuesEquivalent(first_, other.first_) && webf::ValuesEquivalent(second_, other.second_) &&
           identical_values_policy_ == other.identical_values_policy_;
  }

  void TraceAfterDispatch(GCVisitor*) const;

 protected:
  CSSValuePair(ClassType class_type,
               const std::shared_ptr<const CSSValue>& first,
               const std::shared_ptr<const CSSValue>& second)
      : CSSValue(class_type), first_(first), second_(second), identical_values_policy_(kKeepIdenticalValues) {
    assert(first_);
    assert(second_);
  }

 private:
  std::shared_ptr<const CSSValue> first_;
  std::shared_ptr<const CSSValue> second_;
  IdenticalValuesPolicy identical_values_policy_;
};

template <>
struct DowncastTraits<CSSValuePair> {
  static bool AllowFrom(const CSSValue& value) { return value.IsValuePair(); }
};

}  // namespace webf

#endif  // WEBF_CSS_VALUE_PAIR_H
