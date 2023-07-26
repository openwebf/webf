/**
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_CORE_SVG_SVG_GRAPHICS_ELEMENT_H_
#define BRIDGE_CORE_SVG_SVG_GRAPHICS_ELEMENT_H_

#include "core/svg/svg_element.h"

namespace webf {

class SVGGraphicsElement : public SVGElement {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = SVGGraphicsElement*;
  SVGGraphicsElement(const AtomicString&, Document&);

 private:
};
}  // namespace webf

#endif  // BRIDGE_CORE_SVG_SVG_GRAPHICS_ELEMENT_H_
