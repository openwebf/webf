// Copyright 2017 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_SHORTHAND_H
#define WEBF_SHORTHAND_H

#include "core/css/properties/css_property.h"
#include "foundation/casting.h"

namespace webf {

class CSSParserContext;
class CSSParserLocalContext;
class CSSParserTokenStream;
class CSSPropertyValue;

class Shorthand : public CSSProperty {
 public:
  // Parses and consumes entire shorthand value from the token range and adds
  // all constituent parsed longhand properties to the 'properties' set.
  // Returns false if the input is invalid. (If so, all longhands added to
  // 'properties' will be removed again by the caller.)
  //
  // NOTE: This function must accept arbitrary tokens after the value,
  // without returning error. In particular, it must not check for
  // end-of-stream, since there may be “!important” after the value that
  // the caller is responsible for consuming. End-of-stream is checked
  // by the caller (after potentially consuming “!important”).
  //
  // (In practice, there are a few of these implementations that are not
  // robust against _any_ arbitrary tokens, especially those that may be
  // the start of useful values. However, they absolutely need to be
  // resistant against “!important”, at the very least.)
  virtual bool ParseShorthand(
      bool important,
      CSSParserTokenStream&,
      const CSSParserContext&,
      const CSSParserLocalContext&,
      std::vector<CSSPropertyValue>& properties) const {
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return false;
  }

 protected:
  constexpr Shorthand(CSSPropertyID id, Flags flags, char repetition_separator)
      : CSSProperty(id, flags | kShorthand, repetition_separator) {}
};

template <>
struct DowncastTraits<Shorthand> {
  static bool AllowFrom(const CSSProperty& property) {
    return property.IsShorthand();
  }
};
}  // namespace webf

#endif  // WEBF_SHORTHAND_H