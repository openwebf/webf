/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include "html_textarea_element.h"
#include "html_names.h"
#include "qjs_html_textarea_element.h"

namespace webf {

HTMLTextareaElement::HTMLTextareaElement(Document& document) : HTMLElement(html_names::ktextarea, &document) {}

bool HTMLTextareaElement::IsAttributeDefinedInternal(const AtomicString& key) const {
  return QJSHTMLTextareaElement::IsAttributeDefinedInternal(key) || HTMLElement::IsAttributeDefinedInternal(key);
}

}  // namespace webf
