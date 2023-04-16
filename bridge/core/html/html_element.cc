/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_element.h"
#include "element_namespace_uris.h"
#include "qjs_html_element.h"

namespace webf {

HTMLElement::HTMLElement(const AtomicString& tag_name, Document* document, ConstructionType type)
    : Element(element_namespace_uris::khtml, tag_name, AtomicString::Null(), document, type) {}

bool HTMLElement::IsAttributeDefinedInternal(const AtomicString& key) const {
  return QJSHTMLElement::IsAttributeDefinedInternal(key) || Element::IsAttributeDefinedInternal(key);
}

}  // namespace webf
