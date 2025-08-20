/**
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_CORE_SVG_SVG_CIRCLE_ELEMENT_H_
#define BRIDGE_CORE_SVG_SVG_CIRCLE_ELEMENT_H_

#include "core/svg/svg_geometry_element.h"

namespace webf {

class SVGCircleElement : public SVGGeometryElement {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = SVGCircleElement*;
  explicit SVGCircleElement(Document&);

 private:
};
}  // namespace webf

#endif  // BRIDGE_CORE_SVG_SVG_CIRCLE_ELEMENT_H_
