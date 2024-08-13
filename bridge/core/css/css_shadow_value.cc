/**
* (C) 1999-2003 Lars Knoll (knoll@kde.org)
* Copyright (C) 2004, 2005, 2006, 2009 Apple Computer, Inc.
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

#include "core/css/css_shadow_value.h"
#include "core/css/css_identifier_value.h"
#include "core/css/css_primitive_value.h"

namespace webf {

// Used for text-shadow and box-shadow
CSSShadowValue::CSSShadowValue(CSSPrimitiveValue* x,
                               CSSPrimitiveValue* y,
                               CSSPrimitiveValue* blur,
                               CSSPrimitiveValue* spread,
                               CSSIdentifierValue* style,
                               CSSValue* color)
    : CSSValue(kShadowClass),
      x(x),
      y(y),
      blur(blur),
      spread(spread),
      style(style),
      color(color) {}

std::string CSSShadowValue::CustomCSSText() const {
  std::string text = "";

  if (color) {
    text += color->CssText() + ' ';
  }
  text += x->CssText() + ' ';
  text += y->CssText();

  if (blur) {
    text += ' ' + blur->CssText();
  }
  if (spread) {
    text += ' ' + spread->CssText();
  }
  if (style) {
    text += ' ' + style->CssText();
  }
  return text;
}

bool CSSShadowValue::Equals(const CSSShadowValue& other) const {
  return color == other.color &&
         x == other.x &&
         y == other.y &&
         blur == other.blur &&
         spread == other.spread &&
         style == other.style;
}

void CSSShadowValue::TraceAfterDispatch(webf::GCVisitor* visitor) const {
  CSSValue::TraceAfterDispatch(visitor);
}

}  // namespace webf
