/**
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "svg_rect_element.h"
#include "qjs_svg_rect_element.h"
#include "svg_geometry_element.h"
#include "svg_names.h"

namespace webf {
SVGRectElement::SVGRectElement(Document& document) : SVGGeometryElement(svg_names::kRect, document) {}

}  // namespace webf
