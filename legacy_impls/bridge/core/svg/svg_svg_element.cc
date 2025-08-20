/**
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "svg_svg_element.h"
#include "qjs_svg_svg_element.h"
#include "svg_graphics_element.h"
#include "svg_names.h"

namespace webf {
SVGSVGElement::SVGSVGElement(Document& document) : SVGGraphicsElement(svg_names::ksvg, document) {}

}  // namespace webf
