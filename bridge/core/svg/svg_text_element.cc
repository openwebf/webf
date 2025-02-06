/**
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "svg_text_element.h"
#include "svg_names.h"
#include "svg_text_positioning_element.h"

namespace webf {
SVGTextElement::SVGTextElement(Document& document) : SVGTextPositioningElement(svg_names::kText, document) {}

}  // namespace webf
