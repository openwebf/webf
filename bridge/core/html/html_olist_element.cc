/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_olist_element.h"

namespace webf {

HTMLOListElement::HTMLOListElement(Document& document) : HTMLElement(AtomicString("ol"), &document) {}

}  // namespace webf