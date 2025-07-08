/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_abbr_element.h"

namespace webf {

HTMLAbbrElement::HTMLAbbrElement(Document& document) : HTMLElement(AtomicString("abbr"), &document) {}

}  // namespace webf