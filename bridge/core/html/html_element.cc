/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_element.h"
#include "element_namespace_uris.h"

namespace webf {

HTMLElement::HTMLElement(const AtomicString& tag_name, Document* document, ConstructionType type)
    : Element(element_namespace_uris::khtml, tag_name, AtomicString::Null(), document, type) {}

void HTMLElement::ParseAttribute(const webf::Element::AttributeModificationParams& params) {
  Element::ParseAttribute(params);
}

}  // namespace webf
