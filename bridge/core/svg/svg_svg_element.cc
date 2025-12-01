/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/**
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "svg_svg_element.h"
#include "qjs_svg_svg_element.h"
#include "svg_graphics_element.h"
#include "svg_names.h"

namespace webf {
SVGSVGElement::SVGSVGElement(Document& document) : SVGGraphicsElement(svg_names::kSvg, document) {}

}  // namespace webf
