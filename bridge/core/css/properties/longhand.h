// Copyright 2017 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_LONGHAND_H
#define WEBF_LONGHAND_H

#include "core/css/css_initial_value.h"
#include "core/css/parser/css_tokenizer.h"
#include "core/css/properties/css_property.h"
#include "core/css/resolver/style_resolver_state.h"
#include "core/platform/graphics/color.h"
#include "foundation/casting.h"

namespace webf {

class CSSValue;
class CSSParserContext;
class CSSParserLocalContext;
class CSSParserTokenStream;

class Longhand : public CSSProperty {
 public:
//   Parses and consumes a longhand property value from the token stream.
//   Returns nullptr if the input is invalid.
//
//   NOTE: This function must accept arbitrary tokens after the value,
//   without returning error. In particular, it must not check for
//   end-of-stream, since it may be called as part of parsing a shorthand, or
//   there may be “!important” after the value that the caller is responsible
//   the caller is responsible for consuming. End-of-stream is checked
//   by the caller (after potentially consuming “!important”).
  virtual std::shared_ptr<const CSSValue> ParseSingleValue(
      CSSParserTokenStream& stream,
      std::shared_ptr<const CSSParserContext> context,
      const CSSParserLocalContext& local_tokenizer) const {
    return nullptr;
  }
  virtual void ApplyInitial(StyleResolverState&) const {
    assert_m(false, "NOTREACHED_IN_MIGRATION");
  }
  virtual void ApplyInherit(StyleResolverState&) const {
    assert_m(false, "NOTREACHED_IN_MIGRATION");
  }
  virtual void ApplyValue(StyleResolverState&,
                          const CSSValue&,
                          ValueMode) const {
    assert_m(false, "NOTREACHED_IN_MIGRATION");
  }
  void ApplyUnset(StyleResolverState& state) const {
    if (state.IsInheritedForUnset(*this)) {
      ApplyInherit(state);
    } else {
      ApplyInitial(state);
    }
  }
  virtual const webf::Color ColorIncludingFallback(
      bool,
      const ComputedStyle&,
      bool* is_current_color = nullptr) const {
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return Color();
  }
  virtual std::shared_ptr<const CSSValue> InitialValue() const {
    return CSSInitialValue::Create();
  }

 protected:
  constexpr Longhand(CSSPropertyID id, Flags flags, char repetition_separator)
      : CSSProperty(id, flags | kLonghand, repetition_separator) {}

//   Applies the computed CSSValue of the parent style using ApplyValue.
//   This generally achieves the same as ApplyInherit, but effectively
//   "rezooms" the value.
//
//   https://github.com/w3c/csswg-drafts/issues/9397
  void ApplyParentValue(StyleResolverState&) const;
  // If our zoom is different from the parent zoom, calls ApplyParentValue
  // and returns true. Otherwise does nothing and returns false.
  bool ApplyParentValueIfZoomChanged(StyleResolverState&) const;
};

template <>
struct DowncastTraits<Longhand> {
  static bool AllowFrom(const CSSProperty& longhand) {
    return longhand.IsLonghand();
  }
};


}  // namespace webf

#endif  // WEBF_LONGHAND_H