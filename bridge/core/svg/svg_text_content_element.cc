/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/**
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "svg_text_content_element.h"
#include "svg_graphics_element.h"

namespace webf {
SVGTextContentElement::SVGTextContentElement(const AtomicString& tag_name, Document& document)
    : SVGGraphicsElement(tag_name, document) {}

}  // namespace webf
