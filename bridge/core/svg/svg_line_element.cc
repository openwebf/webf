/**
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "svg_line_element.h"
#include "svg_geometry_element.h"
#include "svg_names.h"

namespace webf {
SVGLineElement::SVGLineElement(Document& document) : SVGGeometryElement(svg_names::kline, document) {}
}  // namespace webf
