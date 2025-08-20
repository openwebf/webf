/**
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "svg_style_element.h"
#include "svg_element.h"
#include "svg_names.h"

namespace webf {
SVGStyleElement::SVGStyleElement(Document& document) : SVGElement(svg_names::kstyle, &document) {}

}  // namespace webf
