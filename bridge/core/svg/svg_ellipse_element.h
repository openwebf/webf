/**
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_CORE_SVG_SVG_ELLIPSE_ELEMENT_H_
#define BRIDGE_CORE_SVG_SVG_ELLIPSE_ELEMENT_H_

#include "core/svg/svg_geometry_element.h"

namespace webf {

class SVGEllipseElement : public SVGGeometryElement {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = SVGEllipseElement*;
  explicit SVGEllipseElement(Document&);

 private:
};
}  // namespace webf

#endif  // BRIDGE_CORE_SVG_SVG_ELLIPSE_ELEMENT_H_
