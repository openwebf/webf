/**
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_CORE_SVG_SVG_LINE_ELEMENT_H_
#define BRIDGE_CORE_SVG_SVG_LINE_ELEMENT_H_

#include "core/svg/svg_geometry_element.h"

namespace webf {

class SVGLineElement : public SVGGeometryElement {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = SVGLineElement*;
  explicit SVGLineElement(Document&);

 private:
};
}  // namespace webf

#endif  // BRIDGE_CORE_SVG_SVG_LINE_ELEMENT_H_
