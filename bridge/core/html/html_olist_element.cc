/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_olist_element.h"

namespace webf {

HTMLOListElement::HTMLOListElement(Document& document) : HTMLElement(AtomicString::CreateFromUTF8("ol"), &document) {}

}  // namespace webf