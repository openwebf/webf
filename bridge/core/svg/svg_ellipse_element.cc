/**
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "svg_ellipse_element.h"
#include "svg_geometry_element.h"
#include "svg_names.h"

namespace webf {
SVGEllipseElement::SVGEllipseElement(Document& document) : SVGGeometryElement(svg_names::kellipse, document) {}

}  // namespace webf
