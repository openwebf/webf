/**
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "svg_element.h"
#include "element_namespace_uris.h"

namespace webf {
SVGElement::SVGElement(const AtomicString& tag_name, Document* document, ConstructionType type)
    : Element(element_namespace_uris::ksvg, tag_name, AtomicString::Null(), document, type) {}
}  // namespace webf
