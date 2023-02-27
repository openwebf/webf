/**
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "svg_geometry_element.h"
#include "svg_graphics_element.h"

namespace webf {
SVGGeometryElement::SVGGeometryElement(const AtomicString& tag_name, Document& document)
    : SVGGraphicsElement(tag_name, document) {}

}  // namespace webf
