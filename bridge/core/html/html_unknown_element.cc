/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include "html_unknown_element.h"
#include "qjs_html_unknown_element.h"

namespace webf {

HTMLUnknownElement::HTMLUnknownElement(const AtomicString& tag_name, Document* document)
    : HTMLElement(tag_name, document) {}

bool HTMLUnknownElement::IsAttributeDefinedInternal(const AtomicString& key) const {
  return QJSHTMLUnknownElement::IsAttributeDefinedInternal(key) || HTMLElement::IsAttributeDefinedInternal(key);
}

}  // namespace webf
