/*
* Copyright (C) 1999-2003 Lars Knoll (knoll@kde.org)
* Copyright (C) 2004, 2005, 2006, 2007, 2008 Apple Inc. All rights reserved.
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

#ifndef WEBF_CSS_QUAD_VALUE_H_
#define WEBF_CSS_QUAD_VALUE_H_

#include "bindings/qjs/atomic_string.h"
#include "core/css/css_value.h"
#include "foundation/casting.h"

namespace webf {

class CSSQuadValue : public CSSValue {
 public:
  enum TypeForSerialization { kSerializeAsRect, kSerializeAsQuad };

  CSSQuadValue(const std::shared_ptr<const CSSValue>& top,
               const std::shared_ptr<const CSSValue>& right,
               const std::shared_ptr<const CSSValue>& bottom,
               const std::shared_ptr<const CSSValue>& left,
               TypeForSerialization serialization_type)
      : CSSValue(kQuadClass),
        serialization_type_(serialization_type),
        top_(top),
        right_(right),
        bottom_(bottom),
        left_(left) {}

  CSSQuadValue(std::shared_ptr<const CSSValue> value, TypeForSerialization serialization_type)
      : CSSValue(kQuadClass),
        serialization_type_(serialization_type),
        top_(value),
        right_(value),
        bottom_(value),
        left_(value) {}

  const CSSValue* Top() const { return top_.get(); }
  const CSSValue* Right() const { return right_.get(); }
  const CSSValue* Bottom() const { return bottom_.get(); }
  const CSSValue* Left() const { return left_.get(); }

  TypeForSerialization SerializationType() { return serialization_type_; }

  std::string CustomCSSText() const;

  bool Equals(const CSSQuadValue& other) const {
    return top_ == other.top_ &&
           right_ == other.right_ &&
           left_ == other.left_ &&
           bottom_ == other.bottom_;
  }

  void TraceAfterDispatch(webf::GCVisitor*) const;

 private:
  TypeForSerialization serialization_type_;
  std::shared_ptr<const CSSValue> top_;
  std::shared_ptr<const CSSValue> right_;
  std::shared_ptr<const CSSValue> bottom_;
  std::shared_ptr<const CSSValue> left_;
};

template <>
struct DowncastTraits<CSSQuadValue> {
  static bool AllowFrom(const CSSValue& value) { return value.IsQuadValue(); }
};

}  // namespace webf

#endif  // WEBF_CSS_QUAD_VALUE_H_
