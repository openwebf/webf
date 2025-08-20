/**
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "svg_path_element.h"
#include "qjs_svg_path_element.h"
#include "svg_geometry_element.h"
#include "svg_names.h"

namespace webf {
SVGPathElement::SVGPathElement(Document& document) : SVGGeometryElement(svg_names::kpath, document) {}

}  // namespace webf
