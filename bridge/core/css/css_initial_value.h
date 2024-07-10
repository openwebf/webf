/*
 * (C) 1999-2003 Lars Knoll (knoll@kde.org)
 * Copyright (C) 2004, 2005, 2006, 2008 Apple Inc. All rights reserved.
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

#ifndef WEBF_CSS_INITIAL_VALUE_H
#define WEBF_CSS_INITIAL_VALUE_H

#include "core/css/css_value.h"
#include "foundation/casting.h"

namespace webf {


class CSSInitialValue : public CSSValue {
 public:
  static CSSInitialValue* Create();

  CSSInitialValue() : CSSValue(kInitialClass) {}

  AtomicString CustomCSSText(JSContext* ctx) const;

  bool Equals(const CSSInitialValue&) const { return true; }

  void TraceAfterDispatch(GCVisitor* visitor) const {
    CSSValue::TraceAfterDispatch(visitor);
  }

 private:
  friend class CSSValuePool;
};

template <>
struct DowncastTraits<CSSInitialValue> {
  static bool AllowFrom(const CSSValue& value) {
    return value.IsInitialValue();
  }
};


}  // namespace webf

#endif  // WEBF_CSS_INITIAL_VALUE_H
