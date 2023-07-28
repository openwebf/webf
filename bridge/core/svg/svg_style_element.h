/**
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_CORE_SVG_SVG_STYLE_ELEMENT_H_
#define BRIDGE_CORE_SVG_SVG_STYLE_ELEMENT_H_

#include "svg_element.h"

namespace webf {

class SVGStyleElement : public SVGElement {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = SVGStyleElement*;
  SVGStyleElement(Document&);

 private:
};
}  // namespace webf

#endif  // BRIDGE_CORE_SVG_SVG_STYLE_ELEMENT_H_
