/**
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "svg_graphics_element.h"
#include "qjs_svg_graphics_element.h"
#include "svg_element.h"

namespace webf {
SVGGraphicsElement::SVGGraphicsElement(const AtomicString& tag_name, Document& document)
    : SVGElement(tag_name, &document) {}

}  // namespace webf
