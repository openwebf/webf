/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/**
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "svg_circle_element.h"
#include "svg_geometry_element.h"
#include "svg_names.h"

namespace webf {
SVGCircleElement::SVGCircleElement(Document& document) : SVGGeometryElement(svg_names::kCircle, document) {}

}  // namespace webf
