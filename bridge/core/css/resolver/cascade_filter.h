/*
 * Copyright (C) 2020 Google Inc. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 *     * Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above
 * copyright notice, this list of conditions and the following disclaimer
 * in the documentation and/or other materials provided with the
 * distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#ifndef WEBF_CORE_CSS_RESOLVER_CASCADE_FILTER_H_
#define WEBF_CORE_CSS_RESOLVER_CASCADE_FILTER_H_

#include "core/css/properties/css_property.h"

namespace webf {

// Pass only properties with the given flags set.
//
// For example, the following applies only inherited properties:
//
//  CascadeFilter filter;
//  filter = filter.Add(CSSProperty::kInherited);
//  filter.Accepts(GetCSSPropertyColor());            // -> true
//  filter.Accepts(GetCSSPropertyScrollbarGutter());  // -> false
//
class CascadeFilter {
 public:
  // Empty filter. Rejects nothing.
  CascadeFilter() = default;

  // Creates a filter with a single rule.
  //
  // This is equivalent to:
  //
  //  CascadeFilter filter;
  //  filter = filter.Add(flag, v);
  //
  explicit CascadeFilter(CSSProperty::Flag flag) : required_bits_(flag) {}

  bool operator==(const CascadeFilter& o) const {
    return required_bits_ == o.required_bits_;
  }
  bool operator!=(const CascadeFilter& o) const {
    return required_bits_ != o.required_bits_;
  }

  // Add a given rule to the filter. For instance:
  //
  //  CascadeFilter f1(CSSProperty::kInherited); // Rejects non-inherited
  //
  // Note that it is not possible to reject on a negative. However, some flags
  // have deliberately inverted flag (e.g. every property has exactly one of
  // kAnimated and kNotAnimated). If you wish to reject all properties, you
  // can do so by testing on both of the flags at the same time.
  //
  // Add() will have no effect if there already is a rule for the given flag:
  //
  //  CascadeFilter filter;
  //  CascadeFilter f1 = filter.Add(CSSProperty::kInherited);
  //  CascadeFilter f2 = f1.Add(CSSProperty::kInherited);
  //  bool equal = f1 == f2; // true. Second call to Add had to effect.
  CascadeFilter Add(CSSProperty::Flag flag) const {
    const CSSProperty::Flags required_bits = required_bits_ | flag;
    return CascadeFilter(required_bits);
  }

  bool Accepts(const CSSProperty& property) const {
    return (property.GetFlags() & required_bits_) == required_bits_;
  }

  bool Requires(CSSProperty::Flag flag) const {
    return (required_bits_ & flag) != 0;
  }

  bool IsEmpty() const { return required_bits_ == 0; }

 private:
  explicit CascadeFilter(CSSProperty::Flags required_bits)
      : required_bits_(required_bits) {}
  // Contains the flags to require.
  CSSProperty::Flags required_bits_ = 0;
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_RESOLVER_CASCADE_FILTER_H_