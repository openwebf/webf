/**
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "svg_g_element.h"
#include "svg_graphics_element.h"
#include "svg_names.h"

namespace webf {
SVGGElement::SVGGElement(Document& document) : SVGGraphicsElement(svg_names::kG, document) {}

}  // namespace webf
