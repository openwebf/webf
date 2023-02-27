/**
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "svg_text_positioning_element.h"
#include "svg_text_content_element.h"

namespace webf {
SVGTextPositioningElement::SVGTextPositioningElement(const AtomicString& tag_name, Document& document)
    : SVGTextContentElement(tag_name, document) {}

}  // namespace webf
