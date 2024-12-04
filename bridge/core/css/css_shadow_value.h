/*
 * (C) 1999-2003 Lars Knoll (knoll@kde.org)
 * Copyright (C) 2004, 2005, 2006, 2008, 2009 Apple Inc. All rights reserved.
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

#ifndef WEBF_CSS_SHADOW_VALUE_H_
#define WEBF_CSS_SHADOW_VALUE_H_

#include "core/css/css_identifier_value.h"
#include "core/css/css_primitive_value.h"
namespace webf {

// Used for text-shadow and box-shadow
class CSSShadowValue : public CSSValue {
 public:
  CSSShadowValue(const std::shared_ptr<const CSSPrimitiveValue>& x,
                 const std::shared_ptr<const CSSPrimitiveValue>& y,
                 const std::shared_ptr<const CSSPrimitiveValue>& blur,
                 const std::shared_ptr<const CSSPrimitiveValue>& spread,
                 const std::shared_ptr<const CSSIdentifierValue>& style,
                 const std::shared_ptr<const CSSValue>& color);

  std::string CustomCSSText() const;

  bool Equals(const CSSShadowValue&) const;

  std::shared_ptr<const CSSPrimitiveValue> x;
  std::shared_ptr<const CSSPrimitiveValue> y;
  std::shared_ptr<const CSSPrimitiveValue> blur;
  std::shared_ptr<const CSSPrimitiveValue> spread;
  std::shared_ptr<const CSSIdentifierValue> style;
  std::shared_ptr<const CSSValue> color;
};

template <>
struct DowncastTraits<CSSShadowValue> {
  static bool AllowFrom(const CSSValue& value) { return value.IsShadowValue(); }
};

}  // namespace webf

#endif  // WEBF_CSS_SHADOW_VALUE_H_
