/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include "html_image_element.h"
#include "html_names.h"
#include "qjs_html_image_element.h"

namespace webf {

HTMLImageElement::HTMLImageElement(Document& document) : HTMLElement(html_names::kimg, &document) {}

bool HTMLImageElement::IsAttributeDefinedInternal(const AtomicString& key) const {
  return QJSHTMLImageElement::IsAttributeDefinedInternal(key) || HTMLElement::IsAttributeDefinedInternal(key);
}

}  // namespace webf
