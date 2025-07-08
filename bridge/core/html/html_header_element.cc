/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_header_element.h"

namespace webf {

HTMLHeaderElement::HTMLHeaderElement(Document& document) : HTMLElement(AtomicString("header"), &document) {}

}  // namespace webf