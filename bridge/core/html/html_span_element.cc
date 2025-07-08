/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_span_element.h"

namespace webf {

HTMLSpanElement::HTMLSpanElement(Document& document) : HTMLElement(AtomicString("span"), &document) {}

}  // namespace webf